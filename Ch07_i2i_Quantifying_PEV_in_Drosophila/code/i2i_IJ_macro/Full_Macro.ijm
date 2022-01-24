//Macro i2i, for the analysis of Position Effect Variegation in the fly eye
//Works on ImageJ version 1.52p with plugin Ilastik (last updated version)
//The training file ilp has been done with Ilastik v1.3.3

//////////////////////////User Interface///////////////////////////////////////////
#@ String(value="Welcome to i2i, please refer to book chapter for further information", visibility="MESSAGE") hint;
#@ File (label = "Source of Raw Images", style = "directory") DirSrc
#@ File (label = "Training Ilastik Model", style = "choose") TrainingFile
#@ Integer (label = "Label to analyse", value = 2) LabelNumber

requires("1.52p");
print(TrainingFile); TrainingFileName = File.getName(TrainingFile); print (TrainingFileName);

DirSrc = DirSrc+"\\";
DirCorr = File.getParent(DirSrc)+"\\ProcessFiles\\";
DirOut = File.getParent(DirSrc)+"\\Output\\";
File.makeDirectory(DirOut);	
File.makeDirectory(DirOut+"LEFT\\");
File.makeDirectory(DirOut+"RIGHT\\");


///////////////////////////////List of File to analyse/////////////////////////////
NmbFile = 0;
count = newArray(1);
countFile(DirSrc,count);
finalList = newArray(count[0]);
print (count[0],finalList.length);
NmbFile =0;
listFiles(DirSrc, finalList);
Array.show(finalList);
/////////////////////////////Initialisation of Arrays////////////////////////////////
PatchNumbercount_A = newArray(finalList.length*2);
AveragePatchIntensity_A = newArray(finalList.length*2);
AveragePatchSize_A = newArray(finalList.length*2);
PerCentArea_A = newArray(finalList.length*2);
Crowdness_A = newArray(finalList.length*2);
IdealRatio_A = newArray(finalList.length*2);
DeviationfromIdeal_A = newArray(finalList.length*2);
DeviationfromRandom_A = newArray(finalList.length*2);
IdealRatio=	newArray(1);
Table.create("Area Distribution.csv");
Table.create("FinalTable.csv");
Table.create("Intensity Distribution.csv");
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");
if (isOpen("ROI Manager")==1){
	close("ROI Manager");
}
fss = File.separator;
//////////////////////////////Cropping Time//////////////////////////////////////////
counter = 0;
for (i = 0; i < finalList.length; i++) {
	if (isOpen("AVG_brightfieldclean.tif")== 0) {
		open(DirCorr+"AVG_brightfieldclean.tif");
	}
	open(finalList[i]); 
	FileName = getInfo("image.filename"); 
	imageCalculator("Subtract stack", FileName,"AVG_brightfieldclean.tif");
	run("Median...", "radius=2 stack");
	for (s = 0; s < 2; s++) {
		if (s==0) {
			Side = "Left";				
		}
		if (s==1) {
			Side = "Right";				
		}
		selectWindow(FileName);
		crop(DirSrc,FileName,Side);
///////////////////////////////////Segmentation ilastik//////////////////////////////

		rename(Side);
		NewFileName = substring(FileName, 0, lengthOf(FileName)-4)+"_"+Side+"_SimpleSeg.tif";
		run("Run Pixel Classification Prediction", "projectfilename="+DirCorr+fss+TrainingFileName +" inputimage="+Side+" pixelclassificationtype=Segmentation");
		rename(NewFileName);
		save(DirOut+Side+fss+NewFileName);
		
////////////////////////////////Analysis of the eye/////////////////////////////////////
	//Selecting the label to analyse
		setThreshold(LabelNumber, LabelNumber);
		run("Analyze Particles...", "size=50-Infinity display add");
		Name = File.nameWithoutExtension;	
		roiManager("save", DirOut+Side+fss+Name+".zip");
		NumberofPatches = roiManager("count");
		PatchNumbercount_A[2*i+s] = NumberofPatches;
		if (NumberofPatches == 0) {
    		p = 2*i+s;
			fillFinalTable(DirOut+NewFileName,0,0,0,0,NaN,NaN,NaN,NaN,p);
			Array_Null = newArray(1);
			fillAreaTable(DirOut+NewFileName,Array_Null,p);
			fillMeanTable(DirOut+NewFileName,Array_Null,p);
		}
		else{
			Table.rename("Results", "Measurements");
	//Initialize Different variables
			X = newArray(NumberofPatches);
			Y = newArray(NumberofPatches);
			Area = newArray(NumberofPatches);
	//Array X and Y of patches coordinates
			PutInArrays(NumberofPatches,X,Y,Area); 
			TableName = "Distances";
			Table.create(TableName);
	//Analysis of distances
			DistanceAnalysis(NumberofPatches,X,Y, TableName);
			saveAs("Results",DirOut+Side+fss+Name+"_Dist.csv");Table.rename(Name+"_Dist.csv", TableName);
			selectWindow("DistanceMatrix"); saveAs("tif",DirOut+Side+fss+Name+"_Dist.tif");close();
	//General Measurements
			Areadata = newArray(roiManager("count"));												
			Meandata = newArray(roiManager("count"));
			Table.rename("Measurements","Results");
			selectWindow(Side);
			TotalPatchArea = 0;
			TotalIntensity = 0;
			for (j=0; j<roiManager("count"); j++) {
				roiManager("select", j);
				roiManager("measure");
				Meandata[j] = getResult("Mean",j+roiManager("count"));
      			Areadata[j] = getResult("Area",j+roiManager("count"));
      			
      			TotalPatchArea = TotalPatchArea+Areadata[j];
      			TotalIntensity = TotalIntensity + Meandata[j];
    		}
    		close(Side);
    		Table.rename("Results", "Measurements");
    		saveAs("Results",DirOut+Side+fss+Name+"_GM.csv");Table.rename(Name+"_GM.csv", "Measurements");
    		print("TotalPatchArea is ",TotalPatchArea);
    		AveragePatchSize_A[2*i+s] = TotalPatchArea/Areadata.length;
    		PerCentArea_A[2*i+s] = TotalPatchArea/(184*416)*100;
    		AveragePatchIntensity_A[2*i+s] = TotalIntensity/Areadata.length;
    		if (NumberofPatches == 1) {
    			p = 2*i+s;
				fillFinalTable(DirOut+NewFileName,PatchNumbercount_A[p],AveragePatchSize_A[p],AveragePatchIntensity_A[p],PerCentArea_A[p],NaN,NaN,NaN,NaN,p);
				fillAreaTable(DirOut+NewFileName,Areadata,p);
				fillMeanTable(DirOut+NewFileName,Meandata,p);
			}
			else{
	//Analysis of Triangular Packing
				TriangularPacking(NumberofPatches, AveragePatchSize_A[2*i+s],2*i+s,Crowdness_A);
	//Ratio of maximum and minimum distances between each patch
				IterationNumber = 3;
				Ratio = newArray(IterationNumber+1);
				Table.create("MaxMinRatio");
				MaxMinRatio(NumberofPatches,Ratio,0,TableName);
	//Compare to ideal organised situation
				time = 0;
				CompareRatio(NumberofPatches,Ratio,IdealRatio,0,time);
	//Randomisation
				Table.create("TempDistances");
				for (k = 1; k <= IterationNumber; k++) {
					print("Iteration number : ", k);
					RandomizePatch(NumberofPatches,X,Y,Area);
					DistanceAnalysis(NumberofPatches,X,Y,"TempDistances");
					MaxMinRatio(NumberofPatches,Ratio,k,"TempDistances");
				}
				
				Array.show(Ratio);
				CompareRatio(NumberofPatches,Ratio,IdealRatio,IterationNumber,time+1);
				selectWindow("MaxMinRatio");run("Close");
				selectWindow("TempDistances");run("Close");
				IdealRatio_A[2*i+s] = IdealRatio[0];
				DeviationfromIdeal_A[2*i+s] = Ratio[0];
				Array.getStatistics(Ratio, min, max, mean, stdDev);
				DeviationfromRandom_A[2*i+s] = mean/Ratio[0];
				close(NewFileName);
				selectWindow("Ratio");run("Close");
				p = 2*i+s;
				fillFinalTable(DirOut+NewFileName,PatchNumbercount_A[p],AveragePatchSize_A[p],AveragePatchIntensity_A[p],PerCentArea_A[p],Crowdness_A[p],IdealRatio_A[p],DeviationfromIdeal_A[p],DeviationfromRandom_A[p],p);
				fillAreaTable(DirOut+NewFileName,Areadata,p);
				fillMeanTable(DirOut+NewFileName,Meandata,p);
				selectWindow(FileName);
			}
		selectWindow("ROI Manager");run("Close");
		selectWindow("Measurements");run("Close");
    	selectWindow("Distances");run("Close");
		}
	}
	waitForUser("The eye "+FileName+" has been analysed, "+count[0]-i-1+" left");
	selectWindow(FileName);run("Close");
}
selectWindow("AVG_brightfieldclean.tif");run("Close");

function crop(DirSrc, FileName, Side) {
	fss = File.separator;
	if (Side == "Right") {
		makeRectangle(1254, 352, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"R.tif";
	}
	if (Side == "Left") {
		makeRectangle(170, 356, 184, 416);
		NewFileName=substring(FileName, 0, lengthOf(FileName)-4)+"L.tif";
	}
	if(File.exists(DirOut+fss+Side+fss +NewFileName)==1){
		Answer = getBoolean("Cropping for this eye has been done, \n Would like to redo it ?", "Yes", "No");print(Answer);
		if (Answer ==1){
			waitForUser("Pause","Adjust and Update "+Side+" eye ROI");
			run("Duplicate...", "duplicate");
			save(DirOut+fss+Side+fss+NewFileName);
		} 
		if (Answer ==0){
			open(DirOut+fss+Side+fss+NewFileName);
		} 
	}
	if(File.exists(DirOut+fss+Side+fss +NewFileName)==0){
		waitForUser("Pause","Adjust and Update "+Side+" eye ROI");
		run("Duplicate...", "duplicate");
		save(DirOut+fss+Side+fss +NewFileName);
	}
}

function countFile(dir, count){
	list = getFileList(dir);
    for (i=0; i<list.length; i++) {
    	if (File.isDirectory(dir+list[i])){
        	countFile(""+dir+list[i],count);
        }
        else {
           print((NmbFile++) + ": " + dir+list[i]);
           count[0]=NmbFile;
        }
	}
}

function listFiles(dir,finalList) {
	list = getFileList(dir);
    for (i=0; i<list.length; i++) {
    	if (File.isDirectory(dir+list[i])){
           listFiles(""+dir+list[i],finalList);
        }
        else {
        	finalList[NmbFile]= dir+list[i];
			print((NmbFile++) + ": " + dir+list[i]);
        }
	}
}


function DistanceAnalysis(PatchNumber,X,Y, TableName){
	newImage("DistanceMatrix", "32-bits", PatchNumber, PatchNumber, 0);
	Table.rename(TableName, "Results");
	selectWindow("Results");
	DistancesNumber = PatchNumber*(PatchNumber-1)/2;
	Distances = newArray(DistancesNumber);
	DistancesSorted = newArray(DistancesNumber);
	counter2 = 0;
	for (i = 0; i < PatchNumber-1; i++) {
		for (j = i+1; j < PatchNumber; j++) {
		Distances[counter2] = sqrt(pow(X[i]-X[j],2)+pow(Y[i]-Y[j],2));
		setResult("Patch1 N°", counter2, i);
		setResult("Patch2 N°", counter2, j);
		setResult("Distances", counter2, Distances[counter2]);
		setPixel(i, j, Distances[counter2]);
		setPixel(j, i, Distances[counter2]);
		counter2 = counter2+1;
		}
	}
	Table.rename("Results",TableName);
}

function PutInArrays(PatchNumber,X,Y,Area){
	Table.rename("Measurements","Results");
	for (i = 0; i < PatchNumber; i++) {
		X[i]= getResult("X", i);
		Y[i]= getResult("Y", i);
		Area[i] =getResult("Area", i);
	}
	Table.rename("Results","Measurements");
}

function MaxMinRatio(PatchNumber,Ratio,r,TableName) {
	counter3 = 0;
	Table.rename(TableName,"Results");
	DistObjecti = newArray(PatchNumber-1);
	Min_DistObjecti_S = newArray(PatchNumber);
	Max_DistObjecti_S = newArray(PatchNumber);
	DistancesNumber = PatchNumber*(PatchNumber-1)/2;
	for (j = 0; j < PatchNumber; j++) {
		for (i = 0; i < DistancesNumber; i++) {
			if (getResult("Patch1 N°", i) == j || getResult("Patch2 N°", i) == j){       
				DistObjecti[counter3] = getResult("Distances", i);
				counter3 = counter3 +1;
			}
		}
		DistObjecti_S = Array.sort(DistObjecti);
		Min_DistObjecti_S[j] = DistObjecti_S[0];                                        
		Max_DistObjecti_S[j] = DistObjecti_S[PatchNumber-2];                            
		counter3 = 0;
	}
	Array.getStatistics(Min_DistObjecti_S, min, max, mean, stdDev);
	MinMean = mean;
	Array.getStatistics(Max_DistObjecti_S, min, max, mean, stdDev);
	MaxMean = mean;
	Ratio[r] = MaxMean/MinMean;
	Table.rename("Results",TableName);
}

function CompareRatio(PatchNumber,Ratio,IdealRatio,IterationNumber,time){
	fss = File.separator;
	open(DirCorr+fss+"Min_MaxMinDistRatio.csv");
	if (PatchNumber>=50){                                                                             
    	Min_Ratio = 0.6972*pow(PatchNumber,0.5845);                                                   
    }
    else{
    	Min_Ratio = getResult("Value",PatchNumber);
   	}
   	close("Min_MaxMinDistRatio.csv");
    IdealRatio[0] = sqrt(Min_Ratio);
	Table.rename("MaxMinRatio","Results");
	for (i = time; i <= IterationNumber; i++) {
		setResult("Iteration of Patches",i,i);
		setResult("Number of Patches",i,PatchNumber);
		setResult("Best Ratio",i,IdealRatio[0]);
		setResult("Actual Ratio",i,Ratio[i]);
		setResult("Deviation from Ratio",i,Ratio[i]/IdealRatio[0]);
	}
	Table.rename("Results","MaxMinRatio");
}


function RandomizePatch(NumberofPatches,X,Y,Area) {
	newImage("Image2", "8-bit white", 184, 416, 1);
	for (i = 0; i < NumberofPatches; i++) {
		do {
			x = 184*round(random*33)/33;
			y = 416*round(random*33)/33;
			selectWindow("Image2");
			roiManager("select", i);
			Roi.move(x, y);
			run("Measure");
			AreaNewROI = getResult("Area",0);
			IntNewROI = getResult("Mean",0);
			print(AreaNewROI, IntNewROI);
			testcount = testcount+1;
			Table.deleteRows(0, 0);
		} while (AreaNewROI < Area[i]-1 || IntNewROI < 255 || testcount >200)
	roiManager("select", i);
	Roi.move(x, y);roiManager("select", NumberofPatches);
	roiManager("add")
	roiManager("fill");
	roiManager("select", NumberofPatches);
	roiManager("delete");
	X[i] = x;
	Y[i] = y;
	}
	close("Image2");
}

function TriangularPacking(PatchNumber, AverageArea,k,Crowdness_A) {
	   	AverageRad = sqrt((AverageArea)/(PI));									//Compute the average radius of the patches, this value will be used to compute some spatial statistics
		print("Average Radius is ",AverageRad);
		NumberLines = floor((416/AverageRad-1)/2);
		NumberColumns = floor((((184/AverageRad-2)/sqrt(3))+1));
		NumberMax = (NumberLines-1)*NumberColumns+NumberLines*NumberColumns;
		Crowdness_A[k] = PatchNumber/NumberMax * 100;
}


function fillFinalTable(ImageList,PatchNumbercount_A,AveragePatchSize_A,AveragePatchIntensity_A,PerCentArea_A,Crowdness_A,IdealRatio_A,DeviationfromIdeal_A,DeviationfromRandom_A,k) {
	Table.rename("FinalTable.csv","Results");	
	setResult("File Name",k,ImageList);	
	setResult("Number of Patches",k,PatchNumbercount_A);	
	setResult("Average Size",k,AveragePatchSize_A);		
	setResult("Average Intensity",k,AveragePatchIntensity_A);
	setResult("% Area",k,PerCentArea_A);
	setResult("Crowdedness",k,Crowdness_A);
	setResult("Ideal Ratio of distances",k,IdealRatio_A);
	setResult("Deviation from Ideal",k,DeviationfromIdeal_A);
	setResult("Deviation from Random Distribution",k,DeviationfromRandom_A);					
	Table.rename("Results","FinalTable.csv");
	saveAs("Results", DirOut+"FinalTable"+".csv");
}

function fillAreaTable(ImageList,Areadata,k){
Table.rename("Area Distribution.csv","Results");										
	setResult("File Name",k,ImageList);
	for (i=0;i<Areadata.length;i++) {
		setResult("Patch_Area"+i,k, Areadata[i]);											
	}
	Table.rename("Results","Area Distribution.csv");										
	saveAs("Results", DirOut+"Area Distribution.csv");
}

function fillMeanTable(ImageList,Meandata,k){
Table.rename("Intensity Distribution.csv","Results");										
	setResult("File Name",k,ImageList);
	for (i=0;i<Meandata.length;i++) {
		setResult("Patch_Intensity"+i,k, Meandata[i]);											
	}
	Table.rename("Results","Intensity Distribution.csv");										
	saveAs("Results", DirOut+"Intensity Distribution.csv");
}

	
