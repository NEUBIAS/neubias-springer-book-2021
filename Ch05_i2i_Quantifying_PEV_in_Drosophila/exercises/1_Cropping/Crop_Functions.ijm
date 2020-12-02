// This code is to be used for the exercice regarding the cropping
// Three versions are presented from the simplest to the most elaborate
// The image PEV000001.tif needs to be open prior running the different versions

DirOut = getDirectory("Choose a Directory to save");
FileName = getInfo("image.filename");print(DirOut, FileName);
Side = "Left";

//Simply put in comment the versions you don't want to run
//Version one hold no argument to run.
crop_V1();

//crop_V2(DirOut,FileName,Side);

//crop_final(DirOut, FileName, Side);

////////Version 1//////////////////
function crop_V1() {
	makeRectangle(1254, 352, 184, 416);
	waitForUser("Pause","Adjust the rectangle");
	run("Duplicate...", "duplicate");
}

///////////Version with if statements to choose the eye on the source image and to save the cropped part.
function crop_V2(DirOut, FileName, Side) {
	fss = File.separator;
	if (Side == "Right") {
		makeRectangle(1254, 352, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"R.tif";
	}
	if (Side == "Left") {
		makeRectangle(170, 356, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"L.tif";
	}
	run("Duplicate...", "duplicate");
	save(DirOut+NewFileName);
}

////////Full version with checking the existence of a cropped image
function crop_final(DirOut, FileName, Side) {
	fss = File.separator;
	if (Side == "Right") {
		makeRectangle(1254, 352, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"R.tif";
	}
	if (Side == "Left") {
		makeRectangle(170, 356, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"L.tif";
	}
	if(File.exists(DirOut+NewFileName)==1){
		Answer = getBoolean("Cropping for this eye has been done, \n Would like to redo it ?", "Yes", "No");print(Answer);
		if (Answer ==1){
			waitForUser("Pause","Adjust and Update "+Side+" eye ROI");
			run("Duplicate...", "duplicate");
			save(DirOut+NewFileName);
		} 
		if (Answer ==0){
			open(DirOut+NewFileName);
		} 
	}
	if(File.exists(DirOut+NewFileName)==0){
		waitForUser("Pause","Adjust and Update "+Side+" eye ROI");
		run("Duplicate...", "duplicate");
		save(DirOut+NewFileName);
	}
}