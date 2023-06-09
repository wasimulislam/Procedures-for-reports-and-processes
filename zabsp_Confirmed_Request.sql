USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_Confirmed_Request]    Script Date: 3/14/2023 12:01:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec zabsp_Confirmed_Request '200010','store prep','9001','01','SR--000002','SR'

ALTER PROC [dbo].[zabsp_Confirmed_Request] --#id,#user,xtornum,xmoprcs,xbatch
	
	@zid int,
	@user varchar(50),
	@position varchar(50),
	@wh VARCHAR(50),
	@tornum varchar(50),
	@request VARCHAR(50)

AS

DECLARE	@xstatus varchar(50),
		@shift varchar(50),
		@trn varchar(50),
		@superior varchar(50),
		@superior2 varchar(50),
		@superior3 varchar(50),
		@superior4 varchar(50),
		@superior5 varchar(50),
		@superior6 varchar(50),
		@delegate1 varchar(50),
		@delegate2 varchar(50),
		@delegate3 varchar(50),
		@signatory varchar(50),
		@voucher VARCHAR(50),
		@type varchar(50),
		@fwh varchar(50),
		@twh varchar(50),
		@date DATETIME,
		@poreqnum varchar(50),
		@pornum varchar(50),
		@pafnum varchar(50),
		@dornum varchar(50),
		@tonum varchar(50),
		@grnnum varchar(50),
		@staff varchar(50),
		@totreqqty DECIMAL(20,2),
		@totprqty DECIMAL(20,2),
		@tomail VARCHAR(150),
		@mail1 varchar(50),
		@mail2 varchar(50),
		@mail3 varchar(50),
		@loantype varchar(50),
		@loanacc varchar(50),
		@reqtype varchar(50),
		@case varchar(50),
		@value DECIMAL(20,2),
		@ypd INT,
		@vyear INT,
		@vper	INT,
		@vouchecrno varchar(50),
		@poaccruedgl VARCHAR(50),
		@potype varchar(50),
		@imglauto varchar(20),
		@subprcs varchar(50)

		
---------init-------
SET @totreqqty=0
SET @totprqty=0
SET @ypd=0
SET @tomail=''
SET @mail1=''
SET @mail2=''
SET @mail3=''
SET @delegate1=''
SET @delegate2=''
SET @delegate3=''
SET @vyear = 0
set @vper=0


------------------------SR Confirmation--------------------------------------------

--IF @request ='SPR'
--BEGIN
--	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,''),@subprcs=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
--	print @subprcs
--	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
--	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' and xsubprcs=@subprcs) AND @shift <> '' AND @reqtype <> ''
--	begin
--	print '2'
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior
--		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' and xsubprcs=@subprcs
--	end
--	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
--	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' and xsubprcs=@subprcs) AND @shift <> ''
--	begin
--	print '323'
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
--		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' and xsubprcs=@subprcs
--	end

--	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
--	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' and xsubprcs=@subprcs) AND @reqtype <> ''
--	begin
--	print '1'
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
--		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' and xsubprcs=@subprcs
--	end

--	ELSE 
--	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
--	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' and xsubprcs=@subprcs
--	print 'here'
	
--	IF @superior<>'' or @superior2<>'' or @superior3<>''
--	BEGIN
----=================Approver Delegations=======================================
--Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
--Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
--Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

--IF @delegate1<>'' SET @superior=@delegate1
--IF @delegate2<>'' SET @superior2=@delegate2 
--IF @delegate3<>'' SET @superior3=@delegate3
----=================================End========================================
--			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
--			-----------------Mail Sending--------------------------
--			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
--			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
--			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
--			IF @mail1<>''
--				set @mail1=@mail1
--			IF @mail2<>''
--				SET @mail2=';'+@mail2
--			IF @mail3<>''
--			SET @mail3=';'+@mail3
	
--			SET @tomail=@mail1+@mail2+@mail3
	
--			--IF @tomail<>''
--			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
--			END
--	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SPR Approval'and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
--	BEGIN
--		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
--		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='SPR Approval' and xsubprcs=@subprcs AND xposition=@position AND xstatus = 'Approved'
--		IF @signatory = 'signatory1'
--		Update imtorheader set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
--		ELSE IF @signatory = 'signatory2'
--		Update imtorheader set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
--		ELSE IF @signatory = 'signatory3'
--		Update imtorheader set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
--		ELSE IF @signatory = 'signatory4'
--		Update imtorheader set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
--		ELSE 
--		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
--	END

--END
IF @request ='SPR'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype='',@subprcs=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

		IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift <> '' AND @reqtype <> '' and @subprcs<>''
	BEGIN
	-- PRINT '1'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift <> '' and @subprcs<>'' and @reqtype=''
	BEGIN
	-- PRINT '2'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' and xsubprcs=@subprcs) AND @shift <> '' and @reqtype<>''  and @subprcs=''
	begin
	-- PRINT '3'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' and xsubprcs=''
	end

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift='' and @reqtype <> '' and @subprcs=''
	BEGIN
	-- PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' AND xsubprcs=''
	END

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift = '' and @reqtype='' and @subprcs<>''
	BEGIN
	-- PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	END
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs) AND @shift = '' and @reqtype='' and @subprcs=''
	BEGIN
	-- PRINT '4'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SPR Approval' AND xsubprcs=''
	END

	ELSE 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,''),
		@superior4=isnull(xsuperior4,''),@superior5=isnull(xsuperior5,''),@superior6=isnull(xsuperior6,'') from pdsuperior
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SPR Approval' AND xsubprcs=@subprcs
	
	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SPR Approval' and xsubprcs=@subprcs  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SPR Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
	BEGIN
		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='SPR Approval' and xsubprcs=@subprcs AND xposition=@position AND xstatus = 'Approved'
		IF @signatory = 'signatory1'
		Update imtorheader set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory2'
		Update imtorheader set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory3'
		Update imtorheader set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory4'
		Update imtorheader set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE 
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
	END

END


------------------------SO Confirmation-------------------------------------------- --exec zabsp_Confirmed_Request '200010','TSO','TSO-0001','03','SO22010000001','SO Approval'
--  EXEC zabsp_apvprcs 200010,'TSO','TSO-0001','SO22010000001','0','Open','SO Approval'
Else IF @request ='SO Approval'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SO Approval') AND @shift <> '' --AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SO Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SO Approval') AND @shift <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift --and isnull(xreqtype,'')='' 
		AND xtypetrn='SO Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SO Approval') --AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' --and isnull(xreqtype,'')=@reqtype 
		AND xtypetrn='SO Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' --and isnull(xreqtype,'')='' 
	AND xtypetrn='SO Approval'
	
	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SO Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Applied' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SO Approval' AND xposition=@position) = 'Approved'
	BEGIN
		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='SO Approval' AND xposition=@position AND xstatus = 'Approved'
		IF @signatory = 'signatory1'
		Update imtorheader set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory2'
		Update imtorheader set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory3'
		Update imtorheader set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory4'
		Update imtorheader set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE 
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
	END

END



-------------------------------------------------------BATP Confirmation--------------------------------------------------------
ELSE IF @request ='BATP'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Product'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Pre Process Batch Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Pre Process Batch Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Pre Process Batch Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Pre Process Batch Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Pre Process Batch Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update moheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xbatch=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Pre Process Batch Approval' AND xposition=@position) = 'Approved'
		Update moheader set xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved'  WHERE zid=@zid AND xbatch=@tornum 
END



-------------------------------------------------------BAT Confirmation--------------------------------------------------------
ELSE IF @request ='BAT'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Product'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Batch Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Batch Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Batch Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Batch Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Batch Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update moheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xbatch=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Batch Approval' AND xposition=@position) = 'Approved'
		Update moheader set xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved'  WHERE zid=@zid AND xbatch=@tornum 
END


-------------------------------------------------------RMCA Confirmation--------------------------------------------------------
ELSE IF @request ='RMCA'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Product'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='RMCA Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RMCA Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'RMCA Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'RMCA Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'RMCA Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update imconsumptionadjheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xadjnum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='RMCA Approval' AND xposition=@position) = 'Approved'
		Update imconsumptionadjheader set xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved'  WHERE zid=@zid AND xadjnum=@tornum 
END


------------------------SR Confirmation--------------------------------------------
--exec zabsp_Confirmed_Request '200010','store prep','9001','01','SR--000002','SR'
ELSE IF @request ='SR'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	-- PRINT @tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='SR_WR Approval')
	begin
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='SR_WR Approval'
		-- PRINT '1'
	end

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='SR_WR Approval')
	begin
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SR_WR Approval'
		-- PRINT '2'
	end 

	ELSE 
	begin
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SR_WR Approval'
	-- PRINT '3'
	end
	
	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SR_WR Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SR_WR Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SR_WR Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	-- PRINT '5'
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END

	
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SR_WR Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum

END

------------------------Scrap Opening Confirmation--------------------------------------------
ELSE IF @request ='SCRP'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,''),@fwh=xfwh,@date=xdate from imtorheader WHERE zid=@zid AND xtornum=@tornum
	
	Select @superior=xposition,@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Scrap Approval'

	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Scrap Approval' and GETDATE() between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Scrap Approval'  and GETDATE() between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Scrap Approval'  and GETDATE() between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END

	
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Scrap Approval' AND xposition=@position) = 'Approved'
	BEGIN
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		EXEC sp_confirmTO @zid,@user,@position,@tornum,@date,@fwh,@fwh,'Approved','Scrap Opening',6
	END

END

------------------------Asset Issue Confirmation--------------------------------------------
ELSE IF @request ='Asset Issue'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='Asset Issue Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Asset Issue Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='Asset Issue Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='Asset Issue Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='Asset Issue Approval'
	
	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Asset Issue Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Asset Issue Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Asset Issue Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END

	
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Asset Issue Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum

END
------------------------ Inspection Confirmation--------------------------------------------
ELSE IF @request ='Inspection'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Inspection Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Inspection Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Inspection Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Inspection Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Inspection Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Inspection Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Inspection Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Inspection Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Inspection Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
END

------------------------ Invoice Confirmation--------------------------------------------
ELSE IF @request ='Invoice'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Invoice Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Invoice Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Invoice Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Invoice Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
Update opdoheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xdornum=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Invoice Approval' AND xposition=@position) = 'Approved'
		Update opdoheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xdornum=@dornum
END

------------------------SQ Confirmation--------------------------------------------
ELSE IF @request in ('SQ')
BEGIN
	SET @poreqnum=@tornum
	Select @reqtype = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum
	
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xtypetrn='SQ Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SQ Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SQ Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SQ Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update poreqheader set xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusreq='Applied' WHERE zid=@zid AND xporeqnum=@poreqnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@poreqnum,@tomail,'Request'
	
			END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SQ Approval' AND xposition=@position) = 'Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusreq='Approved' WHERE zid=@zid AND xporeqnum=@poreqnum
END



------------------------ PRN Confirmation--------------------------------------------
ELSE IF @request ='PRN'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='PRN Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='PRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='PRN Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='PRN Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PRN Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'PRN Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'PRN Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='PRN Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
END

------------------------Transfer - Inspection - Damage Confirmation--------------------------------------------
ELSE IF @request ='TO'
BEGIN
	Select @shift=ISNULL(xshift,''),@fwh=ISNULL(xfwh,''),@twh=isnull(xtwh,''),@date=xdate,@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='TO Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='TO Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND isnull(xreqtype,'')='' AND xtypetrn='TO Approval'
	
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') 	
	and (@fwh not in (Select xwh from userstoreview WHERE zid=@zid AND xposition=@position) 
	or @twh not in (Select xwh from userstoreview WHERE zid=@zid AND xposition=@position))
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'TO Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'TO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'TO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END
	ELSE IF (@fwh in (Select xwh from userstoreview WHERE zid=@zid AND xposition=@position) 
	AND @twh in (Select xwh from userstoreview WHERE zid=@zid AND xposition=@position)) 
	BEGIN
	SET @date=CAST(GETDATE() AS DATE)
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Checked' WHERE zid=@zid AND xtornum=@tornum
	EXEC zabsp_IM_CheckMORequisition @zid,@user,@tornum,@date,@fwh,'Approved'
	
	EXEC sp_confirmTO @zid,@user,@position,@tornum,@date,@fwh,@twh,'Approved','Transfer',6
	
	EXEC sp_confirmTO @zid,@user,@position,@tornum,@date,@fwh,@twh,'transferred','Receive',6

	EXEC zabsp_PROC_Loan_To_Pricing @zid,@user,@tornum,@fwh

	END
	ELSE RETURN
END

------------------------Workshop Issue/ Receive Confirmation--------------------------------------------
ELSE IF @request ='WIS-WRE'
BEGIN
	Select @shift=ISNULL(xshift,''),@fwh=ISNULL(xfwh,''),@twh=isnull(xtwh,''),@date=xdate,@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='TO Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='TO Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='TO Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND isnull(xreqtype,'')='' AND xtypetrn='TO Approval'
	
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') AND left(@tornum,4)='WIS-'
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'TO Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'TO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'TO Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END
	ELSE IF left(@tornum,4)='WRE-'
	BEGIN
	SET @date=CAST(GETDATE() AS DATE)
	Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Checked' WHERE zid=@zid AND xtornum=@tornum	
	EXEC sp_confirmTO @zid,@user,@position,@tornum,@date,@fwh,@twh,'Approved','Transfer',6
	EXEC sp_confirmTO @zid,@user,@position,@tornum,@date,@fwh,@twh,'transferred','Receive',6
	EXEC zabsp_PROC_Loan_To_Pricing @zid,@user,@tornum,@fwh
	END
	ELSE RETURN
END
------------------------Damage Confirmation--------------------------------------------
ELSE IF @request ='Damage'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Damage Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Damage Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Damage Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Damage Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' AND isnull(xreqtype,'')='' AND xtypetrn='Damage Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Damage Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Damage Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Damage Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Damage Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
END

------------------------Loan Confirmation--------------------------------------------
ELSE IF @request ='Loan'
BEGIN
	Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Loan Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Loan Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Loan Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Loan Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Loan Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 

	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Loan Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Loan Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Loan Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Loan Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 
	ELSE RETURN 
END

------------------------Received Return Confirmation--------------------------------------------
ELSE IF @request ='RR'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='RR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='RR Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='RR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='RR Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='RR Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'RR Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'RR Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'RR Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END
		
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='RR Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 

END


------------------------Received Return Confirmation--------------------------------------------
ELSE IF @request ='APN'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Approval Notes')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Approval Notes'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Approval Notes')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Approval Notes'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Approval Notes'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Approval Notes' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Approval Notes'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Approval Notes' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END

END

----------------------------PR Confirmation-------------------------------------
--zabsp_Confirmed_Request 100030,'Ruhul.Amin','10468','','PR--000018','PR'
ELSE IF @request ='PR'
BEGIN
	SET @poreqnum=@tornum
	Select @type=xtype,@tonum=xtornum,@reqtype = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum
	Select @staff=xstaff from pdmst WHERE zid=@zid AND xposition=@position
	
	IF @type in ('Cash','Spot Purchase')
		Update poreqheader set xstatusreq='Recommended For Estimated Cost' WHERE zid=@zid AND xporeqnum=@poreqnum
	ELSE IF @type in ('Agreement','Direct PO')
		Update poreqheader set xstatusreq='Approved',xstatus='Recommended for PO' WHERE zid=@zid AND xporeqnum=@poreqnum
	ELSE IF @type='CS'
		Update poreqheader set xstatusreq='Recommended For Quotation',xsuperiorsp=@position WHERE zid=@zid AND xporeqnum=@poreqnum

	--------------Status-------------
	select @totreqqty=isnull(sum(xqtyreq),0) from imtordetail WHERE zid=@zid AND xtornum=@tonum
	select @totprqty=isnull(sum(xqtypor+xqtyalc+xqtycom),0) from imtordetail WHERE zid=@zid AND xtornum=@tonum
	
	IF @totreqqty>@totprqty
		Update imtorheader set xstatusreq='Create PO' WHERE zid=@zid AND xtornum=@tonum
	ELSE 
		Update imtorheader set xstatusreq='PR Created' WHERE zid=@zid AND xtornum=@tonum

END

------------------------PR Cash Confirmation--------------------------------------------
ELSE IF @request in ('PRConfirm')
BEGIN
	SET @poreqnum=@tornum
	Select @reqtype = '',@subprcs = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype<>'' )
	BEGIN
	-- PRINT 'AA'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=@subprcs   and @subprcs<>'' AND @reqtype='' ) 
	BEGIN
		-- PRINT '34D'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'')  
	BEGIN
	-- PRINT '34C'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=''
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs='' AND @subprcs='' and @reqtype='')
	BEGIN
	-- PRINT @REQTYPE
	-- PRINT '34A' 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='Cash Approval' and xsubprcs=''		
	END
	ELSE
	BEGIN
		-- PRINT '34'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Cash Approval' and xsubprcs=@subprcs
	END
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Cash Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Cash Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Cash Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update poreqheader set xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusreq='Applied' WHERE zid=@zid AND xporeqnum=@poreqnum
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
				--EXEC zabsp_sendmail @zid,@user,@position,@poreqnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Cash Approval' AND xposition=@position) = 'Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusreq='Approved' WHERE zid=@zid AND xporeqnum=@poreqnum

END

------------------------PR Cash Adjustment Confirmation--------------------------------------------
ELSE IF @request in ('PADJ')
BEGIN
	SET @poreqnum=@tornum
	Select @reqtype = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PAF Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PAF Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'PAF Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'PAF Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update poreqheader set xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusreq='Applied' WHERE zid=@zid AND xporeqnum=@poreqnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@poreqnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='PAF Approval' AND xposition=@position) = 'Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusreq='Approved' WHERE zid=@zid AND xporeqnum=@poreqnum

END


------------------------PR Cash Confirmation--------------------------------------------
ELSE IF @request IN ('CS')
BEGIN
	SET @poreqnum=@tornum
	Select @reqtype = '',@subprcs = isnull(xtypeobj,'') from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype<>'' )
	BEGIN
	-- PRINT 'AA'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs=@subprcs   and @subprcs<>'' AND @reqtype='' ) 
	BEGIN
		-- PRINT '34D'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'')  
	BEGIN
	-- PRINT '34C'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=''
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs='' AND @subprcs='' and @reqtype='')
	BEGIN
	-- PRINT @REQTYPE
	-- PRINT '34A' 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='CS Approval' and xsubprcs=''		
	END
	ELSE
	BEGIN
		-- PRINT '34'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='CS Approval' and xsubprcs=@subprcs
	END
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'CS Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'CS Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'CS Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update poreqheader set xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusreq='Applied' WHERE zid=@zid AND xporeqnum=@poreqnum
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
				--EXEC zabsp_sendmail @zid,@user,@position,@poreqnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='CS Approval' AND xposition=@position) = 'Approved'
		Update poreqheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusreq='Approved' WHERE zid=@zid AND xporeqnum=@poreqnum

END

------------------------PO Confirmation--------------------------------------------
--ELSE IF @request ='POConfirm'
--BEGIN
--	SET @pornum=@tornum
--	Select @reqtype = isnull(xtypeobj,''),@subprcs = isnull(xtypeobj,'') from poordheader WHERE zid=@zid AND xpornum=@pornum
--	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs )
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs	
--	ELSE
--		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=@subprcs
	
--		IF @superior<>'' or @superior2<>'' or @superior3<>''
--			BEGIN
----=================Approver Delegations=======================================
--Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PO Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
--Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'PO Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
--Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'PO Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

--IF @delegate1<>'' SET @superior=@delegate1
--IF @delegate2<>'' SET @superior2=@delegate2 
--IF @delegate3<>'' SET @superior3=@delegate3
----=================================End========================================
--			Update poordheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xpornum=@pornum 
--			-----------------Mail Sending--------------------------
--			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
--			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
--			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
--			IF @mail1<>''
--				set @mail1=@mail1
--			IF @mail2<>''
--				SET @mail2=';'+@mail2
--			IF @mail3<>''
--			SET @mail3=';'+@mail3
	
--			SET @tomail=@mail1+@mail2+@mail3
	
--			--IF @tomail<>''
--				--EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
--			END

--	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='PO Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
--		Update poordheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xpornum=@pornum

--END


ELSE IF @request ='POConfirm'
BEGIN
	SET @pornum=@tornum
	Select @reqtype = '',@subprcs = isnull(xtypeobj,'') from poordheader WHERE zid=@zid AND xpornum=@pornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs and @subprcs<>'' and @reqtype<>'' )
	BEGIN
	-- PRINT 'AA'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=@subprcs   and @subprcs<>'' AND @reqtype='' ) 
	BEGIN
		-- PRINT '34D'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=@subprcs
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs='' and @subprcs='' and @reqtype<>'')  
	BEGIN
	-- PRINT '34C'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=''
	END
	else IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs='' AND @subprcs='' and @reqtype='')
	BEGIN
	-- PRINT @REQTYPE
	-- PRINT '34A' 
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='PO Approval' and xsubprcs=''		
	END
	ELSE
	BEGIN
		-- PRINT '34'
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PO Approval' and xsubprcs=@subprcs
	END
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PO Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'PO Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'PO Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update poordheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xpornum=@pornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
				--EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='PO Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
		Update poordheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xpornum=@pornum

END

------------------------PAF Confirmation--------------------------------------------
ELSE IF @request ='PAF'
BEGIN
	SET @pafnum=@tornum
	Select @reqtype = isnull(xtypeobj,'') from appaymentreqh WHERE zid=@zid AND xpafnum=@pafnum
	
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='PAF Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='PAF Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'PAF Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'PAF Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'PAF Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update appaymentreqh set xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusreq='Applied' WHERE zid=@zid AND xpafnum=@pafnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pafnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='PAF Approval' AND xposition=@position) = 'Approved'
				Update appaymentreqh set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusreq='Approved' WHERE zid=@zid AND xpafnum=@pafnum 

END

------------------------GRN Confirmation--------------------------------------------
ELSE IF @request ='GRN'
BEGIN
	SET @grnnum=@tornum
	Select @reqtype = '',@subprcs=isnull(xtypeobj,'') from pogrnheader WHERE zid=@zid AND xgrnnum=@grnnum
	Select @imglauto =isnull(ximglauto,'No'),@poaccruedgl =ISNULL(xpoaccruedgl,'No') from poimdef where zid = @zid

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GRN Approval' and xsubprcs=@subprcs)
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GRN Approval' AND xsubprcs=@subprcs
	ELSE
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='GRN Approval' AND xsubprcs=@subprcs
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'GRN Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'GRN Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'GRN Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pogrnheader set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusdoc='Applied' WHERE zid=@zid AND xgrnnum=@grnnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
			SET @tomail=@mail1+@mail2+@mail3
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pafnum,@tomail,'Request'
			END
			 -- exec zabsp_Confirmed_Request '200010','store apv','9003','01','GRN-000026','GRN'
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='GRN Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
			BEGIN
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusdoc='Approved' WHERE zid=@zid AND xgrnnum=@grnnum 

		IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@grnnum) ='Approved' AND left(@grnnum,3) = 'GRN' --and @zid in (100070,200010,100120,100170,100180)
	BEGIN
		-- PRINT 'moshiur'
		EXEC zabsp_PO_confirmGRN @zid,@user,@grnnum,@date,@wh,6
		-- PRINT 'ok'
		IF (Select xstatusdoc from pogrnheader  WHERE zid=@zid AND xgrnnum=@grnnum and isnull(xtype,'') NOT IN ('Cash','Spot Purchase')) ='Approved' AND left(@grnnum,3) = 'GRN'  AND @imglauto = 'Yes'  --and @zid in (100070,100120,200010,100170,100180)
		BEGIN
		EXEC zabsp_PO_transferPOtoAP @zid,@user,@grnnum,'pogrnheaderac'
		EXEC zabsp_PO_transferPOtoGL @zid,@user,@grnnum,'pogrnheaderac'

		Select @vouchecrno=xvoucher from pogrnheader where zid = @zid AND xgrnnum = @grnnum
		Select @vyear=xyear, @vper =xper from acheader where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		Update acheader set xstatus='Approved' where zid = @zid AND xvoucher = @vouchecrno and xstatusjv='Balanced'
		EXEC sp_acPost @zid,@user,@vyear,@vper,@vouchecrno,@vouchecrno
		END

		END
	END
END

------------------------ GRN Confirmation --------------------------------------------
ELSE IF @request ='SQC'
BEGIN
	SET @grnnum=@tornum
	Select @reqtype = isnull(xtypeobj,''),@shift=isnull(xproject,'') from pogrnheader WHERE zid=@zid AND xgrnnum=@grnnum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SQC Approval') AND @shift <> '' AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND isnull(xshift,'')=@shift  AND xtypetrn='SQC Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval') AND @shift <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xshift,'')=@shift and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift ='' and isnull(xreqtype,'') = @reqtype AND xtypetrn='SQC Approval') AND @reqtype <> ''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition = @position) and isnull(xshift,'')='' and isnull(xreqtype,'')=@reqtype AND xtypetrn='SQC Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='SQC Approval'
	
/*	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQC Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='SQC Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='SQC Approval'
*/	
IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SQC Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SQC Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SQC Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pogrnheader set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusdoc='Applied' WHERE zid=@zid AND xgrnnum=@grnnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pafnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SQC Approval' AND xposition=@position) = 'Approved'
				Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusdoc='Approved' WHERE zid=@zid AND xgrnnum=@grnnum 

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SQC Approval' AND xposition=@position) = 'Approved' AND left(@grnnum,3) = 'SQC'
		Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusdoc='Approved',xstatusgrn='Confirmed' WHERE zid=@zid AND xgrnnum=@grnnum 
END


------------------------GL Confirmation--------------------------------------------
ELSE IF @request ='GL'
BEGIN
	SET @voucher=@tornum
	SET @trn =Left(@voucher,4)
	Select @reqtype = isnull(xtypeobj,'') from acheader WHERE zid=@zid AND xvoucher=@voucher

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GL Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='GL Approval'	
	ELSE	
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= '' AND xtypetrn='GL Approval'
	
		IF (@superior<>'' or @superior2<>'' or @superior3<>'') and @trn not in ('JV--')--('BP--','CP--','JV-M','CR--','CP--')
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'GL Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'GL Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'GL Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update acheader set xsuperiorgl=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xvoucher=@voucher
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@voucher,@tomail,'Request'
	
			END

			Else if (@superior<>'' or @superior2<>'' or @superior3<>'') and @trn in ('JV--')
				Update acheader set xsuperiorgl='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xvoucher=@voucher
		    ELSE 
			-- PRINT 'No Superior Setup'

IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='GL Approval' AND xposition=@position) = 'Approved'
			Update acheader set xsuperiorgl='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xvoucher=@voucher

END
------------------------ Deal Confirmation--------------------------------------------

ELSE IF @request ='Deal'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from podealsheader WHERE zid=@zid AND xdealno=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Deal Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='Deal Approval'
	
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift AND xtypetrn='Deal Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift  AND xtypetrn='Deal Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and ISNULL(xreqtype,'')='' AND xtypetrn='Deal Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Deal Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Deal Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Deal Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update podealsheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xdealno=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Deal Approval' AND xposition=@position) = 'Approved'
		Update podealsheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved',xstatuspor='Continue' WHERE zid=@zid AND xdealno=@tornum
END

------------------------END Deal Confirmation--------------------------------------------

------------------------Leave Confirmation--------------------------------------------
ELSE IF @request ='Leave'
BEGIN
	SET @ypd=CAST (@wh as INT)
	SET @staff=@tornum

--	Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Leave Approval'
--------pick up superior--------------
Select @superior= isnull(xsid,''),@superior2=isnull(xsuperior4,'') from pdmst WHERE zid=@zid AND xstaff=@staff
--Select @superior2=isnull(xsuperiorsp,'') from pdmst WHERE zid=@zid AND xstaff=(select xstaff from pdmst WHERE zid=@zid and xposition=(select xsid from pdmst where zid=@zid AND xstaff=@staff))
Set @superior3='hr.admin'

	
		IF (@superior<>'' or @superior2<>'' or @superior3<>'')
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Leave Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Leave Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Leave Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update pdleaveheader set xsid=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xyearperdate=@ypd and xstaff=@staff
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail_leave @zid,@user,@position,@staff,@ypd,@tomail,'Request'
	
			END

--IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Leave Approval' AND xposition=@position) = 'Approved'
	--		Update pdleaveheader set xsid='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xyearperdate=@ypd AND xstaff=@staff

END

------------------------Leave Confirmation--------------------------------------------
ELSE IF @request ='Absent'
BEGIN
	SET @ypd=CAST (@wh as INT)
	SET @staff=@tornum

--	Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Leave Approval'
--------pick up superior--------------
Select @superior= isnull(xsid,''),@superior2=isnull(xsuperior4,'') from pdmst WHERE zid=@zid AND xstaff=@staff
--Select @superior2=isnull(xsuperiorsp,'') from pdmst WHERE zid=@zid AND xstaff=(select xstaff from pdmst WHERE zid=@zid and xposition=(select xsid from pdmst where zid=@zid AND xstaff=@staff))
Set @superior3='hr.admin'

	
		IF (@superior<>'' or @superior2<>'' or @superior3<>'')
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Leave Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Leave Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Leave Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

			Update pdathd set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusabsent='WFA' WHERE zid=@zid AND xyearperdate=@ypd and xstaff=@staff
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail_leave @zid,@user,@position,@staff,@ypd,@tomail,'Request'
	
			END

IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Absent Approval' AND xposition=@position) = 'Approved'
			Update pdathd set xstatusabsent='Approved' WHERE zid=@zid AND xyearperdate=@ypd AND xstaff=@staff

END

--zabsp_Confirmed_Request 400010,'10101','10101','0','RFP-000001','RFP Approval'
ELSE IF @request ='RFP Approval'
BEGIN
	SET @case=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='RFP Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='RFP Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='RFP Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'RFP Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'RFP Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'RFP Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update acreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xacreqnum=@case 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='RFP Approval' AND xposition=@position) = 'Approved'
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case

END

--zabsp_Confirmed_Request 400010,'10101','10101','0','RFP-000001','Cooking Facility Approval'
ELSE IF @request ='Cooking Facility Approval'
BEGIN
	SET @request=@tornum
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Cooking Facility Approval'
	
IF @superior<>'' or @superior2<>'' or @superior3<>''
BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Cooking Facility Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Cooking Facility Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Cooking Facility Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pdfacilityreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xreqnum=@request 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Cooking Facility Approval' AND xposition=@position) = 'Approved'
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xreqnum=@request
END

--zabsp_Confirmed_Request 400010,'10101','10101','0','RFP-000001','Accommodation Approval'
ELSE IF @request ='Accommodation Approval'
BEGIN
	SET @request=@tornum
	--	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Accommodation Approval'
	select @staff=xstaff from pdfacilityreqheader WHERE zid=@zid AND xreqnum=@request and xtype='Accommodation Requisition'
	
	Select @superior= isnull(xsid,''),@superior2=isnull(xsuperior4,'') from pdmst WHERE zid=@zid AND xstaff=@staff
	Set @superior3='hr.admin'

IF @superior<>'' or @superior2<>'' or @superior3<>''
BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Accommodation Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Accommodation Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Accommodation Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pdfacilityreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied',xsendreqdate=GETDATE() WHERE zid=@zid AND xreqnum=@request 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Accommodation Approval' AND xposition=@position) = 'Approved'
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xreqnum=@request
END

--zabsp_Confirmed_Request 400010,'10101','10101','0','RFP-000001','Transport Approval'
ELSE IF @request ='Transport Approval'
BEGIN
	SET @request=@tornum
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Transport Approval'
	
IF @superior<>'' or @superior2<>'' or @superior3<>''
BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Transport Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Transport Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Transport Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pdfacilityreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied',xsendreqdate=GETDATE() WHERE zid=@zid AND xreqnum=@request 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Transport Approval' AND xposition=@position) = 'Approved'
		Update pdfacilityreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xreqnum=@request
END
--zabsp_Confirmed_Request 100150,'1874','1874','0','LGL-000001','Legal Fund Approval'
ELSE IF @request ='Legal Fund Approval'
BEGIN
	SET @case=@tornum
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Legal Fund Approval'
	
IF @superior<>'' or @superior2<>'' or @superior3<>''
BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Legal Fund Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Legal Fund Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Legal Fund Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update acreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xacreqnum=@case 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Legal Fund Approval' AND xposition=@position) = 'Approved'
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case

END


------------------------------------LPR for NLDL------
IF @request ='LPR'
BEGIN
	Select @shift=ISNULL(xshift,''),@reqtype=isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum

	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and isnull(xreqtype,'')=@reqtype AND xtypetrn='LPR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')=@reqtype AND xtypetrn='LPR Approval'

	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) 
	and xshift=@shift AND xtypetrn='LPR Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
		WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and xshift=@shift and isnull(xreqtype,'')='' AND xtypetrn='LPR Approval'

	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior 
	WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and ISNULL(xshift,'')='' and isnull(xreqtype,'')='' AND xtypetrn='LPR Approval'
	
	IF @superior<>'' or @superior2<>'' or @superior3<>''
	BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'LPR Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'LPR Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'LPR Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatustor='Open' WHERE zid=@zid AND xtornum=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
			END
	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='LPR Approval' AND xposition=@position) = 'Approved'
	BEGIN
		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='LPR Approval' AND xposition=@position AND xstatus = 'Approved'
		IF @signatory = 'signatory1'
		Update imtorheader set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory2'
		Update imtorheader set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory3'
		Update imtorheader set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE IF @signatory = 'signatory4'
		Update imtorheader set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
		ELSE 
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum
	END

END


------------------------LRN Confirmation--------------------------------------------
ELSE IF @request ='LRN'
BEGIN
	SET @grnnum=@tornum
	Select @reqtype = isnull(xtypeobj,'') from pogrnheader WHERE zid=@zid AND xgrnnum=@grnnum
	
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='LRN Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='LRN Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='LRN Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'LRN Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'LRN Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'LRN Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update pogrnheader set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xsuperiorsp=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatusdoc='Applied' WHERE zid=@zid AND xgrnnum=@grnnum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pafnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='LRN Approval' AND xposition=@position) = 'Approved'
				Update pogrnheader set xsuperiorsp='',xsuperior2='',xsuperior3='',xstatusdoc='Approved' WHERE zid=@zid AND xgrnnum=@grnnum 

END

------------------------Land Advance Confirmation--------------------------------------------



--zabsp_Confirmed_Request 300030,'1037','1037','0','EAD-000003','Land Advance Approval'
ELSE IF @request ='Land Advance Approval'
BEGIN
	SET @case=@tornum
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Land Advance Approval'
	-- PRINT @superior
IF @superior<>'' or @superior2<>'' or @superior3<>''
BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Land Advance Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Land Advance Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Land Advance Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update acreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xacreqnum=@case 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Land Advance Approval' AND xposition=@position) = 'Approved'
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case

END

-------------------------------------------------------PRODUCT--------------------------------------------------------
ELSE IF @request ='Product Approval'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Product'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Product Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Product Approval'
	
 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Product Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Product Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Product Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update caitem set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),  xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xitem=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Product Approval' AND xposition=@position) = 'Approved'
		Update caitem set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position), xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved',zactive='1' WHERE zid=@zid AND xitem=@tornum 
END

------------------==========================CUSTOMER APPROVAL===========================

ELSE IF @request ='Customer Approval'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Customer'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Customer Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Customer Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Customer Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Customer Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Customer Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update cacus set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xcus=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Customer Approval' AND xposition=@position) = 'Approved'
		Update cacus set xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved',zactive='1' WHERE zid=@zid AND xcus=@tornum 
END

--================================================SUPPLIER APPROVAL==========================================================

ELSE IF @request ='Supplier Approval'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Supplier'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Supplier Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Supplier Approval'
	
	--IF left(@tornum,4)='LRE-' AND @loantype<>'Loan Return' and left(@loanacc,1) not in ('P','C','S')
	--Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatustor='Approved' WHERE zid=@zid AND xtornum=@tornum 	
	--ELSE 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIn
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Supplier Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Supplier Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Supplier Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update cacus set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),  xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xcus=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Supplier Approval' AND xposition=@position) = 'Approved'
		Update cacus set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position), xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved',zactive='1' WHERE zid=@zid AND xcus=@tornum 
END



------------------------ Pre BOM Confirmation--------------------------------------------
ELSE IF @request ='Pre BOM Approval'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Pre BOM Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Pre BOM Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Pre BOM Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Pre BOM Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
Update bmbomheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xbomkey=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Pre BOM Approval' AND xposition=@position) = 'Approved'
		Update bmbomheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xbomkey=@dornum
END


------------------------ BOM Confirmation--------------------------------------------
ELSE IF @request ='BOM Approval'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='BOM Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'BOM Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'BOM Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'BOM Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
Update bmbomheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xbomkey=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='BOM Approval' AND xposition=@position) = 'Approved'
		Update bmbomheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xbomkey=@dornum
END

------------------------ Batch Inspection Confirmation--------------------------------------------
ELSE IF @request ='Batch Inspection Approval'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Batch Inspection Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Batch Inspection Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Batch Inspection Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Batch Inspection Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
Update imtorheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xtornum=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Batch Inspection Approval' AND xposition=@position) = 'Approved'
		Update imtorheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xtornum=@dornum
END


				------------------------ Sales Return Confirmation--------------------------------------------
					ELSE IF @request ='SLR Approval'
					BEGIN
					 SET @dornum = @tornum
					Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='SLR Approval'

							IF @superior<>'' or @superior2<>'' or @superior3<>''
								BEGIN
					--=================Approver Delegations=======================================
					Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'SLR Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
					Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'SLR Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
					Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'SLR Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

					IF @delegate1<>'' SET @superior=@delegate1
					IF @delegate2<>'' SET @superior2=@delegate2 
					IF @delegate3<>'' SET @superior3=@delegate3
					--=================================End========================================

					Update opcrnheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xcrnnum=@dornum 
								-----------------Mail Sending--------------------------
								Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
								Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
								Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
						
								IF @mail1<>''
									set @mail1=@mail1
								IF @mail2<>''
									SET @mail2=';'+@mail2
								IF @mail3<>''
								SET @mail3=';'+@mail3
						
								SET @tomail=@mail1+@mail2+@mail3
						
								--IF @tomail<>''
								--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
						
							END
					IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='SLR Approval' AND xposition=@position) = 'Approved'
							Update opcrnheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xcrnnum=@dornum
					END

					--alter table acreqheader add xtypeobj varchar(100)
--zabsp_Confirmed_Request 300030,'1037','1037','0','EAD-000003','Advance Approval'
ELSE IF @request ='Advance Approval'
BEGIN
	SET @case=@tornum
	Select @subprcs=isnull(xtypeobj,'') from acreqheader WHERE zid=@zid AND xacreqnum=@case
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Approval' AND xsubprcs=@subprcs) and @subprcs<>''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Approval' AND xsubprcs=@subprcs
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Approval' AND xsubprcs=@subprcs

	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Advance Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Advance Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Advance Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update acreqheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xacreqnum=@case
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'

			--  zabsp_Confirmed_Request'200010','2419','2419','','EAD-000008','Advance Approval'
	
	END 
    IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Advance Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
	BEGIN
		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='Advance Approval' and xsubprcs=@subprcs AND xposition=@position AND xstatus = 'Approved'
		IF @signatory = 'signatory1'
		Update acreqheader set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory2'
		Update acreqheader set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory3'
		Update acreqheader set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory4'
		Update acreqheader set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE 
		Update acreqheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@tornum
	END
END




------------------------ Advance Adjustment Confirmation--------------------------------------------
 
--zabsp_Confirmed_Request 300030,'1037','1037','0','EAD-000003','Land Advance Approval'
ELSE IF @request ='Advance Adjustment Approval'
BEGIN
	SET @case=@tornum
	Select @subprcs=isnull(xtypeobj,'') from acreqheaderadj WHERE zid=@zid AND xacreqnum=@case
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs) and @subprcs<>''
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Advance Adjustment Approval' AND xsubprcs=@subprcs

	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Advance Adjustment Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Advance Adjustment Approval' and xsubprcs=@subprcs  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Advance Adjustment Approval' and xsubprcs=@subprcs and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update acreqheaderadj set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xacreqnum=@case
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Advance Adjustment Approval' and xsubprcs=@subprcs AND xposition=@position) = 'Approved'
	BEGIN
		Select @staff= xstaff from pdmst where zid = @zid and xposition = @position
		Select @signatory = xdesignation from apvprcs  WHERE zid=@zid and xtypetrn='Advance Adjustment Approval' and xsubprcs=@subprcs AND xposition=@position AND xstatus = 'Approved'
		IF @signatory = 'signatory1'
		Update acreqheaderadj set xsignatory1= @staff,xsigndate1=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory2'
		Update acreqheaderadj set xsignatory2= @staff,xsigndate2=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory3'
		Update acreqheaderadj set xsignatory3= @staff,xsigndate3=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE IF @signatory = 'signatory4'
		Update acreqheaderadj set xsignatory4= @staff,xsigndate4=GETDATE(),xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@case
		ELSE 
		Update acreqheaderadj set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xacreqnum=@tornum
	END
END


--------------------------------------------SERVICE APPROVAL----------------------------
ELSE IF @request ='Service Approval'
BEGIN
	--Select @shift=ISNULL(xshift,''),@loantype=isnull(xtype,''),@loanacc=isnull(xacc,''),@reqtype = isnull(xtypeobj,'') from imtorheader WHERE zid=@zid AND xtornum=@tornum
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'
		
	--  exec zabsp_Confirmed_Request_product '100090','admin','9004','','IC--00012','Service'
	ELSE IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Service Approval')
	
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'
		
	ELSE 
	Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Service Approval'
	
 
	-- PRINT @superior
	IF (@superior<>'' or @superior2<>'' or @superior3<>'') --left(@tornum,4)= 'LIS-' 
	BEGIN
		--=================Approver Delegations=======================================
		Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Service Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Service Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
		Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Service Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

		IF @delegate1<>'' SET @superior=@delegate1
		IF @delegate2<>'' SET @superior2=@delegate2 
		IF @delegate3<>'' SET @superior3=@delegate3
		--=================================End========================================
			Update caitem set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),  xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xitem=@tornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
	END 
    ELSE IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Service Approval' AND xposition=@position) = 'Approved'
		Update caitem set xpreparer=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position), xidsup='',xsuperior2='',xsuperior3='',xstatus ='Approved',zactive='1' WHERE zid=@zid AND xitem=@tornum 
END



------------------------Settlement Confirmation--------------------------------------------
--zabsp_Confirmed_Request 400010,'17622','17622','0','CSN-000014','Final Settlement Approval'
ELSE IF @request ='Final Settlement Approval'
BEGIN
	SET @case=@tornum
	-- PRINT @case
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Final Settlement Approval')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  AND xtypetrn='Final Settlement Approval'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='Final Settlement Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Final Settlement Approval' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Final Settlement Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Final Settlement Approval'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
---- PRINT @superior
			Update pdsettlement set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xappstatus='Applied' WHERE zid=@zid AND xcase=@case 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@pornum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Final Settlement Approval' AND xposition=@position) = 'Approved'
		Update pdsettlement set xidsup='',xsuperior2='',xsuperior3='',xappstatus='Approved' WHERE zid=@zid AND xcase=@case

END


------------------------ Delivery Challan Confirmation--------------------------------------------
ELSE IF @request ='DC'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='DC Approval'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'DC Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'DC Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'DC Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
Update opdcheader set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xdocnum=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='DC Approval' AND xposition=@position) = 'Approved'
		Update opdcheader set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xdocnum=@dornum
END


------------------------Supplier Invoice Approval for Multiple GRN Confirmation--------------------------------------------
ELSE IF @request ='Supplier Invoice Approval for Multiple GRN'
BEGIN
	Select @reqtype =''
	
Select @imglauto =isnull(ximglauto,'No'),@poaccruedgl =ISNULL(xpoaccruedgl,'No') from poimdef where zid = @zid
	
	IF EXISTS (Select xposition from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Supplier Invoice Approval for Multiple GRN')
		Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) and isnull(xreqtype,'')= @reqtype AND xtypetrn='Supplier Invoice Approval for Multiple GRN'	
	ELSE
		Select @superior=isnull(xposition,''),@superior2=xsuperior2,@superior3=xsuperior3 from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position)  and isnull(xreqtype,'')= '' AND xtypetrn='Supplier Invoice Approval for Multiple GRN'
	
		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'Supplier Invoice Approval for Multiple GRN' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'Supplier Invoice Approval for Multiple GRN'  and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'Supplier Invoice Approval for Multiple GRN' and CAST(GETDATE() AS DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================
			Update apsupinvm set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xgrninvno=@tornum
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			IF @tomail<>''
				EXEC zabsp_sendmail @zid,@user,@position,@pafnum,@tomail,'Request'
	
			END

	IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='Supplier Invoice Approval for Multiple GRN' AND xposition=@position) = 'Approved'
		BEGIN
				Update apsupinvm set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xgrninvno=@tornum
				
				
 
		/*IF (Select xstatus from apsupinvm  WHERE zid=@zid AND xgrninvno=@tornum) ='Approved' AND @imglauto = 'Yes'  
		BEGIN
			IF @poaccruedgl='Yes'
			BEGIN*/
				IF (Select isnull(xstatusap,'Open') from apsupinvm  WHERE zid=@zid AND xgrninvno=@tornum) ='Open'
				BEGIN
					EXEC zabsp_PO_transferPOtoAPsupinv @zid,@user,@tornum,'apsupinvm'
				END 
				IF (Select isnull(xstatusgl,'Open') from apsupinvm  WHERE zid=@zid AND xgrninvno=@tornum) ='Open'
				BEGIN
					EXEC zabsp_PO_transferPOtoGLsupinv @zid,@user,@tornum,'apsupinvm'
				END 
		/*print 's'
			END  
		END*/
		 
		END

END

------------------------ Dealer Closing Confirmation--------------------------------------------
ELSE IF @request ='DLC Approval'
BEGIN
 SET @dornum = @tornum
Select @superior=isnull(xposition,''),@superior2=isnull(xsuperior2,''),@superior3=isnull(xsuperior3,'') from pdsuperior WHERE zid=@zid AND xstaff=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position) AND xtypetrn='DLC Approval'

		IF @superior<>'' or @superior2<>'' or @superior3<>''
			BEGIN
--=================Approver Delegations=======================================
Select @delegate1=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior and xtypetrn= 'DLC Approval' and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate2=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior2 and xtypetrn= 'DLC Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 
Select @delegate3=isnull(xsuperior2,'') from pdsupdelegation WHERE zid=@zid and xposition=@superior3 and xtypetrn= 'DLC Approval'  and CAST(GETDATE() as DATE) between xdateeff AND xdateexp 

IF @delegate1<>'' SET @superior=@delegate1
IF @delegate2<>'' SET @superior2=@delegate2 
IF @delegate3<>'' SET @superior3=@delegate3
--=================================End========================================

Update opdealshd set xidsup=@superior,xsuperior2=@superior2,xsuperior3=@superior3,xstatus='Applied' WHERE zid=@zid AND xcrnnum=@dornum 
			-----------------Mail Sending--------------------------
			Select @mail1=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior
			Select @mail2=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior2
			Select @mail3=isnull(xemail,'') from pdmst WHERE zid=@zid AND xposition=@superior3
	
			IF @mail1<>''
				set @mail1=@mail1
			IF @mail2<>''
				SET @mail2=';'+@mail2
			IF @mail3<>''
			SET @mail3=';'+@mail3
	
			SET @tomail=@mail1+@mail2+@mail3
	
			--IF @tomail<>''
			--	EXEC zabsp_sendmail @zid,@user,@position,@tornum,@tomail,'Request'
	
		END
IF (Select isnull(xstatus,'') from apvprcs WHERE zid=@zid and xtypetrn='DLC Approval' AND xposition=@position) = 'Approved'
		Update opdealshd set xidsup='',xsuperior2='',xsuperior3='',xstatus='Approved' WHERE zid=@zid AND xcrnnum=@dornum
END

ELSE Return




/*


select xposition,xstaff,* from pdmst where xposition='2120'


select xstatus,xstatusmor,xstatusjv,xpreparer,xidsup,xsignatory1,xsignatory2,xsignatory3,* from moheader

select xposition,xstaff,* from pdmst where xposition='204'

 --update moheader  set xstatus='Open',xidsup='' where xbatch='BAT-000001'


 Select xposition,* from pdsuperior WHERE zid=200010 AND xstaff='EID-02120'








select * from xusers where zid=200010 order by ztime desc

--update xusers set xoldpass=xpassword where zid=200010  
--update xusers set xpassword='' where zid=200010  


select xpreparer,* from moheader order by ztime desc


select xposition,xstaff,* from pdmst where xposition='2120'










*/