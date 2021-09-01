// Rename output image
rename("output");

// Display in grayscale
Stack.setDisplayMode("grayscale");

// "argmax"
setThreshold(0.34, 1.0);
setOption("BlackBackground", true);
run("Convert to Mask", "method=Mean background=Dark black");
run("Divide...", "value=255.000 stack");
setSlice(1);
run("Multiply...", "value=0 slice");
setSlice(2);
run("Multiply...", "value=1 slice");
setSlice(3);
run("Multiply...", "value=2 slice");
run("Z Project...", "projection=[Max Intensity]");
rename("argmax");
close( "output" )

// Analyze foreground (1) label only
run("Select Label(s)", "label(s)=1");
close("argmax")
selectWindow("argmax-keepLabels");
// Fill holes
run("Fill Holes (Binary/Gray)");
close("argmax-keepLabels");
// Convert to 0-255
run("Multiply...", "value=255.000");
// Apply distance transform watershed to extract objects
run("Distance Transform Watershed", "distances=[Borgefors (3,4)] output=[32 bits] normalize dynamic=1 connectivity=4");
close("argmax-keepLabels-fillHoles");
// Remove small objects
run("Label Size Filtering", "operation=Greater_Than size=10");
close("argmax-keepLabels-fillHoles-dist-watershed");
// Rename final image and assign color map
selectWindow("argmax-keepLabels-fillHoles-dist-watershed-sizeFilt");
rename( "segmented-cells" );
run("Set Label Map", "colormap=[Golden angle] background=White shuffle");
resetMinAndMax();
