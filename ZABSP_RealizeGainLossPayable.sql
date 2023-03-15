USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[ZABSP_RealizeGainLossPayable]   Script Date: 2022-11-12 1-:02:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC ZABSP_RealizeGainLossPayable  100000,'',90,'2022-12-12'
ALTER PROCEDURE [dbo].[ZABSP_RealizeGainLossPayable]
	@zid INT,
	@user VARCHAR(150),
	@exchrate DECIMAL(20,2),
	@date VARCHAR(50)

 AS

DECLARE 
 @ztime VARCHAR(150)
,@zauserid VARCHAR(150)
,@xvoucher VARCHAR(150)
,@xcus VARCHAR(150)
,@xdate VARCHAR(150)
,@xprime DECIMAL(20,6)
,@xtype VARCHAR(150)
,@xlcno VARCHAR(150)
,@xinvnum VARCHAR(150)
,@xexch DECIMAL(20,6)
,@dollar DECIMAL(20,6)
,@dollarexch DECIMAL(20,6)
,@bdt DECIMAL(20,6)
,@gainloss DECIMAL(20,6)
,@trnnum VARCHAR(50)
,@xsign int
,@offset INT
,@trnlength INT
,@row int
,@gsup VARCHAR(150)
,@acc VARCHAR(150)
,@accgainloss VARCHAR(150)
,@message VARCHAR(550)
,@ref VARCHAR(50)
,@year INT
,@per INT
,@reltrn VARCHAR(50)
,@preparer VARCHAR(50)
,@wh VARCHAR(50)
,@amount DECIMAL(20,6)

-- initialization

  SET @row = 0
  SET @acc = ''
  SET @message = 'Money Receipt No ' +@xvoucher
  SET @year = YEAR(@date)
  SET @per = MONTH(@date)

SELECT @offset = xoffset,@trnlength=xlength
FROM acdef 
WHERE zid=@zid

SET @per = 12+@per-@offset

IF @per <= 12
	SET @year = @year-1
ELSE
	SET @per = @per-12


DECLARE result_cursor CURSOR FORWARD_ONLY FOR

--select ISNULL(a.xcus,''),sum(ISNULL(a.xprime,0)*ISNULL(a.xexch,0)),sum(ISNULL(a.xprime,0)*ISNULL(@exchrate,0))
--from arallocationarccashview a 
--where 
--a.zid=@zid and a.xinvnum<>'' 
--group by a.xcus

----select xcus,SUM((xprime+isnull(xvatamt,0)+isnull(xaitbase,0)+isnull(xadjustbase,0)+isnull(xgainlossbase,0))*xsign),
----SUM((xbase+isnull(xvatamt,0)+isnull(xaitbase,0)+isnull(xadjustbase,0)+isnull(xgainlossbase,0))*xsign)
----from arhed
----where xtypetrn = 'Purchase' and xexch>1
----group by xcus 
----having SUM((xprime+isnull(xvatamt,0)+isnull(xaitbase,0)+isnull(xadjustbase,0)+isnull(xgainlossbase,0))*xsign) > 0


select xcus,SUM(xprime*xsign),
SUM(xbase*xsign)
from arreportview
where xtypetrn = 'Purchase' and xexch>1 and xdate<=@date
group by xcus 
having SUM(xprime*xsign) > 0

OPEN result_cursor

FETCH FROM result_cursor INTO @xcus,@dollar,@bdt
WHILE @@FETCH_STATUS = 0

BEGIN

	SET @dollarexch=@dollar*@exchrate
	SET @gainloss=@bdt-@dollarexch


	EXEC Func_getTrn @zid,'AR Transactions','ADAP',6,@strVar=@trnnum OUTPUT


	INSERT INTO arhed(ztime,zauserid,zid,xvoucher,xcus,xprime,xdate,xlcno,xinvnum,xexch,xgainlossbase,xsign,xtypetrn,xbank,xwh,xcur,xbase,xpaymenttype,xref,xdateref,xaitamt,xaitexch,xadjustment,xstatusjv,xdocnum,xnote)
			    VALUES
				(GETDATE(),@zauserid,@zid,@trnnum,@xcus,0,@date,'','',@xexch,@gainloss,1,'Purchase','','',$,0,'','','',0,0,0,'','','')
     set @trnnum=''

     Select @gsup = xgsup from cacus where zid=@zid and xcus=@xcus

			SELECT @acc = xacc,@accgainloss=xaccgainloss
				FROM xcodes
				WHERE zid=@zid
				AND xtype='Supplier Group'
				AND xcode=@gsup
				print @acc
				print @accgainloss
				print @gsup
				print @xcus

	        IF @gainloss > 0
			BEGIN
	
					EXEC Func_getTrn @zid,'GL Voucher','JV--',6,@strVar=@trnnum OUTPUT
			INSERT INTO acheader(ztime,zid,zauserid,xvoucher,xref,xdate,xlong,xstatusjv,xyear,xper,xtype,xtrn,xlcno,xsub,xinvnum,xdornum,xstatus,xpreparer,xwh)VALUES
							(GETDATE(),@zid,@user,@trnnum,@ref,@date,@message,'Balanced',@year,@per,'','JV--',@xlcno,@xcus,@xinvnum,@xvoucher,'Open',@preparer,@wh)
		    
			select @row = isnull(max(xrow),0)+1 from acdetail where zid=@zid and xvoucher=@trnnum	
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xdebit,xcredit,xlong,xsub)VALUES
			(GETDATE(),@zid,@user,@trnnum,@row,@acc,@gainloss,@gainloss,0,'',@xcus)

			select @row = isnull(max(xrow),0)+1 from acdetail where zid=@zid and xvoucher=@trnnum
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xdebit,xcredit,xlong,xsub)VALUES
			(GETDATE(),@zid,@user,@trnnum,@row,@accgainloss,0-@gainloss,0,@gainloss,'','')

			-- **************** CHECKING FOR Suspended Status Flag IN ACHEADER ******************

			SELECT @amount = SUM(xprime) FROM acdetail WHERE zid=@zid AND xvoucher=@trnnum
			IF @amount <> 0
				UPDATE acheader SET xstatusjv='Suspended' WHERE  zid=@zid AND xvoucher=@trnnum
			IF @amount = 0
				UPDATE acheader SET xstatusjv='Balanced' WHERE  zid=@zid AND xvoucher=@trnnum	

			    set @trnnum=''
			END

			IF @gainloss < 0
			BEGIN
			EXEC Func_getTrn @zid,'GL Voucher','JV--',6,@strVar=@trnnum OUTPUT
			INSERT INTO acheader(ztime,zid,zauserid,xvoucher,xref,xdate,xlong,xstatusjv,xyear,xper,xtype,xtrn,xlcno,xsub,xinvnum,xdornum,xstatus,xpreparer,xwh)VALUES
							(GETDATE(),@zid,@user,@trnnum,@ref,@date,@message,'Balanced',@year,@per,'','JV--',@xlcno,@xcus,@xinvnum,@xvoucher,'Open',@preparer,@wh)
		    
			select @row = isnull(max(xrow),0)+1 from acdetail where zid=@zid and xvoucher=@trnnum
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xdebit,xcredit,xlong,xsub)VALUES
			(GETDATE(),@zid,@user,@trnnum,@row,@accgainloss,0-@gainloss,0-@gainloss,0,'','')
			
			select @row = isnull(max(xrow),0)+1 from acdetail where zid=@zid and xvoucher=@trnnum
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xdebit,xcredit,xlong,xsub)VALUES
			(GETDATE(),@zid,@user,@trnnum,@row,@acc,@gainloss,0,0-@gainloss,'',@xcus)

			-- **************** CHECKING FOR Suspended Status Flag IN ACHEADER ******************

				SELECT @amount = SUM(xprime) FROM acdetail WHERE zid=@zid AND xvoucher=@trnnum
			IF @amount <> 0
				UPDATE acheader SET xstatusjv='Suspended' WHERE  zid=@zid AND xvoucher=@trnnum
			IF @amount = 0
				UPDATE acheader SET xstatusjv='Balanced' WHERE  zid=@zid AND xvoucher=@trnnum

			    set @trnnum=''
			END



	FETCH NEXT FROM result_cursor INTO @xcus,@dollar,@bdt
END

CLOSE result_cursor

DEALLOCATE result_cursor




