noise=2;
fftMax=1;
fftMin=0;
sigma=2;

//filter properties
maxArea=0.3;
minCircularity=0.6;

//filetype
extention=".tif"


dir=getDirectory("Choose_Directory_to_Save_Results");
files=getFileList(dir);
subfolder=dir+"\\analysis\\";
File.makeDirectory(subfolder);
File.makeDirectory(subfolder+"ROIs\\");
File.makeDirectory(subfolder+"CSVs\\");
File.makeDirectory(subfolder+"CSVs\\Localizations\\");
File.makeDirectory(subfolder+"CSVs\\Counts\\");
File.makeDirectory(subfolder+"Overlays\\");


extention=getString("Enter identifier (e.g. .tif .png)", extention);

particles=newArray();
names=newArray();
processed=0;

print(files.length);

for (i=0;i<files.length;i++)
	{
	print(files[i]);

	if ((indexOf(files[i], extention)) >= 0) 

		{
		
		
			
		close("*");
		run("Clear Results");
		roiManager("reset");
	
//		run("Collect Garbage");
//		call("java.lang.System.gc");
			
		
		run("Bio-Formats", "  open="+dir+files[i]+" color_mode=Default view=Hyperstack stack_order=XYCZT");	
		//run("32-bit");

		title=getTitle();		
		run("Select All");
		resetMinAndMax();
		run("Duplicate...", " ");
		
		
		
		/*
//		run("Median...", "radius=1");
		setAutoThreshold("Shanbhag dark");
		run("Threshold...");
		run("Convert to Mask");
		run("Analyze Particles...", "size=3-Infinity display clear add");
		getStatistics(area, mean, min, max, std, histogram);
		setColor(mean);
		//run("Create Selection");
		roiManager("Deselect");
		roiManager("Combine");
		
		run("Fill", "slice");
		run("Select All");
		run("Enlarge...", "enlarge=3 pixel");
		
		*/
		
		
		run("Bandpass Filter...", "filter_large="+fftMax+" filter_small="+fftMin+" suppress=None tolerance=5");

		//run("Multiply...", "value=10");
		//run("Morphological Filters", "operation=[White Top Hat] element=Square radius=1");
		run("Kill Borders");

		run("Gaussian Blur...", "sigma="+sigma+"");
		run("Mexican Hat Filter", "radius=1");
		rename("filtered");
		run("Find Maxima...", "prominence="+noise+" output=List");



		selectWindow("Results");
		saveAs("Results", ""+subfolder+"CSVs\\Localizations\\"+title+".csv");
		

		
		

		
		selectImage(title);
		run("RGB Color");
		run("Enhance Contrast", "saturated=0.35");
		d=30;
		resultnumber=nResults;

		
		for(j=0; j<resultnumber; j++)
			{
			x=getResult("X", j);
			y=getResult("Y", j);
			//makeOval((thisX-(2*d)), (thisY-(2*d)), d[l], d[l]);
			makeOval((x-(d/2)), (y-(d/2)), d, d);
			run("Add to Manager");
			}
			

			selectImage("filtered");
			wait(500);
			removeArtefacts();
			particles[processed]=roiManager("count");
			names[processed]=files[i];


			

			selectImage(title);
			//rename ROI
			roinumber = roiManager("count");
			if(roinumber>0)
				{
				
				filename = "roi";
				for(k=0;k<roinumber;k++) {
				 filename = "roi";
				 for(j=0;j<3-lengthOf(toString(k));j++) {
				 	filename = filename + "0";
				 }	
					roiname = filename + toString(k);
					roiManager("Select",(k));
					setForegroundColor(255, 0, 0);
					run("Draw", "slice");
					roiManager("Rename", roiname);
				}
				
	
			roiManager("Save", ""+subfolder+"ROIs\\"+title+".zip");
			selectImage(title);
			saveAs("Tiff", ""+subfolder+"Overlays\\"+title);
	
	
	
	
			close("*");
			run("Clear Results");		
			
	
	
			
			for (p = 0; p <= processed; p++) 
			{			
			setResult("filename", p, names[p]);
			setResult("particles", p, particles[p]);
			}
	
			selectWindow("Results");
			saveAs("Results", ""+subfolder+"CSVs\\Counts\\Counts.csv");
			run("Clear Results");
			
			
			processed++;
			}
		//end of one file
		}
	}
		















//functions #########################





function removeArtefacts()
{
validRedions=newArray();
badRedions=newArray();
counter=0;
counterb=0;
titleB=getTitle();	
run("Set Measurements...", "area mean standard modal min center perimeter fit shape integrated skewness redirect=None decimal=9");
resetThreshold();
for (r = 0; r < roiManager("count"); r++) {
	
	run("Clear Results");
    // Select the ROI
    selectImage(titleB);
    roiManager("Select", r);

    // Create a duplicate of the current ROI
    resetMinAndMax();
    run("Duplicate...", "title=tmp");


    // Convert to 8-bit grayscale
    //run("8-bit");

    // Apply Otsu thresholding to the duplicated ROI
    //run("Subtract Background...", "rolling=1");
    run("32-bit");
    setAutoThreshold("Minimum dark");


    // Convert the thresholded image to a binary mask
    run("Convert to Mask");

        
    run("Analyze Particles...", "  show=Overlay display");
    validCirc=getResult("Circ.", 0)>minCircularity;
	validArea=getResult("Area", 0)<maxArea;
	if(validCirc==1 && validArea==1)
	{
	validRedions[counter]=r;
	counter+=1;
	print(files[i]+" "+getResult("Circ.", 0)+" "+getResult("Area", 0));
	}
	else 
	{
	badRedions[counterb]=r;
	counterb+=1;	
	}
	close("tmp");
}
roiManager("Select", badRedions);
roiManager("Delete");
    
}

