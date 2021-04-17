library(xml2)
library(rvest)
library(dplyr)

library(tidyr)
library(splitstackshape)
library(stringr)
#library(tidyr)

# url <- "http://www.indiaplants.com/plant-index.php"
# 
# html_dt<-url %>%
#   read_html()  
# 
# 
# tbl<-
# html_dt%>%
#   html_table(header = T,fill = T)
# 
# tb1<-tbl[[1]]
# 
# 
# ?html_table



#Address of the login webpage
login<-"http://www.indiaplants.com/customer-login.php"

#create a web session with the desired login address
pgsession<-html_session(login)
pgform<-html_form(pgsession)[[2]]  #in this case the submit is the 2nd form
filled_form<-set_values(pgform, userName="akt.ankit7@gmail.com", userPwd="joystick")

s<-submit_form(pgsession, filled_form,submit = "action")

pl <-
  s %>%
  follow_link(i=16)

f <- list()

init <- 1000

for( link in 1000:1200)
{
  

h<-
pl %>%
  jump_to(url=paste0("http://www.indiaplants.com/plant-details.php?plant=",link)) %>%
  read_html()

#h %>%
 # html_structure()

# h_text<-
#   final_node %>%
#   html_text()

tryCatch(
   
final_node <-  
h %>%
  xml_child(search = 2) %>%
  xml_child(search = 2) %>%
  xml_child(search = 4) %>%
  xml_child(search = 6) 
,error=function(e){})
 #xml_children()

l<-
final_node %>%
  xml_child(1) %>%
  as_list()

text1<-
final_node %>%
  xml_child(1) %>%
  html_text()



common_name<-
gsub('[\t\n]', '', text1)


df.common<-as.data.frame(common_name)


wide_df.common<-cSplit(df.common,splitCols = "common_name",sep = ": ","y",direction = "wide",fixed = T,drop = T)

text3<-
  final_node %>%
  xml_child(3) %>%
  html_text()

details<-
  gsub('[\t\n]', '', text3)


df<-as.data.frame(details)


wide_df<-cSplit(df,splitCols = "details",sep = ": ","y",direction = "wide",fixed = T,drop = T)

final_df <- cbind(wide_df.common,wide_df)

f[[link-init +1]] <- final_df

}


full.df<-
rbind_list(f)

distinct.df<-
full.df %>%
  distinct()


