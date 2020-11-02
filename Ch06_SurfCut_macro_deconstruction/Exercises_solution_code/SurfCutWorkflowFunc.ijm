///Parameters
Rad = 3;
Thld = 20;
Top = 6;
Bot = 8;
Dpt = 0.5;
Cut1= Top/Dpt;
Cut2= Bot/Dpt;

///Open a stack and get names
open();
imgDir = File.directory;
print(imgDir);
imgName = getTitle();
print(imgName);
imgPath = imgDir+imgName;
print(imgPath);

///SurfCut Workflow User-Difined Functions
Preprocessing(); //Component1
Denoising(Rad); //Component2
Thresholding(Thld); //Component3
EdgeDetection(imgName); //Component4
ZAxisShifting(Cut1, Cut2); //Component5a
StackCropping(imgPath, imgName); //Component5b
ZProjections(imgName); //Component6

///End
print("=== Done ===");


///Functions
//=Component1=//
function Preprocessing(){
	print ("Pre-processing");
	run("8-bit");
};

//=Component2=//
function Denoising(Rad){
	//Gaussian blur (uses the variable "Rad" to define the sigma of the gaussian blur)
	print ("Gaussian Blur");	
	run("Gaussian Blur...", "sigma=&Rad stack");	
};

//=Component3=//
function Thresholding(Thld){
	//Object segmentation (uses the variable Thld to define the threshold applied)
	print ("Threshold segmentation");
	setThreshold(0, Thld);
	run("Convert to Mask", "method=Default background=Light");
};

//=Component4=//
function EdgeDetection(imgName){
	print ("Edge detect");
	//Get the dimensions of the image to know the number of slices in the stack and thus the number of loops to perform
	getDimensions(w, h, channels, slices, frames);
	print (slices);
	run("Invert", "stack");
	for (img=0; img<slices; img++){
		//Display progression in the log
		print("Edge detect projection" + img + "/" + slices);
		slice = img+1;
		selectWindow(imgName);
		//Successively projects stacks with increasing slice range (1-1, 1-2, 1-3, 1-4,...)
		run("Z Project...", "stop=&slice projection=[Max Intensity]");
	};
	//Make a new stack from all the Z-projected images generated in the loop above
	run("Images to Stack", "name=Stack-0 title=[]");
	//Duplicate and invert
	run("Duplicate...", "title=Stack-0-invert duplicate");
	run("Invert", "stack");
	selectWindow(imgName);
	close();
	//Close binarized image generated in component2 (imgName), but keeps the image (mask) generated after the edge detect ("Stack-0") 
	//and an inverted version of this mask ("Stack-0-invert"). Both masks are used in the next steps to be shifted in Z-Axis and make a layer mask.
};

//=Component5a=//
function ZAxisShifting(Cut1, Cut2){
	print ("Layer mask creation");
	///First z-axis shift
	//Get dimension w and h, and pre-defined variable Cut1 depth to create an new "empty" stack
	getDimensions(w, h, channels, slices, frames);
	newImage("AddUp", "8-bit white", w, h, Cut1);
	//Duplicate stack-0 while removing bottom slices corresponding to the z-axis shift (Cut1 depth)
	Slice1 = slices - Cut1;
	selectWindow("Stack-0-invert");
	run("Duplicate...", "title=StackUpSub duplicate range=1-&Slice1");
	close("Stack-0-invert");
	//Add newly created empty slices (AddUp) at begining of stackUpSub, thus recreating a stack with the original dimensions of the image and in whcih the binarized object is shifted in the Z-axis.
	run("Concatenate...", "  title=[StackUpShifted] image1=[AddUp] image2=[StackUpSub] image3=[-- None --]");
	///Second z-axis shift
	//Use image dimension w and h from component3 and pre-defined variable Cut2 depth to create an new "empty" stack
	newImage("AddInv", "8-bit black", w, h, Cut2);
	//Duplicate stackInv while removing bottom slices corresponding to the z-axis shift (Cut2 depth)
	Slice2 = slices - Cut2;
	selectWindow("Stack-0");
	run("Duplicate...", "title=StackInvSub duplicate range=1-&Slice2");
	close("Stack-0");
	//Add newly created empty slices (AddInv) at begining of stackInvSub,
	run("Concatenate...", "  title=[StackInvShifted] image1=[AddInv] image2=[StackInvSub] image3=[-- None --]");
	//Subtract both shifted masks to create a layer mask
	imageCalculator("Add create stack", "StackUpShifted","StackInvShifted");
	close("StackUpShifted");
	close("StackInvShifted");
	//Close shifted masks ("StackUpShifted" and "StackInvShifted"), but keeps the layer mask ("Result of StackUpShifted")
	//resulting from the subtraction of the two shifted masks
};

//=Component5b=//
function StackCropping(imgPath, imgName){
	print ("Cropping stack");
	//Open raw image
	open(imgPath);
	run("Grays");
	//Apply mask to raw image
	imageCalculator("Subtract create stack", imgName,"Result of StackUpShifted");
	close("Result of StackUpShifted");
};

//=Component6=//
function ZProjections(imgName){
	selectWindow("Result of " + imgName);
	run("Z Project...", "projection=[Max Intensity]");
	rename("SurfCut projection");
	selectWindow(imgName);
	run("Z Project...", "projection=[Max Intensity]");
	rename("Original projection");
};
