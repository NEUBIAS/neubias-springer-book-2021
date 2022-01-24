Areadata = newArray(roiManager("count"));M
eandata = newArray(roiManager("count"));
Table.rename("Measurements","Results");
selectWindow(Side);
TotalPatchArea = 0; TotalIntensity = 0;
	for (j=0; j<roiManager("count"); j++) {
		roiManager("select", j);
		roiManager("measure");
		Meandata[j] = getResult("Mean",j+roiManager("count"));
		Areadata[j] = getResult("Area",j+roiManager("count"));
   		TotalPatchArea = TotalPatchArea + Areadata[j];
   		TotalIntensity = TotalIntensity + Meandata[j];
   	}
close(Side);
Table.rename("Results", "Measurements");