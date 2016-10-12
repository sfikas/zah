# Zoning Aggregated Hypercolumns for Keyword Spotting #

The provided code takes an input image as input, and returns a numerical feature vector (called 'ZAH feature') as output. This can be used for keyword spotting.

Zoning Aggregated Hypercolumn features (ZAH features) are introduced with this work as pixel-level cues for document images.
Motivated by recent research in machine vision, we use an appropriately pretrained convolutional network as a feature extraction tool.
The [convolutional network] has been trained with [matconvnet] on a large collection of word images.
The resulting local cues are subsequently aggregated to form *word-level fixed-length descriptors*.

The Euclidean distance can then be used to compare and query resulting descriptors of different word images (Query-by-Example keyword spotting).

If you find this work useful, please read and cite the [related paper]:
```
@inproceedings{sfikas2016zoning,
  title={Zoning Aggregated Hypercolumns for Keyword Spotting},
  author={Sfikas, Giorgos and Retsinas, Giorgos and Gatos, Basilis},
  booktitle={15th International Conference on Frontiers in Handwriting Recognition (ICFHR)},
  year={2016},
  organization={IEEE}
}
```

## ZAH Workflow

The workflow is:

1. The (normalised) image is split into zones
2. Hypercolumn features are computed for each of the zones, using a pretrained convolutional neural network
3. Hypercolumns are aggregated into a single feature vector per zone 
4. Per-zone features are concatenated into a single feature vector, which therefore describes the whole word image

The workflow is summarized in the following figure. A word image is in the input (top), and a vector is returned at the output (bottom):

![workflow](https://github.com/sfikas/zah/blob/master/img/workflow.png "ZAH Workflow")

## Before running the code

First you will have to compile some of the code with matlab mex, and optionally enable GPU support: 

* In ```pretrained/matconvnet/Makefile```, change the MEX variable appropriately. It should point to the path of the ```mex``` executable in your system. 
For example this could be something similar to ```/usr/local/MATLAB/R2012a/bin/mex``` .
* (optional) Set ENABLE_GPU in the same file in order to use the GPU for extracting ZAH features.
* Run ```cd pretrained/matconvnet/ && make distclean && make``` on the OS shell.

On the MATLAB prompt, add all repo subfolders to the path, by running the following:

* ```cd zah/```
* ```addpath(genpath('.'))```

Note that it is important that you execute ```addpath``` *after* having finished compiling the necessary items with MEX.

## Running the code

In order to compute the ZAH descriptor of an input image, run

```
descriptor = extractAggregatedHypercolumns_zoning('img/1/1.jpg');
```

After the input file argument, the parameters are: 

* modelchoice
    * 0           Use the [unigram model](https://github.com/sfikas/zah/blob/master/pretrained/models/charnet_layers.mat)
    * 1           Use the [bigram model](https://github.com/sfikas/zah/blob/master/pretrained/models/bigramsvtnet_layers.mat) (default choice)
    * 2           Use both

* layerchoice:  Choose layers to use. You can select more than one layer. Suggested layers are 3, 6, 11 (default), 16.
* centerprior:  Prior that makes pixels near the center row more important. Input is the Gaussian precision. Zero precision corresponds to no smoothing. Default value is 6.
* resizeheight: Resize word image to this height. This should ideally be a value close to 24, ie the window with which the related CNN was originally trained with. Default value is 30.

For example, the following command will extract a ZAH descriptor using only the unigram-trained CNN model, use activations of layers 3 and 6, apply a centerprior with precision equal to 3 and resize input to a height of 24 pixels:

```
descriptor = extractAggregatedHypercolumns_zoning('img/1/1.jpg', 0, [3 6], 3, 24);
```

## Batch extraction

Multiple images can be processed with ```batch_extract_zoning.m```. For example:

```
D = batchExtract_zoning('img/1/');
```

Note that filenames of images in the given folder should be numbered, with names starting with 

## Acknowledgements

In the current work we make use of this third-party code/material:

* Two pretrained CNN models from [this work]. See the related [license].
* [matconvnet] code to perform feed-forward passes on the pretrained CNN models.


[related paper]: <http://www.cs.uoi.gr/~sfikas/2016ICFHR-ZAH.pdf>
[here]: <https://bitbucket.org/jaderberg/eccv2014_textspotting>
[this work]: <http://www.robots.ox.ac.uk/~vgg/publications/2014/Jaderberg14/jaderberg14.pdf>
[convolutional network]: <http://www.robots.ox.ac.uk/~vgg/publications/2014/Jaderberg14/jaderberg14.pdf>
[matconvnet]: <http://www.vlfeat.org/matconvnet/>
[license]: <https://github.com/sfikas/zah/blob/master/pretrained/LICENSE>
