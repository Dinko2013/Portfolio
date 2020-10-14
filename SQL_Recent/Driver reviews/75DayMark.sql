
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Zvw_DriverReview] 
AS

Select DriverID,
HireDate,
DriverName,
Division,
DriverType,
Employeed_Days,
days_until_threshold,
Notify_Manager,
Review_Completed,
Review_Completed_On,
notes
From Ztbl_DriverReviews
GO




USE TMW_STD_dev
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE proc  [dbo].[zsp_DriverReviewList] as

SELECT mpp_id AS DriverID
      ,mpp_hiredate As HireDate
      ,mpp_lastfirst AS DriverName
	  ,l.name AS Division
	  ,l2.name AS DriverType
	  ,Datediff(dd,mpp_hiredate,getutcdate()) As Employeed_Days
	  ,Datediff(dd,Datediff(dd,mpp_hiredate,getutcdate()),75) AS days_until_threshold
	  ,CASE WHEN(Datediff(dd,Datediff(dd,mpp_hiredate,getutcdate()),75) >= 0 AND Datediff(dd,Datediff(dd,mpp_hiredate,getutcdate()),75)<=7) THEN
		'1'
		ELSE
		'0'
		END AS Notify_Manager
		,isnull(EI.COL_DATA,'0') as Review_Completed
		,isnull(EI.last_updatedate,'') as Review_Completed_on
		,isnull(EI2.Col_data,'No Comments') as Notes
into #TempTable1
  FROM [TMW_STD_PRO].[dbo].[manpowerprofile]
  LEFT JOIN [TMW_STD_PRO].[dbo].[labelfile] AS l ON mpp_division = l.abbr AND l.labeldefinition = 'RevType1'
  LEFT JOIN [TMW_STD_PRO].[dbo].[labelfile] AS l2 ON mpp_type1 = l2.abbr AND l2.labeldefinition = 'DrvType1'
  LEFT JOIN [TMW_STD_PRO].[dbo].[EXTRA_INFO_DATA] AS EI ON mpp_id = EI.TABLE_KEY AND EI.COL_ID = '6' and EI.TAB_ID = '6' and EI.COL_ID='70'
  LEFT JOIN [TMW_STD_PRO].[dbo].[EXTRA_INFO_DATA] AS EI2 ON mpp_id = EI2.TABLE_KEY AND EI2.COL_ID = '6' and EI2.TAB_ID = '6' and EI.COL_ID='71'
  WHERE Datediff(dd,mpp_hiredate,getutcdate()) <=75 AND mpp_terminationdt>getutcdate()
  ORDer BY Employeed_Days DESC


Delete from Ztbl_DriverReviews


Insert into Ztbl_DriverReviews
Select * from #TempTable1 where Notify_Manager  = '1' and Review_Completed = '0'

Drop table #TempTable1
GO

USE [TMW_STD_dev]
GO
/****** Object:  StoredProcedure [dbo].[DriverReviewEmailNotifications]    Script Date: 2020-10-14 5:28:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc  [dbo].[DriverReviewEmailNotifications] as

BEGIN

DECLARE @DriverID varchar(10)
	,@fleet VARCHAR(8)
	,@email	varchar(MAX)
	,@Division nvarchar(max)
	,@profile_name varchar(256)
	,@recipients varchar(max)
	,@subject varchar(256)
	,@message varchar(max)
	,@return_value nvarchar(max)
	,@DriverName varchar(max)
	,@hiredate as datetime
	,@days as varchar(8)
	,@SQL as Nvarchar(MAX)
	,@error as nvarchar(max)
	,@heading as varchar(200)
	,@AttachementName as  varchar(256)
	,@pram1 as varchar
	,@pram2 as varchar
	,@pram3 as varchar
	,@char as char
DECLARE Email_Cursor CURSOR FOR 

 
SELECT Distinct(DR.Division)
		, REL.Email 
	FROM Ztbl_DriverReviews DR 
	left join ztl_DriverReviewEmailList REL on DR.Division = REL.Division



OPEN Email_Cursor  

FETCH NEXT FROM Email_Cursor   
INTO  @Division,@email

WHILE @@FETCH_STATUS = 0  
BEGIN
	set @heading = 'Driver Reviews for ' + @Division
	set @message = N'<p> Good Morning,</p>'+
				   N'<p>Attached to the link below is your list of drivers about to reach their 75 day mark.</p>'+
				   N'<p>It is suggested at this point in time, that preparations be made to begin the review process</p>'+
				   N'<h3 style = "color: #429EEE";text-decoration: underline> PURPOSE</h3>'+
				   N'<p>The 75 day check-in process is meant to act as a retention tool when onboarding new employees. It serves as a great opportunity to touch base with newly hired employees to ensure their first couple months with the company are going well and to make sure lines of communication are open. It is also an opportunity for the employee to voice any concerns or questions they may have. This check in is to be done at or near the 75 day mark to ensure any concerns are identified prior to their 90 day probation completion.</p>'+
				   N'<p>We want to touch base with the people who interact the closest with the newly hired driver. This way, we will get a full understanding of how the onboarding process went. We will gain feedback on training, as well as on-the-job details from dispatch on how well the driver is adapting to the processes, the work and the company as a whole.</p>'+
				   N'<p>Link to find the process document and proposed questions : <a href= "https://seaintranet.seaboard.acl.local/index.php/documents/type/2"> Link </a></p>'+
				   N'<p><ol><H3>New Hire</h3>
				   <li>Driver 75 Day Check in – Process & Questions</li>
				   </ol></p>'+
				   N'<p>Using the link below, please record all responses in the “notes” section as well as confirm when the review has been completed.</p>'+
				   ----Change Link Once report has been moved
				   N'<p><a href ="http://seasql2/ReportServer?%2F6000%20Corporate%2F6800%20Driver%20Review%2F6801%20Driver%20Review&div='+@division+'&rs%3AParameterLanguage=en-US"> Report Link </a> - Please ensure you use this link in Google Chrome </p>'+
				   N'<p>Regards</p>'+
				   N'<p>Human Resources Department</p>'

	EXEC @return_value = msdb.dbo.sp_send_dbmail
	@profile_name = 'SHSQL Profile',
	@recipients = @email,
	@subject = @heading,
	@body = @message,
	@importance = 'High',
	@body_format = 'HTML',
	@execute_query_database= TMW_STD_dev,
	@copy_recipients = ''

	SELECT @error = 
	CASE 
	WHEN @return_value = 1 THEN
		'Email Profile Error' + @profile_name 
	WHEN @return_value = 2 THEN
		'Email Address Error' + @recipients
	WHEN @return_value = 3 THEN
		'Subject Error' + @subject
	WHEN @return_value = 4 THEN
		'Message composition Error' + @message
	WHEN @return_value = 6 THEN
		'Query Error' 
	WHEN @return_value = 7 THEN
		'Attachement Error' 
	ELSE 
		''
	END 

	IF @error <> '' 
	BEGIN
		UPDATE Ztbl_DriverReviews SET [message] = @error WHERE Division = @Division
	END
	ELSE
	BEGIN
		UPDATE Ztbl_DriverReviews SET email_sent = '1'  WHERE Division = @Division
	END

	SET @message = ''

FETCH NEXT FROM Email_Cursor   
INTO @Division,@email

 END
 CLOSE Email_Cursor;  
DEALLOCATE Email_Cursor;  
 END
GO






USE [TMW_STD_dev]
GO
/****** Object:  StoredProcedure [dbo].[DriverReviewConfirmation]    Script Date: 2020-10-14 5:26:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- UPDATE DRIVER PROFILE WHEN REVIEW HAS BEEN COMPLETED.
ALTER proc  [dbo].[DriverReviewConfirmation](@DriverID varchar(10),@Manager as varchar(MAX), @Notes as varchar(Max),@Status as bit) as


IF @DriverID is not null 
BEGIN

Declare @Done as bit = (SELECT [Review_Completed] FROM [Ztbl_DriverReviews] where DriverID = @DriverID)

IF @Done <> '1'
BEGIN
INSERT INTO [dbo].[EXTRA_INFO_DATA]
           ([EXTRA_ID]
           ,[TAB_ID]
           ,[COL_ID]
           ,[COL_DATA]
           ,[TABLE_KEY]
           ,[COL_ROW]
           ,[last_updateby]
           ,[last_updatedate]
)
VALUES(6,6,71,isnull(@Status,'0'),@DriverID,2,@Manager,cast(getdate() as datetime))

INSERT INTO [dbo].[EXTRA_INFO_DATA]
           ([EXTRA_ID]
           ,[TAB_ID]
           ,[COL_ID]
           ,[COL_DATA]
           ,[TABLE_KEY]
           ,[COL_ROW]
           ,[last_updateby]
           ,[last_updatedate]
)
VALUES(6,6,70,isnull(@Notes,''),@DriverID,3,@Manager,cast(getdate() as datetime))

Update Ztbl_DriverReviews
Set Notes = @notes,
	Review_Completed =@Status,
	Review_Completed_on = cast(getdate() as datetime)
	where DriverID = @DriverID
END

END