// Specify the directory with the images to process 
path_images = "/home/user/NEUBIAS_textbook/PhC-C2DL-PSC/01/"
// Read the name of all the images in that directory
list = getFileList(path_images);
print(list.length+" images in the directory "+path_images);

// Create a directory in which the masks will be stored
path_masks = path_images+"masks/"
  if (!File.exists(path_masks)){
  	File.makeDirectory(path_masks);
  	if (!File.exists(path_masks)){
  		exit("Unable to create a directory for masks");
  	}
  }

// Create a directory in which the masks will be stored
path_morphology = path_images+"morphology/";
  if (!File.exists(path_morphology)){
  	File.makeDirectory(path_morphology);
  	if (!File.exists(path_morphology)){
  		exit("Unable to create a directory for morphology results");
  	}
  }  

// Name of the trained model you want to use
model_name = "DeepImageJ-model";

// Process each image with the trained model and save the results.
for (i=0; i<list.length; i++) {
	// avoid any subfolder
	if (!endsWith(list[i], "/")){
		// store the name of the image to save the results
		image_name = split(list[i], ".");
		image_name = image_name[0];
		// open the image
		open(path_images + list[i]);  
		// process the image using the trained model
		run("DeepImageJ Run", "model="+model_name+" preprocessing=preprocessing.txt postprocessing=postprocessing.txt patch=832 overlap=47 logging=normal");
		// close the input image
		close(list[i]);
		// save the mask
		saveAs("Tiff", path_masks+image_name+"_mask.tif");
		// Analyze regions (morphology) and save the results
		run("Analyze Regions", "area perimeter circularity euler_number bounding_box centroid equivalent_ellipse ellipse_elong. convexity max._feret oriented_box oriented_box_elong. geodesic tortuosity max._inscribed_disc average_thickness geodesic_elong.");
		saveAs("Results", path_morphology+image_name+".csv");
		// close all (tables and images)
		run("Close");
		run("Close All");
	}
}