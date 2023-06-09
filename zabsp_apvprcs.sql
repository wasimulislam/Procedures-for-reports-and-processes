USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_apvprcs]    Script Date: 3/14/2023 12:00:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- EXEC zabsp_apvprcs 100070,'1349','1349','GRN-002690','0','Applied','GRN Approval'
ALTER PROC [dbo].[zabsp_apvprcs]
	
	 @zid INT
	,@user VARCHAR(50)
	,@position VARCHAR(50)
	,@reqnum VARCHAR(50)
	,@ypd INT
	,@status VARCHAR(50)
	,@aprcs VARCHAR(50)


AS

DECLARE 
	@appstatus VARCHAR(50),
	@designation VARCHAR(50),
	@action VARCHAR(50),
	@superior VARCHAR(50),
	@superior2 varchar(50),
	@superior3 varchar(50),
	@superior4 VARCHAR(50),
	@superior5 varchar(50),
	@superior6 varchar(50),
	@cus VARCHAR(50),
	@xwh VARCHAR(50),
	@trn VARCHAR(50),
	@staff VARCHAR(50),
	@vouchecrno VARCHAR(50),
	@vyear INT,
	@vper INT,
	@date DATE,
	@sign INT,
	@year INT,
	@empposition INT,
	@dornum VARCHAR(50),
	@costrow INT,
	@wh VARCHAR(50),
	@shift VARCHAR(50),
	@statusar VARCHAR(50),
	@statusjv VARCHAR(50),
	@tomail VARCHAR(150),
	@mail1 varchar(50),
	@mail2 varchar(50),
	@mail3 varchar(50),
	@delegate1 varchar(50),
	@delegate2 varchar(50),
	@delegate3 varchar(50),
	@loantype varchar(50),
	@loanacc varchar(50),
	@reqstatus varchar(50),
	@reqtype varchar(50),
	@value DECIMAL(20,2),
	@maxval DECIMAL(20,2),
	@maxvalexceed DECIMAL(20,2),
	@reqval DECIMAL(20,2),
	@poaccruedgl VARCHAR(50),
	@potype varchar(50),
	@imglauto varchar(20),
	@subprcs varchar(50)



----init----------
SET @tomail=''
SET @mail1=''
SET @mail2=''
SET @mail3=''
SET @delegate1=''
SET @delegate2=''
SET @delegate3=''
SET @vyear = 0
SET @vper = 0
SET @value=0	set @maxval=0	set @reqval=0	SET @reqstatus=''	SET @maxvalexceed = 0

--======================================SR & WR Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','SR_WR Approval'
--================================================================================================
IF @aprcs='SR_WR Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='SR_WR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='SR_WR Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='SR_WR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SR_WR Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SR_WR Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SR_WR Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SR_WR Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SR_WR Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Approved',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END




--======================================Pre Process Batch Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','Pre Process Batch Approval'
--================================================================================================


IF @aprcs='Pre Process Batch Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Pre Process Batch Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Pre Process Batch Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Pre Process Batch Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE moheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE moheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE moheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE moheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE moheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE moheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE moheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE moheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from moheader  WHERE zid=@zid AND xbatch=@reqnum) ='Approved'
		Update moheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xbatch=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END




--======================================Batch Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','Batch Approval'
--================================================================================================


IF @aprcs='Batch Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Batch Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Batch Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Batch Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE moheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE moheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE moheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE moheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE moheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE moheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE moheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE moheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbatch=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from moheader  WHERE zid=@zid AND xbatch=@reqnum) ='Approved'
		Update moheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xbatch=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--======================================RMCA Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','RMCA Approval'
--================================================================================================


IF @aprcs='RMCA Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='RMCA Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='RMCA Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='RMCA Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imconsumptionadjheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imconsumptionadjheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xadjnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from imconsumptionadjheader  WHERE zid=@zid AND xadjnum=@reqnum) ='Approved'
		Update imconsumptionadjheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xadjnum=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--======================================Scrap Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','SR_WR Approval'
--================================================================================================
ELSE IF @aprcs='Scrap Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,''),@xwh=xfwh,@date=xdate from imtorheader WHERE zid=@zid AND xtornum=@reqnum

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Scrap Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Scrap Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Scrap Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Scrap Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		BEGIN
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'
		EXEC sp_confirmTO @zid,@user,@position,@reqnum,@date,@xwh,@xwh,'Approved','Scrap Opening',6
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END

--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','SR--000018','0','Open','SR_WR Approval'
--================================================================================================
ELSE IF @aprcs='Asset Issue Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='Asset Issue Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Asset Issue Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='Asset Issue Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='Asset Issue Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='Asset Issue Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Asset Issue Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Asset Issue Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Asset Issue Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Approved',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END





Else IF @aprcs='SPR Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype='' ,@subprcs=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift <> '' AND @reqtype <> '' and @subprcs<>''
	BEGIN
	---- PRINT '1'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift <> '' and @subprcs<>'' and @reqtype=''
	BEGIN
	--PRINT '2'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' and xsubprcs=@subprcs) AND @shift <> '' and @reqtype<>''  and @subprcs=''
	begin
	--print '3'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' and xsubprcs=''
	end
	

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift='' and @reqtype <> '' and @subprcs=''
	BEGIN
	--PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' AND xsubprcs=''
	END
	
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift = '' and @reqtype='' and @subprcs<>''
	BEGIN
	--PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift = '' and @reqtype='' and @subprcs=''
	BEGIN
	--PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=''
	END
	
	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')=@shift and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SPR Approval' AND xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SPR Approval' AND xsubprcs=@subprcs  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SPR Approval' AND xsubprcs=@subprcs  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
	  ,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END

--=================================Transfer & Damage Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','DAM-000018','0','Open','TO Approval'
--================================================================================================
ELSE IF @aprcs='TO Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='TO Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='TO Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND isnull(xreqtype,'')='' AND xtypetrn='TO Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='TO Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='TO Approval'  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='TO Approval'  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--=================================Inspection Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','DAM-000018','0','Open','Inspection Approval'
--================================================================================================
ELSE IF @aprcs='Inspection Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Inspection Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Inspection Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Inspection Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Inspection Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Inspection Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Inspection Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Inspection Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Inspection Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--=================================Invoice Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','DAM-000018','0','Open','Invoice Approval'
--================================================================================================
ELSE IF @aprcs='Invoice Approval'
BEGIN
SET @dornum =@reqnum
----------------------------------Getting Superior--------------------
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xtypetrn='Invoice Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Invoice Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Invoice Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Invoice Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE opdoheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE opdoheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory2'
			UPDATE opdoheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory3'
			UPDATE opdoheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory4'
			UPDATE opdoheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory5'
			UPDATE opdoheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory6'
			UPDATE opdoheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE IF @designation='signatory7'
			UPDATE opdoheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdornum=@dornum
		ELSE RETURN
	END
	
	IF (Select xstatus from opdoheader  WHERE zid=@zid AND xdornum=@dornum) ='Approved'
		Update opdoheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xdornum=@dornum and xstatus='Approved'

	IF (Select isnull(xcat,'') from zbusiness where zid = @zid) ='Construction' AND (Select isnull(xstatus,'') from opdoheader  WHERE zid=@zid AND xdornum=@dornum) ='Approved'
	BEGIN
	Select @wh = xwh,@statusar =isnull(xstatusar,''),@statusjv = isnull(xstatusjv,'') from opdoheader where zid = @zid AND xdornum = @dornum
	IF @statusar = 'Open'
		EXEC zabsp_OP_transferOPtoAR @zid,@user,@dornum,'opdoheader'
	IF @statusjv = 'Open'
		EXEC zabsp_OP_transferOPtoGL @zid,@user,@dornum,'opdoheader'
	END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END
--=================================Purchase Return Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','DAM-000018','0','Open','Inspection Approval'
--================================================================================================
ELSE IF @aprcs='PRN Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='PRN Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='PRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='PRN Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='PRN Approval'


------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='PRN Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='PRN Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='PRN Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
--IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
--	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
--ELSE 
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--=================================Damage Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','DAM-000018','0','Open','Damage Approval'
--================================================================================================
ELSE IF @aprcs='Damage Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Damage Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Damage Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Damage Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Damage Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND isnull(xreqtype,'')='' AND xtypetrn='Damage Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Damage Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Damage Approval'  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Damage Approval'  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum

ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--======================================Loan Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','LRE-000018','0','Open','Loan Approval'
--================================================================================================
ELSE IF @aprcs='Loan Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Loan Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Loan Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Loan Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Loan Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Loan Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Loan Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Loan Approval'  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Loan Approval'  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
 IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory1' and ((left(@loanacc,1) not in ('P','C','S') AND Left(@reqnum,4) ='LIS-' AND @loantype='Loan Issue') 
											or (left(@loanacc,1) not in ('P','C','S') AND Left(@reqnum,4) ='LRE-' AND @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor ='Approved',xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3=''
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory2' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory3' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory4' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory5' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory6' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		
		ELSE IF @designation='signatory7' and (left(@loanacc,1) in ('P','C','S') or (Left(@reqnum,4) ='LRE-' and @loantype='Loan Receive') or (Left(@reqnum,4) ='LIS-' and @loantype='Loan Return'))
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
	Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--=================================Received Return Approval=======================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','RR--000018','0','Open','RR Approval'
--================================================================================================
ELSE IF @aprcs='RR Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='RR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='RR Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='RR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='RR Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='RR Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='RR Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='RR Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='RR Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END
--========================Cash Approval & Adjustment Approval=====================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','PR--000018','0','Approved_EP','Cash Approval'
--================================================================================================
ELSE IF @aprcs in ('Cash Approval')
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN

Select @reqtype='',@subprcs=isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@reqnum
	--print @reqtype
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype<>'' )
	BEGIN
	--PRINT 'AA'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=@subprcs   and @subprcs<>'' AND @reqtype='' ) 
	BEGIN
		--PRINT '34D'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'')  
	BEGIN
	--PRINT '34C'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=''
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs='' AND @subprcs='' and @reqtype='')
	BEGIN
	--PRINT @REQTYPE
	--PRINT '34A' 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=''		
	END
	ELSE
	BEGIN
		-- PRINT '34'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs
Select @xwh=ISNULL(xfwh,'') from poreqheader WHERE zid=@zid and xporeqnum=@reqnum

Select @reqval=sum(isnull(xlineamt,0)) from poreqdetail WHERE zid=@zid AND xporeqnum=@reqnum 
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Cash Approval' and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Cash Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Cash Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3

--=================================End========================================		
		IF @designation='signatory1'
			UPDATE poreqheader set xstatusreq =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE poreqheader set xstatusreq =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE poreqheader set xstatusreq =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE poreqheader set xstatusreq =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE poreqheader set xstatusreq =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE poreqheader set xstatusreq =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE poreqheader set xstatusreq =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatusreq from poreqheader  WHERE zid=@zid AND xporeqnum=@reqnum) ='Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xporeqnum=@reqnum and xstatusreq='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--=============================Payment Authorization form Approval================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','PAF-000018','0','Approved_EP','PAF Approval'
--================================================================================================
ELSE IF @aprcs='PAF Approval'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @reqtype = isnull(xtypeobj,'') from appaymentreqh WHERE zid=@zid AND xpafnum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='PAF Approval'

--================== Threshold Approval =====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xlineamt,0)) from appaymentreqd WHERE zid=@zid AND xpafnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
		
		IF @designation='signatory1'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE appaymentreqh set xstatusreq =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpafnum=@reqnum
		ELSE RETURN
 END

	IF (Select xstatusreq from appaymentreqh  WHERE zid=@zid AND xpafnum=@reqnum) ='Approved'
		Update appaymentreqh set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xpafnum=@reqnum and xstatusreq='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--=============================Payment Authorization form Approval================================
--************************************************************************************************
--EXEC zabsp_apvprcs 100000,'mohiuddin','00238','PADJ000001','0','Applied','Adjustment Approval'
--================================================================================================
ELSE IF @aprcs='Adjustment Approval'
BEGIN
SET @aprcs='PAF Approval'

IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @reqtype = isnull(xtypeobj,'') from appaymentreqh WHERE zid=@zid AND xpafnum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='PAF Approval'

--================== Threshold Approval =====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xlineamt,0)) from poreqdetail WHERE zid=@zid AND xporeqnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='PAF Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================	 
		
		IF @designation='signatory1'
			UPDATE poreqheader set xstatusreq =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE poreqheader set xstatusreq =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE poreqheader set xstatusreq =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE poreqheader set xstatusreq =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE poreqheader set xstatusreq =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE poreqheader set xstatusreq =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE poreqheader set xstatusreq =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE RETURN
 END

	IF (Select xstatusreq from poreqheader  WHERE zid=@zid AND xporeqnum=@reqnum) ='Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xporeqnum=@reqnum and xstatusreq='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END
--================================CS Approval=====================================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Suvasish.Sarkar','00541','PR--000022','0','Recommended','CS Approval'
--================================================================================================
ELSE IF @aprcs in ('CS Approval') 
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN

Select @reqtype='',@subprcs=isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@reqnum
	-- PRINT @reqtype
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype<>'' )
	BEGIN
	-- PRINT 'AA'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs=@subprcs   and @subprcs<>'' AND @reqtype='' ) 
	BEGIN
		-- PRINT '34D'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'')  
	BEGIN
	-- PRINT '34C'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=''
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs='' AND @subprcs='' and @reqtype='')
	BEGIN
	-- PRINT @REQTYPE
	-- PRINT '34A' 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs=''		
	END
	ELSE
	BEGIN
		-- PRINT '34'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs
Select @xwh=ISNULL(xfwh,'') from poreqheader WHERE zid=@zid and xporeqnum=@reqnum

Select @reqval=sum(isnull(xlineamt,0)) from poquotdetail WHERE zid=@zid AND xporeqnum=@reqnum and xqotnum =(Select xqotnum from poreqheader where  zid=@zid AND xporeqnum=@reqnum) and xqotnum <>''
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END

--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'CS Approval' and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='CS Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='CS Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3

IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs)
	 UPDATE poreqheader set xstatusreq ='Applied',xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3 WHERE zid=@zid AND xporeqnum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs)
BEGIN
--=================================End========================================		
		IF @designation='signatory1'
			UPDATE poreqheader set xstatusreq =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE poreqheader set xstatusreq =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE poreqheader set xstatusreq =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE poreqheader set xstatusreq =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE poreqheader set xstatusreq =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE poreqheader set xstatusreq =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE poreqheader set xstatusreq =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatusreq from poreqheader  WHERE zid=@zid AND xporeqnum=@reqnum) ='Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xporeqnum=@reqnum and xstatusreq='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
	END
END

--================================CS Approval=====================================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Suvasish.Sarkar','00541','PR--000022','0','Recommended','CS Approval'
--================================================================================================
ELSE IF @aprcs='SQ Approval'
BEGIN
Select @reqtype = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQ Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQ Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@reqstatus=isnull(xstatus,''),@maxvalexceed =isnull(xmaxbal,0) from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='SQ Approval'
--================== Threshold Approval =====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xlineamt,0)) from poreqdetail WHERE zid=@zid AND xporeqnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='SQ Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SQ Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SQ Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE poreqheader set xstatusreq ='Applied',xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3 WHERE zid=@zid AND xporeqnum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
		IF @designation='signatory1'
			UPDATE poreqheader set xstatusreq =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE poreqheader set xstatusreq =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE poreqheader set xstatusreq =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE poreqheader set xstatusreq =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE poreqheader set xstatusreq =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE poreqheader set xstatusreq =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE poreqheader set xstatusreq =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xporeqnum=@reqnum
		ELSE RETURN

 	IF (Select xstatusreq from poreqheader  WHERE zid=@zid AND xporeqnum=@reqnum) ='Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatusreq='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
 END
END
--================================PO Approval=====================================================

--ELSE IF @aprcs='PO Approval'
--BEGIN
--IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
--BEGIN

--Select @reqtype=isnull(xtypeobj,''),@subprcs=isnull(xtypeobj,'') from poordheader WHERE zid=@zid AND xpornum=@reqnum

--	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
--	and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs)
--	BEGIN
--	-- PRINT 'Cursor in position A'
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
--		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval = isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus = isnull(xstatus,'') from pdsuperior 
--			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=@subprcs AND isnull(xreqtype,'')= @reqtype
--	END
--	ELSE IF isnull(@reqtype,'')=''
--	BEGIN
--	-- PRINT 'Cursor in position B'
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
--		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
--			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=@subprcs AND isnull(xreqtype,'')=''
--	END
----================== Threshold Approval=====================================
--SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs 

--Select @reqval=sum(isnull(xlineamt,0)) from poorddetail WHERE zid=@zid AND xpornum=@reqnum 
--IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
--SET @status=@reqstatus

--IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
--BEGIN
--IF @superior4 <> '' SET @superior = @superior4
--IF @superior5 <> '' SET @superior2 = @superior5
--IF @superior6 <> '' SET @superior3 = @superior6
--END
----=================Approver Delegations=======================================
--Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PO Approval' and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
--Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='PO Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
--Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='PO Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 

--IF @delegate1<>'' SET @superior=@delegate1
--IF @delegate2<>'' SET @superior2=@delegate2 
--IF @delegate3<>'' SET @superior3=@delegate3

----=================================End========================================		
--		IF @designation='signatory1'
--			UPDATE poordheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory2'
--			UPDATE poordheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory3'
--			UPDATE poordheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory4'
--			UPDATE poordheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory5'
--			UPDATE poordheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory6'
--			UPDATE poordheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE IF @designation='signatory7'
--			UPDATE poordheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
--				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
--		ELSE RETURN
-- END

-- 	IF (Select xstatus from poordheader  WHERE zid=@zid AND xpornum=@reqnum) ='Approved'
--		Update poordheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xpornum=@reqnum and xstatus='Approved'

--		-----------------Mail Configure & Sending Mail----------------
--	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
--	BEGIN
--	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
--	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
--	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
--	IF @mail1<>'' SET @mail1=@mail1
--	IF @mail2<>'' SET @mail2=';'+@mail2
--	IF @mail3<>'' SET @mail3=';'+@mail3
--	SET @tomail=@mail1+@mail2+@mail3
		
--	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
--	END
--END



--************************************************************************************************
--zabsp_apvprcs 100070,'675','675','PO--000001','0','Open','PO Approval'
--================================================================================================
ELSE IF @aprcs='PO Approval'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN

Select @reqtype='',@subprcs=isnull(xtypeobj,'') from poordheader WHERE zid=@zid AND xpornum=@reqnum
	-- PRINT @reqtype
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs  and @subprcs<>'' and @reqtype<>'') -- 
	BEGIN
	-- PRINT 'Cursor in position A'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval = isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus = isnull(xstatus,'') from pdsuperior 
			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=@subprcs 
			AND isnull(xreqtype,'')= @reqtype
	END
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype='') -- 
	BEGIN
	-- PRINT 'Cursor in position b'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval = isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus = isnull(xstatus,'') from pdsuperior 
			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=@subprcs 
			AND isnull(xreqtype,'')= ''
	END
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'' ) -- 
	BEGIN
	-- PRINT 'Cursor in position c'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval = isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus = isnull(xstatus,'') from pdsuperior 
			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs='' 
			AND isnull(xreqtype,'')= @reqtype
	END

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=''  and @subprcs='' and @reqtype='') --and @reqnum=''
	BEGIN
	-- PRINT 'Cursor in position d'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval = isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus = isnull(xstatus,'') from pdsuperior 
			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=''
			AND isnull(xreqtype,'')= ''
	END
	ELSE
	BEGIN
	-- PRINT 'Cursor in position e'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
			WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='PO Approval' and xsubprcs=@subprcs 
			AND isnull(xreqtype,'')=@reqtype
	END
--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs 

Select @reqval=sum(isnull(xlineamt,0)) from poorddetail WHERE zid=@zid AND xpornum=@reqnum 
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PO Approval' and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='PO Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='PO Approval'and xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3

--=================================End========================================		
		IF @designation='signatory1'
			UPDATE poordheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE poordheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE poordheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE poordheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE poordheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE poordheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE poordheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xpornum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatus from poordheader  WHERE zid=@zid AND xpornum=@reqnum) ='Approved'
		Update poordheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xpornum=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--================================================================================================
IF @aprcs='SO Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn=@aprcs) --//and xshift=@shift
	Select @superior=isnull(xsuperior1,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn=@aprcs -- and xshift=@shift 

ELSE 
	Select @superior=isnull(xsuperior1,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND xtypetrn=@aprcs

---- PRINT @position
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= @aprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= @aprcs  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= @aprcs  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
-- PRINT '======'
---- PRINT @position
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
	  ,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum

ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs																																																																	
																																			
		IF @designation='signatory1'
			BEGIN
			--print @superior
			--print @designation
			--print @status
			--print @reqnum

				UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
					,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
			END
		ELSE IF @designation='signatory2'
			BEGIN
			--print @superior2
			--print @designation
			--print @status
			--print @reqnum


			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
					,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
				--,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
			END
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatus =@status,xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END  
-- PRINT @position
	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved'  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior 
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
		--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END



--================================PO Approval=====================================================
--************************************************************************************************
-- EXEC zabsp_apvprcs 100070,'1349','1349','GRN-002690',0,'Applied','GRN Approval'
--================================================================================================
ELSE IF @aprcs='GRN Approval'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @date = xdate, @wh = xwh,@reqtype='',@subprcs = isnull(xtypeobj,'') from pogrnheader WHERE zid = @zid AND xgrnnum = @reqnum 
Select @imglauto =isnull(ximglauto,'No'),@poaccruedgl =ISNULL(xpoaccruedgl,'No') from poimdef where zid = @zid
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GRN Approval' and xsubprcs = @subprcs)
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GRN Approval' and xsubprcs = @subprcs
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='GRN Approval' and xsubprcs = @subprcs

--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs = @subprcs

Select @reqval=sum(isnull(xlineamt,0)) from pogrndetail WHERE zid=@zid AND xgrnnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'GRN Approval' and xsubprcs = @subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'GRN Approval' and xsubprcs = @subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'GRN Approval' and xsubprcs = @subprcs and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================		
		IF @designation='signatory1'
			UPDATE pogrnheader set xstatusdoc =@status,xfwh=xwh,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum and xtypeobj = @subprcs) ='Approved'
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xgrnnum=@reqnum and xstatus='Approved'


	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum and xtypeobj = @subprcs) ='Approved' AND left(@reqnum,3) = 'GRN' --and @zid in (100070,200010,100120,100170,100180)
	BEGIN
		-- PRINT 'moshiur'
		EXEC zabsp_PO_confirmGRN @zid,@user,@reqnum,@date,@wh,6
		-- PRINT 'ok'
		IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid and xtypeobj = @subprcs AND xgrnnum=@reqnum and isnull(xtype,'') NOT IN ('Cash','Spot Purchase')) ='Approved' AND left(@reqnum,3) = 'GRN'  AND @imglauto = 'Yes'  --and @zid in (100070,100120,200010,100170,100180)
		BEGIN
		EXEC zabsp_PO_transferPOtoAP @zid,@user,@reqnum,'pogrnheaderac'
		EXEC zabsp_PO_transferPOtoGL @zid,@user,@reqnum,'pogrnheaderac'

		Select @vouchecrno=xvoucher from pogrnheader where zid = @zid AND xgrnnum = @reqnum
		Select @vyear=xyear, @vper =xper from acheader where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		Update acheader set xstatus='Approved' where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		EXEC sp_acPost @zid,@user,@vyear,@vper,@vouchecrno,@vouchecrno
		END

	end
		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--================================PO Approval=====================================================
--************************************************************************************************
--zabsp_apvprcs 100000,'mazhar.iqbal','00253','','0','GRN-000368','GRN Approval'
--================================================================================================
ELSE IF @aprcs='SQC Approval'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @date = xdate, @wh = xwh,@reqtype = isnull(xtypeobj,''),@shift=isnull(xproject,'') from pogrnheader WHERE zid = @zid AND xgrnnum = @reqnum 

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SQC Approval') AND @shift <> '' AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SQC Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval') AND @shift <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SQC Approval') AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SQC Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
	@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval'

/*	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQC Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'')  from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQC Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'')  from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='SQC Approval'*/

--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xlineamt,0)) from pogrndetail WHERE zid=@zid AND xgrnnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SQC Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SQC Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SQC Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================		 
		
		IF @designation='signatory1'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum) ='Approved'
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xgrnnum=@reqnum and xstatus='Approved'

	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum) ='Approved' AND left(@reqnum,3) = 'SQC'
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusdoc='Approved',xstatusgrn='Confirmed' WHERE zid=@zid AND xgrnnum=@reqnum --,xdate=CAST(GETDATE() as DATE) 

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--================================GL Voucher Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','PV--000018','0','Open','GL Approval'
--================================================================================================
ELSE IF @aprcs='GL Approval'
BEGIN

IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @reqtype = isnull(xtypeobj,'') from acheader WHERE zid = @zid AND xvoucher = @reqnum 

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GL Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GL Approval'	
	ELSE	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='GL Approval'
--================== Threshold Approval =====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xprime,0)) from acdetail WHERE zid=@zid AND xvoucher=@reqnum and xprime>0 
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='GL Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='GL Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='GL Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================		
		
	IF @designation='signatory1' and left(@reqnum,4) in ('JV-M','BP--','CP--')
			UPDATE acheader set xstatus =@status,xsigndate1=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	
	IF @designation='signatory1' and left(@reqnum,4) in ('BR--','CR--')
			UPDATE acheader set xstatus ='Approved',xsigndate1=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	
	ELSE IF @designation='signatory2' and left(@reqnum,4)<>'JV-M'
			UPDATE acheader set xstatus =@status,xsigndate2=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	
	ELSE IF @designation='signatory2' and left(@reqnum,4)='JV-M'
			UPDATE acheader set xstatus ='Approved',xsigndate2=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE IF @designation='signatory3'
			UPDATE acheader set xstatus =@status,xsigndate3=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE IF @designation='signatory4'
			UPDATE acheader set xstatus =@status,xsigndate4=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE IF @designation='signatory5'
			UPDATE acheader set xstatus =@status,xsigndate5=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE IF @designation='signatory6'
			UPDATE acheader set xstatus =@status,xsigndate6=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE IF @designation='signatory7'
			UPDATE acheader set xstatus =@status,xsigndate7=GETDATE(),xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xvoucher=@reqnum
	ELSE RETURN
 END

 IF (Select xstatus from acheader  WHERE zid=@zid AND xvoucher=@reqnum) ='Approved'
	Update acheader set xsuperiorgl='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xvoucher=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


----------------------------------Start DEAL Approval--------------------

ELSE IF @aprcs='Deal Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from podealsheader WHERE zid=@zid AND xdealno=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Deal Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Deal Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Deal Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Deal Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Deal Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Deal Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Deal Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Deal Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE podealsheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE podealsheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE podealsheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE podealsheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE podealsheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE podealsheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE podealsheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE podealsheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdealno=@reqnum
		ELSE RETURN
	END
	
	IF (Select xstatus from podealsheader  WHERE zid=@zid AND xdealno=@reqnum) ='Approved'
		Update podealsheader set xidsup='',xsuperior2='',xsuperior3='',xstatuspor='continue'  WHERE zid=@zid AND xdealno=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

----------------------------------End  DEAL Approval--------------------

--================================Late Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','Staff-000','1','Open','Late_Early Approval'
--================================================================================================
ELSE IF @aprcs='Late_Early Approval' AND @status='Late'
BEGIN

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Late_Early Approval'
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
			UPDATE pdathd set xstatuslate ='Approved',xsigndate1=GETDATE()
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
	
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 
		
	IF @designation='signatory1'
			UPDATE pdathd set xstatuslate =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory2'
				UPDATE pdathd set xstatuslate =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory3'

				UPDATE pdathd set xstatuslate =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	ELSE RETURN
 END

 IF @status ='Approved'
 BEGIN
 Select @date=xdate from pdathd WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
 EXEC zabsp_Pd_attndence_Roster @zid,@user,'','',@reqnum,@date,@date
 END
	-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail_leave @zid,@user,@position,@reqnum,@ypd,@tomail,'Request'
	END
END

--================================Early Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','Staff-000','1','Open','Late_Early Approval'
--================================================================================================
ELSE IF @aprcs='Late_Early Approval' AND @status='Early Leave'
BEGIN

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Late_Early Approval'
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Late_Early Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
			UPDATE pdathd set xstatusel ='Approved',xsigndate4=GETDATE()
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 
		
	IF @designation='signatory1'
			UPDATE pdathd set xstatusel =@status,xsigndate4=GETDATE(),xsuperior4=@superior,xsuperior5=@superior2,xsuperior6=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory2'
				UPDATE pdathd set xstatusel =@status,xsigndate5=GETDATE(),xsuperior4=@superior,xsuperior5=@superior2,xsuperior6=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory3'

				UPDATE pdathd set xstatusel =@status,xsigndate6=GETDATE(),xsuperior4=@superior,xsuperior5=@superior2,xsuperior6=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	ELSE RETURN
 END

 IF @status ='Approved'
 BEGIN
 Select @date=xdate from pdathd WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
 EXEC zabsp_Pd_attndence_Roster @zid,@user,'','',@reqnum,@date,@date
 END
	-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail_leave @zid,@user,@position,@reqnum,@ypd,@tomail,'Request'
	END
END

--================================Absent Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','Staff-000','1','Open','Absent Approval'
--================================================================================================
ELSE IF @aprcs='Absent Approval' AND @status='Absent'
BEGIN

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Absent Approval'
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Absent Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Absent Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Absent Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
			UPDATE pdathd set xstatusabsent ='Approved',xsigndate7=GETDATE()
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 
		
	IF @designation='signatory1'
			UPDATE pdathd set xstatusabsent =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory2'
				UPDATE pdathd set xstatusabsent =@status,xsigndate8=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory8=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory3'

				UPDATE pdathd set xstatusabsent =@status,xsigndate9=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory9=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd
	ELSE RETURN
 END

  IF (Select xstatusabsent from pdathd  WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd) ='Approved'
	Update pdathd set xstatus='Present' WHERE zid=@zid AND xstaff=@reqnum  AND xyearperdate=@ypd

	-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail_leave @zid,@user,@position,@reqnum,@ypd,@tomail,'Request'
	END
END

/*
--================================Late & Early Leave Approval=====================================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','PR--000018','0','Open','PO Approval'
--================================================================================================
ELSE IF @aprcs='Late_Early Approval' AND @status='Late'
BEGIN
			UPDATE pdathd set xstatuslate ='Approved',xsigndate1=GETDATE()
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
END

ELSE IF @aprcs='Late_Early Approval' AND @status='Early Leave'
BEGIN
			UPDATE pdathd set xstatusel ='Approved',xsigndate4=GETDATE()
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
END

ELSE IF @aprcs='Absent Approval' AND @status='Absent'
BEGIN
			UPDATE pdathd set xstatusabsent ='Approved',xstatus='Present',xsigndate7=GETDATE()
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xstaff=@reqnum AND xyearperdate=@ypd
END
*/
--================================Leave Approval=============================================
--************************************************************************************************
--zabsp_apvprcs 100030,'Nizam.Ahmed','00759','Staff-000','1','Open','Leave Approval'
--================================================================================================
ELSE IF @aprcs='Leave Approval'
BEGIN

Select @staff=isnull(xstaff,'') from pdleaveheader where zid=@zid and xyearperdate=@ypd

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Leave Approval'
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Leave Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Leave Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Leave Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	UPDATE pdleaveheader set xstatus ='Approved',xsigndate2=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
	
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 
		
	IF @designation='signatory1'
			UPDATE pdleaveheader set xstatus =@status,xsigndate1=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory2'
				UPDATE pdleaveheader set xstatus =@status,xsigndate2=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory3'

				UPDATE pdleaveheader set xstatus =@status,xsigndate3=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd
	
	ELSE IF @designation='signatory4'

				UPDATE pdleaveheader set xstatus =@status,xsigndate4=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd

	ELSE IF @designation='signatory5'

				UPDATE pdleaveheader set xstatus =@status,xsigndate5=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd

	ELSE IF @designation='signatory6'

				UPDATE pdleaveheader set xstatus =@status,xsigndate6=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd

	ELSE IF @designation='signatory7'

				UPDATE pdleaveheader set xstatus =@status,xsigndate7=GETDATE(),xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xyearperdate=@ypd
	ELSE RETURN
 END

 IF (Select xstatus from pdleaveheader  WHERE zid=@zid AND xyearperdate=@ypd) ='Approved'
 BEGIN
	Update pdleaveheader set xsid='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xyearperdate=@ypd and xstatus='Approved'
	  Select @year=xyear from pdleaveheader WHERE zid=@zid AND xyearperdate=@ypd
	  exec zabsp_leaveconf @zid,@user,@reqnum,@ypd,@year

 END
		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail_leave @zid,@user,@position,@staff,@ypd,@tomail,'Request'
	END
END
--zabsp_apvprcs 400010,'10109','10109','RFP-000001','0','Recommended','RFP Approval'
ELSE IF @aprcs='RFP Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='RFP Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'RFP Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'RFP Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'RFP Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE acreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE acreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE acreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE acreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE acreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE acreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE acreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from acreqheader  WHERE zid=@zid AND xacreqnum=@reqnum) ='Approved'
		BEGIN
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xacreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--zabsp_apvprcs 400010,'10109','10109','RFP-000001','0','Recommended','Transport Approval'
ELSE IF @aprcs='Transport Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Transport Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Transport Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Transport Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Transport Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from pdfacilityreqheader  WHERE zid=@zid AND xreqnum=@reqnum) ='Approved'
		BEGIN
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--zabsp_apvprcs 400010,'10109','10109','RFP-000001','0','Recommended','Accommodation Approval'
ELSE IF @aprcs='Accommodation Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Accommodation Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Accommodation Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Accommodation Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Accommodation Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from pdfacilityreqheader  WHERE zid=@zid AND xreqnum=@reqnum) ='Approved'
		BEGIN
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--zabsp_apvprcs 400010,'10109','10109','RFP-000001','0','Recommended','Cooking Facility Approval'
ELSE IF @aprcs='Cooking Facility Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Cooking Facility Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Cooking Facility Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Cooking Facility Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Cooking Facility Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pdfacilityreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from pdfacilityreqheader  WHERE zid=@zid AND xreqnum=@reqnum) ='Approved'
		BEGIN
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--zabsp_apvprcs 100150,'1876','1876','LGL-000001','0','Recommended','Legal Fund Approval'
------=================================================================================
ELSE IF @aprcs='Legal Fund Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Legal Fund Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Legal Fund Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Legal Fund Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Legal Fund Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE acreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE acreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE acreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE acreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE acreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE acreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE acreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from acreqheader  WHERE zid=@zid AND xacreqnum=@reqnum) ='Approved'
		BEGIN
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xacreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END


--======================================LPR Approval==========================================
--************************************************************************************************
--zabsp_apvprcs 100060,'1004','1004','LPR-000003','0','Open','LPR Approval'
--================================================================================================
Else IF @aprcs='LPR Approval'
BEGIN
----------------------------------Getting Superior--------------------
Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@reqnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='LPR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='LPR Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='LPR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='LPR Approval'

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='LPR Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'LPR Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'LPR Approval'  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'LPR Approval'  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatustor ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
	  ,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatustor =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatustor =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatustor =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatustor =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatustor =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatustor =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatustor =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatustor from imtorheader  WHERE zid=@zid AND xtornum=@reqnum) ='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatustor='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END
---------------------------------------------------------

--================================LRN Approval=====================================================
--************************************************************************************************
-- EXEC zabsp_apvprcs 300030,'1001','1001','LRN-000012',0,'Applied','LRN Approval'
--================================================================================================
ELSE IF @aprcs='LRN Approval'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
Select @date = xdate, @wh = xwh,@reqtype = isnull(xtypeobj,'') from pogrnheader WHERE zid = @zid AND xgrnnum = @reqnum 

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='LRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='LRN Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='LRN Approval'

--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 

Select @reqval=sum(isnull(xlineamt,0)) from pogrndetail WHERE zid=@zid AND xgrnnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'LRN Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'LRN Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'LRN Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================		
		
		IF @designation='signatory1'
			UPDATE pogrnheader set xstatusdoc =@status,xfwh=xwh,xsigndate1=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate2=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate3=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate4=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate5=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate6=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pogrnheader set xstatusdoc =@status,xsigndate7=GETDATE(),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrnnum=@reqnum
		ELSE RETURN
 END

 	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum) ='Approved'
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xgrnnum=@reqnum and xstatus='Approved'

	IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum) ='Approved' AND left(@reqnum,3) = 'LRN'  
	BEGIN
		--EXEC zabsp_PO_confirmGRN @zid,@user,@reqnum,@date,@wh,6
		UPDATE pogrnheader SET xstatusgrn='Confirmed',zutime=GETDATE(),zuuserid=@user 
		WHERE zid=@zid AND xgrnnum=@reqnum
		--IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@reqnum and isnull(xtype,'')<>'Cash') ='Approved' AND left(@reqnum,3) = 'LRN' and @zid in (100070,100120,100170,300030)
		--BEGIN
		--EXEC zabsp_PO_transferPOtoAP @zid,@user,@reqnum,'pogrnheaderac'
		--EXEC zabsp_PO_transferPOtoGL @zid,@user,@reqnum,'pogrnheaderac'

		--Select @vouchecrno=xvoucher from pogrnheader where zid = @zid AND xgrnnum = @reqnum
		--Select @vyear=xyear, @vper =xper from acheader where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		--Update acheader set xstatus='Approved' where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		--EXEC sp_acPost @zid,@user,@vyear,@vper,@vouchecrno,@vouchecrno
		--END
	END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--================================Land Advance Approval=====================================================
--************************************************************************************************ 

--zabsp_apvprcs 300030,'00928','00928','EAD-000003','0','Applied','Land Advance Approval'
------=================================================================================
ELSE IF @aprcs='Land Advance Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Land Advance Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Land Advance Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Land Advance Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Land Advance Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs

		IF @designation='signatory1'
			UPDATE acreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE acreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE acreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE acreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE acreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE acreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE acreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from acreqheader  WHERE zid=@zid AND xacreqnum=@reqnum) ='Approved'
		BEGIN
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xacreqnum=@reqnum and xstatus='Approved'
		
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END
																			-----------------------------------------PRODUCT APPROVAL----------------------------------
IF @aprcs='Product Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Product Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Product Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Product Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE caitem set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE caitem set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE caitem set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE caitem set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE caitem set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE caitem set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE caitem set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE caitem set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from caitem  WHERE zid=@zid AND xitem=@reqnum) ='Approved'
		Update caitem set xidsup='',xsuperior2='',xsuperior3='',zactive='1'  WHERE zid=@zid AND xitem=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

---------------------------------------Supplier approval----------------------------------

IF @aprcs='Supplier Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Supplier Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Supplier Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Supplier Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE cacus set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE cacus set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE cacus set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE cacus set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE cacus set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE cacus set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE cacus set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE cacus set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from cacus  WHERE zid=@zid AND xcus=@reqnum) ='Approved'
		Update cacus set xidsup='',xsuperior2='',xsuperior3='',zactive='1'  WHERE zid=@zid AND xcus=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END



-----------------CUSTOMER APPROVAL----------------------------------------------

IF @aprcs='Customer Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Customer Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Customer Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Customer Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE cacus set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE cacus set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE cacus set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE cacus set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE cacus set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE cacus set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE cacus set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE cacus set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcus=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from cacus  WHERE zid=@zid AND xcus=@reqnum) ='Approved'
		Update cacus set xidsup='',xsuperior2='',xsuperior3='',zactive='1'  WHERE zid=@zid AND xcus=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--======================================Pre BOM Approval==========================================
--************************************************************************************************


IF @aprcs='Pre BOM Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre BOM Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre BOM Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre BOM Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre BOM Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre BOM Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Pre BOM Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Pre BOM Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Pre BOM Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE bmbomheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE bmbomheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE bmbomheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE bmbomheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE bmbomheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE bmbomheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE bmbomheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE bmbomheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from bmbomheader  WHERE zid=@zid AND xbomkey=@reqnum) ='Approved'
		Update bmbomheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xbomkey=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


--======================================BOM Approval==========================================
--************************************************************************************************


IF @aprcs='BOM Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='BOM Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='BOM Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='BOM Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='BOM Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='BOM Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='BOM Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='BOM Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='BOM Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE bmbomheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE bmbomheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE bmbomheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE bmbomheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE bmbomheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE bmbomheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE bmbomheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE bmbomheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xbomkey=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from bmbomheader  WHERE zid=@zid AND xbomkey=@reqnum) ='Approved'
		Update bmbomheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xbomkey=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--======================================Batch Inspection Approval==========================================
--************************************************************************************************


IF @aprcs='Batch Inspection Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Inspection Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Inspection Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Inspection Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Inspection Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Inspection Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Batch Inspection Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Batch Inspection Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Batch Inspection Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE imtorheader set xstatus='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE imtorheader set xstatus=@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE imtorheader set xstatus=@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE imtorheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE imtorheader set xstatus=@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE imtorheader set xstatus=@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE imtorheader set xstatus=@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE imtorheader set xstatus=@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xtornum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from imtorheader  WHERE zid=@zid AND xtornum=@reqnum)='Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xtornum=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

		
					--======================================Sales Return Approval==========================================
			--************************************************************************************************


			IF @aprcs='SLR Approval'
			BEGIN

			----------------------------------Getting Superior--------------------

				IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='SLR Approval')

					Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='SLR Approval'

				ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='SLR Approval')

					Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='SLR Approval'

				ELSE 
				Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='SLR Approval'
			------------------------------End of getting Superior------------------
			--=================Approver Delegations=======================================
			Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='SLR Approval' and GETDATE() between xdateeff AND xdateexp 
			Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='SLR Approval' and GETDATE() between xdateeff AND xdateexp
			Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='SLR Approval' and GETDATE() between xdateeff AND xdateexp 

			IF @delegate1<>'' SET @superior=@delegate1
			IF @delegate2<>'' SET @superior2=@delegate2 
			IF @delegate3<>'' SET @superior3=@delegate3
			--=================================End========================================
				
			IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
				 UPDATE opcrnheader set xstatus='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
					,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
			ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
				BEGIN
				SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
					IF @designation='signatory1'
						UPDATE opcrnheader set xstatus=@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory2'
						UPDATE opcrnheader set xstatus=@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory3'
						UPDATE opcrnheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory4'
						UPDATE opcrnheader set xstatus=@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory5'
						UPDATE opcrnheader set xstatus=@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory6'
						UPDATE opcrnheader set xstatus=@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE IF @designation='signatory7'
						UPDATE opcrnheader set xstatus=@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
							,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
					ELSE RETURN
				END

				IF (Select xstatus from imtorheader  WHERE zid=@zid AND xtornum=@reqnum)='Approved'
					Update opcrnheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xcrnnum=@reqnum and xstatus='Approved'

					-----------------Mail Configure & Sending Mail----------------
				IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
				BEGIN
				Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
				Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
				Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
				
				IF @mail1<>'' SET @mail1=@mail1
				IF @mail2<>'' SET @mail2=';'+@mail2
				IF @mail3<>'' SET @mail3=';'+@mail3
				SET @tomail=@mail1+@mail2+@mail3
					
				--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
				END
			END



IF @aprcs='Service Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE caitem set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE caitem set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE caitem set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE caitem set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE caitem set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE caitem set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE caitem set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE caitem set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from caitem  WHERE zid=@zid AND xitem=@reqnum) ='Approved'
		Update caitem set xidsup='',xsuperior2='',xsuperior3='',zactive='1'  WHERE zid=@zid AND xitem=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


			
--================================Advance Approval=====================================================
--************************************************************************************************ 

--zabsp_apvprcs 300030,'00928','00928','EAD-000003','0','Applied','Land Advance Approval'
------=================================================================================
ELSE IF @aprcs='Advance Approval'
BEGIN
----------------------------------Getting Superior--------------------
	Select @subprcs=isnull(xtypeobj,'') from acreqheader WHERE zid=@zid AND xacreqnum=@reqnum
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Advance Approval' and xsubprcs=@subprcs

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Advance Approval' and GETDATE() between xdateeff AND xdateexp and xsubprcs=@subprcs
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Advance Approval' and GETDATE() between xdateeff AND xdateexp and xsubprcs=@subprcs
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Advance Approval' and GETDATE() between xdateeff AND xdateexp and xsubprcs=@subprcs

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs and xsubprcs=@subprcs

		IF @designation='signatory1'
			UPDATE acreqheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE acreqheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE acreqheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE acreqheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE acreqheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE acreqheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE acreqheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from acreqheader  WHERE zid=@zid AND xacreqnum=@reqnum) ='Approved'
		BEGIN
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xacreqnum=@reqnum and xstatus='Approved'
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END

END

	
--================================Advance Adjustment Approval=====================================================
--************************************************************************************************ 

--zabsp_apvprcs 300030,'00928','00928','EAD-000003','0','Applied','Land Advance Approval'
------=================================================================================
IF @aprcs='Advance Adjustment Approval'
BEGIN

----------------------------------Getting Superior--------------------
Select @subprcs=isnull(xtypeobj,'') from acreqheaderadj WHERE zid=@zid AND xacreqnum=@reqnum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs)
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs)
	 UPDATE acreqheaderadj set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs AND xsubprcs=@subprcs
		IF @designation='signatory1'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE acreqheaderadj set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xacreqnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from acreqheaderadj  WHERE zid=@zid AND xacreqnum=@reqnum) ='Approved'
		BEGIN
			Update acreqheaderadj set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xacreqnum=@reqnum and xstatus='Approved'
		END

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


IF @aprcs='Service Approval'
BEGIN

----------------------------------Getting Superior--------------------

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval')

		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='Service Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE caitem set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE caitem set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE caitem set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE caitem set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE caitem set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE caitem set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE caitem set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE caitem set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xitem=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from caitem  WHERE zid=@zid AND xitem=@reqnum) ='Approved'
		Update caitem set xidsup='',xsuperior2='',xsuperior3='',zactive='1'  WHERE zid=@zid AND xitem=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--zabsp_apvprcs'400010','10101','10101','CSN-000031','0','Open','Final Settlement Approval'
--================================================================================================
ELSE IF @aprcs='Final Settlement Approval'
BEGIN
----------------------------------Getting Superior--------------------


	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Final Settlement Approval'

------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Final Settlement Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Final Settlement Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Final Settlement Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE pdsettlement set xappstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE pdsettlement set xappstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE pdsettlement set xappstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE pdsettlement set xappstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE pdsettlement set xappstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE pdsettlement set xappstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE pdsettlement set xappstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcase=@reqnum
		ELSE RETURN
	END

	IF (Select xappstatus from pdsettlement  WHERE zid=@zid AND xcase=@reqnum) ='Approved'
		BEGIN
		Update pdsettlement set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xcase=@reqnum and xappstatus='Approved'
		
		END


--======================================End Final Settlement Approval==========================================


		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END
 

--=================================Delivery Challan Approval=====================================
--************************************************************************************************
--================================================================================================
ELSE IF @aprcs='DC Approval'
BEGIN
SET @dornum =@reqnum
----------------------------------Getting Superior--------------------
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xtypetrn='DC Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='DC Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='DC Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='DC Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE opdcheader set xstatus ='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE opdcheader set xstatus =@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory2'
			UPDATE opdcheader set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory3'
			UPDATE opdcheader set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory4'
			UPDATE opdcheader set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory5'
			UPDATE opdcheader set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory6'
			UPDATE opdcheader set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE IF @designation='signatory7'
			UPDATE opdcheader set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xdocnum=@dornum
		ELSE RETURN
	END
	
	IF (Select xstatus from opdcheader  WHERE zid=@zid AND xdocnum=@dornum) ='Approved'
		Update opdcheader set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xdocnum=@dornum and xstatus='Approved'


		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END

--************************************************************************************************
-- EXEC zabsp_apvprcs 400010,'16746','16746','GINV001878',0,'Applied','Supplier Invoice Approval for Multiple GRN'
--================================================================================================
ELSE IF @aprcs='Supplier Invoice Approval for Multiple GRN'
BEGIN
IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
BEGIN
--Select @date = xdate, @wh = xwh,@reqtype = isnull(xtypeobj,''),@potype =xtype from pogrnheader WHERE zid = @zid AND xgrnnum = @reqnum 
Select @imglauto =isnull(ximglauto,'No'),@poaccruedgl =ISNULL(xpoaccruedgl,'No') from poimdef where zid = @zid

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Supplier Invoice Approval for Multiple GRN')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Supplier Invoice Approval for Multiple GRN'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,''),@maxval=isnull(xprime,0),@maxvalexceed =isnull(xmaxbal,0),@reqstatus=isnull(xstatus,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='Supplier Invoice Approval for Multiple GRN'

--================== Threshold Approval=====================================
SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs 
print @status+@designation
Select @reqval=sum(isnull(xlineamt,0)) from pogrndetail WHERE zid=@zid AND xgrnnum=@reqnum
IF @reqval>@maxval AND @reqstatus<>'' AND @maxval>0
SET @status=@reqstatus

IF @maxvalexceed > 0 AND  @reqval > @maxvalexceed
BEGIN
IF @superior4 <> '' SET @superior = @superior4
IF @superior5 <> '' SET @superior2 = @superior5
IF @superior6 <> '' SET @superior3 = @superior6
END
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Supplier Invoice Approval for Multiple GRN' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Supplier Invoice Approval for Multiple GRN' and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Supplier Invoice Approval for Multiple GRN' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================		
		
		IF @designation='signatory1'
			UPDATE apsupinvm set xstatus=@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE apsupinvm set xstatus =@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE apsupinvm set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE apsupinvm set xstatus =@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE apsupinvm set xstatus =@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE apsupinvm set xstatus =@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE apsupinvm set xstatus =@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xgrninvno=@reqnum
		ELSE RETURN
 END  
		/*IF (Select xstatus from apsupinvm  WHERE zid=@zid AND xgrninvno=@reqnum) ='Approved' AND @imglauto = 'Yes'  
		BEGIN
			IF @poaccruedgl='Yes'
			BEGIN*/ 
				IF (Select isnull(xstatusap,'Open') from apsupinvm  WHERE zid=@zid AND xgrninvno=@reqnum) ='Open'
				BEGIN
					EXEC zabsp_PO_transferPOtoAPsupinv @zid,@user,@reqnum,'apsupinvm'
				END 
				IF (Select isnull(xstatusgl,'Open') from apsupinvm  WHERE zid=@zid AND xgrninvno=@reqnum) ='Open'
				BEGIN
					EXEC zabsp_PO_transferPOtoGLsupinv @zid,@user,@reqnum,'apsupinvm'
				END 
		/*print 's'
			END  
		END*/
		 
END

--======================================Dealer Closing Approval==========================================
--************************************************************************************************


IF @aprcs='DLC Approval'
BEGIN

----------------------------------Getting Superior--------------------

IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='DLC Approval')

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='DLC Approval'

ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='DLC Approval')

	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='DLC Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='DLC Approval'
------------------------------End of getting Superior------------------
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn='DLC Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn='DLC Approval' and GETDATE() between xdateeff AND xdateexp
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn='DLC Approval' and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
	
IF NOT EXISTS(SELECT xstatus from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	 UPDATE opdealshd set xstatus='Recommended',xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
		,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
ELSE IF EXISTS(SELECT * from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs)
	BEGIN
	SELECT @status=xstatus,@designation=xdesignation from apvprcs WHERE zid=@zid and xposition=@position and xtypetrn=@aprcs
		IF @designation='signatory1'
			UPDATE opdealshd set xstatus=@status,xsigndate1=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory1=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory2'
			UPDATE opdealshd set xstatus=@status,xsigndate2=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory2=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory3'
			UPDATE opdealshd set xstatus =@status,xsigndate3=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory3=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory4'
			UPDATE opdealshd set xstatus=@status,xsigndate4=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory4=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory5'
			UPDATE opdealshd set xstatus=@status,xsigndate5=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory5=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory6'
			UPDATE opdealshd set xstatus=@status,xsigndate6=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory6=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE IF @designation='signatory7'
			UPDATE opdealshd set xstatus=@status,xsigndate7=GETDATE(),xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3
				,xsignatory7=(select xstaff from pdmst WHERE zid=@zid and xposition=@position) WHERE zid=@zid AND xcrnnum=@reqnum
		ELSE RETURN
	END

	IF (Select xstatus from opdealshd WHERE zid=@zid AND xcrnnum=@reqnum)='Approved'
		Update opdealshd set xidsup='',xsuperior2='',xsuperior3=''  WHERE zid=@zid AND xcrnnum=@reqnum and xstatus='Approved'

		-----------------Mail Configure & Sending Mail----------------
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @status<>'Approved'
	BEGIN
	Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
	Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
	Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
	IF @mail1<>'' SET @mail1=@mail1
	IF @mail2<>'' SET @mail2=';'+@mail2
	IF @mail3<>'' SET @mail3=';'+@mail3
	SET @tomail=@mail1+@mail2+@mail3
		
	--IF @tomail<>'' EXEC zabsp_sendmail @zid,@user,@position,@reqnum,@tomail,'Request'
	END
END


ELSE RETURN