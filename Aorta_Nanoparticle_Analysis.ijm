// Detection parameters
noise=2;        // Prominence threshold used by "Find Maxima"
fftMax=1;       // Upper size cutoff for the bandpass filter
fftMin=0;       // Lower size cutoff for the bandpass filter
sigma=2;        // Gaussian blur sigma

// Filter properties
maxArea=0.3;            // Maximum accepted particle area
minCircularity=0.6;     // Minimum accepted circularity

// File type
extention=".tif";        // Default file identifier/extension


// Ask user to choose the directory containing images and where results will be saved
dir=getDirectory("Choose_Directory_to_Save_Results");

// Get list of files in the selected directory
files=getFileList(dir);

// Define output folder structure
subfolder=dir+"\\analysis\\";

// Create main and nested result folders
File.makeDirectory(subfolder);
File.makeDirectory(subfolder+"ROIs\\");
File.makeDirectory(subfolder+"CSVs\\");
File.makeDirectory(subfolder+"CSVs\\Localizations\\");
File.makeDirectory(subfolder+"CSVs\\Counts\\");
File.makeDirectory(subfolder+"Overlays\\");


// Ask user to confirm or enter the image identifier/extension
extention=getString("Enter identifier (e.g. .tif .png)", extention);

// Arrays for storing particle counts and filenames
particles=newArray();
names=newArray();

// Counter for processed image files
processed=0;

// Print number of files found in the selected directory
print(files.length);


// Loop over all files in the selected directory
for (i=0;i<files.length;i++)
	{
	// Print current filename
	print(files[i]);

	// Process only files matching the selected extension/identifier
	if ((indexOf(files[i], extention)) >= 0) 

		{
		
		// Close open images/windows and reset previous results/ROIs
		close("*");
		run("Clear Results");
		roiManager("reset");
	
//		// Optional garbage collection
//		run("Collect Garbage");
//		call("java.lang.System.gc");
			
		
		// Open image using Bio-Formats as a hyperstack
		run("Bio-Formats", "  open="+dir+files[i]+" color_mode=Default view=Hyperstack stack_order=XYCZT");	
		
		// Optional conversion to 32-bit
		//run("32-bit");

		// Store image title
		title=getTitle();	
		
		// Select the full image
		run("Select All");
		
		// Reset display intensity range
		resetMinAndMax();
		
		// Duplicate image for processing
		run("Duplicate...", " ");
		
		
		
		/*
		// Optional/disabled preprocessing block for threshold-based masking
		
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
		
		
		// Apply bandpass filter to reduce unwanted frequency components
		run("Bandpass Filter...", "filter_large="+fftMax+" filter_small="+fftMin+" suppress=None tolerance=5");

		// Optional intensity amplification
		//run("Multiply...", "value=10");
		
		// Optional white top-hat filtering
		//run("Morphological Filters", "operation=[White Top Hat] element=Square radius=1");
		
		// Remove particles touching image borders
		run("Kill Borders");

		// Smooth image with Gaussian blur
		run("Gaussian Blur...", "sigma="+sigma+"");
		
		// Enhance particle-like features
		run("Mexican Hat Filter", "radius=1");
		
		// Rename processed image
		rename("filtered");
		
		// Detect local maxima as candidate particles
		run("Find Maxima...", "prominence="+noise+" output=List");



		// Save detected local maxima coordinates
		selectWindow("Results");
		saveAs("Results", ""+subfolder+"CSVs\\Localizations\\"+title+".csv");
		

		
		

		
		// Switch back to original image
		selectImage(title);
		
		// Convert original image to RGB for overlay drawing
		run("RGB Color");
		
		// Enhance contrast for visualization
		run("Enhance Contrast", "saturated=0.35");
		
		// Diameter of circular ROI around each detected maximum
		d=30;
		
		// Number of detected maxima
		resultnumber=nResults;

		
		// Create circular ROIs around each detected particle coordinate
		for(j=0; j<resultnumber; j++)
			{
			x=getResult("X", j);
			y=getResult("Y", j);
			
			// Create circular ROI centered on detected maximum
			//makeOval((thisX-(2*d)), (thisY-(2*d)), d[l], d[l]);
			makeOval((x-(d/2)), (y-(d/2)), d, d);
			
			// Add ROI to ROI Manager
			run("Add to Manager");
			}
			

			// Switch to filtered image for artifact filtering
			selectImage("filtered");
			
			// Brief pause to ensure image/window is active
			wait(500);
			
			// Remove ROIs that do not meet area/circularity criteria
			removeArtefacts();
			
			// Store number of valid particles for current image
			particles[processed]=roiManager("count");
			
			// Store current filename
			names[processed]=files[i];


			

			// Switch back to original image for ROI drawing
			selectImage(title);
			
			// Get number of retained ROIs
			roinumber = roiManager("count");
			
			// Continue only if at least one ROI remains
			if(roinumber>0)
				{
				
				// Rename ROIs with consistent numbering
				filename = "roi";
				for(k=0;k<roinumber;k++) {
				 filename = "roi";
				 
				 // Add leading zeros to ROI names
				 for(j=0;j<3-lengthOf(toString(k));j++) {
				 	filename = filename + "0";
				 }	
					
					// Construct ROI name
					roiname = filename + toString(k);
					
					// Select ROI
					roiManager("Select",(k));
					
					// Set drawing color to red
					setForegroundColor(255, 0, 0);
					
					// Draw ROI on image overlay
					run("Draw", "slice");
					
					// Rename ROI in ROI Manager
					roiManager("Rename", roiname);
				}
				
	
			// Save retained ROIs as ZIP file
			roiManager("Save", ""+subfolder+"ROIs\\"+title+".zip");
			
			// Save overlay image
			selectImage(title);
			saveAs("Tiff", ""+subfolder+"Overlays\\"+title);
	
	
	
	
			// Close all images/windows and clear results
			close("*");
			run("Clear Results");		
			
	
	
			
			// Write cumulative particle count table
			for (p = 0; p <= processed; p++) 
			{			
			setResult("filename", p, names[p]);
			setResult("particles", p, particles[p]);
			}
	
			// Save cumulative particle counts
			selectWindow("Results");
			saveAs("Results", ""+subfolder+"CSVs\\Counts\\Counts.csv");
			
			// Clear results table
			run("Clear Results");
			
			
			// Increase processed-file counter
			processed++;
			}
		// End of one file
		}
	}
		















// Functions #########################





// Remove ROIs corresponding to artifacts based on circularity and area
function removeArtefacts()
{
	// Arrays for valid and rejected ROI indices
	validRedions=newArray();
	badRedions=newArray();
	
	// Counters for valid and rejected ROIs
	counter=0;
	counterb=0;
	
	// Store active image title
	titleB=getTitle();	
	
	// Define measurements to calculate
	run("Set Measurements...", "area mean standard modal min center perimeter fit shape integrated skewness redirect=None decimal=9");
	
	// Reset threshold before processing
	resetThreshold();
	
	// Loop through all ROIs in ROI Manager
	for (r = 0; r < roiManager("count"); r++) {
	
		// Clear previous measurements
		run("Clear Results");
		
	    // Select image and ROI
	    selectImage(titleB);
	    roiManager("Select", r);

	    // Duplicate current ROI region for local analysis
	    resetMinAndMax();
	    run("Duplicate...", "title=tmp");


	    // Optional conversion to 8-bit grayscale
	    //run("8-bit");

	    // Optional background subtraction
	    //run("Subtract Background...", "rolling=1");
	    
	    // Convert temporary image to 32-bit
	    run("32-bit");
	    
	    // Apply automatic threshold to isolate local particle signal
	    setAutoThreshold("Minimum dark");


	    // Convert thresholded image to binary mask
	    run("Convert to Mask");

	        
	    // Measure particle properties in the local ROI
	    run("Analyze Particles...", "  show=Overlay display");
	    
	    // Check whether measured circularity passes threshold
	    validCirc=getResult("Circ.", 0)>minCircularity;
	    
		// Check whether measured area passes threshold
		validArea=getResult("Area", 0)<maxArea;
		
		// Keep ROI if both circularity and area criteria are met
		if(validCirc==1 && validArea==1)
		{
			validRedions[counter]=r;
			counter+=1;
			
			// Print accepted ROI measurements
			print(files[i]+" "+getResult("Circ.", 0)+" "+getResult("Area", 0));
		}
		else 
		{
			// Mark ROI for deletion if criteria are not met
			badRedions[counterb]=r;
			counterb+=1;	
		}
		
		// Close temporary ROI image
		close("tmp");
	}
	
	// Select rejected ROIs and remove them from ROI Manager
	roiManager("Select", badRedions);
	roiManager("Delete");
}
