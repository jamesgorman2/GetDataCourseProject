library(plyr)
library(stringr)
  
zip.file <- "UCI_HAR.zip"
data.path <- "UCI HAR Dataset"
activity.name.file <- paste(data.path, "activity_labels.txt", sep="/")
measurement.name.file <- paste(data.path, "features.txt", sep="/")

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

DownloadData <- function(skip.if.exists) {
  if (!skip.if.exists && !file.exists(zip.file)) {
    download.file("http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  zip.file, mode="wb")
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
  Normalise <- function(x) {
    elements <- str_split(x, "-")[[1]]
    measurement <- substring(elements[1], 2)
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
  Normalise <- function(x) {
    paste0(substring(x, 1, 1),  gsub("_+", " ", tolower(substring(x, 2))))
  }
  activities$Activity <- sapply(activities$Activity, Normalise)
  activities
}

LoadRawActivtyNames <- function() {
  read.table(activity.name.file, col.names=c("id", "Activity"))
}

LoadActivities <- function(data.set) {
  activity.names <- ReLabelActivities(LoadRawActivtyNames())
  raw.activities <- read.table(ActivityFile(data.set), col.names="id")
  activities <- join(raw.activities, activity.names, by="id")
  activities[, "Activity", drop=FALSE]
}

LoadMeasurements <- function(data.set) {
  names <- ReLabelNames(LoadRawNames())
  read.table(MeasurementsFile(data.set), col.names=names)
}

LoadSubjects <- function(data.set) {
  subjects <- read.table(SubjectFile(data.set), col.names=c("Subject"))
}

LoadDataSet <- function(data.set) {
  measurements <- LoadMeasurements(data.set)
  activities <- LoadActivities(data.set)
  subjects <- LoadSubjects(data.set)
  cbind(measurements, activities, subjects)
}
  
GetMeasurements <- function() {
  DownloadData(TRUE)
  UnzipData()
  rbind(LoadDataSet("test"), LoadDataSet("train"))
}

IsMeanOrStdColumn <- function(name) {
  grepl("(Mean|Std)$", name) 
}

GetKeyNames <- function(all.names) {
  all.names[IsMeanOrStdColumn(all.names) | all.names == "Activity" | all.names == "Subject"]
}

GetKeyMeasurements <- function(all.measurements) {
  all.measurements[,GetKeyNames(names(all.measurements))]
}
