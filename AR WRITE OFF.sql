--Import Data dari Production berdasarkan query berikut:

select 
	b.RequestNo,
	b.SalesmanPIC,
	a.BusinessArea RequestorBranch,
	e.AREA_NAME,
	LEFT(CAST(a.ProfitCenter as INT), 4) ProfitCenter,
	b.CustomerName,
	FORMAT(b.CreatedDate, 'yyyy') Year,
	c.Type,
	d.SubType,
	b.Status,
	cast(case when len(a.amountinloccur) = 0 then '0' else a.AmountInLocCur end as decimal(10,2)) AmountInLocCur

from EDW_TOD.rpa.ARWrOExtractFormB a
left join EDW_TOD.rpa.ARWrORequest b on a.HreqId = b.Id
left join EDW_TOD.rpa.ARWrOType c on b.ARWrOTypeID = c.Id
left join EDW_TOD.rpa.ARWrOSubType d on b.ARWrOSubTypeID = d.Id
left join [EDWMDS].[EDW_MDS].[ECC].[MT_BUSINESS_AREA] e on a.BusinessArea = e.BUSINESS_AREA

-------------------------------------------------------------------------------------

--Import Data dari Development berdasarkan query berikut:
select 
	a.RequestNo,
	a.SalesmanPIC,
	a.RequestorBranch,
	e.AREA_NAME,
	LEFT(CAST(a.ProfitCenter as INT), 4) ProfitCenter,
	a.CustomerName,
	a.Year,
	left(a.SubType, 3) as Type,
	a.SubType,
	5 as Status,
	cast(case when len(a.amountinloccur) = 0 then '0' else a.AmountInLocCur end as decimal(10,2)) AmountInLocCur
from CR_EDW_TOD.rpa.ARWrORequestInject a
left join [EDWMDS].[EDW_MDS].[ECC].[MT_BUSINESS_AREA] e on a.RequestorBranch = e.BUSINESS_AREA


--Lalu kedua table yang terpisah disatukan menggunakan command append di Power Query
