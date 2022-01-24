//Code to use for the exercice considering the computation of distances between n objects
//As an input, select the subfolder named 3.Distances in folder exercices. It contains the
//file PEV000001L_GM.csv that hold the values retrieved from [Analyse Particles...]
//for each patch : The Patch area, the average intensity and the coordinates of the patch centroïd
// There is the double of patchNumber since the average intensity is collected by a second reading of the ROIs
// Therefore, the number of patches is retrieved by the number of results divided by 2.
// As an output, I propose two ways. A table that will hold the indexes of the patches and the computed distances between them,
// And a graphical one by creating a squared image. Its size will be the number of patches. Each pixel (x,y) will hold the distance 
// computed between the patch x and the patch y. This matrix being diagonal, the intensity pixel (y,x) will be the same.

fss = File.separator;
Dir = getDirectory("Choose Directory Exercice Distances Computing")
open(Dir+fss+"PEV000001L_GM.csv");
Table.rename("PEV000001L_GM.csv", "Results");
PatchNumber = nResults/2;
X = newArray(PatchNumber);
Y = newArray(PatchNumber);
Area = newArray(PatchNumber);
TableName = "Distances";
Table.create(TableName);
open("PEV000001L_GM.csv");
PutInArrays(PatchNumber,X,Y,Area)
DistanceAnalysis(PatchNumber,X,Y, TableName);

function DistanceAnalysis(PatchNumber,X,Y, TableName){
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
		counter2 = counter2+1;
		}
	}
	Table.rename("Results",TableName);
}

function PutInArrays(PatchNumber,X,Y,Area){
	for (i = 0; i < PatchNumber; i++) {
		X[i]= getResult("X", i);
		Y[i]= getResult("Y", i);
		Area[i] =getResult("Area", i);
	}
}

function DistanceAnalysis_ImageOutput(PatchNumber,X,Y, TableName){
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
		setPixel(i, j, Distances[counter2]); setPixel(j, i, Distances[counter2]);
		counter2 = counter2+1;
		}
	}
	Table.rename("Results",TableName);
}

