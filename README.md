# ici_ae_trinetx
#######Raw files utilized from trinetx
###diagnosis.csv file
#this file is the raw file from trinetx, listing every icd-9 and 10 code occuring for each patient in the data set

#######Processed files created from trinetx raw files
###charleston_scores.csv
#this file provides each patient ID, whether or not they have dx codes matching each prospective charleston criteria, and their charelston score. These patients are only ici patients
#who took them up to the end of 2021
###oncdx_ids.csv
#this file provides patient id's of all patients explicitly having some sort of neoplasm dx code



######R files utilized to create data sets and results
###charleston_score.R
#this file utilizes the diagnosis.csv file as a starting point.
#this file utilizes basic R functions, dplyr, and the comorbitity package
#this file ultimately creates a table listing each patient, and several columns with 1s and 0s indicating whether or not a patient has dx codes matching one of the charleston categories
#utilized in the scoring system. finally, it tabulates the charleston score for each prospective patient as well
###neoplasm_pts.R
#this file utilizes the diagnosis.csv file as a starting point.
#this file utilizes base R, dplyr, and stringr packages
#this file ultimately creates a subset of patient ids that explicitly have some sort of neoplasm dx code



######Tables/figures of interest
