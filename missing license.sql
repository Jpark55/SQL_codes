/*
one of my first queries. used to locate missing license data
*/


SELECT f.[FileName]
	  ,l.[NameOV]
	  ,p.[PartyID]
      ,[CategoryID]
      --,[FirstName]
      --,[MiddleName]
      --,[LicenseNo]
      --,[CHUMSNo]
      --,[ContactNMLSID]
      --,[CompanyNMLSID]
      --,[LockToUser]
      ,[LicensingAgencyCode]
      
  FROM server1.[Party] as P
		inner join server1.[FileData] as F
		on f.[FileDataID] = p.[FileDataID]
		inner join server1.[status] as S
		on f.[FileDataID] = s.[FileDataID]
		inner join server1.[LoanStatusItem] as L
		on s.[LoanStatus] = l.[LoanStatus]
  WHERE [LicensingAgencyCode] is not null
		and CategoryID = '21'
