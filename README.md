# Getting and Cleaning Data Course Project

This is the code submition for the [Getting and Cleaning Data Course Project](https://class.coursera.org/getdata-009/human_grading/view/courses/972587/assessments/3).
It takes data from the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
(HAR) and calculates the mean of a subset of measurements.

## Files

* [`README.md`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/README.md) - this file
* [`run_analysis.R`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/run_analysis.R) - an 
  [R](http://www.r-project.org/) script that downloads the HAR data and performs the calculations, described below.
* [`CodeBook.md`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/CodeBook.md) - describes 
  the transformations applied to the original HAR data and the output of `run_analysis.R`. 
* [`uci_har_means_long.txt`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/uci_har_means_long.txt) - 
  the output of `run_analysis.R` as described in `CodeBook.md`.

## Reproducing the output

Running the project requires [R](http://www.r-project.org/). 

To reproduce the data run:

```
$ r
> source('run_analysis.R')
```

This will download the original data, perform the calculations and output the data to `uci_har_means_long.txt`.
The data is only downloaded if it is not present. `dyplyr` will produce masking warnings that can be
ignored. All operations happen in the current working directory.
