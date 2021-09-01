NmbFile = 0;
count = newArray(1);
countFile(DirSrc,count);
finalList = newArray(count[0]);
print (count[0],finalList.length);
NmbFile =0;
listFiles(DirSrc, finalList);
Array.show(finalList);

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
        	finalList[NmbFile]= dir+"\\"+list[i];
			print((NmbFile++) + ": " + dir+list[i]);
        }
	}
}