USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[ZABSP_RealizeGainLoss]    Script Date: 2022-11-07 1:02:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC ZABSP_RealizeGainLoss  100000,'',90,'2022-12-12'
ALTER PROCEDURE [dbo].[ZABSP_RealizeGainLoss]
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
,@gcus VARCHAR(150)
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
--SET @lineamt = 0
--SET @totcost = 0
--SET @totqty = 0

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

select xcus,sum((isnull(xadjustment,0)+isnull(xvatamt,0)+isnull(xaitamt,0)+isnull(xprime,0))*xsign),(select sum(xbase*xsign) from arreportview where  xcus=arhed.xcus group by xcus) from arhed
where arhed.xtypetrn='Sale' and xdate<=@date
group by arhed.xcus
having sum((isnull(xadjustment,0)+isnull(xvatamt,0)+isnull(xaitamt,0)+isnull(xprime,0))*xsign)>0

OPEN result_cursor

FETCH FROM result_cursor INTO @xcus,@dollar,@bdt
WHILE @@FETCH_STATUS = 0

BEGIN

	SET @dollarexch=@dollar*@exchrate
	SET @gainloss=@bdt-@dollarexch


	EXEC Func_getTrn @zid,'AR Transactions','ADAR',6,@strVar=@trnnum OUTPUT


	INSERT INTO arhed(ztime,zauserid,zid,xvoucher,xcus,xprime,xdate,xlcno,xinvnum,xexch,xgainlossbase,xsign,xtypetrn,xbank,xwh,xcur,xbase,xpaymenttype,xref,xdateref,xaitamt,xaitexch,xadjustment,xstatusjv,xdocnum,xnote)
			    VALUES
				(GETDATE(),@zauserid,@zid,@trnnum,@xcus,0,@date,'','',@xexch,@gainloss,-1,'Sale','','',$,0,'','','',0,0,0,'','','')
     set @trnnum=''
     Select @gcus = xgcus from cacus where zid=@zid and xcus=@xcus
     SELECT @acc = xacc,@accgainloss=xaccgainloss
			FROM xcodes
			WHERE zid=@zid
			AND xtype='Customer Group'
			AND xcode=@gcus


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
			(GETDATE(),@zid,@user,@trnnum,@row,@accgainloss,0-@gainloss,0,@gainloss,'','')
			
			select @row = isnull(max(xrow),0)+1 from acdetail where zid=@zid and xvoucher=@trnnum
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xdebit,xcredit,xlong,xsub)VALUES
			(GETDATE(),@zid,@user,@trnnum,@row,@acc,@gainloss,@gainloss,0,'',@xcus)

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




