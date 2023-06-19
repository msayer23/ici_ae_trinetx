# ici_ae_trinetx
#######Raw files utilized from trinetx

###diagnosis.csv file
#this file is the raw file from trinetx, listing every icd-9 and 10 code occuring for each patient in the data set

###medication_ingredient.csv
#file of every medication a patient received, provides start date and medication code

###procedure.csv
#this is a raw file from trinetx, providing every documented procedure and the date they occur

###patient.csv
#contains patient background info like date of birth, death, race/ethnicity, region etc. 


#######Processed files created from trinetx raw files

###all_ici_rows_061323.csv
#this file comes from the medication ingredient file and the procedure file, it has every instance of ici occuring in the data set, where each row is an ici administration.
#only patients with neoplasm are included in this data set. The dates of ici administration are not filtered in this file

###agg_all_ici_cols_demographic_061323.csv
#this file contains an isolated row for each patient, with columns for each ici administration. additoinally attached is the patient demographic data
#this limits patients taking ici therapy to the end of 2021 only, only neoplasm pts

###all_ici_demo_startdates_neo.csv
#related to agg_all_ici_cols_demographic_061323.csv, contains the listed ici start date for each prospective ici for a patient, even if they took more than 1
#only neoplasm dx patients till end of 2021


###charleston_scores.csv#this file provides each patient ID, whether or not they have dx codes matching each prospective charleston criteria, and their charelston score. These patients are only ici patients#who took them up to the end of 2021

###oncdx_ids.csv#this file provides patient id's of all patients explicitly having some sort of neoplasm dx code





######R files utilized to create data sets and results

###charleston_score.R
#this file utilizes the diagnosis.csv file as a starting point.
#this file utilizes basic R functions, dplyr, and the comorbitity package
#this file ultimately creates a table listing each patient, and several columns with 1s and 0s indicating whether or not a patient has dx codes matching one of the charleston categories
#utilized in the scoring system. finally, it tabulates the charleston score for each prospective patient as well

###neoplasm_pts.R
#this file utilizes the diagnosis.csv file as a starting point.
#this file utilizes base R, dplyr, and stringr packages
#this file ultimately creates a subset of patient ids that explicitly have some sort of neoplasm dx code, creating the oncdx_ids.csv

###Every_ICI_Columns.R
#multiple raws files are utilized in this  code including medication_ingredient.csv and procedure.csv, 
#this files utilizes a variety of R packages including:base R, dplyr, and data.table
#this file creates a vareity of files. first it aggregates medication and procedure files to create all_ici_rows_061323.csv, which has row for each ici administration and its timing
#additionally it creates agg_all_ici_cols_demographic_061323.csv, which has a singular row for each patient, and a column represent each ici administration
#finally, this code creates ll_ici_demo_startdates_neo.csv, including additionally info on the first time a patient received each prospective ici. resulting csv files
#all_ici_rows_061323.csv and agg_all_ici_cols_demographic_061323.csv are exclusively neoplasm dx patients and icis up to end of 2021




######Tables/figures of interest
