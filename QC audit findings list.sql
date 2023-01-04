declare @startdate date; 
declare @enddate   date; 
--set @enddate = case when datepart(day,getdate()) = 1 then DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1) else (dateadd(day, -1, getdate())) end;
--set @startdate = case when datepart(day,getdate()) = 1 then DATEADD(month, datediff(month, 0, getdate())-1, 0) else DATEADD(month, datediff(month, 0, getdate()), 0) end;
set @startdate =  '2021-10-01 00:00:00'
set @enddate   =  '2021-10-31 23:59:00'

;with list as
(select  [FileName],[BrwName],[LoanProgramName],[LoanProgramCode] as 'Program Code',[MortgageType], [UnderwriterUserName] as 'Underwriter'
		,convert(CHAR(10),[SpfRdate],120) as 'QC Start date'
		,convert(CHAR(10),[pfsdate] ,120) as 'QC End date'
		,[ConditionNo] as CondNo
		,case when [ConditionNo] = '1501' then 'Credit' 
			  when [ConditionNo] = '1502' then 'Income'
			  when [ConditionNo] = '1503' then 'Asset' 
			  when [ConditionNo] = '1504' then 'Title/Escrow/Pur' 
			  when [ConditionNo] = '1505' then 'Collateral' 
			  when [ConditionNo] = '1506' then 'Fees / invoice' 
			  when [ConditionNo] = '1507' then 'Disclosures/Compliance'  
			  when [ConditionNo] = '1508' then 'Gov''t related'
			  when [ConditionNo] = '1509' then 'Other'  
			  when [ConditionNo] = '1510' then 'Other'  
			  when [ConditionNo] = '1500' then 'default'  
			  when [ConditionNo] = '1511' then 'default2'  
		 else null end as 'Category'
		, case when [ExceptionStatus] = '5' then 'waived' else null end as 'ExceptionStatus'
		,[waived]
		,cast(convert(varchar, [ClearedDate], 102) as date) as ClearedDate
		,[_Description] as 'Description'
		,cast(convert(varchar, [FundingDate], 102) as date) as funded
from BPDBO.[FD] with (nolock)
left join BPDBO.[Status] with (nolock) on [FD].[FDI] = [Status].[FDI]
left join 
	( select [FDI]
			,[ConditionNo]
			,[_Description]
			,[ExceptionStatus]
			,[ClearedDate]
	  from BPDBO.[Condition] with (nolock)
	  where [ConditionNo] between '1500' and '1511'
	) as c on [FD].[FDI] = c.[FDI]
left join
	( select [FDI]
			,[loanprogramcode]
			,[LoanProgramName]
			,case when [MortgageType] = '1' then 'VA' when [MortgageType] = '2' then 'FHA' when [MortgageType] = '3' then 'Conventional' when [MortgageType] = '4' then 'RHS' when [MortgageType] = '5' then 'Other' when [MortgageType] = '6' then 'HELOC' when [MortgageType] = '7' then 'State Agency' when [MortgageType] = '8' then 'Local Agency' else null end as MortgageType
	  from BPDBO.[Loan] with (nolock)
	) as L on [FD].[FDI] = l.[FDI]
left join
	( select [FDI],[BrwName]
	  from  ( select [FDI]
					,[BorrowerID]
					,[LastName] + ', ' + [FirstName] as 'BrwName'
					,ROW_NUMBER() over(partition by [FDI] order by [borrowerid]) r
			  from BPDBO.[Borrower] with (nolock)
			) brw
	  where r = 1
	) as B on [FD].[FDI] = b.[FDI]
left join 
	( SELECT [FDI],[Value] AS 'SpfRdate'
	  FROM BPDBO.[ExtendedDateValue]  with (nolock) 
	  WHERE [Name]='QCAuditPreClosingRandQCAudStart' 
	) SPFR ON [FD].[FDI] = [SPFR].[FDI]
left join
	 (SELECT [FDI],case when [Value]='1' then 'yes' else 'no' end AS 'waived'
	  FROM BPDBO.[ExtendedBooleanValue]  with (nolock) 
	  WHERE [Name]='QCAuditreleasedcheckbox' 
	 ) WPF ON [FD].[FDI] = [WPF].[FDI]
left join
	(SELECT [FDI]
	,case when cast(convert(varchar, [Field102], 102) as date) = '1900-01-01' then null else  cast(convert(varchar, [Field102], 101) as date)  end as 'pfsdate'
	FROM BPDBO.[CustomFields] with (nolock)
	) PFS on [PFS].[FDI] = [FD].[FDI]
where [FileName] not like 'test%'
and [SpfRdate] between @startdate and @enddate

union 

select   [FileName],[BrwName],[LoanProgramName],[LoanProgramCode] as 'Program Code',[MortgageType], [UnderwriterUserName] as 'Underwriter'
		,convert(CHAR(10),[SpfRdate],120) as 'QC Start date'
		,convert(CHAR(10),[pfsdate] ,120) as 'QC End date'
		,[ConditionNo] as CondNo
		,case when [ConditionNo] = '1001' then 'Credit' 
			  when [ConditionNo] = '1002' then 'Income'
			  when [ConditionNo] = '1003' then 'Asset'
			  when [ConditionNo] = '1004' then 'Title/Escrow/Pur' 
			  when [ConditionNo] = '1005' then 'Collateral' 
			  when [ConditionNo] = '1006' then 'Fees / invoice' 
			  when [ConditionNo] = '1007' then 'Disclosures/Compliance'  
			  when [ConditionNo] = '1008' then 'Gov''t related'
			  when [ConditionNo] = '1009' then 'Other'  
			  when [ConditionNo] = '1010' then 'Other'
			  when [ConditionNo] = '1000' then 'default'  
			  when [ConditionNo] = '1011' then 'default2'  
		 else null end as 'Category'
		, case when [ExceptionStatus] = '5' then 'waived' else null end as 'ExceptionStatus'
		,[waived]
		,cast(convert(varchar, [ClearedDate], 102) as date) as ClearedDate
		,[_Description] as 'Description'
		,cast(convert(varchar, [CustomStatus16Date], 102) as date) as funded
from serv2.BPDBO.[FD] with (nolock)
left join serv2.BPDBO.[Status] with (nolock) on [FD].[FDI] = [Status].[FDI]
left join 
	( select [FDI]
			,[ConditionNo]
			,[_Description]
			,[ExceptionStatus]
			,[ClearedDate]
	  from serv2.BPDBO.[Condition] with (nolock)
	  where [ConditionNo] between '1000' and '1011'
	) as c on [FD].[FDI] = c.[FDI]
left join
	( select [FDI]
			,[loanprogramcode]
			,[LoanProgramName]
			,case when [MortgageType] = '1' then 'VA' when [MortgageType] = '2' then 'FHA' when [MortgageType] = '3' then 'Conventional' when [MortgageType] = '4' then 'RHS' when [MortgageType] = '5' then 'Other' when [MortgageType] = '6' then 'HELOC' when [MortgageType] = '7' then 'State Agency' when [MortgageType] = '8' then 'Local Agency' else null end as MortgageType
	  from serv2.BPDBO.[Loan] with (nolock)
	) as L on [FD].[FDI] = l.[FDI]
left join
	( select [FDI],[BrwName]
	  from  ( select [FDI]
					,[BorrowerID]
					,[LastName] + ', ' + [FirstName] as 'BrwName'
					,ROW_NUMBER() over(partition by [FDI] order by [borrowerid]) r
			  from serv2.BPDBO.[Borrower] with (nolock)
			) brw
	  where r = 1
	) as B on [FD].[FDI] = b.[FDI]
left join 
	( SELECT [FDI],[Value] AS 'SpfRdate'
	  FROM serv2.BPDBO.[ExtendedDateValue]  with (nolock) 
	  WHERE [Name]='QCAuditPreClosingRandQCAudStart' 
	) SPFR ON [FD].[FDI] = [SPFR].[FDI]
left join
	 (SELECT [FDI],case when [Value]='1' then 'yes' else 'no' end AS 'waived'
	  FROM serv2.BPDBO.[ExtendedBooleanValue]  with (nolock) 
	  WHERE [Name]='QCAuditreleasedcheckbox' 
	 ) WPF ON [FD].[FDI] = [WPF].[FDI]
left join 
	(SELECT [FDI],[Value] AS 'pfsdate'
	 FROM serv2.BPDBO.[ExtendedDateValue] with (nolock)
	 WHERE [Name]='PFQCCompletedDate' 
	) PFS ON [PFS].[FDI] = [FD].[FDI]
where [FileName] not like 'test%'
and [SpfRdate] between @startdate and @enddate
)

select [FileName]
		,[BrwName] 
		,[LoanProgramName]
		,[Program Code]
		,[MortgageType]
		,[list].[Underwriter]
		,[QC Start date]
		,[QC End date]
		,[file count]
		,[CondNo]
		,[Category]
		,[ExceptionStatus]
		,[list].[waived]
		,[ClearedDate]
		,[Description]
		,[funded]
from list 
left  join (select [underwriter], count([filename]) as 'file count' from (select distinct [FileName],[Underwriter] from list) c group by [Underwriter]) fc on fc.[underwriter] = list.[underwriter]
order by [FileName]




