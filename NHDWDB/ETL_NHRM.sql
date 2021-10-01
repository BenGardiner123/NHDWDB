CREATE PROCEDURE ETL AS
BEGIN
	--trans
	--CALL ETL PROCEDURES FROM EACH SOURCE DB
	EXEC ETL_NHRM
	--end trans
END;

CREATE PROCEDURE ETL_NHRM AS 
BEGIN
	-- FOR EACH DIMENSION  /FACT TABLE IN THE THE DW WE'LL HAVE ONE SP TO CALL
	 -- THE ORDER CALL IS IMPORTANT -DIMENSIONS BEFORE FACTS
	 -- FOCUS ON PATIENT / MEASUREMENT /DATAPOINT 

	 EXEC ETL_NHRM_PATIENT
	 EXEC ETL_NHRM_MEASUREMENT
	 EXEC ETL_NHRM_DATAPOINT
END;


CREATE PROCEDURE ETL_NHRM AS 
BEGIN
	-- WE ONLY WANT TO CALL THE DATA OVER THE NETWORK ONCE
	 -- WE ONLY WANT TO GET THE MINIMUM REQUIRED DATA
	 -- AVOID MAKING PERMAMNENT COPIES ON THE DW SIDE

	 EXEC ETL_NHRM_PATIENT
	 EXEC ETL_NHRM_MEASUREMENT
	 EXEC ETL_NHRM_DATAPOINT

	 -- query that exludes data allready in EE and DW
	 -- get required dat from source
		-- store that data in a no permament way  to pass between vaious ETL procedures
		-- apply any filters to the data
		-- insert the good data
		-- insert any data which the fiklter needs to be transofmred -- transform
END;


create procedure va_select_test as 

Begin
	--		
	declare @Testatbletype Testtabletype;
	
	declare @command nvarchar(max)

	set @command  = 'SELECT * FROM OPENROWSET(''SQLNCLI'', ' +
                    '''Server=dad.cbrifzw8clzr.us-east-1.rds.amazonaws.com;UID=ldtreadonly;PWD=Kitemud$41;'',' +
                    '''SELECT * FROM DDDM_TPS_1.dbo.PATIENT'');'
	insert into @testtable
	exec(@commnad);

	exec ETL_NHRM_PATIENT_FILTER1 @inTBALE = @testtable
	exec ETL_NHRM_PATIENT_FILTER2 @inTBALE = @testtable
	exec ETL_NHRM_PATIENT_FILTER3 @inTBALE = @testtable

	exec ETL_NHRM_PATIENT_TRANSFER_GOOD @inTBALE = @testtable










