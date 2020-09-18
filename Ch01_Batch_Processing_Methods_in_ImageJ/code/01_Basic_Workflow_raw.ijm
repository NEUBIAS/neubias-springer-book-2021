/*
 * Example IJ macro: 
 * splits channels, segments nuclei in channel 3, measures the area of the nuclei and gets the nuclei outlines
*/
 
//get the image name
title = getTitle();
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //we remove the scaling since the pixel size is obviously incorrect (inches)

//basic measurement: get the outlines of the nuclei (C3) and measure the area (in pixels)
Stack.setChannel(3);
run("Duplicate...", "title=C3_" + title); //Duplicate only C3 for further processing

//median filtering to smoothen the image
run("Median...", "radius=10");
//set an auto threshold and binarize
setAutoThreshold("Li dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Fill Holes");
//use the "Analyze Particles" command to get the outlines and the measurements
run("Set Measurements...", "area display redirect=None decimal=3");
run("Analyze Particles...", "size=1000-Infinity display exclude add");

