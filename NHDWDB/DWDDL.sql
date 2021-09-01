﻿--///Ben Gardiner 102151272

-- Northen Hospital Database DDL

CREATE TABLE DIMSTAFF(
	DWDIM_STAFFID INT IDENTITY(1,1) NOT NULL, 
	DWDIM_SOURCEID INT NOT NULL, 
	DWDIM_SOURCETABLE INT NOT NULL, 
	STAFFTYPE NVARCHAR(50) NOT NULL

	CONSTRAINT PK_DIMSTAFF PRIMARY KEY (DWDIM_STAFFID),
);

CREATE TABLE DIMTREATMENT(
	DWDIM_TREATMENTID INT IDENTITY(1,1) NOT NULL,  
	DWDIM_SOURCEID INT NOT NULL, 
	DWDIM_SOURCETABLE NVARCHAR(50) NOT NULL,
	RECORDTYPE NVARCHAR(50) NOT NULL, 
	CATEGORY NVARCHAR(50) NOT NULL

	CONSTRAINT PK_DIMTREATMENT PRIMARY KEY (DWDIM_TREATMENTID),
);

CREATE TABLE DIMPATIENT(
	DWDIM_TREATMENTID INT IDENTITY(1,1) NOT NULL,
	DWDIM_SOURCEID INT NOT NULL, 
	DWDIM_SOURCETABLE NVARCHAR(50) NOT NULL, 
	GENDER NVARCHAR(50) NOT NULL,
	YEAROFBIRTH INT NOT NULL,
	SUBURB NVARCHAR(50) NOT NULL,
	POSTCODE NVARCHAR(4) NOT NULL,
	COUNTRYOFBIRTH NVARCHAR(50) NOT NULL,
	PREFERREDLANGUAGE NVARCHAR(50) NOT NULL,
	LIVESALONE BIT NOT NULL,
	ACTIVE BIT NOT NULL,
	DIAGNOSIS NVARCHAR(500) NULL,
	CATEGORYNAME NVARCHAR(50) NOT NULL,
	PROCEDUREDATE DATETIME NULL

	CONSTRAINT PK_DIMTREATMENT PRIMARY KEY (DWDIM_TREATMENTID),
);


CREATE TABLE DIMEASUREMENT(
	DWDIM_MEASUREMENTID INT IDENTITY(1,1) NOT NULL,
	DWDIM_SOURCETABLE NVARCHAR(50) NULL,
	MEASUREMENTID INT NOT NULL,
	MEASUREMENTNAME NVARCHAR(50) NOT NULL,
	DATAPOINTNUMBER INT NOT NULL,
	UPPERLIMIT INT NOT NULL,
	LOWERLIMIT INT NOT NULL,
	[NAME] NVARCHAR(50)
	CONSTRAINT PK_DIMTREATMENT PRIMARY KEY (DWDIM_MEASUREMENTID),
);

CREATE TABLE DWEPISODE(
	DWFACT_EPISODEID INT IDENTITY(1,1) NOT NULL,
	DWFACT_EPISODEDATEID INT NOT NULL,
	DATETIMERECORDED DATETIME NOT NULL,
	FREQUENCYSETDATE DATETIME NOT NULL,
	FREQUENCY INT NOT NULL,
	[VALUE] FLOAT NOT NULL,
	CONSTRAINT PK_FACTEPISODE PRIMARY KEY (DWFACT_EPISODEID),
);

CREATE TABLE DWINTERVENTION(
	DWFACT_INTERVENTIONID INT IDENTITY(1,1) NOT NULL,
	DWDATE_INTERVENTIONDATEID INT NOT NULL,
	DWDIM_PATIENTID INT NOT NULL,
	DWDIM_TREATMENTID INT,
	NOTES NVARCHAR(MAX), 
	CONSTRAINT PK_FACTINTERVENTION PRIMARY KEY (DWFACT_INTERVENTIONID),
);

CREATE TABLE DWTREATING(
	DWFACT_TREATINGID INT IDENTITY(1,1) NOT NULL,
	DWDIM_STAFFID INT NOT NULL,
	DWDIM_PATIENTID INT NOT NULL,
	DWDATE_STARTDATE INT NOT NULL,
	DWDATE_ENDDATE INT NULL
	CONSTRAINT PK_FACTTREATING PRIMARY KEY (DWFACT_TREATINGID),
);

