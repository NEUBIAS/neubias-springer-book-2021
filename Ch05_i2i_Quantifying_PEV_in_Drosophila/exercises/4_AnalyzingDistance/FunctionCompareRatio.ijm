// This code is to be used for the exercice regarding the analysis of the previous computed distances
// It follows the output Ratio given by the function MaxMinRatio
// It needs to access to a file holding the theoritical values.
// It is a slightly different version from the function found in the full macro in order to focus on the important part
Ratio = 10.4029;
PatchNumber = 33;
fss = File.separator;
Dir = getDirectory("Choose the Directory 4.Distances")
open(Dir+fss+"Min_MaxMinDistRatio.csv");
CompareRatio(PatchNumber,Ratio);

function CompareRatio(PatchNumber,Ratio){
	fss = File.separator;
	if (PatchNumber>=50){                                                                             
    	Min_Ratio = 0.6972*pow(PatchNumber,0.5845);                                                   
    else{
    	Min_Ratio = getResult("Value",PatchNumber);
   	}
   	close("Min_MaxMinDistRatio.csv");
    IdealRatio = sqrt(Min_Ratio);
	print("Ideal ratio for "+PatchNumber+" patches is "+ IdealRatio);
	print("The computed ratio is "+Ratio);
	print("The deviation from the theoritical value is ",Ratio/IdealRatio);
}