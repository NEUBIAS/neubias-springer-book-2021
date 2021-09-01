//=Component1=// 8bit conversion
run("8-bit");

//=Component2=// Denoising
run("Gaussian Blur...", "sigma=&Rad stack");
	
//=Component3=// Binarization
setThreshold(0, Thld);
run("Convert to Mask", "method=Default background=Light");
run("Invert", "stack");

//=Component4=// Edge detection
print (slices);
for (img=0; img<slices; img++){
	print("Edge detect projection" + img + "/" + slices);
	slice = img+1;
	selectWindow(list[j]);
	run("Z Project...", "stop=&slice projection=[Max Intensity]");
}
print("Concatenate images");
run("Images to Stack", "name=Stack title=[]");
wait(1000);
selectWindow(list[j]);
close();

//=Component5=// Masking
//Substraction2
print("Substraction2");
selectWindow("Stack");
run("Duplicate...", "title=Stack-1 duplicate range=1-&slices");
open(dir+File.separator+list[j]);
wait(1000);
run("8-bit");
run("Invert", "stack");
imageCalculator("Subtract create stack", "Stack-1",list[j]);
//Substraction1
print("Substraction1");
selectWindow("Stack");
run("Invert", "stack");
getDimensions(w, h, channels, slices, frames);
Slice1 = Cut2 +1 - Cut1;
Slice2 = slices - Cut1;
run("Duplicate...", "title=Stack-2 duplicate range=&Slice1-&Slice2");
selectWindow("Result of Stack-1");
run("Invert", "stack");
imageCalculator("Subtract create stack", "Stack-2","Result of Stack-1");

//=Component6=//Z projection
print("Project and save SurfCutProj"); 
run("Z Project...", "projection=[Max Intensity]");
