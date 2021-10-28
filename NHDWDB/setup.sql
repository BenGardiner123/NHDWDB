--///Ben Gardiner 102151272

-- Northen Hospital Database DDL

--CREATE DATABASE BensNHDW

------------------------------------------------------------------------------
----set up the remote login mechanaisim, ****for a regular server**** --------
------------------------------------------------------------------------------
------------need to modify the db instance to accept the new paramter group---
use master;

RECONFIGURE;

exec sp_configure 'show advanced options', 1;  

RECONFIGURE;

exec sp_configure 'Ad Hoc Distributed Queries', 1;  
RECONFIGURE;

--GO  

---------------------------------------------------------------------------
----set up the remote login mechanaisim, ****for an AWS server**** --------
---------------------------------------------------------------------------
---have to go into the GUI on aws and configure from there

-------------------------------------------------------------------------
--------------------creating a read only user on the source db-----------
-------------------------------------------------------------------------

-------------------------droppping users----------------------------------------------------
--docs.microsoft.com/en-us/sql/t-sql/statements/drop-user-transact-sql?view=sql-server-ver15
--docs.microsoft.com/en-us/sql/t-sql/statements/drop-login-transact-sql?view=sql-server-ver15
--------------------------------------------------------------------------------------------

---------------BEGIN step 1------------------------------------------------------------------
--this is settting up on the source db - in this case its the one tim has setup  - but essentially its like creating a read only account on the source db
--first login to tims db  - 
--USE [master]

--GO

----create a server level login name 'jobmanager' with a password
--CREATE LOGIN bgmanager WITH PASSWORD = 'beng123';

--GO

---------------END step 1-------------------------------------------------------------------

---------------BEGIN step 2------------------------------------------------------------------
--then using the actual db we wwant to target wse create a user for our server level login

----set context to msdb database
--USE [DDDM_TPS_1];

--GO

----added databse user and their name and link it to server level login above
--CREATE USER bgmanager FOR LOGIN bgmanager;
--GO

--exec sp_addrolemember 'db_datareader', bgmanager;

---------------END step 2-------------------------------------------------------------------
--------------------------------------------------------------------------------------------

-------------EXTRA STEP IF REQUIRED-- Verify that user is created on target db-------------
--------------------------------------------------------------------------------------------


--select name as username,
--       create_date,
--       modify_date,
--       type_desc as type,
--       authentication_type_desc as authentication_type
--from sys.database_principals
--where type not in ('A', 'G', 'R', 'X')
--      and sid is not null
--      and name != 'guest'
--order by username;
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

---------------BEGIN step 3------------------------------------------------------------------
-------------------------------------------------------------
---------this is on the datawarehouse database---------------
-------------------------------------------------------------

---then on the shared db / or alternatively the one i created we connect to the source db from our db

--CREATE DATABASE BensNHDW



SELECT *
FROM
OPENROWSET('SQLNCLI', 'Server=db.cgau35jk6tdb.us-east-1.rds.amazonaws.com;UID=bgmanager;PWD=beng123;', 
'SELECT * FROM DDDM_TPS_1.dbo.PATIENT') source;

---------------END step 3------------------------------------------------------------------


------------------------------------------------------------------
--THEN RUN THIS SCRIPT TO CREATE THE DW
------------------------------------------------------------------


--USE [BensNHDW]

--DROP TABLE IF EXISTS DIMSTAFF;
--DROP TABLE IF EXISTS DIMTREATMENT;
--DROP TABLE IF EXISTS DIMPATIENT;
--DROP TABLE IF EXISTS DIMEASUREMENT;
--DROP TABLE IF EXISTS DWEPISODE;
--DROP TABLE IF EXISTS DWINTERVENTION;
--DROP TABLE IF EXISTS DWTREATING;
--DROP TABLE IF EXISTS DWDATE;
--DROP TABLE IF EXISTS ERROR_EVENT;


--CREATE TABLE DIMSTAFF(
--	DWDIM_STAFFID INT IDENTITY(1,1) NOT NULL, -- THE SURROGATE KEY
--	DWDIM_SOURCEDB NVARCHAR(50) NOT NULL,  -- THE DATA MAY BE COMING FROM MORE THAN 1 DB E.G."RMH" OR "AUSTIN"  
--	DWDIM_SOURCETABLE INT NOT NULL, -- SOURCE TABLE POTENTIALLY FROM ANOTHER HOSPITAL ("AUSTIN_TREATMENT " OR "RMH-TREATMENT")
--	DWDIM_SOURCEID INT NOT NULL, -- THE HOSPITAL STAFF UNIQUE ID 
--	STAFFTYPE NVARCHAR(50) NOT NULL --  E.G. CLINICIAN, NURSE, RESIDENT, ADMIN ETC

--	CONSTRAINT PK_DIMSTAFF PRIMARY KEY CLUSTERED (DWDIM_STAFFID ASC)
--);


--CREATE TABLE DIMTREATMENT(
--	DWDIM_TREATMENTID INT IDENTITY(1,1) NOT NULL,  -- THE SURROGATE KEY
--	DWDIM_SOURCEDB NVARCHAR(50) NOT NULL,  -- the data may be coming from more than 1 DB e.g."RMH" or "Austin"  
--	DWDIM_SOURCETABLE NVARCHAR(50) NOT NULL, -- SOURCE TABLE POTENTIALLY FROM ANOTHER HOSPITAL ("AUSTIN_TREATMENT " OR "RMH-TREATMENT")
--	DWDIM_SOURCEID INT NOT NULL,  -- THE UNIQUE IDENTIFIER FROM THE SOURCE DB
--	RECORDTYPE NVARCHAR(50) NOT NULL, -- E.G., MMR, MRI, COVID 
--	CATEGORY NVARCHAR(50) NOT NULL --THE CATEGORY THE TREATMENT FALLS UNDER E.G., “IMMUNISATION” 

--	CONSTRAINT PK_DIMTREATMENT PRIMARY KEY CLUSTERED (DWDIM_TREATMENTID ASC)
--);

--CREATE TABLE DIMPATIENT(
--	DWDIM_PATIENTID INT IDENTITY(1,1) NOT NULL, -- SURROGATE KEY FOR THE TABLE
--	DWDIM_SOURCEDB NVARCHAR(50) NOT NULL,  -- the data may be coming from more than 1 DB e.g."RMH" or "Austin"  
--	DWDIM_SOURCETABLE NVARCHAR(50) NOT NULL,  -- SOURCE TABLE POTENTIALLY FROM ANOTHER HOSPITAL ("AUSTIN" OR "RMH")
--	DWDIM_SOURCEID NVARCHAR(50) NOT NULL,  --ALLOWS FOR OTHER DATABASES TO BE LINKED – TAKING THE PLACE OF URNUMBER HERE 
--	GENDER NVARCHAR(50) NOT NULL, -- M, F, I
--	YEAROFBIRTH INT NOT NULL, -- 1908 -- to work with the year conversion
--	SUBURB NVARCHAR(50) NOT NULL, -- E.G., “ELTHAM”
--	POSTCODE NVARCHAR(4) NOT NULL, -- E.G., 3113, 4578
--	COUNTRYOFBIRTH NVARCHAR(50) NOT NULL, --E.G., AUSTRALIA, INDIA 
--	LIVESALONE BIT NOT NULL, -- 1 OR 0
--	ACTIVE BIT NOT NULL, -- 1 OR 0
--	DIAGNOSIS NVARCHAR(500) NULL,  --EXPLANATION TO THE PATIENT ABOUT THEIR CONDITION 
--	CATEGORYNAME NVARCHAR(50) NULL, --SO, WE CAN ACCESS THE CATEGORY OF ISSUE THEY HAVE E.G., INDWELLING PLEURAL CATHETER, COPD, ASTHMA
--	PROCEDUREDATE DATETIME NULL -- 12/12/12 12:23:23:22

--	CONSTRAINT PK_DIMAPATIENT PRIMARY KEY CLUSTERED (DWDIM_PATIENTID ASC)
--);


--CREATE TABLE DIMEASUREMENT(
--	DWDIM_MEASUREMENTID INT IDENTITY(1,1) NOT NULL, -- THE SURROGATE KEY
--	DWDIM_SOURCEDB NVARCHAR(50) NOT NULL,  -- the data may be coming from more than 1 DB e.g."RMH" or "Austin"  ----added because of previous erro not to include
--	DWDIM_SOURCETABLE NVARCHAR(50) NOT NULL, -- SOURCE TABLE POTENTIALLY FROM ANOTHER HOSPITAL E.G ("AUSTIN_IPC") 
--	MEASUREMENTID INT NOT NULL, --THE ID NUMBER RELATED TO EACH MEASUREMENT
--	MEASUREMENTNAME NVARCHAR(50) NOT NULL, --THE NAME OF THE MEASUREMENT TO BE TAKEN E.G., ”BREATHLESSNESS”
--	DATAPOINTNUMBER INT NOT NULL, --EACH MEASUREMENT HAS EITHER ONE OR MANY DATA POINTS ASSOCIATED WITH IT, E.G., 1, 2, 3
--	UPPERLIMIT INT NOT NULL, -- MAX REPORTABLE VALUE, E.G., 100, 600, 5  
--	LOWERLIMIT INT NOT NULL, --MIN REPORTABLE VALUE E.G., 1, 0  
--	[NAME] NVARCHAR(50) NULL --NAME OF THE DATA POINT MEASUREMENT  MATCHES UP WITH MEASUREMENT NAME E.G., ‘MOBILITY'
--	CONSTRAINT PK_DIMMEASUREMENT PRIMARY KEY CLUSTERED (DWDIM_MEASUREMENTID ASC)
--);

--CREATE TABLE DWEPISODE(
--	DWFACT_EPISODEID INT IDENTITY(1,1) NOT NULL, --THE SURROGATE KEY
--	DWFACT_EPISODEDATEID INT NOT NULL, --WILL REFER TO A DATE KEY IN THE DWADATE TABLE
--	DWDIM_MEASUREMENTID INT NOT NULL, --REFERS TO THE PRIMARY KEY IN THE DIMMEASUREMENT TABLE
--	DWDIM_PATIENTID INT NOT NULL, --REFERS TO THE SURROGATE KEY FROM THE PATIENT DIMENSION TABLE 
--	DATETIMERECORDED DATETIME NOT NULL, --REFERS TO THE DATE AND TIME THAT THE EPISODE BETWEEN PATIENT AND CLINICIAN OCCURS E.G(2021-09-01 12:12:22.00)
--	FREQUENCYSETDATE DATETIME NOT NULL, --REFERS TO THE DATE AND TIME THE CLINICIAN SETS THE FREQUENCY E.G (2021-09-01 12:12:22.00)
--	FREQUENCY INT NOT NULL, -- THE NUMBER OF DAYS BETWEEN MEASUREMENTS (31 OR 7 etc..)
--	[VALUE] FLOAT(10) NOT NULL, -- ACTUAL VALUE TAKEN E.G (1.0 OR 2.3)
	
--	CONSTRAINT PK_FACTEPISODE PRIMARY KEY CLUSTERED (DWFACT_EPISODEID ASC)
--);

--CREATE TABLE DWINTERVENTION(
--	DWFACT_INTERVENTIONID INT IDENTITY(1,1) NOT NULL, -- SURROGATE KEY FOR THIS TABLE 
--	DWDATE_INTERVENTIONDATEID INT NOT NULL, -- ID THAT WILL REFERENCE THE KEY FORM DWDATE TABLE
--	DWDIM_PATIENTID INT NOT NULL, -- SURROGATE KEY FROM PATIENT TABLE
--	DWDIM_TREATMENTID INT, -- SURROGATE KEY FROM TREATMENT TABLE
--	NOTES NVARCHAR(MAX), --CLINICIANS NOTES REGARDING THE INTERVENTION E.G., “PATIENT REQUIRES COVID VACCINE ASAP”
	
--	CONSTRAINT PK_FACTINTERVENTION PRIMARY KEY CLUSTERED (DWFACT_INTERVENTIONID ASC)
--);

--CREATE TABLE DWTREATING(
--	DWFACT_TREATINGID INT IDENTITY(1,1) NOT NULL, -- SURROGATE KEY
--	DWDIM_STAFFID INT NOT NULL,	-- REFERENCES THE STAFF DIMESNSION TABLE 
--	DWDIM_PATIENTID INT NOT NULL, -- REFENCES THE PATIENT DIMENSION TABLE
--	DWDATE_STARTDATE INT NOT NULL, -- REFERENCES THE DATE KEY FROM THE DATE TABLE 
--	DWDATE_ENDDATE INT NULL -- THE END DATE OF THE TREATMENT WILL BE NULL TO BEGIN WITH 
	
--	CONSTRAINT PK_FACTTREATING PRIMARY KEY CLUSTERED (DWFACT_TREATINGID ASC)
--);

--CREATE TABLE DWDATE(   
--	DATEKEY INTEGER PRIMARY KEY,  -- 1, 2, 3, further feilds to follow 

--);

--CREATE TABLE ERROREVENT (
--ERRORID INT IDENTITY(1,1) NOT NULL, --KEY GENERATED TO ID THE SPECIFIC ERROR EG 1, 2, 3
--SOURCE_DB NVARCHAR(50), -- THE DB THAT THE TPS TABLE IS IN "RMH", "AUSTIN"
--SOURCE_ID NVARCHAR(50), -- THE KEY FROM THE TPS TABLE 
--SOURCE_TABLE NVARCHAR(50), -- THE TABLE NAME
--FILTERID INTEGER, -- THE CORRSPONDING FILTER ID THAT TRIGGERS THE ERRROR
--DATE_TIME DATETIME, -- (2021-09-01 12:12:22.00)
--ACTION NVARCHAR(50), --'SKIP','MODIFY'
--NOTES NVARCHAR(500)
--CONSTRAINT ERROREVENTACTION CHECK (ACTION IN ('SKIP','MODIFY'))
--);

--GO

--CREATE TABLE ETL_LOG (
--SOURCE_PROCEDURE NVARCHAR(100), -- THIS TELLS YOU THE PROCEDURE THAT CREATES THE LOG ENTRY E.DIM_PATIENT
--ETL_EVENT_DATETIME DATETIME, -- (2021-09-01 12:12:22.00)
--EVENT_DETAILS NVARCHAR(MAX), -- THE DETAILS OR MESSAGE -- PROBABLY AN ERROR MESSAGE(WITH A CODE) OR SUCCESS MESSAGE
--);

--GO

-------------------create the connection string function----------------------------------------------

DROP FUNCTION IF EXISTS GET_CONNECTION_STRING;
GO

CREATE FUNCTION GET_CONNECTION_STRING() RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN 'Server=db.cgau35jk6tdb.us-east-1.rds.amazonaws.com;UID=ldtreadonly;PWD=Kitemud$41;';
END;
GO
------------------------------------------------------------------------------------------------------
---------------------------create the table varivbles-------------------------------------------------
USE NHDW
DROP TYPE IF EXISTS TestPatientTable;
GO

-- Create a table varible to pass the new data into - then we can pass this into each filter

CREATE TYPE TESTPATIENTTABLE AS TABLE (
    DWDIM_SOURCEID       NVARCHAR(100),
    GENDER               NVARCHAR(100),
    YEAROFBIRTH          INT,
    SUBURB               NVARCHAR(100),
    POSTCODE             NVARCHAR(4),
    COUNTRYOFBIRTH       NVARCHAR(100),
    LIVESALONE           BIT,
    ACTIVE               BIT,
	DIAGNOSIS            NVARCHAR(500),
    CATEGORYNAME         NVARCHAR(100),
    PROCEDUREDATE        DATETIME
);

GO

USE NHDW
DROP TYPE IF EXISTS TESTMEASUREMENTTABLE;

GO

-- Create a table varible to pass the new data into - then we can pass this into each filter

CREATE TYPE TESTMEASUREMENTTABLE AS TABLE (
    MEASUREMENTID INT NOT NULL, --THE ID NUMBER RELATED TO EACH MEASUREMENT
    DATAPOINTNUMBER INT NOT NULL, --EACH MEASUREMENT HAS EITHER ONE OR MANY DATA POINTS ASSOCIATED WITH IT, E.G., 1, 2, 3
    MEASUREMENTNAME NVARCHAR(50) NOT NULL, --THE NAME OF THE MEASUREMENT TO BE TAKEN E.G., ”BREATHLESSNESS”
    [NAME] NVARCHAR(50) NULL, --NAME OF THE DATA POINT MEASUREMENT  MATCHES UP WITH MEASUREMENT NAME E.G., C:\Users\ben_g\Source\Repos\NHDWDB\NHDWDB\DIM_PATIENT_FILTER_1.sql‘MOBILITY'
    UPPERLIMIT INT NOT NULL, -- MAX REPORTABLE VALUE, E.G., 100, 600, 5  
    LOWERLIMIT INT NOT NULL --MIN REPORTABLE VALUE E.G., 1, 0  
);

GO

USE NHDW
DROP TYPE IF EXISTS TEST_TREAMENT_TABLE;

GO

-- Create a table varible to pass the new data into - then we can pass this into each filter

CREATE TYPE TEST_TREAMENT_TABLE AS TABLE (
   
   	DWDIM_SOURCEID INT NOT NULL,  -- THE UNIQUE IDENTIFIER FROM THE SOURCE DB
    RECORDTYPE NVARCHAR(50) NOT NULL, -- E.G., MMR, MRI, COVID 
    CATEGORY NVARCHAR(50) NOT NULL --THE CATEGORY THE TREATMENT FALLS UNDER E.G., “IMMUNISATION” 
    );

GO

USE NHDW
DROP TYPE IF EXISTS TEST_EPISODE_TABLE;

GO

-- Create a table varible to pass the new data into - then we can pass this into each filter

CREATE TYPE TEST_EPISODE_TABLE AS TABLE (
   
   	
    );

GO



-------------------------------------populate the dwdate table-------------------------------------
use NHDW

SET NOCOUNT ON

TRUNCATE TABLE DWDATE

DECLARE @CurrentDate DATE = '1910-01-01'
DECLARE @EndDate DATE = '2022-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO [dbo].[DWDATE] (
      [DateKey],
      [Date],
      [Day],
      [DaySuffix],
      [Weekday],
      [WeekDayName],
      [WeekDayName_Short],
      [WeekDayName_FirstLetter],
      [DOWInMonth],
      [DayOfYear],
      [WeekOfMonth],
      [WeekOfYear],
      [Month],
      [MonthName],
      [MonthName_Short],
      [MonthName_FirstLetter],
      [Quarter],
      [QuarterName],
      [Year],
      [MMYYYY],
      [MonthYear],
      [IsWeekend],
      [IsHoliday],
      [FirstDateofYear],
      [LastDateofYear],
      [FirstDateofQuater],
      [LastDateofQuater],
      [FirstDateofMonth],
      [LastDateofMonth],
      [FirstDateofWeek],
      [LastDateofWeek]
      )
   SELECT DateKey = DAY(@CurrentDate) + MONTH(@CurrentDate) * 100 + YEAR(@CurrentDate) * 10000,
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [DaySuffix] = CASE 
         WHEN DAY(@CurrentDate) = 1
            OR DAY(@CurrentDate) = 21
            OR DAY(@CurrentDate) = 31
            THEN 'st'
         WHEN DAY(@CurrentDate) = 2
            OR DAY(@CurrentDate) = 22
            THEN 'nd'
         WHEN DAY(@CurrentDate) = 3
            OR DAY(@CurrentDate) = 23
            THEN 'rd'
         ELSE 'th'
         END,
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
      [DOWInMonth] = DAY(@CurrentDate),
      [DayOfYear] = DATENAME(dy, @CurrentDate),
      [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'second'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'third'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'fourth'
         END,
      [Year] = YEAR(@CurrentDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
      [MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
            OR DATENAME(dw, @CurrentDate) = 'Saturday'
            THEN 1
         ELSE 0
         END,
      [IsHoliday] = 0,
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Update Holiday information
UPDATE DWDATE
SET [IsHoliday] = 1,
   [HolidayName] = 'Christmas'
WHERE [Month] = 12
   AND [DAY] = 25

UPDATE DWDATE
SET SpecialDays = 'Valentines Day'
WHERE [Month] = 2
   AND [DAY] = 14

--Update current date information
UPDATE DWDATE
SET CurrentYear = DATEDIFF(yy, GETDATE(), DATE),
   CurrentQuater = DATEDIFF(q, GETDATE(), DATE),
   CurrentMonth = DATEDIFF(m, GETDATE(), DATE),
   CurrentWeek = DATEDIFF(ww, GETDATE(), DATE),
   CurrentDay = DATEDIFF(dd, GETDATE(), DATE)

-----------------------------------------------------------------------------------------------
--------------------------- populate the patient dimension table-------------------------------


-----------------------------------------------------------------------------------------------

--------------------------------call the etl process--------------------------
EXEC ETL_NHRM;

select * from
DIMPATIENT

select *
FROM ERRORevent