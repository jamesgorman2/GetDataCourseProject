# This code will download UCI HAR data, normalise it, extract and calculate the
# desired means, then export the resulting data.
# 
# The output data format is 'tall' - it is in the format provided by `melt`, 
# where the interesting variables are output in the column 'variable', with the
# mean values in 'mean'.
# 
# When run, `dplyr` will produce masking warnings that can be ignored.
# 
# It is broken into four sections: constants, loading data, calculating means
# and running.

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
  # Column names are split into measurement (eg fBodyAcc), direction (eg X) and 
  # calculation (eg mean), extra characters removed,rendered in camelCase,
  # reordered and joined underscores. Further normalisation is done using
  # `make.names` - this forces uniqueness and removes illegal characters from
  # names not treated in the first round. We will split these names after we have
  # melted the table and set all the measurements as variables.
  
  Normalise <- function(x) {
    elements <- str_split(x, "-")[[1]]
    domain <- if (grepl("^f", elements[1])) {
      "frequency"
    } else if (grepl("^f", elements[1])) {
      "time"
    } else {
      ""
    }
    measurement <- sub("^[ft]", "", elements[1])
    direction <- if (length(elements) > 2) {
      gsub("X,Y,Z", "XYZ", elements[3])
    } else {
      ""
    }
    calculation <- if (length(elements) > 1) {
      tolower(gsub("[\\(\\)]", "", elements[2]))
    } else {
      ""
    }
    paste(calculation, direction, domain, measurement, sep="_")
  }
  make.names(sapply(names, Normalise, USE.NAMES=FALSE), unique=TRUE)
}

ReLabelActivities <- function(activities) {
  # Activity names are split to include white space and are put in sentence case
  
  Normalise <- function(x) {
    gsub("_+", " ", tolower(x))
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

IsMeanOrStd <- function(name) {
  grepl("^(mean|std)_", name) 
}

LoadMeanAndStdMeasurements <- function(data.set) {
  names <- ReLabelNames(LoadRawNames())
  classes <- sapply(read.table(MeasurementsFile(data.set), nrows=5), class)
  all.measurements <- read.table(MeasurementsFile(data.set), col.names=names, colClasses=classes)
  all.measurements[, IsMeanOrStd(names)]
}

LoadSubjects <- function(data.set) {
  subjects <- read.table(SubjectFile(data.set), col.names=c("subject"))
}

LoadDataSet <- function(data.set) {
  # Loads an individual named data set (eg test or train).
  
  measurements <- LoadMeanAndStdMeasurements(data.set)
  activities <- LoadActivitiesAsLabels(data.set)
  subjects <- LoadSubjects(data.set)
  cbind(measurements, activities, subjects)
}
  
LoadData <- function() {
  # Load the test and training data from UCI HAR. Only download the data if it
  # has not been downloaded. The current working directory is used to store 
  # the raw files. Only the 'mean' and 'standard deviation' columns are loaded

  DownloadData(TRUE)
  UnzipData()
  rbind(LoadDataSet("test"), LoadDataSet("train"))
}


###############################################################################
# Functions to extract and transform the data we are interested in. 
###############################################################################

SplitJoinedVariableName <- function(original) {
  new.columns <- data.frame(do.call(rbind, str_split(original$joinedVariableName, "_")))
  names(new.columns) <- c("calculation", "direction", "domain", "measurement")
  cbind(original, new.columns)
}

FindMeans <- function(measurements) {
  # Find the mean of each measurement, grouped by 'activity' and 'subject'. This
  # returnes a melted table, where the measurements are per-row, not per-column.
  # The input should be non-tidy measurements in columns. After melting, the
  # measuments will be broken down into their constituent factors. The order of
  # these operations is not important as the group-by is effectively the same.
  
  melt(measurements, id=c("activity", "subject"), variable.name="joinedVariableName") %>%
    group_by(activity, subject, joinedVariableName) %>%
    summarise(mean=mean(value)) %>%
    SplitJoinedVariableName() %>%
    select(activity, subject, measurement, direction, domain, calculation, mean)
}


###############################################################################
# Run the analysis
#
# This is a simple composition of the entry point functions provided above,
# with the resulting table output as-is.
###############################################################################

means <- FindMeans(LoadData())
write.table(means, output.file, row.name=FALSE)