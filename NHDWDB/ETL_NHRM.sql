﻿use NHDW
IF OBJECT_ID('ETL_NHRM') IS NOT NULL
DROP PROCEDURE ETL_NHRM;
GO
CREATE PROCEDURE ETL_NHRM AS 
BEGIN
	-- FOR EACH DIMENSION  /FACT TABLE IN THE THE DW WE'LL HAVE ONE SP TO CALL
	 -- THE ORDER CALL IS IMPORTANT -DIMENSIONS BEFORE FACTS
	 -- FOCUS ON PATIENT / MEASUREMENT /DATAPOINT 

	 --EXEC ETL_NHRM_PATIENT
	 --EXEC ETL_NHRM_MEASUREMENT
	 --EXEC ETL_NHRM_DATAPOINT
END;