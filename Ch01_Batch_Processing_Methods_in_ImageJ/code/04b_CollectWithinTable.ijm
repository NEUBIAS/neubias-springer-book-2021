/*
 * Example of using an array to collect values from different images.
 * Executes workflow for each .suffix image within folder process. 
 * Input, output and suffix entered by the user via GUIs using Scripting Parameters.
 * Workflow:
 * * Segments nuclei in channel 3, measures the area of the nuclei and gets the nuclei outlines.
 * * Saves results, roiManager and binary image as control image.
 * * Collects measurements of nuclei of all images and calculates basic statistics.
*/

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tiff") suffix


//create empty collector array
//collect_nNuclei = newArray();
Table.create("Numbers");
rowIndex = 0;

//processFolder function with the collector array as output
processFolder(input);

//do something with the collected values: calculate statistiics
close("Results");
selectWindow("Numbers");
Table.update;
Table.rename("Numbers", "Results");
run("Summarize");

//Array.getStatistics(collect_nNuclei, min, max, mean, stdDev);
//print("In average, there were " + mean + " +- " + stdDev + " nuclei analyzed in an image (number of images=" + collect_nNuclei.length + ")." );

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			collect_nNuclei = processFolder(input + File.separator + list[i], collect_nNuclei);
		if(endsWith(list[i], suffix)){
			nNuclei = processFile(input, output, list[i]);
			selectWindow("Numbers");
			Table.set("nNuclei", rowIndex++, nNuclei);

			//collect_nNuclei = Array.concat(collect_nNuclei , nNuclei);
			//print("The collecting array collect_nNuclei now contains: ");
			//Array.print(collect_nNuclei);
		}
	}
	//return collect_nNuclei;
	

}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	//print("Saving to: " + output);

	//opening the image
	open(input + File.separator + file);
	filename_pure = File.nameWithoutExtension;
	
	//preparations
	roiManager("reset");
	run("Clear Results");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel"); //we remove the scaling
	saving_prefix = output + File.separator + filename_pure;
	
	//get the image name
	title = getTitle(); //here we could also use the variable file
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

	//get number of ROIs
	nROIs = roiManager("count");
	return nROIs; //output of the processFile function
}
