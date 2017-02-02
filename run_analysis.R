# first, load all librarys
library(readr)
library(dplyr)

# I stored the data files not in the github clone to avoid them being uploaded to github 
directory <- "C:/Users/Andre/Documents/Coursera/data/UCIHARDataset/"

# one function to read in one set of files and return an consolidated
# dataframe - the parameter "filename" should either contain test or train
read_files_to_df <- function(directory, filename, col_names, activity_lbls) {
    
    # read in the files in three dataframes    
    
    # -1- Read in and work on the measurements
    df_x <- read_table(paste0(directory,filename,"/X_",filename,".txt"),
                       col_names=x_cols$features_clr)
    # get only the colums with the mean or the standard deviation 
    df_x <- select(df_x, matches("mean_|std_"))    
    
    # -2- Read in and enrich the acitivities
    df_y <- read_table(paste0(directory,filename,"/y_",filename,".txt"),
                       col_names="activity_id")
    df_y <- merge(df_y,activity_lbls,all.x=TRUE)
    df_y <- select(df_y,activity)
    
    # -3- Read in the subject file
    df_subject <- read_table(paste0(directory,filename,"/subject_",filename,".txt"),
                             col_names="subject")


    
    df_all <- tbl_df(cbind(df_y, df_subject, df_x))
    df_all
}

# first, get the column names for the file X_xxx, to achieve this, read in the features.txt
# this can be used for both files X_test.txt and X_train.txt, so I do it once outside the function
x_cols <- read_table(paste0(directory,"features.txt"),col_names="features")
# now, get rid of the numbering and the parentheses in the texts
x_cols <- mutate(x_cols,features_clr=gsub("^[0-9]+|\\()| ","",features))
# personnally, I prefer underscores over dashes, so let's substitute them
x_cols <- mutate(x_cols,features_clr=gsub("-","_",features_clr))
# It appears, that some entries in the features file are duplicate. 
# Those have to be made unique, otherwise read_table gives a warning
x_cols <- cbind(x_cols,duplicated(x_cols$features_clr))
for (i in 1:nrow(x_cols)) {
    if (x_cols[i,3]==TRUE) {
        # Just add the for counter here, as none of those columns will be required in the dataset
        x_cols[i,2] <- paste0(x_cols[i,2],"_",i) 
    }
}
# Now, get the activities from the file activity_lables.txt
activities <- read_table(paste0(directory,"activity_labels.txt"),
                         col_names=c("activity_id","activity"))

df_test <- read_files_to_df(directory,"test",x_cols$features_clr,activities)
df_train <- read_files_to_df(directory,"train",x_cols$features_clr,activities)

df_both <- rbind(df_test, df_train)

# Now, calculate the mean of each column per activity and subject
df_mean <- df_both %>% group_by(activity,subject) %>% summarise_each(funs(mean))

# at last, write out the files, use the current working directory
# write out a file with the column names
df_col_names <- as.data.frame(names(df_both))
write_tsv(df_col_names,"./Col_names.txt",col_names=FALSE)
# write out the file with both data
write_tsv(df_both,"./train_text.txt",col_names=FALSE)
# write out the file with the means
write_tsv(df_mean,"./train_text_mean.txt",col_names=FALSE)