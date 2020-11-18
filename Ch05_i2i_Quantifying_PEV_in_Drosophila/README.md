# i.2.i. with the (fruit) fly: Quantifying position effect variegation in *Drosophila melanogaster*

This folder contains the code discussed in Chapter 5 about the i2i workflow for quantifying position effecti variegation in *Drosophila melanogaster* eyes.

This semi-automated workflow uses [ilastik](https://www.ilastik.org/) for segmentation of 'eye spots' and [ImageJ](https://imagej.nih.gov/ij/) scripts to do the post-processing and quantification.

The overview is as follows with script-automated and user interactive parts indicated:  
* Open the image of the fly head *(Automated)*
* Crop the left and the right eye *(User Interactive)*
* Use Ilastik pixel segmentation to get binary masks *(Automated)*
* Use them to extract relevant information concerning the eye and its patchiness *(Automated)*
  * Easy parts *(Automated)*
    * Analyse Patch Area
    * Analyse Patch intensity
  * More advanced *(Automated)*
    * Analyse Patch Organization
    * Batch processing into multifolder

Happy quantifying!

All code and data here are under the MIT License.
