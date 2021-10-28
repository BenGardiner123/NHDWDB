

--//CREATE THE TABLE DATA TYPE 
DROP TYPE IF EXISTS DEMOTABLETYPE
CREATE TYPE DEMOTABLETYPE AS TABLE
(
	URNNUMBER NVARCHAR(100),
	EMAIL NVARCHAR(256),
	TITLE NVARCHAR(100)
);

GO

BEGIN

DECLARE @PATIENTTABLE DEMOTABLETYPE;
INSERT INTO @PATIENTTABLE
SELECT URNNUMBER, EMAIL, TITLE
FROM PATIENT;

SELECT * FROM @PATIENTTABLE
END


--use NHDW
--IF OBJECT_ID('TRANSFER_GOOD_NEW_PATIENT_DATA') IS NOT NULL
--DROP PROCEDURE TRANSFER_GOOD_NEW_PATIENT_DATA;
--GO
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- =============================================
---- Author:		<Ben Gardiner>
---- Create date: <6/10/21>
---- Description:	<This checks for existign source ids in the error event and dimpatient and then
---- imports all the new patient information that is new from the TPS>
---- =============================================
--CREATE PROCEDURE TRANSFER_GOOD_NEW_PATIENT_DATA 
--as
--begin

--	--THIS CREATES A STRING WHICH IS A LIST OF THE SOURCE ID'S IN DWPATIENT
--	DECLARE @ALREADY_IN_DIM NVARCHAR(MAX);
--    SELECT @ALREADY_IN_DIM = COALESCE(@ALREADY_IN_DIM + ',', '') + NHDW.dbo.DIMPATIENT.DWDIM_SOURCEID
--    FROM NHDW.dbo.DIMPATIENT
--	WHERE DIMPATIENT.DWDIM_SOURCEDB = 'NHRM'

--	--THIS CREATES A STRING WHICH IS A LIST OF THE SOURCE ID'S IN ERROREVENT
--	DECLARE @ERROR_EVENT_EXISTING NVARCHAR(MAX);
--	SELECT @ERROR_EVENT_EXISTING = COALESCE(@ERROR_EVENT_EXISTING + ',', '') +  ERROREVENT.SOURCE_ID
--	FROM NHDW.dbo.ERROREVENT
--	WHERE SOURCE_DB = 'NHRM';

	
	
--	--COMBINE THE TWO LISTS OF NUMBERS INTO ONE VARIABLE TO BE PUSHED IN TTHE QUERY BELOW
--	DECLARE @TO_EXCLUDE NVARCHAR(MAX);
--	SET @TO_EXCLUDE = @ALREADY_IN_DIM + ', ' + @ERROR_EVENT_EXISTING;

--	DECLARE @SELECTQUERY NVARCHAR(MAX);

--	if @TO_EXCLUDE is not Null 
--		Begin
--			SET @SELECTQUERY = '''SELECT URNUMBER, GENDER, YEAR(DOB) AS YOB,' +
--                'SUBURB, POSTCODE, COUNTRYOFBIRTH, LIVESALONE, ACTIVE, ' +
--                '(SELECT TOP 1 DIAGNOSIS FROM DDDM_TPS_1.DBO.CONDITIONDETAILS CD WHERE CD.URNUMBER = P.URNUMBER) AS [DIAGNOSIS],' +
--                '(SELECT TOP 1 CATEGORYNAME FROM DDDM_TPS_1.DBO.PATIENTCATEGORY PC' +
--                ' INNER JOIN DDDM_TPS_1.DBO.TEMPLATECATEGORY TC' +
--                ' ON PC.CATEGORYID = TC.CATEGORYID' +
--                ' WHERE PC.URNUMBER = P.URNUMBER) AS [CATEGORY], ' +
--                '(SELECT TOP 1 PROCEDUREDATE FROM DDDM_TPS_1.DBO.CONDITIONDETAILS CD WHERE CD.URNUMBER = P.URNUMBER) AS [PROCEDURE]' +
--                ' FROM DDDM_TPS_1.DBO.PATIENT P WHERE URNUMBER NOT IN (' + @TO_EXCLUDE + ')''';
--				--check data here

--		end
--	else
--		begin
--		   SET @SELECTQUERY = '''SELECT URNUMBER, GENDER, YEAR(DOB) AS YOB,' +
--                    'SUBURB, POSTCODE, COUNTRYOFBIRTH, LIVESALONE, ACTIVE, ' +
--                    '(SELECT TOP 1 DIAGNOSIS FROM DDDM_TPS_1.DBO.CONDITIONDETAILS CD WHERE CD.URNUMBER = P.URNUMBER) AS [DIAGNOSIS],' +
--                    '(SELECT TOP 1 CATEGORYNAME FROM DDDM_TPS_1.DBO.PATIENTCATEGORY PC' +
--                    ' INNER JOIN DDDM_TPS_1.DBO.TEMPLATECATEGORY TC' +
--                    ' ON PC.CATEGORYID = TC.CATEGORYID' +
--                    ' WHERE PC.URNUMBER = P.URNUMBER) AS [CATEGORY], ' +
--                    '(SELECT TOP 1 PROCEDUREDATE FROM DDDM_TPS_1.DBO.CONDITIONDETAILS CD WHERE CD.URNUMBER = P.URNUMBER) AS [PROCEDURE]' +
--                    ' FROM DDDM_TPS_1.DBO.PATIENT P''';
--					--check the output here
--		end

--	-- write the code to get the required data - excludes those identified above.
--    DECLARE @CONNSTRING NVARCHAR(MAX);
--    EXECUTE @CONNSTRING = GET_CONNECTION_STRING;

--    DECLARE @COMMAND NVARCHAR(MAX);
--    SET @COMMAND =  'SELECT * FROM OPENROWSET(''SQLNCLI'', ' + '''' + @CONNSTRING + ''',' + @SELECTQUERY + ') SOURCE';
    
--    --EXECUTE(@COMMAND);
	
--	--declare a table varible to hold the data coming form the TPS system

--	 declare @PatientTable TestPatientTable;
--	 INSERT INTO @PatientTable
--	 EXEC(@COMMAND);

--	-- SELECT * FROM @PatientTable;

--	 EXEC ETL_FILTER_PROCESS_PATIENT @DATA = @PatientTable;

		
--END

-------------------if you want to insert a specific patient use this =----------------------
--INSERT INTO DIMPATIENT(DWDIM_SOURCEDB, DWDIM_SOURCETABLE, DWDIM_SOURCEID, GENDER, YEAROFBIRTH, SUBURB, POSTCODE, COUNTRYOFBIRTH,
--LIVESALONE, ACTIVE, DIAGNOSIS, CATEGORYNAME, PROCEDUREDATE) VALUES
--('NHRM', 'PATIENT', 123456785, 'MALE', 1234, 'SOMEWHERE', '1234',
--'AUSTRALIA', 1, 0, NULL, NULL, NULL);

USE NHDW
DROP PROCEDURE IF EXISTS ETL_FILTER_PROCESS_PATIENT;

-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================


CREATE PROCEDURE ETL_FILTER_PROCESS_PATIENT  @DATA TestPatientTable READONLY AS
BEGIN
    BEGIN TRY

     --Select d.CategoryName from (SELECT * FROM @DATA) d;

	-- FILTER YEAR
	-- SELECT * FROM @DATA
	-- WHERE YEAR.LEN

	--FILTER GENDER
	--SELECT * FROM @DATA
	--WHERE Gender NOT IN ('Male', 'Female')

  
	--INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATE_TIME], [ACTION], NOTES) 
	--SELECT 'NHRM', Dt.DWDIM_SOURCEID, 'PATIENT', 1, (SELECT SYSDATETIME()), 'MODIFY', 'misspleled gender' 
	--FROM @DATA Dt
	--WHERE dt.Gender NOT IN ('Male', 'Female');

	--INSERT INTO ERROREVENT(ERRORID, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATE_TIME], [ACTION], NOTES) 
	--SELECT 'NHRM', Dt.DWDIM_SOURCEID, 'PATIENT', 2, (SELECT SYSDATETIME()), 'SKIP', 'wrong year lwength' 
	--FROM @DATA Dt
	--WHERE LEN(dt.YEAROFBIRTH) != 4;

	INSERT INTO ERROREVENT( SOURCE_DB, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATE_TIME], [ACTION], NOTES) 
	SELECT 'NHRM', Dt.DWDIM_SOURCEID, 'PATIENT', 3, (SELECT SYSDATETIME()), 'SKIP', 'Category Name is null and requires investigaton' 
	FROM @DATA Dt
	WHERE dt.CategoryName IS NULL;

	--Select CategoryName
	--from @DATA
	
	select * from ERROREVENT
	
 
    END TRY
    BEGIN CATCH
      
    --   IF ERROR_NUMBER() IN (50290, 50300)
    --   THROW;
      
    --   BEGIN
    --       DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    --       THROW 50000 , @ERRORMESSAGE , 1
    --   END
    END CATCH
END


--ADDING THE SELCETS TO GET AL LTHE OTHER DIM TABLES----------------------------------------------------

--SELECT M.MEASUREMENTID, DP.DATAPOINTNUMBER, M.MEASUREMENTNAME, DP.[NAME], DP.UPPERLIMIT, DP.LOWERLIMIT
--FROM MEASUREMENT M
--INNER JOIN DataPoint DP
--ON M.MeasurementID = DP.MeasurementID

--------------------THE sp FOR THE GET MEAUREMENTS----------------------------------------------------------

--CREATE PROCEDURE TRANSFER_GOOD_NEW_MEASUREMENT_DATA 
--as
--begin

--	--THIS CREATES A STRING WHICH IS A LIST OF THE SOURCE ID'S IN DWPATIENT
--	DECLARE @ALREADY_IN_DIM NVARCHAR(MAX);
--    SELECT @ALREADY_IN_DIM = COALESCE(@ALREADY_IN_DIM + ',', '') + NHDW.dbo.DIMEASUREMENT.MEASUREMENTID
--    FROM NHDW.dbo.DIMEASUREMENT
--	WHERE NHDW.dbo.DIMEASUREMENT.DWDIM_SOURCEDB = 'NHRM'

--	--THIS CREATES A STRING WHICH IS A LIST OF THE SOURCE ID'S IN ERROREVENT
--	DECLARE @ERROR_EVENT_EXISTING NVARCHAR(MAX);
--	SELECT @ERROR_EVENT_EXISTING = COALESCE(@ERROR_EVENT_EXISTING + ',', '') +  ERROREVENT.SOURCE_ID
--	FROM NHDW.dbo.ERROREVENT
--	WHERE SOURCE_DB = 'NHRM'
--	AND SOURCE_TABLE = 'DIMEASUREMENT';

	
	
--	--COMBINE THE TWO LISTS OF NUMBERS INTO ONE VARIABLE TO BE PUSHED IN TTHE QUERY BELOW
--	DECLARE @TO_EXCLUDE NVARCHAR(MAX);
--	SET @TO_EXCLUDE = @ALREADY_IN_DIM + ', ' + @ERROR_EVENT_EXISTING;

--	DECLARE @SELECTQUERY NVARCHAR(MAX);

--	if @TO_EXCLUDE is not Null 
--		Begin
--			SET @SELECTQUERY = '''SELECT M.MEASUREMENTID, DP.DATAPOINTNUMBER, M.MEASUREMENTNAME,' +
--                'DP.[NAME], DP.UPPERLIMIT, DP.LOWERLIMIT' +
--				' FROM DDDM_TPS_1.DBO.MEASUREMENT M' +
--				' INNER JOIN DataPoint DP' +
--				' ON M.MeasurementID = DP.MeasurementID' +
--                ' WHERE M.MEASUREMENTID NOT IN (' + @TO_EXCLUDE + ')''';
--				PRINT(@SELECTQUERY)

--		end
--	else
--		begin
		
--		   SET @SELECTQUERY = '''SELECT M.MEASUREMENTID, DP.DATAPOINTNUMBER, M.MEASUREMENTNAME,' +
--                'DP.[NAME], DP.UPPERLIMIT, DP.LOWERLIMIT' +
--				' FROM DDDM_TPS_1.DBO.MEASUREMENT M' +
--				' INNER JOIN DDDM_TPS_1.DBO.DataPoint DP' +
--				' ON M.MeasurementID = DP.MeasurementID''';
--				PRINT(@SELECTQUERY)
--		end

--	-- write the code to get the required data - excludes those identified above.
--    DECLARE @CONNSTRING NVARCHAR(MAX);
--    EXECUTE @CONNSTRING = GET_CONNECTION_STRING;

--    DECLARE @COMMAND NVARCHAR(MAX);
--    SET @COMMAND =  'SELECT * FROM OPENROWSET(''SQLNCLI'', ' + '''' + @CONNSTRING + ''',' + @SELECTQUERY + ') SOURCE';
    
--    --EXECUTE(@COMMAND);
	
--	--declare a table varible to hold the data coming form the TPS system

--	 declare @measurementTable TESTMEASUREMENTTABLE;
--	 INSERT INTO @measurementTable
--	 EXEC(@COMMAND);

--	SELECT * FROM @measurementTable;

--	 --EXEC ETL_FILTER_PROCESS_PATIENT @DATA = @PatientTable;

		
--END

--------------------------------------------treatment table join----------------------------------------------------------------------


SELECT 	RC.RecordCategoryID, RT.RecordType, RC.Category
FROM RecordCategory RC
INNER JOIN RecordType RT
ON 	RC.RecordCategoryID = RT.RecordCategoryID

----------------------------------------------

USE [NHDW]
GO
IF OBJECT_ID('[ETL_FILTER_PROCESS_STAFF]') IS NOT NULL
DROP PROCEDURE [ETL_FILTER_PROCESS_STAFF];

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		bEN gARDINER
-- Create date: 11/10/21
-- Description:	FILTER THE TREAMENT DIMENSION DATA
-- =============================================


CREATE PROCEDURE [dbo].[ETL_FILTER_PROCESS_STAFF]  @DATA TEST__TABLE READONLY AS
BEGIN
    BEGIN TRY

    SELECT * FROM @DATA;

	--HONESTLY I HAVE NO IDEA WHAT FILTER TO APPLY HERE
	--INSERT INTO ERROREVENT( SOURCE_DB, SOURCE_ID, SOURCE_TABLE, FILTERID, [DATE_TIME], [ACTION], NOTES) 
	--SELECT 'NHRM', Dt.DWDIM_SOURCEID, 'STAFF', 2, (SELECT SYSDATETIME()), 'SKIP', 'NULL CATEGORY NAME' 
	--FROM @DATA Dt
	--WHERE dt.CATEGORY IS NULL;

	--SELECT * FROM ERROREVENT
	
 
    END TRY
    BEGIN CATCH
      
    --   IF ERROR_NUMBER() IN (50290, 50300)
    --   THROW;
      
    --   BEGIN
    --       DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
    --       THROW 50000 , @ERRORMESSAGE , 1
    --   END
    END CATCH
END


GO
	
USE NH
DROP TYPE IF EXISTS TEST_STAFF_TABLE AS TABLE;

GO
CREATE TYPE TEST_STAFF_TABLE AS TABLE (
	DWDIM_SOURCEID INT NOT NULL, -- THE HOSPITAL STAFF UNIQUE ID 
	STAFFTYPE NVARCHAR(50) NOT NULL --  E.G. CLINICIAN, NURSE, RESIDENT, ADMIN ETC
)
GO

---------------filter staff
---THIS DIDNT WORK BECAUSE I WAS GETTING ALL THE ROWS IN THE STAFF TABLE AS WELL - OF COURSE THERE WILL BE TONS AND TONS 
--OF DUPLCAITES
Select s.StaffID AS DWDIM_SOURCE_ID, sr.Stafftype
from Staff s
inner join StaffRole sr
on s.roleid = sr.Roleid
--GROUP BY s.StaffID , SR.STAFFTYPE
--HAVING ( COUNT(*) > 1)

--- insert into the error event table any rows from the staff role table that have a dupluicate staff type  


select *
from StaffRole


---------------------------------- query to get the valeus for my fact table called interventino table---------------------------

-----select CONVERT(CHAR(8), pm.FrequencySetDate, 112) creates a converted date - 
---https://www.mssqltips.com/sqlservertip/6452/sql-convert-date-to-yyyymmdd/
--from patientmeasurement pm

select pm.Frequency, pm.FrequencySetDate, mr.dateTimeRecorded, dr.[value]
from patientmeasurement pm
inner join MeasurementRecord mr
on pm.measurementid = mr.MeasurementID
and pm.CategoryID = mr.CategoryID
and pm.URNumber = mr.URNumber
inner join DataPointRecord dr
on mr.MeasurementRecordID = dr.MeasurementRecordID

--with dates convert

select pm.Frequency, CONVERT(CHAR(8), pm.FrequencySetDate, 112), CONVERT(CHAR(8), mr.dateTimeRecorded, 112), dr.[value]
from patientmeasurement pm
inner join MeasurementRecord mr
on pm.measurementid = mr.MeasurementID
and pm.CategoryID = mr.CategoryID
and pm.URNumber = mr.URNumber
inner join DataPointRecord dr
on mr.MeasurementRecordID = dr.MeasurementRecordID


--------------------GETTING THE QUERY SORTED FOR LOADING THE FACT TABLE------------------------------
-----------------------------------------------------------------------------------------------------
--DROP TYPE IF EXISTS TEST_EPISODE_TABLE
--GO
--CREATE TYPE TEST_EPISODE_TABLE as TABLE(
--URNumber        NVARCHAR(50),
--MeasurementID   INT,
--DatapointNumber INT,
--FrequenceySetDate CHAR(8),
--DatetimeRecorded  CHAR(8),
--Frequency         INT,
--[Value]           FLOAT
--);

drop table if exists DWEPISODE

--- dropped the dateid row - i didnt need it, swapped order - patient at top

CREATE TABLE DWEPISODE(
	DWFACT_EPISODEID INT IDENTITY(1,1) NOT NULL, --THE SURROGATE KEY
	DWDIM_PATIENTID INT NOT NULL, --REFERS TO THE SURROGATE KEY FROM THE PATIENT DIMENSION TABLE 
	DWDIM_MEASUREMENTID INT NOT NULL, --REFERS TO THE PRIMARY KEY IN THE DIMMEASUREMENT TABLE
	DATETIMERECORDED CHAR(8) NOT NULL, --REFERS TO THE DATE AND TIME THAT THE EPISODE BETWEEN PATIENT AND CLINICIAN OCCURS E.G(2021-09-01	12:12:22.00)
	FREQUENCYSETDATE CHAR(8) NOT NULL, --REFERS TO THE DATE AND TIME THE CLINICIAN SETS THE FREQUENCY E.G (2021-09-01 12:12:22.00)
	FREQUENCY INT NOT NULL, -- THE NUMBER OF DAYS BETWEEN MEASUREMENTS (31 OR 7 etc..)
	[VALUE] FLOAT(10) NOT NULL, -- ACTUAL VALUE TAKEN E.G (1.0 OR 2.3)
	
	CONSTRAINT PK_FACTEPISODE PRIMARY KEY CLUSTERED (DWFACT_EPISODEID ASC)
);

BEGIN
DECLARE @SELECTQUERY NVARCHAR(MAX);
	-- GET CONNECTION STRING.
    DECLARE @CONNSTRING NVARCHAR(MAX);
    EXEC @CONNSTRING = GET_CONNECTION_STRING;
	SET @SELECTQUERY = '''SELECT P.URNUMBER, DP.MEASUREMENTID, DP.DATAPOINTNUMBER, CONVERT(CHAR(8), PM.FREQUENCYSETDATE, 112) as freqencysetdate, '+
                       'CONVERT(CHAR(8), MR.DATETIMERECORDED, 112)as datetimerecorded, PM.FREQUENCY, DR.[VALUE] ' +
                       'FROM DDDM_TPS_1.DBO.PATIENT P ' +
                       'INNER JOIN DDDM_TPS_1.DBO.PATIENTCATEGORY PC ' +
                       'ON P.URNUMBER = PC.URNUMBER ' +
					   'INNER JOIN DDDM_TPS_1.DBO.PATIENTMEASUREMENT PM ' +
					   'ON PM.CATEGORYID = PC.CATEGORYID ' +
					   'AND PM.URNUMBER = PC.URNUMBER ' +
					   'INNER JOIN DDDM_TPS_1.DBO.MEASUREMENTRECORD MR ' +
					   'ON PM.MEASUREMENTID = MR.MEASUREMENTID ' +
					   'AND PM.CATEGORYID = MR.CATEGORYID ' +
					   'AND PM.URNUMBER = MR.URNUMBER ' +
					   'INNER JOIN DDDM_TPS_1.DBO.DATAPOINTRECORD DR ' +
					   'ON MR.MEASUREMENTRECORDID = DR.MEASUREMENTRECORDID ' +
                       'INNER JOIN DDDM_TPS_1.DBO.DATAPOINT DP ' +
                       'ON DP.MEASUREMENTID = DR.MEASUREMENTID ' +
                       'AND DP.DATAPOINTNUMBER = DR.DATAPOINTNUMBER'
	--Print @SELECTQUERY;
    DECLARE @COMMAND NVARCHAR(MAX);
    SET @COMMAND = 'SELECT * FROM OPENROWSET(''SQLNCLI'', ' +
                    '''' + @CONNSTRING + ''',' + @SELECTQUERY+''') SOURCE;'
    --PRINT(@COMMAND);
     --EXEC(@COMMAND);
	 DECLARE @FromDatapointRecord TEST_EPISODE_TABLE;
	 INSERT INTO @FromDatapointRecord
	 EXEC(@COMMAND);

	 SELECT * FROM @FromDatapointRecord;
	 
	 EXEC INSERTFACT @DATA = @FromDatapointRecord;
END


----------------this is the insertFACT stored proc--------------
drop procedure if exists  INSERTFACT
go
CREATE PROCEDURE INSERTFACT @DATA TEST_EPISODE_TABLE readonly as
BEGIN
	BEGIN TRY

		insert into DWEPISODE(DWDIM_PATIENTID, DWDIM_MEASUREMENTID, DATETIMERECORDED, FREQUENCYSETDATE, FREQUENCY, [VALUE])
		select DWDIM_PATIENTID, DWDIM_MEASUREMENTID, DATETIMERECORDED, FrequenceySetDate, Frequency, [Value]
		from DIMPATIENT p
		inner join @DATA d
		on p.DWDIM_SOURCEID = d.URNumber
		inner join DIMEASUREMENT dm
		on dm.MEASUREMENTID = d.MeasurementID
		and dm.DATAPOINTNUMBER = d.DatapointNumber
		inner join DWDATE dd
		on dd.DateKey = d.DatetimeRecorded
		inner join DWDATE dd2
		on dd2.DateKey = d.FrequenceySetDate
		

	END TRY
	BEGIN CATCH

	END CATCH

END