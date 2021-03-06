select 
	*
from (
	select 
		a.*,
		b.CreatedDate CreatedDateRequest,
		CASE
			WHEN a.ARWrOLevel = 1 THEN b.CreatedDate
			WHEN SignerName = '-' THEN a.CreatedDate
			WHEN a.ARWrOLevel > a.LevelReject THEN a.CreatedDate
			WHEN a.LagStatus < 0 THEN a.CreatedDate
			WHEN a.Status = -1 THEN LagDate
			WHEN (a.Status >= 0 AND Dateapprove IS NOT NULL) THEN LagDate
			WHEN (a.Status >= 0 AND Dateapprove IS NULL) THEN LagDate END AS PreviousLevelDate,
		CASE
			WHEN a.ARWrOLevel = 1 THEN a.Dateapprove
			WHEN SignerName = '-' THEN a.LastModifiedDate
			WHEN a.ARWrOLevel > a.LevelReject THEN a.CreatedDate
			WHEN a.LagStatus < 0 THEN a.CreatedDate
			WHEN a.Status = -1 THEN GETDATE()
			WHEN (a.Status >= 0 AND Dateapprove IS NOT NULL) THEN Dateapprove
			WHEN (a.Status >= 0 AND Dateapprove IS NULL) THEN a.LastModifiedDate END AS CurrentLevelDate,
		b.AREA_NAME, 
		b.CustomerName, 
		CASE when a.SignerName is null then b.SalesmanPIC else a.SignerName end Approver,
		b.RequestNo, 
		b.Status as Status_Request 
	from (
		select * from (
			select 
				*,
				LAG(LastModifiedDate,1) OVER(PARTITION BY HreqID ORDER BY HreqID, ARWrOLevel, LastModifiedDate) AS LagDate,
				LAG(Status,1) OVER(PARTITION BY HreqID ORDER BY HreqID, ARWrOLevel, Status) AS LagStatus
			from EDW_TOD.rpa.ARWrOApprovalDetail where SignerName <> '-' and PositionName not like 'Additional%'
			union 
			select 
				*,
				LastModifiedDate AS LagDate,
				Status AS LagStatus
			from EDW_TOD.rpa.ARWrOApprovalDetail where SignerName = '-'
		) aa
		left join (select HReqID idHeader, ARWrOLevel LevelReject from EDW_TOD.rpa.ARWrOApprovalDetail where Status = 0) b
		on aa.HReqID = b.idHeader
	) a
	full join (
		select a.*, e.AREA_NAME
		from EDW_TOD.rpa.ARWrORequest a
		left join [EDWMDS].[EDW_MDS].[ECC].[MT_BUSINESS_AREA] e on a.RequestorBranch = e.BUSINESS_AREA
	) b on a.HReqID = b.Id
	left join (
		select ARWrOLevel, count(*) as count_request
		from EDW_TOD.rpa.ARWrOApprovalDetail aa 
		where status < 3
		group by ARWrOLevel
	) c on a.ARWrOLevel = c.ARWrOLevel
) a
