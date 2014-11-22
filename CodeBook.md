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

Both the test and training data sets are joined to produce the final result

## Data and Variables

The data in [`uci_har_means_long.txt`](https://github.com/jamesgorman2/GetDataCourseProject/blob/master/uci_har_means_long.txt)
consists of the mean value of each mean or standard deviation measument in the original data, grouped by _activity_ and _subject_.

Each record consists of:

* *activity* - one of six activities performed by the subjects. One of: laying, sitting, standing, walking, walking downstairs, or walking upstairs;
* *subject* - an ID interger in the range [1, 30] representing a single volunteer. Subject IDs are randomly assigned to volunteers;
* *measurement* - a measurment from the original data. One of: BodyAcc, BodyAccJerk, BodyAccJerkMag, BodyAccMag, BodyBodyAccJerkMag, 
  BodyBodyGyroJerkMag, BodyBodyGyroMag, BodyGyro, BodyGyroJerk, BodyGyroJerkMag, BodyGyroMag, GravityAcc, or GravityAccMag;
* *direction* - one of:
    * _empty_ - directionless data;
    * one of *X*, *Y* or *Z* - the measured direction.
* *domain* - one of:
    * _empty_ - normalised raw data;
    * *time* - accelerometer and gyroscope 3-axial raw signals, sampled at 50Hz, filtered for noise and normalised;
    * *frequency* - measurments made in the frequency domain. These were produced by performing a Fast Fourier Transform over the
      original time data.
* *calculation* - one of:
    * *mean* - the mean of the measurment;
    * *std* - the standard deviation of the measurement;
* *mean* - the mean of all measurments for a measurement, grouped by activity, subject, domain and calculation. All variables have 
  been normalised in the range [-1, 1] in the orignal data.
  
## <a name="clean"/>Cleaning and Transformations

The order of operations for producing the output data is:

1. download the original data if it is not present in the working directory;
2. unzip the original data in the working directory. This is performed even if the unzipped data already exists;
3. for each of the test and training data sets:
    1. load and transform the measurment names, see [Transforming measurment names](#measurmentnames);
    2. load the raw measurement data as a data frame, using the transformed names as column names;
    3. extract the columns that contain mean or standard deviation data, discarding the remainder;
    4. load the activity names for each measurement as a data frame, see [Loading activity names](#activitynames);
    5. load the subject IDs as a data frame;
    6. combine the measurement, activity and subject frames using `cbind`;
4. union the test and training data using `rbind`. We now have a data frame with activity and subject comlumns, and one column
  for each of the mean and standard deviation measurments;
5. melt the table so we have a table so we have activity, subject, measurement and value columns;
6. calculate the mean of the value, grouped by activity, subject and measument;
7. split the measurement column into measurement, direction, domain, and calculation columns;
8. remove the original, joined measurment column;
9. reorder the columns for output.

### <a name="measurmentnames"/>Transforming measurment names

Measurement names are normalised by:

1. splitting into domain, measurement, direction and calculation compents;
2. domain is expanded from a single letter to a descriptive word;
3. the parentheses are remove from the calculation;
4. these are joined in the order calculation, direction, domain, measurement, separated by the underscore
  and with missing values rendered as the empty string;
5. `make-names` is applied to remove any bad characters and renames duplicates (since measurement is last in the joined name,
  duplicates are marked on the measurement, not the domain, direction or calculation).

Some original measurement names will produce junk data at this point, but their columns will be removed in step 3.3 of Cleaning and
Transformations, so we can safely ignore them.

Producing the decoded columns in step 7 of Cleaning and Transformations simply involves splitting on the underscores.

### <a name="activitynames"/>Loading activity names

Activity names are loaded by joining the activity ID file to the activity name file and discarding the IDs.
Each row in the activity ID file corresponds to a row in the measurements file.

Activity names are normalised by setting to lower case and replacing `_`s with spaces.

## References

<a name="ref1"/>[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition
on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop
of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
