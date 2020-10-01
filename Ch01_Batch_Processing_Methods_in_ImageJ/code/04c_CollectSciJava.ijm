/*
 * Code optimized to use the Batch function of the script editor.
 * Executes workflow for each .suffix image within the input folder. 
 * Input, output and suffix entered by the user via GUIs using Scripting Parameters.
 * Workflow:
 * * Segments nuclei in channel 3, measures the area of the nuclei and gets the nuclei outlines.
 * * Saves results, roiManager and binary image as control image.
 * 
*/

#@ File (label = "Input file", style = "open") input
//#@ File input // = alternative
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix
#@output nROIs

//opening the image
open(input);
filename_pure = File.nameWithoutExtension;

//preparations
roiManager("reset");
run("Clear Results");
run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //we remove the scaling
saving_prefix = output + File.separator + filename_pure;

//get the image name
title = getTitle(); 

//AIM: basic measurement: get the outlines of the nuclei (C3) and measure the area (in pixels)
Stack.setChannel(3);
run("Duplicate...", "title=C3_" + title); //Duplicate only C3 for further processingg
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

//saving
//save the results window as a comma-separated-value file
saveAs("results", saving_prefix + "_results.csv"); //use saveAs command to save results
//save the isolated C3 (binary image)
selectWindow("C3_" + title);
saveAs("tiff", saving_prefix + "_C3.tif"); //use saveAs command to save an image
//save the roiManager
roiManager("save", saving_prefix + "_rois.zip");

//Clean-up
run("Close All");

//get number of ROIs
nROIs = roiManager("count");
