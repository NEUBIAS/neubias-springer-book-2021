[![minimal Python version](https://img.shields.io/badge/Python-3.6-6666ff)](https://www.anaconda.com/distribution/)

# Ch03 Building a Bioimage Analysis Workflow using Deep Learning
This repository contains all the material for the chapter "Building a Bioimage Analysis Workflow using Deep Learning".

The proposed workflow makes use of open source software tools ([Keras](https://keras.io/), [DeepImageJ](https://deepimagej.github.io/deepimagej/) and [MorphoLibJ](https://imagej.net/MorphoLibJ)) to segment and analyze the morphology of phase contrast images from the [Cell Tracking Challenge](http://celltrackingchallenge.net/).

![Workflow diagram](https://github.com/esgomezm/NEUBIAS_chapter_DL_2020/blob/master/notebook/img/workflow-diagram-small.png)

## Worflow steps 
Steps 0 to 4.1 take place in a Python notebook (click to open the notebook in Google Colab: [![GoogleColab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/NEUBIAS/neubias-springer-book-2021/blob/master/Ch03_Building_a_Bioimage_Analysis_Workflow_using_Deep_Learning/notebook/U_Net_PhC_C2DL_PSC_segmentation.ipynb)), while the rest of steps (4.2 to 5) are executed in ImageJ/Fiji. The complete list of worflow steps are as follows:
* **Step 0**: initialize the notebook in Google Colab to make use of a GPU runtime and set-up the correct Keras/Tensorflow versions.
* **Step 1**: download, extract and partition the image data into training, validation and test sets.
* **Step 2**: define and train a deep learning model for segmentation:
    * **Step 2.1**: prepare images for training.
    * **Step 2.2**: design a convolutional neural network (U-Net-like).
    * **Step 2.3**: define loss function and optimizer.
    * **Step 2.4**: train model.
* **Step 3**: evaluate trained model in test set.
* **Step 4** starts at the end of the notebook and involves importing the train model into DeepImageJ:
  * **Step 4.1**: download the train model from the notebook in Tensorflow format.
  * **Step 4.2**: import model into DeepImageJ using "Create Bundled Model" plugin.
* **Step 5**: apply the trained model to all images in a folder using DeepImageJ from [an ImageJ macro](https://github.com/esgomezm/NEUBIAS_chapter_DL_2020/blob/master/ij-macros/Step-5-process-folder.ijm).


Detailed instructions of all the steps can be found in [these Google slides](https://docs.google.com/presentation/d/1MKuQJEWPJnGTJpTxQ85LYfI-1dytNRplC1xxXVAwErQ/edit?usp=drivesdk). Please, feel free to provide any feedback about the described steps.
