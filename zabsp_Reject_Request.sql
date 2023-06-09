USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_Reject_Request]    Script Date: 3/14/2023 12:02:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec zabsp_Full_Reqn_Approved '100010','admin','TO--000017','Open''
--zabsp_Reject_Request 100060,'shamer','670','1','EID-00356','Leave'
ALTER PROC [dbo].[zabsp_Reject_Request] --#id,#user,xtornum,xmoprcs,xbatch
	
	@zid int,
	@user varchar(50),
	@position varchar(50),
	@wh VARCHAR(50),
	@tornum varchar(50),
	@request VARCHAR(50)

AS

DECLARE	@xstatus varchar(50),
		@shift varchar(50),
		@superior varchar(50),
		@superior2 varchar(50),
		@superior3 varchar(50),
		@grnnum varchar(50),
		@type varchar(50),
		@poreqnum varchar(50),
		@pornum varchar(50),
		@voucher varchar(50),
		@dornum varchar(50),
		@pafnum varchar(50),
		@tonum varchar(50),
		@staff varchar(50),
		@case varchar(50),
		@totreqqty DECIMAL(20,2),
		@totprqty DECIMAL(20,2),
		@ypd INT,
		@bomkey varchar(50)


---------init-------
SET @totreqqty=0
SET @totprqty=0


------------------------GL Voucher Reject--------------------------------------------
IF @request ='GL'
BEGIN
Set @voucher=@tornum
Update acheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Open',
					xsuperiorgl='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xvoucher=@voucher
END
------------------------SR WR TO Damage Reject--------------------------------------------
ELSE IF @request ='SR_WR_TO'
BEGIN
Update imtorheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatustor='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xtornum=@tornum
END
------------------------BAT Reject--------------------------------------------
ELSE IF @request ='BATP'
BEGIN
Update moheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xbatch=@tornum
END

------------------------BAT Reject--------------------------------------------
ELSE IF @request ='BAT'
BEGIN
Update moheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xbatch=@tornum
END

------------------------RMCA Reject--------------------------------------------
ELSE IF @request ='RMCA'
BEGIN
Update imconsumptionadjheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xadjnum=@tornum
END

ELSE IF @request ='CS'
BEGIN
SET @poreqnum=@tornum
Update poreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusreq='Recommended For Quotation',
					xsuperiorsp=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xporeqnum=@poreqnum
END

ELSE IF @request ='SQ'
BEGIN
SET @poreqnum=@tornum
Update poreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusreq='Rejected',
					xsuperiorsp=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xporeqnum=@poreqnum
END

ELSE IF @request ='Cash'
BEGIN
SET @poreqnum=@tornum
Update poreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusreq='Recommended For Estimated Cost',
					xsuperiorsp=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xporeqnum=@poreqnum
END

ELSE IF @request ='Cash Adjustment'
BEGIN
SET @poreqnum=@tornum
Update poreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusreq='',
					xsuperiorsp=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poreqheader WHERE zid=@zid AND xporeqnum=@poreqnum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xporeqnum=@poreqnum
END


ELSE IF @request ='PO'
BEGIN
SET @pornum=@tornum
Update poordheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poordheader WHERE zid=@zid AND xpornum=@pornum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xpornum=@pornum
END

ELSE IF @request ='Invoice'
BEGIN
SET @dornum=@tornum
Update opdoheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from poordheader WHERE zid=@zid AND xpornum=@pornum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xdornum=@dornum
END


ELSE IF @request ='PAF'
BEGIN
SET @pafnum=@tornum
Update appaymentreqh set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusreq='',
					xsuperiorsp=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from appaymentreqh WHERE zid=@zid AND xpafnum=@pafnum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xpafnum=@pafnum
END

ELSE IF @request ='GRN'
BEGIN
SET @grnnum=@tornum
Update pogrnheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusdoc='Open',
					xsuperiorsp='',xsuperior2='',xsuperior3='' WHERE zid=@zid AND xgrnnum=@grnnum
END

------------------------PO  Deal Reject--------------------------------------------
IF @request ='deal'
BEGIN
Set @voucher=@tornum
Update podealsheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Open',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xdealno=@voucher
END


ELSE IF @request ='Late'
BEGIN
SET @staff=@tornum
SET @ypd=CAST(@wh AS INT)
Update pdathd set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatuslate='Rejected'
					WHERE zid=@zid AND xstaff=@staff AND xyearperdate=@ypd
END

ELSE IF @request ='Early Leave'
BEGIN
SET @staff=@tornum
SET @ypd=CAST(@wh AS INT)
Update pdathd set xsignatory4='',xsigndate4=null,xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,
					xsignreject2=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject2=GETDATE(),xstatusel='Rejected'
					WHERE zid=@zid AND xstaff=@staff AND xyearperdate=@ypd
END

ELSE IF @request ='Absent'
BEGIN
SET @staff=@tornum
SET @ypd=CAST(@wh AS INT)
Update pdathd set xsignatory7='',xsigndate8=null,xsignatory9='',xsigndate7=null,xsignatory8='',xsigndate9=null,
					xsignreject3=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject3=GETDATE(),xstatusabsent='Rejected'
					WHERE zid=@zid AND xstaff=@staff AND xyearperdate=@ypd
END

ELSE IF @request ='Leave'
BEGIN
print '-------------------Leave----------------'
SET @staff=@tornum
SET @ypd=CAST(@wh AS INT)
Update pdleaveheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xsid='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xyearperdate=@ypd AND xstaff=@staff

END
--zabsp_Reject_Request 400010,'10109','10109','0','RFP-000001','RFP'
ELSE IF @request ='RFP'
BEGIN
set @case=@tornum
Update acreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xacreqnum=@case
END

--zabsp_Reject_Request 400010,'10109','10109','0','RFP-000001','Transport Reject'
ELSE IF @request ='Transport Reject'
BEGIN
set @request=@tornum
Update pdfacilityreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xreqnum=@request
END
--zabsp_Reject_Request 400010,'10109','10109','0','RFP-000001','Cooking Facility Reject'
ELSE IF @request ='Cooking Facility Reject'
BEGIN
set @request=@tornum
Update pdfacilityreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xreqnum=@request
END
--zabsp_Reject_Request 400010,'10109','10109','0','RFP-000001','Accommodation Reject'
ELSE IF @request ='Accommodation Reject'
BEGIN
set @request=@tornum
Update pdfacilityreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xreqnum=@request
END

--zabsp_Reject_Request 100150,'1876','1876','0','LGL-000001','Legal Fund'
ELSE IF @request ='Legal Fund'
BEGIN
set @case=@tornum
Update acreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xacreqnum=@case
END


------------------------LPR Reject--------------------------------------------
ELSE IF @request ='LPR'
BEGIN
Update imtorheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatustor='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xtornum=@tornum
END

ELSE IF @request ='LRN'
BEGIN
SET @grnnum=@tornum
Update pogrnheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatusdoc='Open',
					xsuperiorsp='',xsuperior2='',xsuperior3='' WHERE zid=@zid AND xgrnnum=@grnnum
END

--zabsp_Reject_Request 300030,'00928','00928','0','EAD-000003','Land Advance'
ELSE IF @request ='Land Advance'
BEGIN
set @case=@tornum
Update acreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xacreqnum=@case
END

ELSE IF @request ='BOM'
BEGIN
Update bmbomheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xbomkey=@tornum
END


ELSE IF @request ='BOMP'
BEGIN
Update bmbomheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xbomkey=@tornum
END

ELSE IF @request ='Batch Inspection'
BEGIN
Update imtorheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xtornum=@tornum
END

ELSE IF @request ='Customer'
BEGIN
Update cacus set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xcus=@tornum
END
ELSE IF @request ='SO'
BEGIN
Update imtorheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatustor='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xtornum=@tornum
END

	
ELSE IF @request ='SLR Approval'
BEGIN
				Update opcrnheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
									xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
									xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
									xidsup='',xsuperior2='',xsuperior3=''
									WHERE zid=@zid AND xcrnnum=@tornum
END

ELSE IF @request ='Supplier'
BEGIN
				Update cacus set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
									xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
									xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
									xidsup='',xsuperior2='',xsuperior3=''
									WHERE zid=@zid AND xcus=@tornum
END

ELSE IF @request ='Customer'
BEGIN
				Update cacus set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
									xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
									xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
									xidsup='',xsuperior2='',xsuperior3=''
									WHERE zid=@zid AND xcus=@tornum
END

ELSE IF @request ='Product'
BEGIN
				Update caitem set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
									xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
									xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
									xidsup='',xsuperior2='',xsuperior3=''
									WHERE zid=@zid AND xitem=@tornum
END



--zabsp_Reject_Request 300030,'00928','00928','0','EAD-000003','Land Advance'
ELSE IF @request ='Advance'
BEGIN
set @case=@tornum
Update acreqheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xacreqnum=@case
END

--zabsp_Reject_Request 300030,'00928','00928','0','EAD-000003','Land Advance Adjustment'
ELSE IF @request ='Advance Adjustment'
BEGIN
set @case=@tornum
Update acreqheaderadj set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xacreqnum=@case
END


--zabsp_Reject_Request'400010','10106','10106','0','CSN-000028','Settlement'
ELSE IF @request ='Settlement'
BEGIN
set @case=@tornum
print 'Sara'
Update pdsettlement set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xcase=@case
END


ELSE IF @request ='DC'
BEGIN
SET @dornum=@tornum
Update opdcheader set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup=(Select xposition from pdmst WHERE zid=@zid AND xstaff=(Select xpreparer from opdcheader WHERE zid=@zid AND xdocnum=@dornum)),
					xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xdocnum=@dornum
END


ELSE IF @request ='Supplier Invoice Approval for Multiple GRN'
BEGIN 
Update apsupinvm set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
					xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
					xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
					xidsup='',xsuperior2='',xsuperior3=''
					WHERE zid=@zid AND xgrninvno=@tornum
END

ELSE IF @request ='DLC Approval'
BEGIN
				Update opdealshd set xsignatory1='',xsigndate1=null,xsignatory2='',xsigndate2=null,xsignatory3='',xsigndate3=null,xsignatory4='',xsigndate4=null,
									xsignatory5='',xsigndate5=null,xsignatory6='',xsigndate6=null,xsignatory7='',xsigndate7=null,
									xsignreject=(Select xstaff from pdmst WHERE zid=@zid AND xposition=@position),xdatereject=GETDATE(),xstatus='Rejected',
									xidsup='',xsuperior2='',xsuperior3=''
									WHERE zid=@zid AND xcrnnum=@tornum
END


ELSE Return
