/*
one of the first queries joining data on two servers
*/

declare @startdate date; set @startdate = '2020-03-23';

SELECT distinct
        wT.[CompletedBy]
       ,wT.complete_date 
       ,DATENAME(dw, wT.complete_date) as dayname
	    ,(isnull(wT.[total tasks], 0) + isnull(cT.[total tasks], 0)) as 'total tasks'
	    ,(isnull(wT.[conditions], 0) + isnull(cT.[conditions], 0)) as conditions
       ,(isnull(wT.[new file], 0) + isnull(cT.[new file], 0)) as 'new file'

FROM (
       select [CompletedBy]  
                             ,convert (nvarchar(10),[DateCompleted], 101) as complete_date 
                             ,count ( case when [Description] like '%new uw%' then 1 else null end ) as 'new file'
                             ,((count ( [CompletedBy] )) - (count ( case when [Description] like '%new uw%' then 1 else null end ))) as 'conditions'
                             ,count ( [CompletedBy] ) as 'total tasks'
       from   server1.[Task] WITH (NOLOCK)
       where  cast([task].[DateCompleted] as date) = @startdate
       --and [completedby] like '???%'
	     --and [CompletedBy] in ('????', '????')
	     group by [CompletedBy], convert (nvarchar(10),[DateCompleted], 101)
) wT
left join (
		select corrt.[CompletedBy]  
                             ,convert (nvarchar(10),corrt.[DateCompleted], 101) as complete_date 
                             ,count ( case when corrt.[Description] like '%new uw%'  then 1 else null end ) as 'new file'
                             ,((count ( corrt.[CompletedBy] )) - (count ( case when corrt.[Description] like '%new uw%' then 1 else null end ))) as 'conditions'
                             ,count ( corrt.[CompletedBy] ) as 'total tasks'
       from   server2.[Task] corrt WITH (NOLOCK)
	     where  cast(corrt.[DateCompleted] as date) = @startdate 
       group by corrt.[CompletedBy], convert (nvarchar(10),corrt.[DateCompleted], 101)

) ct on cast(wt.[complete_date] as date) = cast(ct.[complete_date] as date) and wt.[CompletedBy] = ct.[CompletedBy]

order by wT.[CompletedBy] asc, 
		     wT.complete_date asc
		     --,wT.[CompletedBy] asc
