## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#clean your workspace and load required packages

rm(list=ls())
packages <- c("data.table", "reshape2", "downloader")
sapply(packages, require, character.only = TRUE, quietly = TRUE)

#set your working directory and download files

path <- getwd()
if(!file.exists("GettingAndCleaningdata")){dir.create("GettingAndCleaningdata")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "GettingAndCleaningdata/Dataset.zip", mode = "wb")
unzip(zipfile="GettingAndCleaningdata/Dataset.zip",exdir="GettingAndCleaningdata")
pathIn <- file.path("./GettingAndCleaningdata", "UCI HAR Dataset")
list.files(pathIn, recursive = TRUE)

#load actities' labels

activities <- read.table("GettingAndCleaningdata/UCI HAR Dataset/activity_labels.txt")[,2]

#load features
features <- read.table("GettingAndCleaningdata/UCI HAR Dataset/features.txt")[,2]

#load and pre-process test data

x_test <- read.table("GettingAndCleaningdata/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("GettingAndCleaningdata/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("GettingAndCleaningdata/UCI HAR Dataset/test/subject_test.txt")
colnames(x_test) <- features
x_test_final <- x_test[,grepl("mean|std", colnames(x_test))]

#assign labels to y_test
y_test[,2] <- activities[y_test[,1]]
colnames(y_test) <- c("activity_id", "activity_label")
names(subject_test) <- "subject"

test<- cbind(as.data.table(subject_test),y_test, x_test_final)

#load and pre-process train data

x_train <- read.table("GettingAndCleaningdata/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("GettingAndCleaningdata/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("GettingAndCleaningdata/UCI HAR Dataset/train/subject_train.txt")
colnames(x_train) <- features
x_train_final <- x_train[,grepl("mean|std", colnames(x_train))]

#assign labels to y_test
y_train[,2] <- activities[y_train[,1]]
colnames(y_train) <- c("activity_id", "activity_label")
names(subject_train) = "subject"

train<- cbind(as.data.table(subject_train), y_train, x_train_final)

# merge test and train data

final_data <-rbind(test, train)

#create your tidy dataset
ids <- c("subject", "activity_id", "activity_label")
data_features <- setdiff(colnames(final_data), ids)
melt_data <- melt(final_data, id = ids, measure.vars = data_features)

tidy_data <- dcast(melt_data, subject + activity_label ~ variable, mean)

#make variables' names clear and nicer

colnames(tidy_data) <-gsub("\\()", "", colnames(tidy_data))
colnames(tidy_data) <-gsub("^t", "time_", colnames(tidy_data))
colnames(tidy_data) <-gsub("^f", "freq_", colnames(tidy_data))
colnames(tidy_data) <-gsub("BodyBody", "Body", colnames(tidy_data))
colnames(tidy_data) <-gsub("Body", "Body_", colnames(tidy_data))
colnames(tidy_data) <-gsub("Gravity", "Gravity_", colnames(tidy_data))
colnames(tidy_data) <-gsub("Acc", "Accelerometer_", colnames(tidy_data))
colnames(tidy_data) <-gsub("Gyro", "Gyroscope_", colnames(tidy_data))
colnames(tidy_data) <-gsub("Jerk", "Jerk_", colnames(tidy_data))
colnames(tidy_data) <-gsub("Mag", "Magnitude", colnames(tidy_data))
colnames(tidy_data) <- tolower(colnames(tidy_data))

write.table(tidy_data, file = "GettingAndCleaningdata/tidy_data.txt", row.name=FALSE)

