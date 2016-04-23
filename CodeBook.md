
Getting and Cleaning Data Course Project CodeBook
================================================= 

Url For Data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
* run_analysis.R script performs the following steps to clean the data:   
 1. Read X_train.txt, y_train.txt and subject_train.txt from the "./data/train" folder and store them in *dtTrain*, *dtActivityTrain* and *dtSubjectTrain* variables respectively.       
 2. Read X_test.txt, y_test.txt and subject_test.txt from the "./data/test" folder and store them in *dtTest*, *dtActivityTest* and *dtSubjectTest* variables respectively.  
 3. Concatenate *dtTrain* and *dtTest* to form *dtTest*, concatenate *dtActivityTrain* and *dtActivityTest* to *dtActivity*, concatenate *dtSubjectTrain* and *dtSubjectTest* to *dtSubject* 
 4. Read the features.txt file from the "/data" folder and store the data in a variable called *dtFeatures*. We only extract the measurements on the mean and standard deviation. This results in a 66 indices list. We get a subset of *joinData* with the 66 corresponding columns.  
 5. Read the activity_labels.txt file from the "./data"" folder and store the data in a variable called *dtActivityNames*.  
 7. Clean the activity names in the second column of *dtActivityNames*. We first make all names to lower cases. If the name has an underscore between letters, we remove the underscore and capitalize the letter immediately after the underscore.  
 8. Now merge the columns.
 11. Finally, generate a second independent tidy data set with the average of each measurement for each activity and each subject. 
 

