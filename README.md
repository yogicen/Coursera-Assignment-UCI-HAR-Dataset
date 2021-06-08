# Coursera-Assignment-UCI-HAR-Dataset

## Code Book
test_set = extracted from X_test.txt
train_set = extracted from X_train.txt
test_label = extracted from y_test.txt
train_label = extracted from y_test.txt
test_subject = extracted from subject_test.txt
train_subject = extracted from subject_test.txt

all_set = combining rows from test_set and train_set
all_label = combining rows from test_label and train_label
all_subject = combining rows from test_subject and train_subject
all_data = combining columns from all_set, all_label and all_subject

features = extracted from features.txt
wanted_column = chosen column with mean and std
result = all_data by chosen column

activity_labels = extracted from activity_labels.txt

DT = merging activity_labels, result and features
dt = copy of DT

levels = for matrix multiplication when creating new columns
logical = for matrix multiplication when creating new columns


## How does it work?
### The Objectives
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set.
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### 1
Merge the training and test data set using rbind and cbind

### 2
Use grepl to identify which rows contain mean() and std()
Create new column which rows containing V + feature.number to match the column names in all_data
Get all the data from the wanted column

### 3
Extract activity_labels and put the appropriate column names

### 4
Merge activity_labels and result
Melt the merged table
Merge the merged table with features

### 5
Make a copy of the previously merged table
Add various new columns to the dataset by feature column
Create the new tidy dataset with count and average
