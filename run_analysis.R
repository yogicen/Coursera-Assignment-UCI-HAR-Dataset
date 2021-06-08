test_set <- read.table("./UCI HAR Dataset/test/X_test.txt")
train_set <- read.table("./UCI HAR Dataset/train/X_train.txt")
test_subject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
train_subject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
test_label <- read.table("./UCI HAR Dataset/test/y_test.txt")
train_label <- read.table("./UCI HAR Dataset/train/y_train.txt")

## Merge the training and the test sets to create one data set.
all_set <- rbind(test_set, train_set)
all_subject <- rbind(test_subject, train_subject)
setnames(all_subject, "V1", "subject")
all_label <- rbind(test_label, train_label)
setnames(all_label, "V1", "activity.label")
all_data <- cbind(all_set, all_subject, all_label)
dim(all_data)

## Extract only the measurements on the mean and standard deviation for each measurement.
features <- fread("./UCI HAR Dataset/features.txt")
setnames(features, names(features), c("feature.number", "feature.name"))
features <- features[grepl("mean\\(\\)|std\\(\\)", feature.name)]
dim(features)
# Create feature.code column
features$feature.code <- features[, paste0("V", feature.number)]
# Set subject and activity.label as keys
setkey(all_data, subject, activity.label)
# Append the feature.code to the keys
wanted_column <- c(key(all_data), features$feature.code)
# These are the data from the columns that we want
result <- all_data[, wanted_column, with = F]
str(result)

## Use descriptive activity names to name the activities in the data set.
activity_labels <- fread("./UCI HAR Dataset/activity_labels.txt")
setnames(activity_labels, names(activity_labels), c("activity.label", "activity.name"))
activity_labels

## Appropriately label the data set with descriptive activity names.
DT <- merge(activity_labels, result, by = "activity.label", all.x = T)
str(DT)
setkey(DT, subject, activity.label, activity.name)
# Use reshape2 library to melt the dataset
DT <- data.table(melt(DT, key(DT), variable.name = "feature.code"))
DT <- merge(DT, features[, list(feature.number, feature.code, feature.name)], by = "feature.code", all.x = TRUE)
head(DT, nrow = 10)
tail(DT, nrow = 10)

## Create a second, independent tidy data set with the average of each variable for each activity and each subject.
# Making a copy
dt <- DT
# Making new columns on the copy
dt[, `:=`(feature, factor(dt$feature.name))]
dt[, `:=`(activity, factor(dt$activity.name))]
# Is the feature from the Time domain or the Frequency domain?
levels <- matrix(1:2, nrow = 2)
logical <- matrix(c(grepl("^t", dt$feature), grepl("^f", dt$feature)), ncol = 2)
dt$Domain <- factor(logical %*% levels, labels = c("Time", "Freq"))
# Was the feature measured on Accelerometer or Gyroscope?
levels <- matrix(1:2, nrow = 2)
logical <- matrix(c(grepl("Acc", dt$feature), grepl("Gyro", dt$feature)), ncol = 2)
dt$Instrument <- factor(logical %*% levels, labels = c("Accelerometer", "Gyroscope"))
# Was the Acceleration due to Gravity or Body (other force)?
levels <- matrix(1:2, nrow = 2)
logical <- matrix(c(grepl("BodyAcc", dt$feature), grepl("GravityAcc", dt$feature)), ncol = 2)
dt$Acceleration <- factor(logical %*% levels, labels = c(NA, "Body", "Gravity"))
# The statistics - mean and std?
logical <- matrix(c(grepl("mean()", dt$feature), grepl("std()", dt$feature)), ncol = 2)
dt$Statistic <- factor(logical %*% levels, labels = c("Mean", "SD"))
# Features on One category - 'Jerk', 'Magnitude'
dt$Jerk <- factor(grepl("Jerk", dt$feature), labels = c(NA, "Jerk"))
dt$Magnitude <- factor(grepl("Mag", dt$feature), labels = c(NA, "Magnitude"))
# Axial variables, 3-D:
levels <- matrix(1:3, 3)
logical <- matrix(c(grepl("-X", dt$feature), grepl("-Y", dt$feature), grepl("-Z", dt$feature)), ncol = 3)
dt$Axis <- factor(logical %*% levels, labels = c(NA, "X", "Y", "Z"))
# Create the tidy dataset
setkey(dt, subject, activity, Domain, Instrument, Acceleration, Jerk, Magnitude, Statistic, Axis)
TIDY <- dt[, list(count = .N, average = mean(value)), by = key(dt)]

## Save the TIDY dataset
write.table(TIDY, "./TIDY_HumanActivity.txt", quote = FALSE, sep = "\t", row.names = FALSE)
write.csv(TIDY, "./TIDY_HumanActivity.csv", quote = FALSE, row.names = FALSE)