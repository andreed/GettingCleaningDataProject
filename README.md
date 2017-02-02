# GettingCleaningDataProject
Assignment Project for getting and cleaning data

## Input Data
The input data provided added up to about 90 MB (already letting out the data in the directories "inertial signals" which aren't needed here.
Due to this, I decided not to include the data into the github repo. My script assumes, that the file structure as provided by the download is stored in the working directory. 
The script works, when there is a directory UCIHARDataset with the files underneath (so the zip-file from the download has been unzipped to the working directory).

## Prerequisites
The script uses functions from (at least) the following packages which are loaded at the beginning of the script. Installation has to be done before starting the script
* readr
* dplyr

## Processing Sequence
First, the two packages readr and dplyr are loaded.
Then, the directory is set to the directory "UCIHARDataset" in the current working directory.

### Function "read_files_to_df"
The function "read_files_to_df" encapsulates the logic to read in the files in the sub directories "train" and "test". As both directories contain the same structure of files, only with different names, putting this into a function may save some lines of code.
The function requires four arguments:
* directory must contain the directory, where the directories "test" and "train" are stored
* filename must contain either "test" or "train"
* col_names has to contain a vector with the column names of file X_*.txt
* activity_lbls has to contain a data frame with the activity ids and the lables

Within that function, the following is processed:
* File X_*.txt (measurements) is read into a data frame df_x. The file path and name are pasted together using the arguments "directory" and "filename". 
* File y_*.txt (activities) is read into a data frame. 
* File subject_*.txt (subjects) is read into data frame df_subject.
* In the next step, all three data frames containing the measurements (df_x), the activities (df_y), and the subjects (df_subject) are added together with cbind.

Until now, no further alteration has been done to the data, as I learned that at least merge() will change the sorting order (and cbind-ing reordered data would have made the data useless) and I wanted to avoid any unwanted change to the data. All selecting and merging takes place in the following lines
* The data frame is then reduced to only those columns, that contain "mean_" or "std_" in their names. I don't take the columns that contain "meanFreq" as I think they are not required. In a real life scenario, I would have asked the team, whether these columns are required. In this step it is important to keep the columns "activity_id" and "subject"
* The data frame is then merged with a data frame containing the labels of the different activities. merge() reorders the data frame, therefore this step can only be done at this point of time.
* Now, we have two columns in the data frame, containing the same information: activity_id and activity. As the requirement said to have the activity label in the data set, the column activity_id is deselected.
* Now, the columns activity and subject are the last columns of the data frame. This isn't really bad, but for human readability it's nicer to have them at the beginning. Lines 36 and 39 take care about that.
* After coercing the data frame df_all to a data frame table, it is returned

### Skript
The rest of the script prepares the arguments for calling function read_files_to_df, calling it, and postprocessing the returned values. But one by one:
* The file "features.txt" contains the column names for file X_*.txt. This file is therefore read into a data frame. The first call to the mutate function is used to clear out the numbering at the beginning, the parentheses at the end and any whitespaces. The second call to the mutate function replaces the dashes "-" with underscores "_", which is done because of my personal preferences. During development I found out that some column names are duplicate, which throws warning messages during read_table. These are columns that are not required, however I decided to implement some logic to avoid this warning by first finding out, which rows contain duplicate entries (line 54) and then adding a number to those column names. As these columns are not used, I didn't spend too much time to find a more elegant solution.
* The file "activity_labels.txt" contains the labels of the activities. This file is read into a data frame and passed to read_files_to_df
* in lines 65 and 66, the files for "test" and "train" are read into two data frame tables using read_file_to_df
* both data frame tables are then put together using rbind. df_both now contains a tidy data frame for the measurements, activities and subjects
* the mean values per activity and subject are calculated with summarise_each with grouping the complete data frame table by these two columns before

Writing out the files
* I decided to write out one file with the column names to be able to refer to it from the codebook
* The two data files don't contain the column names.
