///Parameters
Rad = 3;
Thld = 20;
Top = 6;
Bot = 8;
Dpt = 0.5;
Cut1= Top/Dpt;
Cut2= Bot/Dpt;
Ero1 = Cut1;
Ero2 = Cut2-Cut1;
MODE = "erode"; //(or "Z-shift")

///Open a stack and get names
open();
imgDir = File.directory;
print(imgDir);
imgName = getTitle();
print(imgName);
imgPath = imgDir+imgName;
print(imgPath);

///SurfCut Workflow User-Difined Functions
BitConversion(); //Component1
Denoising(Rad); //Component2
Binarization(Thld); //Component3
EdgeDetection(imgName); //Component4
if (MODE=="erode"){ //Component5a
	Erosion(Ero1, Ero2);
} else if (MODE=="Z-shift"){
	ZAxisShifting(Cut1, Cut2); 
};
Masking(imgPath, imgName); //Component5b
ZProjections(imgName); //Component6

///End
print("=== Done ===");


///Functions
//=Component1=//
function BitConversion(){
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
function Binarization(Thld){
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
	run("Images to Stack", "name=Mask title=[]");
	selectWindow(imgName);
	close();
	//Close binarized image generated in component2 (imgName), but keeps the image (Mask) generated after the edge detect.	
};

//=Component5a=//
function ZAxisShifting(Cut1, Cut2){
	print ("Layer mask creation - ZAxisShifting");
	///First Z-axis shift
	//Get dimension w and h, and pre-defined variable Cut1 depth to create an new "empty" stack
	getDimensions(w, h, channels, slices, frames);
	newImage("Add1", "8-bit white", w, h, Cut1);
	//Duplicate and invert Mask while removing bottom slices corresponding to the Z-axis shift (Cut1 depth)
	Slice1 = slices - Cut1;
	selectWindow("Mask");
	run("Duplicate...", "title=Mask1Sub duplicate range=1-&Slice1");
	run("Invert", "stack");
	//Add newly created empty slices (Add1) at begining of Mask1Sub, thus recreating a stack with the original dimensions of the image and in whcih the mask is shifted in the Z-axis.
	run("Concatenate...", "  title=[Mask1] image1=[Add1] image2=[Mask1Sub] image3=[-- None --]");
	///Second Z-axis shift
	//Use image dimension w and h from component3 and pre-defined variable Cut2 depth to create an new "empty" stack
	newImage("Add2", "8-bit black", w, h, Cut2);
	//Duplicate Mask while removing bottom slices corresponding to the Z-axis shift (Cut2 depth)
	Slice2 = slices - Cut2;
	selectWindow("Mask");
	run("Duplicate...", "title=Mask2Sub duplicate range=1-&Slice2");
	//Add newly created empty slices (Add2) at begining of Mask2Sub,
	run("Concatenate...", "  title=[mask2] image1=[Add2] image2=[Mask2Sub] image3=[-- None --]");
	//Subtract both shifted masks to create a layer mask
	imageCalculator("Add create stack", "Mask1","mask2");
	close("Mask");	
	close("Mask1");
	close("Mask2");
	selectWindow("Result of Mask1");
	rename("LayerMask");
	//Close original and shifted masks ("Mask", "Mask1" and "Mask2"), but keeps the newly created "layerMask" resulting from the subtraction of the two shifted masks.
};

//=Component5a=//
function Erosion(Ero1, Ero2){
	print ("Layer mask creation - Erosion");
	//Erosion 1
	selectWindow("Mask");
	run("Duplicate...", "title=Mask-Ero1 duplicate");
	print("Erosion1");
	print(Ero1 + " erosion steps");
	for (erode1=0; erode1<Ero1; erode1++){ 
		print("Erode1");
		run("Erode (3D)", "iso=255");
	};
	//Erosion 2 (here instead of restarting from the original mask, the eroded mask is duplictaed and further eroded. In this case Ero2 corresponds
	//to the number of additional steps of erosion, or the thickness of the future layer mask)
	selectWindow("Mask-Ero1");
	run("Duplicate...", "title=Mask-Ero2 duplicate");
	print("Erosion2");
	print(Ero2 + " erosion steps");
	for (erode2=0; erode2<Ero2; erode2++){ 
		print("Erode2");
		run("Erode (3D)", "iso=255");
	};	
	selectWindow("Mask-Ero1");
	run("Invert", "stack");
	//Subtract both shifted masks to create a layer mask
	imageCalculator("Add create stack", "Mask-Ero1","Mask-Ero2");
	close("Mask");	
	close("Mask-Ero1");
	close("Mask-Ero2");
	selectWindow("Result of Mask-Ero1");
	rename("LayerMask");
	//Close original and eroded masks ("Mask", "Mask-Ero1" and "Mask-Ero2"), but keeps the newly created "layerMask" resulting from the subtraction of the two eroded masks.
};

//=Component5b=//
function Masking(imgPath, imgName){
	print ("Cropping stack");
	//Open raw image
	open(imgPath);
	run("Grays");
	//Apply LayerMask to raw image
	imageCalculator("Subtract create stack", imgName, "LayerMask");
	close("LayerMask");
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
