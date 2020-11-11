[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/bercowskya/neubias-springer-book-2021/273abea9640a0d15c8a0959c2b8c0872863bbfa7)

# Chapter 2: Python - Data Handling, Analysis and Plotting

When performing an image analysis pipeline, a programming language like Python is mainly used for two distinctive applications: (1) the analysis of the acquired images, such as background removal, noise reduction, object segmentation, etc. and (2) the analysis of the data obtained as a result of the image analysis, such as a calculating a histogram from the noise-removed image or statistics on the shape of the segmented object. The aim of this chapter is to show Python as a tool to analyze the data obtained as the final step of a bio-image analysis workflow. Specific Python libraries for data handling and plotting are discussed along this chapter. Jupyter notebooks (specified in red at the beginning of each section) are available for the reader to follow the examples and to play with the Python code:

- NB-0-Installation\_Guide.ipynb : Installation of Python distribution and all the packages needed to follow the chapter.
- NB-1-Python\_Introduction.ipynb : Brief introduction to basic operations in Python, which will be useful if you are new to Python. 
- NB-2-Pandas\_Data\_Handling.ipynb : This notebook covers section 2.3, how to handle data using the package ``pandas``.
- NB-3-Bokeh\_Plotting.ipynb : This notebook covers section 2.4, specifically 2.4.1 - using ``Bokeh``
to create interactive figures. 
- NB-4-Holoviews\_Plotting.ipynb : This notebook covers section 2.4, specifically 2.4.1 - using ``Holoviews`` to create interactive figures.


In case you do not want to install Anaconda or any of the packages, you can still follow the chapter using the notebooks that are in Binder (See the link at the beginning of this file). 
