USE [TMW]
GO

/****** Object:  Trigger [dbo].[tr_SendEmail]    Script Date: 2018-08-07 12:23:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[tr_SendEmail]
ON [dbo].[serviceexception]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @body NVARCHAR(MAX) = ' The following Service Exception Report was submitted: ';
	DECLARE @subject NVARCHAR(MAX) = '';
	DECLARE @revtype1 NVARCHAR(MAX) = '';




    SELECT @body = ' The following Service Exception Report was submitted: '+ CHAR(13) + CHAR(10) + 
	CHAR(13) + CHAR(10) +  'Division: ' + Lf2.name +
	CHAR(13) + CHAR(10) +  'Originator: ' + sxn_createdby +
	CHAR(13) + CHAR(10) +  'Incident Date: ' + CAST(sxn_expdate as varchar) +
	CHAR(13) + CHAR(10) +  'Exception Number: ' + CAST(sxn_sequence_number  as varchar) +
	CHAR(13) + CHAR(10) +  'Reference Number: ' + CAST(O.ord_hdrnumber  as varchar) +
	CHAR(13) + CHAR(10) +  'Customer Reference Number: ' + ISNULL(ord_refnum, 'NONE') +
	CHAR(13) + CHAR(10) +  'Cause: ' + Lf3.name +
	CHAR(13) + CHAR(10) +  'Result: ' + Lf.name +
	CHAR(13) + CHAR(10) +  'Action: ' + Lf4.name +
	CHAR(13) + CHAR(10) +  'Description: ' + sxn_description, 
	@subject = 'Service Exception Report ' +  CAST(sxn_sequence_number  as varchar) + ' - '  + c2.cmp_name,
	@revtype1 = o.ord_revtype1
	FROM inserted SX
   left join orderheader O on CASE WHEN NULLIF(sxn_ord_hdrnumber, '') IS NULL THEN  sxn_mov_number  ELSE sxn_ord_hdrnumber END= CASE WHEN NULLIF(sxn_ord_hdrnumber, '') IS NULL THEN  O.mov_number  ELSE O.ord_hdrnumber END
left join labelfile LF on SX.sxn_expcode = LF.abbr and LF.labeldefinition = 'ReasonLate'
left join labelfile LF2 on O.ord_revtype1 = LF2.abbr and LF2.labeldefinition = 'Division'
left join labelfile LF3 on SX.sxn_late = LF3.abbr and LF3.labeldefinition = 'ServiceExceptionLate'
left join labelfile LF4 on SX.sxn_actioncode = LF4.abbr and LF4.labeldefinition = 'ActionCode'
left join company C on SX.sxn_cmp_id = C.cmp_id 
left join company C2 on O.ord_billto = C2.cmp_id

---select * from serviceexception  where  labeldefinition LIKE 'Action%'
	
	IF (@revtype1  = 'AJWLIQ')
	BEGIN
	
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
          @recipients = '', 
          @profile_name = 'shsqlMail',
          @subject = @subject , 
          @body = @body;
    END
	END
	ELSE
	BEGIN



    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
          @recipients = '', 
          @profile_name = 'shsqlMail',
          @subject = @subject, 
          @body = @body;
    END

	END



END
GO

ALTER TABLE [dbo].[serviceexception] ENABLE TRIGGER [tr_SendEmail]
GO


