library(dplyr)

zip_file = "./dataset.zip"
file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(file_url, destfile = zip_file)

unzip(zipfile = zip_file, exdir = ".")

folder_path = "./UCI HAR Dataset" 

# training dataset
x_train <- read.table(sprintf("%s/train/X_train.txt",folder_path))
y_train <- read.table(sprintf("%s/train/y_train.txt",folder_path))
subject_train <- read.table(sprintf("%s/train/subject_train.txt",folder_path))

# test dataset
x_test <- read.table(sprintf("%s/test/X_test.txt",folder_path))
y_test <- read.table(sprintf("%s/test/y_test.txt",folder_path))
subject_test <- read.table(sprintf("%s/test/subject_test.txt",folder_path))

# features
features <- read.table(sprintf("%s/features.txt",folder_path))
# activity labels
activity_labels <- read.table(sprintf("%s/activity_labels.txt",folder_path))
colnames(activity_labels) <- c("activityID", "activityType")

# assign varialbe names
colnames(x_train) <- features[, 2]
colnames(y_train) <- "activityID"
colnames(subject_train) <- "subjectID"
colnames(x_test) <- features[, 2]
colnames(y_test) <- "activityID"
colnames(subject_test) <- "subjectID"

# merge
train <- cbind(y_train, subject_train, x_train)
test <- cbind(y_test, subject_test, x_test)
ds <- rbind(train, test)

# use measurements on the mean and sd
mean_and_std <- grepl("activityID|subjectID|mean\\(\\)|std\\(\\)", colnames(ds))
ds <- ds[, mean_and_std]

ds <- merge(ds, activity_labels, by = "activityID", all.x = TRUE)

colnames(ds) <- gsub("^t", "time", colnames(ds))
colnames(ds) <- gsub("^f", "frequency", colnames(ds))
colnames(ds) <- gsub("Acc", "Accelerometer", colnames(ds))
colnames(ds) <- gsub("Gyro", "Gyroscope", colnames(ds))
colnames(ds) <- gsub("Mag", "Magnitude", colnames(ds))
colnames(ds) <- gsub("BodyBody", "Body", colnames(ds))

# creating tidy set with averages
output_file = "tidy_set.txt"
tidy_set <- ds %>%
  group_by(subjectID, activityID, activityType) %>%
  summarise(across(everything(), ~ mean(.x, na.rm = TRUE)))
write.table(tidy_set, output_file, row.names = FALSE)
