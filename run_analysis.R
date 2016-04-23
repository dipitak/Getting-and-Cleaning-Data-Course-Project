
#Load the file to datatable
pathIn ="folder location..."

dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest  <- fread(file.path(pathIn, "test" , "subject_test.txt" ))

dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest  <- fread(file.path(pathIn, "test" , "Y_test.txt" ))

#function: read data from file and convert to datatable
fileToDataTable <- function (f) {
        rdTable <- read.table(f)
        dt <- data.table(rdTable)
}

#function: show the property of datatable
printDataProperty <- function(dt){
        
        print("Dimesion")
        print(dim(dt))
        dtDim <- dim(dt)
        print("Column Names")
        print(names(dt))
        print("First 3 rows")
        print(head(dt,3))
        
        if(dim(dt)[2]==1){
                print("Data variation")
                print(table(dt))
        }
        
}

printDataProperty(dtTest)

dtTrain <- fileToDataTable(file.path(pathIn, "train", "X_train.txt"))
dtTest  <- fileToDataTable(file.path(pathIn, "test" , "X_test.txt" ))

########## 1. Merge the training and the test sets ##########

#Merge Subject
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
#change colum name V1 to subject
setnames(dtSubject, "V1", "subject")

#Merge Activity
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
#change colum name V1 to activityNum
setnames(dtActivity, "V1", "activityNum")

#Merge Data
dt <- rbind(dtTrain, dtTest)

printDataProperty(dtSubject)

#Merge Subject  and Activity
dtMSubject <- cbind(dtSubject, dtActivity)
printDataProperty(dtMSubject)

#Merge Subject, Activity and data
dtM <- cbind(dtMSubject, dt)
printDataProperty(dtMSubject)

#Set key to subject and activityNum in dtM
setkey(dtM, subject, activityNum)



########## 2. Extract only the mean and standard deviation ###########

dtFeatures <- fread(file.path(pathIn, "features.txt"))
printDataProperty(dtFeatures)
#change column Name v1 to featureNum and v2 to featureName
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))


#Subset only measurements for the mean and standard deviation.
#get the row having the word mean or std in featureName
dtFeaturesSub <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
printDataProperty(dtFeaturesSub)

#add 1 column featureCode: combination of 'v' and featureNum
dtFeaturesSub$featureCode <- dtFeaturesSub[, paste0("V", featureNum)]
printDataProperty(dtFeaturesSub)

# get the data having the feature code(i.e mean or std featureName)
select <- c(key(dtM), dtFeaturesSub$featureCode)
dtM1 <- dtM[, select, with=FALSE]
printDataProperty(dtM1)


########## 3. Use descriptive activity names #############

dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))

printDataProperty(dtActivityNames)
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))

#merge the activity label
dtM2 <- merge(dtM1, dtActivityNames, by="activityNum", all.x=TRUE)

setkey(dtM2, subject, activityNum, activityName)

# Now, Melt data table to reshape it from a short and wide format to a tall and narrow format.
dtM3 <- data.table(melt(dtM2, key(dtM2), variable.name="featureCode"))
printDataProperty(dtM3)

# merge activity name.
dtM4 <- merge(dtM3, dtFeaturesSub[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=TRUE)


# Create a new variable, `activity` that is equivalent to `activityName` as a factor class.
# Create a new variable, `feature` that is equivalent to `featureName` as a factor class.

dtM4$activity <- factor(dtM4$activityName)
dtM4$feature <- factor(dtM4$featureName)
printDataProperty(dtM4)

# now seperate features from `featureName` using the helper function `grepthis`
grepthis <- function (regex,dt) {
        grepl(regex, dt$feature)
}

############# 4. Appropriately labels the data set with descriptive variable names. ##########3
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("^t",dtM4), grepthis("^f",dtM4)), ncol=nrow(y))

dtM4$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
x <- matrix(c(grepthis("Acc",dtM4), grepthis("Gyro",dtM4)), ncol=nrow(y))


dtM4$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc",dtM4), grepthis("GravityAcc",dtM4)), ncol=nrow(y))

dtM4$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()",dtM4), grepthis("std()",dtM4)), ncol=nrow(y))
printDataProperty(dtM4)

x <- matrix(c(grepthis("mean()",dtM4), grepthis("std()",dtM4)), ncol=nrow(y))
dtM4$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))
printDataProperty(dtM4)

## Features with 1 category
dtM4$featJerk <- factor(grepthis("Jerk",dtM4), labels=c(NA, "Jerk"))
dtM4$featMagnitude <- factor(grepthis("Mag",dtM4), labels=c(NA, "Magnitude"))
printDataProperty(dtM4)

## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(grepthis("-X",dtM4), grepthis("-Y",dtM4), grepthis("-Z",dtM4)), ncol=nrow(y))
dtM4$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))


# check if all possible combinations of `feature` are accounted 
# for by all possible combinations of the factor class variables

r1 <- nrow(dtM4[, .N, by=c("feature")])
r2 <- nrow(dtM4[, .N, by=c("featDomain", "featAcceleration", "featInstrument", "featJerk", "featMagnitude", "featVariable", "featAxis")])
r1 == r2 #so accounted for all possible combinations. `feature` is now redundant.


############## 5. From the data set in step 4, creates a second, 
############## independent tidy data set with the average of each variable for each activity and each subject.
# now Create a tidy data set
        
# create a data set with the average of each variable for each activity and each subject.
# set the column to key 
setkey(dtM4, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dtM4[, list(count = .N, average = mean(value)), by=key(dtM4)]


write.table(dtTidy,"tidyData.txt",row.name = FALSE)

