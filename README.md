# GettingCleaningDataProject
Assignment Project for getting and cleaning data

## Input Data
The input data provided added up to about 90 MB (already letting out the data in the directories "inertial signals" which aren't needed here.
Due to this, I decided not to include the data into the github repo. My script assumes, that the file structure as provided by the download are stored in another place. 
The script works, when the path is changed to the local settings.

## Prerequisites
The script uses functions from (at least) the following packages which are loaded at the beginning of the script. Installation has to be done before starting the script
* readr
* dplyr

Before running the script be also sure to have set the directory in line 6 to your local environmental settings.

## Processing Sequence
First, the two packages readr and dplyr are loaded.
Then, the directory is set to my local directory, where the data files are stored.

### Function "read_files_to_df"
The function "read_files_to_df" encapsulates the logic to read in the files in the sub directories "train" and "test". As both directories contain the same structure of files, only with different names, putting this into a function may save some lines of code.
The function requires four arguments:
* directory must contain the directory, where the directories "test" and "train" are stored
* filename must contain either "test" or "train"
* col_names has to contain a vector with the column names of file X_*.txt
* activity_lbls has to contain a data frame with the activity ids and the lables

Within that function, the following is processed:
* File X_*.txt (measurements) is read into a data frame df_x. The file path and name are pasted together using the arguments "directory" and "filename". This data frame is then reduced to only those columns, that contain "mean_" or "std_" in their names. I don't take the columns that contain "meanFreq" as I think they are not required. In a real life scenario, I would have asked the team, whether these columns are required.
* File y_*.txt (activities) is read into a data frame. This data frame is then merged with a data frame containing the labes of the different activities. In the last step working on this data frame, only the activity label is stored. After line 21 the data frame df_y only contains the list of acitivty labels matching the number of lines of data frame df_x.
* File subject_*.txt (subjects) is read into data frame df_subject. This data frame doesn't have to be changed in any way.
* As a last step, all three data frames containing the measurements (df_x), the activity labels (df_y), and the subjects (df_subject) are added together with cbind and changed to a data frame table.
* the data frame table df_all is returned

### Skript
The rest of the script prepares the arguments for calling function read_files_to_df, calling it, and postprocessing the returned values. But one by one:
* The file "features.txt" contains the column names for file X_*.txt. This file is therefore read into a data frame. The first call to the mutate function is used to clear out the numbering at the beginning, the parentheses at the end and any whitespaces. The second call to the mutate function replaces the dashes "-" with underscores "_", which is done because of my personal preferences. During development I found out that some column names are duplicate, which throws warning messages during read_table. These are columns that are not required, however I decided to implement some logic to avoid this warning by first finding out, which rows contain duplicate entries (line 45) and then adding a number to those column names. As these columns are not used, I didn't spend too much time to find a more elegant solution.
* The file "activity_labels.txt" contains the labels of the activities. This file is read into a data frame and passed to read_files_to_df
* in lines 56 and 57, the files for "test" and "train" are read into two data frame tables using read_file_to_df
* both data frame tables are then put together using rbind. df_both now contains a tidy data frame for the measurements, activities and subjects
* the mean values per activity and subject are calculated with summarise_each with grouping the complete data frame table by these two columns before

Writing out the files
* I decided to also write out one file with the column names to be able to refer to it from the codebook
* I also decided to write out the data frame tables to files containing the column names, as this makes it easier to import them again.
