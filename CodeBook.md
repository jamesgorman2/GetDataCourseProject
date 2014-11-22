# Code Book - Getting and Cleaning Data Course Project

The data in [`uci_har_means_long.txt`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/uci_har_means_long.txt)
is derived from the [Human Activity Recognition Using Smartphones Data Set](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)
(HAR).[[1]](#ref1) It was downloaded from [the mirror](http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
provided by [Getting and Cleaning Data](https://class.coursera.org/getdata-009/), and is used by default in
[`run_analysis.R`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/run_analysis.R).

The analysis in [`uci_har_means_long.txt`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/uci_har_means_long.txt)
is designed to fulfil the requirements of the
[Getting and Cleaning Data Course Project](https://class.coursera.org/getdata-009/human_grading/view/courses/972587/assessments/3)
and provides no real analytic insight.
The original data is taken from 30 volunteer performing 6 activites, being measured using the accelerometer and gyroscope of a
Samsung Galaxy S II mounted at the waist. For a full description of the original data, see `README.txt` in the original data.

## Data and Variables

The data in [`uci_har_means_long.txt`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/uci_har_means_long.txt)
consists of the mean value of each mean or standard deviation measument in the original data, grouped by _activity_ and _subject_.

Each record consists of:

* *activity* - one of six activities performed by the 
* *subject* - an ID interger in the range [1, 30] representing a single volunteer. Subject IDs are randomly assigned to volunteers.
* *measurement* - a measurment from the original data. One of: BodyAcc, BodyAccJerk, BodyAccJerkMag, BodyAccMag, BodyBodyAccJerkMag, 
  BodyBodyGyroJerkMag, BodyBodyGyroMag, BodyGyro, BodyGyroJerk, BodyGyroJerkMag, BodyGyroMag, GravityAcc, or GravityAccMag.
* *direction* - one of:
    * _empty_ - directionless data
    * one of *X*, *Y* or *Z* - the measured direction
* *domain* - one of:
    * _empty_ - normalised raw data;
    * *time* - accelerometer and gyroscope 3-axial raw signals, sampled at 50Hz, filtered for noise and normalised;
    * *frequency* - measurments made in the frequency domain. These were produced by performing a Fast Fourier Transform over the
      original time data.
* *calculation* - one of:
    * *mean* - the mean of the measurment
    * *std* - the standard deviation of the measurement
* *mean* - the mean of all measurments for a measurement, grouped by activity, subject, domain and calculation. All variables have 
  been normalised in the range [-1, 1] in the orignal data.
  
## <a name="clean"/>Cleaning and Transformations



## References

<a name="ref1"/>[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition
on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop
of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
