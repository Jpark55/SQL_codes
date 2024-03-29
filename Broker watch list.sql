/*
using below CTEs to create a table of broker's that are on the watch list. 
counts the number of loan per broker that funded / audited. 
lists loans that are audites to ensure accuracy and also flags when broker pipeline should be reviewed to remove from broker watch list


ST = loan info
BWL = broker watch list tags
audit = qc audit clear dates 
VOE = all 3 voe status fields
VOD = all 3 vod status fields
bwdr = Broker Watch Date and Reason
fp = files with pfqc/verifications pass
*/


SELECT  'WS' as CH
		,[BL].[Name]
		,cast([Code] as varchar) as Code
		,[LegalName]
		,case when status = 0  then '' when status = 1  then 'Approved' when status = 2  then 'Inactive - Lack of Activity' when status = 3  then 'Inactive - Lack of Licensure' when status = 4  then 'Inactive - Compliance' when status = 5  then 'Suspended' when status = 6  then 'Terminated'  when status = 7  then 'Approve - Conditional' when status = 8  then 'Pospect' when status = 9  then 'Pending' when status = 10 then 'Declined' when status = 11 then 'Cancelled' else null end as Status
		,convert(varchar,[StatusDate],101) as StatusDate
		,[AccountExecUserName] as 'AE'
		,a.[reason]
		,convert(varchar,[bwdate],101) as 'BW date'
		,[submitted]
		,convert(varchar,[lstsubmit],101) as last_submit
		,[funded]
		,convert(varchar,[lstfund],101) as last_fund
		,[Verifications passed] as 'Verif passed'
		--,[Verifications failed] as 'Verif failed'
		,[fund after watch]
		,[audited after watch]
		,[qm audited after watch]
		,[non qm audited after watch]
		,[times]
		,case 
			when [times] = '2' and [Verifications passed] < '10' then '2nd time on BWL need 10 to release'
			when [times] = '1' and [Verifications passed] < '5'  then '1st time on BWL need 5 to release'
			when (([times] = '2' and [Verifications passed] >= '10' ) or ([times] = '1' and [Verifications passed] >= '5')) then 'review for removal from watchlist'
			else 'need additional review' end as note
		,[file list]
FROM
	(
		select [Name]
				,[bwdate]
				--,[reason]
				,count([submitted]) as submitted
				,max([submitted]) as lstsubmit
				,count([funded]) as funded
				,max([funded]) as lstfund
				,case when (sum([watch]) > 0) then 'yes' else 'no' end as watch_list
				,(sum( case when [funded] > [bwdate] then 1 else 0 end )) as 'fund after watch'
				,(sum( case when ([pfqc audited date] > [bwdate]) then 1 else 0 end )) as 'audited after watch'
				,(sum( case when ([pfqc audited date] > [bwdate] and [qm] = 'qm') then 1 else 0 end )) as 'qm audited after watch'
				,(sum( case when ([pfqc audited date] > [bwdate] and [qm] = 'non_qm') then 1 else 0 end )) as 'non qm audited after watch'
				,(sum( case when (concat([voestatus],[vodstatus]) = 'passedpassed' and [pfqc audited date] > [bwdate]) then 1 
							when (concat([voestatus],[vodstatus]) = 'passed' and [pfqc audited date] > [bwdate] and [loanprogramcode] like 'ai%') then 1
							else 0 end )) as 'Verifications passed'
				,(sum( case when (concat([voestatus],[vodstatus]) like '%fail%' and [pfqc audited date] > [bwdate]) then 1 else 0 end )) as 'Verifications failed'
		FROM ( SELECT * FROM LIST JOIN (SELECT [NAME] as bln, MAX([BWSDATE]) as bwdate from list group by [Name]) bd on [list].[Name]=[bd].bln ) b
		group by [Name],[bwdate]--,[reason]
	) BL 
	join (select [name],[code],[legalname],[Status],[StatusDate],[AccountExecUserName],[OrganizationID] FROM [BytePro].[dbo].[Organization] with (nolock) ) BR on [BL].[name] = [BR].[name]
	left join (select [name],count(bwsdate) as times from (select [name],[bwsdate] from bwdr where [bwsdate] not in (select [bwsdate] from bwdr where bwsdate = '10-01-2021') group by [Name],[bwsdate]) t group by [name]) c on c.Name = BL.name
	left join (select [name],stuff((Select ', ' + reason	From bwdr t2 where t1.Name=t2.Name and [reason] is not null and [bwsdate] <> '10-01-2021' for xml path('')),1,2,'')[reason] From (select [name],[reason] from bwdr ) t1 group by [name] ) a on a.Name=BL.Name
	left join (select [name],stuff((Select ', ' + [filename] From fp t2 where t1.Name=t2.Name for xml path('')),1,2,'') [file list] From fp t1 group by [Name] ) f on f.Name=BL.Name
where ([watch_list] = 'yes')

union

SELECT 'Corr' as CH
		,[BL].[Name]
		,cast([Code] as varchar) as code
		,[LegalName]
		,case when status = 0  then '' when status = 1  then 'Approved' when status = 2  then 'Inactive - Lack of Activity' when status = 3  then 'Inactive - Lack of Licensure' when status = 4  then 'Inactive - Compliance' when status = 5  then 'Suspended' when status = 6  then 'Terminated'  when status = 7  then 'Approve - Conditional' when status = 8  then 'Pospect' when status = 9  then 'Pending' when status = 10 then 'Declined' when status = 11 then 'Cancelled' else null end as status
		,convert(varchar,[StatusDate],101) as StatusDate
		,[AccountExecUserName] as 'AE'
		,a.[reason]
		,convert(varchar,[bwdate],101) as 'BW date'
		,[submitted]
		,convert(varchar,[lstsubmit],101) as last_submit
		,[funded]
		,convert(varchar,[lstfund],101) as last_fund
		,[Verifications passed] as 'Verif passed'
		--,[Verifications failed] as 'Verif failed'
		,[fund after watch]
		,[audited after watch]
		,[qm audited after watch]
		,[non qm audited after watch]
		,[times]
		,case 
			when [times] = '2' and [Verifications passed] < '10' then '2nd time on BWL need 10 to release'
			when [times] = '1' and [Verifications passed] < '5'  then '1st time on BWL need 5 to release'
			when (([times] = '2' and [Verifications passed] >= '10' ) or ([times] = '1' and [Verifications passed] >= '5')) then 'review for removal from watchlist'
			else 'need additional review' end as note
		,[file list]
FROM
	(
		select [Name]
				,[bwdate]
				--,[reason]
				,count([submitted]) as submitted
				,max([submitted]) as lstsubmit
				,count([funded]) as funded
				,max([funded]) as lstfund
				,case when (sum([watch]) > 0) then 'yes' else 'no' end as watch_list
				,(sum( case when [funded] > [bwdate] then 1 else 0 end )) as 'fund after watch'
				,(sum( case when ([pfqc audited date] > [bwdate]) then 1 else 0 end )) as 'audited after watch'
				,(sum( case when ([pfqc audited date] > [bwdate] and [qm] = 'qm') then 1 else 0 end )) as 'qm audited after watch'
				,(sum( case when ([pfqc audited date] > [bwdate] and [qm] = 'non_qm') then 1 else 0 end )) as 'non qm audited after watch'
				,(sum( case when (concat([voestatus],[vodstatus]) = 'passedpassed' and [pfqc audited date] > [bwdate] ) then 1 
							when (concat([voestatus],[vodstatus]) = 'passed' and [pfqc audited date] > [bwdate] and [loanprogramcode] like 'ai%') then 1
							else 0 end )) as 'Verifications passed'
				,(sum( case when (concat([voestatus],[vodstatus]) like '%fail%' and [pfqc audited date] > [bwdate]) then 1 else 0 end )) as 'Verifications failed'
		FROM ( SELECT * FROM cLIST JOIN (SELECT [NAME] as bln, MAX([BWSDATE]) as bwdate from clist group by [Name]) bd on [clist].[Name]=[bd].bln ) b
		group by [Name],[bwdate]--,[reason]
	) BL 
	join (select [name],[code],[legalname],[Status],[StatusDate],[AccountExecUserName],[OrganizationID] FROM [BytePro].[dbo].[Organization] with (nolock) ) BR on [BL].[name] = [BR].[name]
	left join (select [name],count(bwsdate) as times from (select [name],[bwsdate] from bwdr where [bwsdate] not in (select [bwsdate] from bwdr where bwsdate = '10-01-2021') group by [Name],[bwsdate]) t group by [name]) c on c.Name = BL.name
	left join (select [name],stuff((Select ', ' + reason	From bwdr t2 where t1.Name=t2.Name and [reason] is not null and [bwsdate] <> '10-01-2021' for xml path('')),1,2,'')[reason] From (select [name],[reason] from bwdr ) t1 group by [name] ) a on a.Name=BL.Name
	left join (select [name],stuff((Select ', ' + [filename] From fp t2 where t1.Name=t2.Name for xml path('')),1,2,'') [file list] From  fp t1 group by [Name] ) f on f.Name=BL.Name
where ([watch_list] = 'yes') 


order by [Name]
