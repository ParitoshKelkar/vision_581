1. Open the 'carving' folder and run the 'carv_demo.m' script. It will load an image and shrink it by 50rows and 50cols. The original image and the result will be displayed. The code takes almost 4mins to run(sorry about that)
2. Open the `Stitching' folder and run 'mosaic_demo.m'. There are flags for visualisation that can be configured. The possible visualizations include:
	-post ANMS(show_ANMS)
	-initial feature match (visualizeMatched)
	-post RANSAC - best Inlier Set (visualizeRANSAC_result)
3. Even without setting the flags, the number of iterations of RANSAC are displayed on screen
4. The relevant images of al results are placed in the `Results' folder
See also the `paritosh_Project3.pdf' that is included in the submission
