# SQL_codes

Here are some SQL queries I've created over the years to help with by previous job functions. 

Reports created due to limitations of default report builder in BytePro.  
Two instances were created causing some issues/confusion when trying to get data.  
Some fields were used differently while some data had different names.

Temp tables used due to data spread out in multiple tables.  
Custom fields created in BytePro are grouped in two ways
- a *CustomFields* table which only holds a limited number of entries regardless of data type.
- *Extended**(DATA)**Value* tables by data type

---

### missing license.sql
- one of my first queries in 2019 to search for missing license info.
- data input of license was not standardized so many missing and incorrect inputs.
- a few varieties of the query was used to locate all incorrect data. 

### tsk_counts.sql
- a temporary table used until new employees became familiar with the task naming schema

### QC audit findings list.sql

- report created as summary of all qc audit findings on two data servers.
- to be used a part of performance evaulation of underwriters/loan programs

### Broker watch list.sql

- report created to track broker watch list on two data servers. 
- counts loans funded / audited.
- flags when the required number of loans have been audited (5/10 files).
- audited loans are listed on the far right the end to ensure data accuracy and re-review for removal from watch list.

