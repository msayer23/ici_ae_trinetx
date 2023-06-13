#Table

dx_table<- fread("~/Desktop/trinetx/diagnosis.csv")

#Cardio code
dx_table$code<- as.character(trimws(tolower(dx_table$code)))
dx_table<- dx_table[,c("patient_id", "code_system","code","date")]

#icd-9 codes
dx_table_9<- dx_table %>% filter(code_system== "ICD-9-CM")
dx_table_9$code<- as.numeric(dx_table_9$code)
dx_table_9_neoplasms<- dx_table_9 %>% filter(dx_table_9$code >= 140 & dx_table_9$code<240)

#icd-10 codes
dx_table_10<- dx_table %>% filter(code_system== "ICD-10-CM")
dx_table_10$code<- paste(" ",dx_table_10$code,sep="")


dx_table_10$neoplasms<- (str_detect(dx_table_10$code," c")|
                            str_detect(dx_table_10$code," d0") |
                            str_detect(dx_table_10$code," d1") |
                            str_detect(dx_table_10$code," d2") |
                            str_detect(dx_table_10$code," d3") |
                            str_detect(dx_table_10$code," d4") |
                            str_detect(dx_table_10$code," d5") |
                            str_detect(dx_table_10$code," d6") |
                            str_detect(dx_table_10$code," d7") |
                            str_detect(dx_table_10$code," d8") |
                            str_detect(dx_table_10$code," d9") |
                            str_detect(dx_table_10$code," d10") |
                            str_detect(dx_table_10$code," d11") |
                            str_detect(dx_table_10$code," d12") |
                            str_detect(dx_table_10$code," d13") |
                            str_detect(dx_table_10$code," d14") |
                            str_detect(dx_table_10$code," d15") |
                            str_detect(dx_table_10$code," d16") |
                            str_detect(dx_table_10$code," d17") |
                            str_detect(dx_table_10$code," d18") |
                            str_detect(dx_table_10$code," d19") |
                            str_detect(dx_table_10$code," d20") |
                            str_detect(dx_table_10$code," d21") |
                            str_detect(dx_table_10$code," d22") |
                            str_detect(dx_table_10$code," d23") |
                            str_detect(dx_table_10$code," d24") |
                            str_detect(dx_table_10$code," d25") |
                            str_detect(dx_table_10$code," d26") |
                            str_detect(dx_table_10$code," d27") |
                            str_detect(dx_table_10$code," d28") |
                            str_detect(dx_table_10$code," d29") |
                            str_detect(dx_table_10$code," d30") |
                            str_detect(dx_table_10$code," d31") |
                            str_detect(dx_table_10$code," d32") |
                            str_detect(dx_table_10$code," d33") |
                            str_detect(dx_table_10$code," d34") |
                            str_detect(dx_table_10$code," d35") |
                            str_detect(dx_table_10$code," d36") |
                            str_detect(dx_table_10$code," d37") |
                            str_detect(dx_table_10$code," d38") |
                            str_detect(dx_table_10$code," d39") |
                            str_detect(dx_table_10$code," d40") |
                            str_detect(dx_table_10$code," d41") |
                            str_detect(dx_table_10$code," d42") |
                            str_detect(dx_table_10$code," d43") |
                            str_detect(dx_table_10$code," d44") |
                            str_detect(dx_table_10$code," d45") |
                            str_detect(dx_table_10$code," d46") |
                            str_detect(dx_table_10$code," d47") |
                            str_detect(dx_table_10$code," d48") |
                            str_detect(dx_table_10$code," d49"))

dx_table_10_neoplasms<- dx_table_10 %>% filter(neoplasms== TRUE)


all<- smartbind(dx_table_9_neoplasms,dx_table_10_neoplasms)

patient_ids<- unique(all$patient_id)
write.csv(patient_ids,"~/Desktop/trinetx/oncdx_ids.csv")
