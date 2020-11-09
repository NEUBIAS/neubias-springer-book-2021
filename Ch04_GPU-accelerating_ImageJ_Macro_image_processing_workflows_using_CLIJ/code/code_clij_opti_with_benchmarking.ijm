// configure folders
project_root_folder = "/path/to/project/";
benchmarking_file = project_root_folder + "benchmarking/clij_opti_analysis_timing.xls";

File.append("Processing_time_in_ms", benchmarking_file);

for (iteration = 0; iteration < 100; iteration++) {
	run("Close All");
	run("Clear Results");
	open(project_root_folder + "imagedata/NPCsingleNucleus.tif");
	target_xls_filename = project_root_folder +"benchmarking/clij_opti_analyis_" + iteration + ".xls";

	// the actual script starts here
	// -------------------------------------------------------------------------------

	nuclei_channel = 1;
	protein_channel = 2;
	
	start_time = getTime();
	
	run("CLIJ2 Macro Extensions", "cl_device=");
	Ext.CLIJ2_clear();
	
	orgName = getTitle();
	
	// configure measurements (on CPU)
	opt = "area mean centroid perimeter shape integrated display redirect=None decimal=3";
	run("Set Measurements...", opt);
	
	getDimensions(width, height, channels, slices, frames);
	for (i = 0; i < frames; i ++){    
	    // select channel and frame to analyze
	    Stack.setChannel(nuclei_channel);
	    Stack.setFrame(i + 1);
	    
		// get a single-channel slice and determine nuclear envelope
	    Ext.CLIJ2_pushCurrentSlice(orgName); // first channel; nucleus
	    nucrimID = nucseg( orgName );
		
	    // select the channel showing nuclear envelope signal
	    Stack.setChannel(protein_channel);

	    // pull segmented binary image as ROI from GPU
	    Ext.CLIJ2_pullAsROI(nucrimID);

	    // analyse it
	    run("Measure");

	    // reset selection
	    run("Select None");
	}
	// the actual script ends here
	// -------------------------------------------------------------------------------

	// save results and processing time
	end_time = getTime();
	print("Processing took " + (end_time - start_time) + " ms");
	File.append((end_time - start_time), benchmarking_file);
	saveAs("results", target_xls_filename);
}


function nucseg( orgID ){
	// Gaussian blur, basically for noise removal
    sigma = 1.5;
    Ext.CLIJ2_gaussianBlur2D(orgID, blurred, sigma, sigma);
    
	// threholding / binarization
    Ext.CLIJ2_thresholdOtsu(blurred, thresholded);

    // fill holes
    Ext.CLIJ2_binaryFillHoles(thresholded, binary_mask);
    
	// dilate
    radius = 2;
  	Ext.CLIJ2_maximum2DBox(binary_mask, dilateID, radius, radius);

	// erode
   	Ext.CLIJ2_minimum2DBox(binary_mask, erodeID, radius, radius);

	// subtract eroded from dilated image to get a band corresponding to nuclear envelope
    Ext.CLIJ2_subtractImages(dilateID, erodeID, resultID);
    
	// return result
    return resultID;
}