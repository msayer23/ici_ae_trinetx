setwd("~/Desktop/trinetx")
install.packages("openxlsx")
library(openxlsx)
dx_table<- fread("~/Desktop/trinetx/diagnosis.csv")
neoplasm_pts<- read.csv("~/Desktop/trinetx/oncdx_ids.csv")
dx_table<- subset(dx_table, patient_id %in% neoplasm_pts$x)

dx_table<- dx_table[,c("patient_id", "code", "date")]

#Cardio code
dx_table$code<- as.character(trimws(tolower(dx_table$code)))
desired_values <- c("i40.1", "i40.8", "i40.9", "i51.4", "i30.0", "i30.8", "i30.9", "i31.2", 
                    "i31.3", "i31.31", "i31.39", "i31.4", "i31.8", "i31.9", "i32", 
                    "422.91", "422.93", "422.99", "422.90", "420.91", "420.99",
                    "420.90", "423.0", "423.3", "423.8", "423.9", "115.03", "115.13", "115.93","420.0")
# Subset the data frame based on the desired values in the "code" column
cardio_table <- subset(dx_table, code %in% desired_values)

cardio_table$dx_date_jul<- as.Date(as.character(cardio_table$date), format = "%Y%m%d")
reference_date<- as.Date("1970-01-01")
cardio_table$dx_date_jul<- as.numeric(difftime(cardio_table$dx_date_jul,reference_date, units= "days"))

cardio_table<- cardio_table[,c("patient_id","code","dx_date_jul")]

#additional data sets
ici_demographics<- read.csv("~/Desktop/trinetx/all_ici_demo_startdates_neo.csv")
ici_demographics<- ici_demographics %>% select(-c("X"))

cardio_combined<- merge(cardio_table,ici_demographics, by=c("patient_id"))

exclude_list <- lapply(cardio_combined[,'ici.1'], function(y) cardio_combined$dx_date_jul < y & cardio_combined$dx_date_jul >= (y - 180))
cardio_combined$exclude <- exclude_list 
removed_ids<- cardio_combined %>% filter(exclude== TRUE)
cardio_combined<- cardio_combined %>% filter(!patient_id %in% removed_ids$patient_id)
cardio_combined<- cardio_combined %>% select(-c("exclude"))

result_list <- lapply(cardio_combined[,'ici.1'], function(y) cardio_combined$dx_date_jul >= y & cardio_combined$dx_date_jul <= (y + 360))
result_matrix <- do.call(cbind, result_list)
cardio_combined$meets_criteria <- apply(result_matrix, 1, any)
cardio_combined_ae<- cardio_combined %>% filter(meets_criteria== TRUE)
cardio_combined_ae$unique<- paste(cardio_combined_ae$patient_id,cardio_combined_ae$code,cardio_combined_ae$dx_date_jul,sep=".")
cardio_combined_ae <- cardio_combined_ae %>% distinct(unique, .keep_all = TRUE)
write.csv(cardio_combined_ae,"~/Desktop/trinetx/all_cardio_ae_ici_demo_061323.csv")


