// This code is to be used for the exercice regarding the analysis of the crowdedness

// It is a slightly different version from the function found in the full macro in order to focus on the important part
//It is using the output given by the general measurement step
PatchNumber = 33;
AverageArea = 335.455;

TriangularPacking(PatchNumber, AverageArea);

function TriangularPacking(PatchNumber, AverageArea) {
	   	AverageRad = sqrt((AverageArea)/(PI));									
		print("The average radius is ",AverageRad);
		NumberLines = floor((416/AverageRad-1)/2);
		NumberColumns = floor((((184/AverageRad-2)/sqrt(3))+1));
		NumberMax = (NumberLines-1)*NumberColumns+NumberLines*NumberColumns;
		Crowdedness = PatchNumber/NumberMax * 100;
		print("For a patch with an average area of 335.455 pxl² in an area of 416*184 pxls²,\n we can expect to put "+NumberMax+ " patches. \n Therefore, the crowdedness is "+Crowdedness +" %");
}