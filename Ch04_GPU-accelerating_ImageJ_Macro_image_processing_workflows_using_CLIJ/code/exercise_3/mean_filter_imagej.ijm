// configure folders
project_root_folder = "/path/to/project/";
benchmarking_file = project_root_folder + "benchmarking/imagej_mean_filter_timing.xls";

File.append("Processing_time_in_ms", benchmarking_file);


// load example dataset
run("T1 Head (2.4M, 16-bits)");
saveAs("tif", project_root_folder + "imagedata/t1-head.tif");


for (iteration = 0; iteration < 100; iteration++) {

	open(project_root_folder + "imagedata/t1-head.tif");

	// measure time starting here
	start_time = getTime();
	
	// apply a mean filter on the GPU
	input = getTitle();
	run("Mean 3D...", "x=3 y=3 z=3");

	// save processing time
	end_time = getTime();
	print("Processing took " + (end_time - start_time) + " ms");
	File.append((end_time - start_time), benchmarking_file);

	run("Close All");
}
