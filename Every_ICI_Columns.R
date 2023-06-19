setwd("~/Desktop/trinetx")
library(dplyr)
library(tidyr)
library(stringr)
library(data.table)
library(gtools)
library(ALL)

#patients with a neoplasm dx
neoplasm_pts<- read.csv("~/Desktop/trinetx/oncdx_ids.csv")

####Medication table
medication_table<- fread("~/Desktop/trinetx/medication_ingredient.csv")
medication_table<- medication_table %>% select("patient_id","code", "start_date")
medication_table$code<- trimws(tolower(medication_table$code))
codes<- c("1547545","1597876","2539967","1094833",
          "1792776", "1875534","1919503", "2058826","2596773")
medication_table_ici<- subset(medication_table, code %in% codes)

medication_table_ici[medication_table_ici== "1547545"]<- "pembrolizumab"
medication_table_ici[medication_table_ici== "1597876"]<- "nivolumab"
medication_table_ici[medication_table_ici== "2539967"]<- "dostarlimab"
medication_table_ici[medication_table_ici== "1094833"]<- "ipililumab"
medication_table_ici[medication_table_ici== "1792776"]<- "atezolizumab"
medication_table_ici[medication_table_ici== "1875534"]<- "avelumab"
medication_table_ici[medication_table_ici== "1919503"]<- "durvalumab"
medication_table_ici[medication_table_ici== "2058826"]<- "cemiplimab"
medication_table_ici[medication_table_ici== "2596773"]<- "relatlimab"
medication_table_ici$ici_julian_startdate<- as.Date(as.character(medication_table_ici$start_date), format = "%Y%m%d")
reference_date<- as.Date("1970-01-01")
medication_table_ici$ici_julian_startdate<- as.numeric(difftime(medication_table_ici$ici_julian_startdate,reference_date, units= "days"))
medication_table_ici<- medication_table_ici[,c("patient_id","code","start_date","ici_julian_startdate")]
colnames(medication_table_ici)<- c("patient_id","medication","ici_calendar_startdate","ici_julian_startdate")



procedure_table<- fread("~/Desktop/trinetx/procedure.csv")
procedure_table<- procedure_table %>% select(patient_id, code, date)
procedure_table$code<- trimws(tolower(procedure_table$code))
procedures<- c("j9271", "j9299", "j9272", "j9228", "j9022", "j9023", "j9173", "j9119")
procedure_table_ici<- subset(procedure_table, code %in% procedures)
procedure_table_ici[procedure_table_ici== "j9271"]<- "pembrolizumab"
procedure_table_ici[procedure_table_ici== "j9299"]<- "nivolumab"
procedure_table_ici[procedure_table_ici== "j9272"]<- "dostarlimab"
procedure_table_ici[procedure_table_ici== "j9228"]<- "ipililumab"
procedure_table_ici[procedure_table_ici== "j9022"]<- "atezolizumab"
procedure_table_ici[procedure_table_ici== "j9023"]<- "avelumab"   
procedure_table_ici[procedure_table_ici== "j9173"]<- "durvalumab"
procedure_table_ici[procedure_table_ici== "j9119"]<- "cemiplimab"

procedure_table_ici$ici_julian_startdate<- as.Date(as.character(procedure_table_ici$date), format = "%Y%m%d")
reference_date<- as.Date("1970-01-01")
procedure_table_ici$ici_julian_startdate<- as.numeric(difftime(procedure_table_ici$ici_julian_startdate,reference_date, units= "days"))
colnames(procedure_table_ici)<- c("patient_id", "medication", "ici_calendar_startdate", "ici_julian_startdate")


all_ici<- smartbind(medication_table_ici, procedure_table_ici)
all_ici$unique<- paste(all_ici$patient_id,all_ici$medication,all_ici$ici_julian_startdate)
all_ici_unique <- all_ici %>% distinct(unique, .keep_all = TRUE)
all_ici_unique<- all_ici_unique %>% select(patient_id,medication,ici_calendar_startdate,ici_julian_startdate)
all_ici_unique<- subset(all_ici_unique, patient_id %in% neoplasm_pts$x)

write.csv(all_ici_unique, "~/Desktop/trinetx/all_ici_rows_061323.csv")



####Every unique administration of ICI up to 12-31-2021,julain date 18992
all_ici_unique<- read.csv("~/Desktop/trinetx/all_ici_rows_061323.csv")
all_ici_unique<- all_ici_unique %>% filter(ici_julian_startdate<18993)
all_ici_unique<- all_ici_unique %>% select(patient_id,ici_julian_startdate) %>% group_by(patient_id) %>% arrange(ici_julian_startdate,.by_group = TRUE) %>% as.data.frame()
all_ici_unique$ici_julian_startdate<- as.numeric(all_ici_unique$ici_julian_startdate)
all_ici_unique<- setDT(all_ici_unique)[,counter := seq_len(.N),by=.(patient_id)]
all_ici_unique$ici_num<- as.character(paste("ici",all_ici_unique$counter, sep = "."))
all_ici_unique<- all_ici_unique %>% select(-c("counter"))
all_ici_unique_col<- all_ici_unique %>% pivot_wider(values_from = ici_julian_startdate,names_from = ici_num )
all_ici_unique_col<- as.data.frame(all_ici_unique_col)
all_ici_unique_col<- aggregate(all_ici_unique_col[,2:308], by= list(all_ici_unique_col$patient_id),FUN= max)
names(all_ici_unique_col)[names(all_ici_unique_col) == 'Group.1'] <- 'patient_id'

demographics<- read.csv("~/Desktop/trinetx/patient.csv")
all_info<- merge(all_ici_unique_col, demographics, all.x = TRUE, by=c("patient_id"))

write.csv(all_info,"~/Desktop/trinetx/agg_all_ici_cols_demographic_061323.csv")



###start date of each respective ici
all_ici_start<- read.csv("~/Desktop/trinetx/all_ici_rows_061323.csv")
all_ici_start<- all_ici_start %>% filter(ici_julian_startdate<18993)
all_ici_start<- all_ici_start[,c("patient_id",    "medication", "ici_calendar_startdate", "ici_julian_startdate")]
length(unique(all_ici_start$patient_id))
all_ici_start_min<- aggregate(all_ici_start$ici_julian_startdate, by= list(all_ici_start$patient_id,all_ici_start$medication),FUN= min)
colnames(all_ici_start_min)<- c("patient_id","medication","first_medication_jul_date")
all_ici_start_min<- all_ici_start_min %>% group_by(patient_id,medication) %>% arrange(first_medication_jul_date,.by_group = TRUE) %>% as.data.frame()
all_ici_start_min<- all_ici_start_min %>% pivot_wider(values_from = first_medication_jul_date,names_from = medication) %>% as.data.frame()

all_info<- read.csv("~/Desktop/trinetx/agg_all_ici_cols_demographic_061323.csv")

start_date_incidence<- merge(all_info,all_ici_start_min,by= c("patient_id"))
start_date_incidence<- start_date_incidence[,-c(2)]
start_date_incidence<- start_date_incidence[,c(1,309:326,2:308)]

write.csv(start_date_incidence, "~/Desktop/trinetx/all_ici_demo_startdates_neo.csv")







###Columns including medication names, with may 1 2022 end date
all_ici_defined<- read.csv("~/Desktop/trinetx/all_ici_unique_060423.csv")
all_ici_defined$ici_julian_startdate<- as.numeric(all_ici_defined$ici_julian_startdate)
all_ici_defined<- all_ici_defined %>% filter(ici_julian_startdate<19114)
all_ici_defined<- all_ici_defined %>% select(patient_id,medication,ici_julian_startdate) %>% group_by(patient_id) %>% arrange(ici_julian_startdate,.by_group = TRUE) %>% as.data.frame()
all_ici_defined$med_date<- paste(all_ici_defined$medication,all_ici_defined$ici_julian_startdate)
all_ici_defined<- all_ici_defined %>% select(patient_id,med_date)
all_ici_defined<- setDT(all_ici_defined)[,counter := seq_len(.N),by=.(patient_id)]
all_ici_defined$med_num<- paste("med",all_ici_defined$counter)
all_ici_defined<- all_ici_defined %>% select(-c("counter"))
all_ici_defined_col<- all_ici_defined %>% pivot_wider(values_from = med_date,names_from = med_num) %>% as.data.frame()
all_ici_defined_col<- aggregate(all_ici_defined_col[,c(2:406)], by=list(all_ici_defined_col$patient_id), FUN = function(x) paste(na.omit(x), collapse = ", "))
blah<- all_ici_defined_col %>% rowwise() %>% 
  mutate(aggvalue= paste(na.omit(c_across(starts_with("med"))), collapse=","))
all_ici_defined_col<- cbind(all_ici_defined_col$patient_id,blah$aggvalue)
colnames(all_ici_defined_col)<- c("patient_id","meds_list")





