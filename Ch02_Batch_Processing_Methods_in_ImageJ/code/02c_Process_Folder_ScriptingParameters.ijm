/*
 * Executes workflow for each .suffix image within folder. 
 * Input, output and suffix entered by the user via GUIs using Scripting Parameters.
 * Workflow:
 * * Segments nuclei in channel 3, measures the area of the nuclei and gets the nuclei outlines.
 * * Saves results, roiManager and binary image as control image.
*/

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);

	//opening the image
	open(input + File.separator + file);
	filename_pure = File.nameWithoutExtension;
	
	//preparations
	roiManager("reset");
	run("Clear Results");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //we remove the scaling
	saving_prefix = output + File.separator + filename_pure;
	
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
	
	//saving
	//save the results window as a comma-separated-value file
	saveAs("results", saving_prefix + "_results.csv"); //use saveAs command to save results
	//save the isolated C3 (binary image)
	selectWindow("C3_" + title);
	saveAs("tiff", saving_prefix + "_C3.tif"); //use saveAs command to save an image
	//save the roiManager
	roiManager("save", saving_prefix + "_rois.zip"); //drag&drop zip-file on Fiji to reopen ROIs
	
	//Clean-up
	run("Close All");
}
