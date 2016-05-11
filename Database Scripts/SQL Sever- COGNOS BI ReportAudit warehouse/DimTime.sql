CREATE PROCEDURE [dbo].[PopulateDimTime]
AS
SET NOCOUNT ON
DECLARE @ElapsedSeconds int
     , @MaxElapsedSeconds int
     , @Date datetime
     , @AMPM char(2)
     , @hour24 tinyint
     , @hour tinyint
     , @minute tinyint
     , @second int

SET @ElapsedSeconds = 0
SET @MaxElapsedSeconds = 60 * 60 * 24

WHILE @ElapsedSeconds < @MaxElapsedSeconds
BEGIN
     SET @Date = DATEADD(second, @ElapsedSeconds, CONVERT(DATETIME, '20160101'))
     SET @AMPM = RIGHT(CONVERT(varchar, @Date, 109), 2)
     SET @Hour24 = LEFT(CONVERT(TIME, @Date), 2)
     SET @hour = @hour24
     SET @minute = DATEPART(minute, @Date)
     SET @second = DATEPART(second, @Date)

     INSERT INTO [dbo].DimTime([TimeKey]
          , [Time]
          , [Time24]
          , [HourName]
          , [MinuteName]
          , [Hour24]
          , [MinuteNumber]
          , [AM/PM]
          , [ElapsedMinutes] ) 
     SELECT ((@Hour24 * 10000) + (@minute * 100) + @second) AS [TimeKey]
          , RIGHT('0'+ CONVERT(varchar(2), @hour), 2) + ':' + RIGHT('0'+ CONVERT(varchar(2), @minute), 2) + ':' + RIGHT('0'+ CONVERT(varchar(2), @second), 2) + ' ' + @AMPM AS [Time]
          , cast( @Date as Time(0)) AS [Time24]
          , RIGHT('0' + CONVERT(varchar(2), @hour), 2) + ' ' AS [HourName]
          , RIGHT('0' + CONVERT(varchar(2), @minute), 2)+ ' ' AS [MinuteName]
          , @hour24 AS [Hour24]
          , @minute AS [MinuteNumber]
          , @AMPM AS [AMPM]
          , @ElapsedSeconds / 60 AS [ElapsedMinutes]
     SET @ElapsedSeconds = @ElapsedSeconds + 1
END

GO