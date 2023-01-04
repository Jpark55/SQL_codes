# SQL_codes

Reports created due to limitations of default report builder in BytePro.

temp tables used due to data spread out in multiple tables.
custom fields created in Byte are grouped into a few tables by data type. 



### Broker watch list.sql

- report created to track broker watch list on two data servers. 
- counts loans funded / audited
- flags when the required number of loans have been audited (5/10 files)
- audited loans are listed at the end to ensure data accuracy. 

### QC audit findings list.sql

- report created as summary of all qc audit findings on two data servers.
- to be used a part of performance evaulation of underwriters/loan programs
