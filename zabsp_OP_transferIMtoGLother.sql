USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_OP_transferIMtoGL]    Script Date: 1/26/2023 12:37:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	exec zabsp_OP_transferIMtoGLother 100010,'mamun','ADDO000002'

ALTER PROC [dbo].[zabsp_OP_transferIMtoGLother] --#id,#user,xdate,xdatedue,xdatecom
	
	 @zid INT
	,@user VARCHAR(50)
	,@dornum VARCHAR(50)

AS

DECLARE 
	 @trn VARCHAR(50)
	,@gltrn VARCHAR(50)
	,@trnnum VARCHAR(50)
	,@accdr VARCHAR(50)
	,@acccr VARCHAR(50)
	,@date DATETIME
    ,@year INT
	,@per INT
	,@row INT
	,@count INT
	,@offset INT
	,@amount DECIMAL(20,2)
	,@gitem VARCHAR(50)
	,@message VARCHAR(500)
	,@trnlength INT

-- initialization 



	SELECT @trnnum = xvoucher,@date=xdate
	FROM opdoheader
	WHERE zid=@zid
	AND xdornum=@dornum





SET @year = YEAR(@date)
SET @per = MONTH(@date)
SET @row = 0
SET @accdr = ''
SET @acccr = ''
SET @message = 'Transfer from IM '

/********* GETTING GL YEAR & PERIOD *************/


SELECT @offset = xoffset,@trnlength=xlength
FROM acdef 
WHERE zid=@zid

SET @per = 12+@per-@offset

IF @per <= 12
	SET @year = @year-1
ELSE
	SET @per = @per-12



		-- ************** INSERT INTO ACHEADER ****************

		-- ************** GETTING TRANSACTION NO ****************
		DECLARE main_cursor CURSOR FORWARD_ONLY FOR

		SELECT LEFT(a.ximtrnnum,4),b.xgitem,SUM(xval)
		FROM imtrn a
		JOIN caitem b
		ON a.zid=b.zid
		AND a.xitem=b.xitem
		WHERE a.zid=@zid 
		AND a.xdocnum=@dornum
		AND a.xstatusjv='Open'
		AND LEFT(a.ximtrnnum,4) IN (SELECT xtrn FROM imtogli WHERE zid=@zid)
		AND a.xval>0
		GROUP BY LEFT(a.ximtrnnum,4),b.xgitem

		OPEN main_cursor

		FETCH FROM main_cursor INTO @trn,@gitem,@amount

		WHILE @@FETCH_STATUS = 0
		BEGIN
		
		SET @message = 'Transfer from IM For'+@trn 
					
		--SET @row = 0
		
		
		SELECT @gltrn = xrel 
		FROM xtrnp 
		WHERE zid = @zid 
		AND xtypetrn='Inventory Transaction' 
		AND xtrn=@trn 
		AND xtyperel='GL Voucher'
		
		EXEC Func_getTrn @zid,'GL Voucher',@gltrn,@trnlength,@strVar=@trnnum OUTPUT

		INSERT INTO acheader(ztime,zid,zauserid,xvoucher,xref,xdate,xlong,xstatusjv,xyear,xper,xtype,xsub,xtrn,xstatus,xwh)VALUES
				    (GETDATE(),@zid,@user,@trnnum,'',@date,@message,'Balanced',@year,@per,'','',@gltrn,'Approved','01')	
		
		
		SELECT @accdr = xaccdr,@acccr=xacccr
		FROM imtogli
		WHERE zid=@zid
		AND xtrn=@trn
		AND xgitem=@gitem

		/*********** DEBIT ACCOUNT **********/
		
		SET @row = @row+1

		INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xlong,xsub,xdebit)VALUES
					    (GETDATE(),@zid,@user,@trnnum,@row,@accdr,@amount,'','',@amount)


		/*********** CREDIT ACCOUNT **********/
		
		SET @row = @row+1	

		INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xlong,xsub,xcredit)VALUES
					    (GETDATE(),@zid,@user,@trnnum,@row,@acccr,0-@amount,'','',@amount)


		-- **************** CHECKING FOR Suspended Status Flag IN ACHEADER ******************

		SELECT @amount = SUM(xprime) 
		FROM acdetail 
		WHERE zid=@zid 
		AND xvoucher=@trnnum

		IF @amount <> 0
			UPDATE acheader SET xstatusjv='Suspended' WHERE zid=@zid AND xvoucher=@trnnum
		IF @amount = 0
			UPDATE acheader SET xstatusjv='Balanced' WHERE zid=@zid AND xvoucher=@trnnum

		-- **************** UPDATING FLAG IN lcinfo ******************

														--UPDATE imtrn 
														--SET xstatusjv='Confirmed',xvoucher=@trnnum
														--WHERE zid=@zid 
														--AND xdate BETWEEN @date AND @dateto
														--AND xstatusjv='Open'
														--AND LEFT(ximtrnnum,4)=@trn
														--AND xval>0

		UPDATE im 
		SET im.xstatusjv='Confirmed',im.xvoucher=@trnnum
		From imtrn im Join caitem cm on im.zid=cm.zid AND im.xitem=cm.xitem
		WHERE im.zid=@zid 
		AND im.xdocnum=@dornum
		AND im.xstatusjv='Open'
		AND LEFT(im.ximtrnnum,4)=@trn
		AND im.xval>0
		AND cm.xgitem=@gitem

		
			FETCH NEXT FROM main_cursor INTO @trn,@gitem,@amount
		END
		
		CLOSE main_cursor

		DEALLOCATE main_cursor

	
		--EXEC sp_acUnPost @zid,@user,@year,@per,@trnnum,@trnnum --#id,#user,xyear,xper,xvoucher,xvoucher
		--EXEC sp_acPost @zid,@user,@year,@per,@trnnum,@trnnum --,#id,#user,xyear,xper,xvoucher,xvoucher