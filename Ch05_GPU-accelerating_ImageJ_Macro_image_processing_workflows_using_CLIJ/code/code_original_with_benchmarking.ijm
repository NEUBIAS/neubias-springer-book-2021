// configure folders
project_root_folder = "/path/to/project/";
benchmarking_file = project_root_folder + "benchmarking/original_analysis_timing.xls";

File.append("Processing_time_in_ms", benchmarking_file);

for (iteration = 0; iteration < 100; iteration++) {
	run("Close All");
	run("Clear Results");
	open(project_root_folder + "imagedata/NPCsingleNucleus.tif");
	target_xls_filename = project_root_folder + "benchmarking/original_analyis_" + iteration + ".xls";
		
	start_time = getTime();

	// the actual script starts here
	// -------------------------------------------------------------------------------
	
	orgName = getTitle();
	run("Split Channels");
	c1name = "C1-" + orgName;
	c2name = "C2-" + orgName;
	
	selectWindow(c1name);
	nucorgID = getImageID();
	nucrimID = nucseg( nucorgID );
	
	selectWindow(c2name);
	c2id = getImageID();
	opt = "area mean centroid perimeter shape integrated display redirect=None decimal=3";
	run("Set Measurements...", opt);
	for (i =0; i < nSlices; i++){
	    selectImage( nucrimID );
	    setSlice( i + 1 );
	    run("Create Selection");
	    //run("Make Inverse");
	    selectImage( c2id );
	    setSlice( i + 1 );
	    run("Restore Selection");
	    run("Measure");
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
    selectImage( orgID );
    run("Gaussian Blur...", "sigma=1.50 stack");
    
    setAutoThreshold("Otsu dark");
    setOption("BlackBackground", true);
    run("Convert to Mask", "method=Otsu background=Dark calculate black");
    run("Analyze Particles...", "size=800-Infinity pixel circularity=0.00-1.00 show=Masks display exclude clear include stack");
    dilateID = getImageID();
    run("Invert LUT");
    options =  "title = dup.tif duplicate range=1-" + nSlices;
    run("Duplicate...", options);
    erodeID = getImageID();
    selectImage(dilateID);
    run("Options...", "iterations=2 count=1 black edm=Overwrite do=Nothing");
    run("Dilate", "stack");
    selectImage(erodeID);
    run("Erode", "stack");
    imageCalculator("Difference create stack", dilateID, erodeID);
    resultID = getImageID();
    selectImage(dilateID);
    close();
    selectImage(erodeID);
    close();
    selectImage(orgID);
    close();
    run("Clear Results");
    return resultID;
}