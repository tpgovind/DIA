source = "C:\\Users\\GORDON LAB\\Documents\\Bio-Protocol\\SAMPLE_IMAGES\\"; // Replace with your source folder of images to be analyzed - note the folder name format (Windows format is given here)
sink = "C:\\Users\\GORDON LAB\\Documents\\Bio-Protocol\\RESULTS\\"; // Replace with name of your results folder (this should be in a folder outside of the source folder)

setBatchMode(true); // Sets interpreter in batch mode, which eliminates unnecessary display of images and speeds up execution
run("Close All");
files = getFileList(source);
print("Source folder contains: "+files.length+" files")
if(files.length>0){
	for (i = 0; i < files.length; i++) {
		openImage(i+1,source,files[i]);
		diffImgAnalyse(source,files[i],sink);
	}
} else {
	print("No files in folder!");
}
setBatchMode(false);



function openImage(callNumber,source, filename) {

	/*
 	This function opens the image and converts to 8-bit grayscale.
 	Add to this block if you would like to import image types other
 	than .tif or .avi, or pre-convert all source images to .tif
 	*/
	
	path = source + filename;
	File.append(filename + "\n",sink+"Traces.txt");
	print(callNumber + ". Processing: " + path + "\n");
	
	if(File.exists(path)){
		if (endsWith(path, ".tif")) {
			open(path);
			run("8-bit");
		}
		else if(endsWith(path, ".avi")){
		run("AVI...", "open=["+path+"] convert");
		}
		
		// ADD MORE ELSE IFs HERE, AS NEEDED
		
		else{ 
			print("ERROR: FILE TYPE NOT SUPPORTED");
		}
	}
}

function diffImgAnalyse(source,filename,sink) {

	/*
 	This function performs the difference image analysis and writes
 	mean gray value for each slice to the file specified in 'sink'.
 	General steps: duplicate source image stack; delete first image
 	from first duplicate and last image from second duplicate; subtract
 	second duplicate from the first, slice-by-slice. Plot mean gray values
 	against slice number, extract data and save.
 	*/
 
	if(nImages==1){
		rename("ONE");
		run("Duplicate...", "title=TWO duplicate");
		selectWindow("ONE");
		setSlice(1);
		run("Delete Slice");
		selectWindow("TWO");
		setSlice(nSlices);
		run("Delete Slice");
		imageCalculator("Subtract create stack", "ONE","TWO");
		selectWindow("Result of ONE");
		run("Plot Z-axis Profile");
		Plot.getValues(x, y);
		for (m=0; m < x.length; m++){
			File.append(d2s(x[m],4) + "," + d2s(y[m],4),sink+"Traces.txt");
		}
		File.append("\n"+"\n",sink+"Traces.txt");
		selectWindow("Result of ONE");
		run("Enhance Contrast", "saturated=0.35");
		run("Despeckle", "stack");
		saveAs("Tiff",sink+filename+"_DIFF-IMG");
		print("Result: DONE!");
		run("Close All");
	}
}

function yourHelperFunction(input1,input2) {

	/*
	Add additional functions as needed, and call them within
	the main loop.
 	*/

}
