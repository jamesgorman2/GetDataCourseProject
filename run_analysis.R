# This code will download UCI HAR data, normalise it, extract and calculate
# the desired means, then export the resulting data.
#
# The output data format is 'tall' - it is in the format provided by `melt`,
# where the interesting variables are output in the column 'variable', with 
# the mean values in 'mean'.
#
# This has not been optimised - all data is loaded from the original data, 
# then it is filtered and the new data calculated. This is to improve readability
# at the cost of performance.
#
# When run, `dplyr` will produce masking warnings that can be ignored.
#
# It is broken into three sections: loading, calculating means and running.

library(plyr); library(dplyr) # this ordering is required to prevent incorrect masking
library(reshape2)
library(stringr)


###############################################################################
# Constants and psuedo-constant functions
###############################################################################

data.url <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zip.file <- "UCI_HAR.zip"
data.path <- "UCI HAR Dataset"
activity.name.file <- paste0(data.path, "/activity_labels.txt")
measurement.name.file <- paste0(data.path, "/features.txt")
output.file <- "uci_har_means_long.txt"

DataSetPath <- function(data.set) {
  paste(data.path, data.set, sep="/")
}

ActivityFile <- function(data.set) {
  paste0(DataSetPath(data.set), "/y_", data.set, ".txt")
}

SubjectFile <- function(data.set) {
  paste0(DataSetPath(data.set), "/subject_", data.set, ".txt")
}

MeasurementsFile <- function(data.set) {
  paste0(DataSetPath(data.set), "/X_", data.set, ".txt")
}


###############################################################################
# Functions to download, read and normalise the original data.
###############################################################################

DownloadData <- function(skip.if.exists) {
  if (!skip.if.exists || !file.exists(zip.file)) {
    download.file(data.url, zip.file, mode="wb")
  }
}

UnzipData <- function() {
  unzip(zip.file)
}

LoadRawNames <- function() {
  names <- read.table(measurement.name.file, col.names=c("id", "label"), stringsAsFactors=FALSE)
  names$label
}

ReLabelNames <- function(names) {
  # Column names are split into measurement (eg BodyAcc), dimention (eg X) and
  # calculation (eg mean), extra characters removed, reordered and rendered in
  # camelCase. Further normalisation is done using `make.names` - this forces 
  # uniqueness and removes illegal characters from names not treated in the first
  # round. We are not yet interested in the names/measuments that are modified
  # so they are left as is.
  
  Normalise <- function(x) {
    elements <- str_split(x, "-")[[1]]
    measurement <- sub("^t", "time", sub("^f", "frequency", elements[1]))
    dimention <- if (length(elements) > 2) {
      gsub(",", "", elements[3])
    } else {
      ""
    }
    calculation <- if (length(elements) > 1) {
      calc <- gsub("[\\(\\)]", "", elements[2])
      paste0(toupper(substring(calc, 1, 1)), tolower(substring(calc, 2)))
    } else {
      ""
    }
    paste0(measurement, dimention, calculation)
  }
  make.names(sapply(names, Normalise, USE.NAMES=FALSE), unique=TRUE)
}

ReLabelActivities <- function(activities) {
  # Activity names are split to include white space and are put in sentence case
  
  Normalise <- function(x) {
    paste0(substring(x, 1, 1),  gsub("_+", " ", tolower(substring(x, 2))))
  }
  activities$activity <- sapply(activities$activity, Normalise)
  activities
}

LoadRawActivtyNames <- function() {
  read.table(activity.name.file, col.names=c("id", "activity"))
}

LoadActivitiesAsLabels <- function(data.set) {
  activity.names <- ReLabelActivities(LoadRawActivtyNames())
  raw.activities <- read.table(ActivityFile(data.set), col.names="id")
  activities <- join(raw.activities, activity.names, by="id")
  activities[, "activity", drop=FALSE]
}

LoadMeasurementsWithColumnNames <- function(data.set) {
  names <- ReLabelNames(LoadRawNames())
  classes <- sapply(read.table(MeasurementsFile(data.set), nrows=5), class)
  read.table(MeasurementsFile(data.set), col.names=names, colClasses = classes)
}

LoadSubjects <- function(data.set) {
  subjects <- read.table(SubjectFile(data.set), col.names=c("subject"))
}

LoadDataSet <- function(data.set) {
  # Loads an individual named data set (eg test or train).
  
  measurements <- LoadMeasurementsWithColumnNames(data.set)
  activities <- LoadActivitiesAsLabels(data.set)
  subjects <- LoadSubjects(data.set)
  cbind(measurements, activities, subjects)
}
  
LoadData <- function() {
  # Load the test and training data from UCI HAR. Only download the data if it
  # has not been downloaded. The current working directory is used to store 
  # the raw files.

  DownloadData(TRUE)
  UnzipData()
  rbind(LoadDataSet("test"), LoadDataSet("train"))
}


###############################################################################
# Functions to extract and transform the subset of data we are interested in. 
###############################################################################

IsMeanOrStdColumn <- function(name) {
  grepl("(Mean|Std)$", name) 
}

KeyNames <- function(all.names) {
  all.names[IsMeanOrStdColumn(all.names) | all.names == "activity" | all.names == "subject"]
}

KeyMeasurements <- function(all.measurements) {
  # Return a table with the subset of measurements/columns in which we are interested,
  # as defined by `KeyNames`. The two identifying columns, 'activity' and 'subject' are
  # included in this.
  
  all.measurements[, KeyNames(names(all.measurements))]
}

FindMeans <- function(measurements) {
  # Find the mean of each measurement, grouped by 'activity' and 'subject'. This
  # returnes a melted table, where the measurements are per-row, not per-column.
  
  melted <- melt(measurements, id=c("activity", "subject"))
  grouped <- group_by(melted, activity, subject, variable)
  summarise(grouped, mean=mean(value))
}


###############################################################################
# Run the analysis
#
# This is a simple composition of the entry point functions provided above,
# with the resulting table output as-is.
###############################################################################

means <- FindMeans(KeyMeasurements(LoadData()))
write.table(means, output.file, row.name=FALSE)