USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_confirmDLC]    Script Date: 3/14/2023 12:14:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--sp_confirmDLC 200010,'2126','DLC-23000001','2023-02-22','02',6
ALTER PROC [dbo].[sp_confirmDLC] --#id,#user,xcrnnum,xdate,xwh,6
	
	@zid INT,
	@user VARCHAR(50), 
	@crnnum VARCHAR(50),
	@date datetime,
	@wh VARCHAR(50),
	@trnlength INT

  AS

DECLARE @trn VARCHAR(50),
	@row INT,
	@docrow INT,
	@costrow INT,
	@trnnum VARCHAR(50),
	@dornum VARCHAR(50),
	@imtrnnum VARCHAR(50),
	@item VARCHAR(50),
	@unit VARCHAR(50),
	@statuscrn VARCHAR(50),
	@qtyord DECIMAL(20,2),
	@qty DECIMAL(20,2),
	@balqty DECIMAL(20,2),
	@balance DECIMAL(20,2),
	@cost DECIMAL(20,4),
	@rate DECIMAL(20,4),
	@totamt DECIMAL(20,4),
	@lineamt DECIMAL(20,4)


-- **************INITIALIZATION****************

SET @row = 0
SET @docrow = 0
SET @costrow = 0
SET @trnnum = ''
SET @dornum = ''
SET @imtrnnum = ''
SET @item = ''
SET @unit = ''
SET @statuscrn = ''
SET @qtyord = 0
SET @qty = 0
SET @cost = 0
SET @rate = 0
SET @balqty = 0
SET @balance = 0
SET @totamt = 0
SET @lineamt = 0


	SELECT @statuscrn = xstatuscrn FROM opdealshd WHERE zid=@zid AND xcrnnum=@crnnum
	IF @statuscrn ='Confirmed'
		RETURN
	SELECT @trn = xrel FROM xtrnp WHERE zid=@zid AND xtypetrn='DLC Number' AND xtrn=LEFT(@crnnum,4) AND xtyperel='Inventory Transaction' AND zactive='1'

	DECLARE result_cursor CURSOR FORWARD_ONLY FOR

	SELECT xrow,xitem,xunit,xqtyord,xlineamt FROM opdealsdt WHERE zid=@zid AND xcrnnum=@crnnum 

	OPEN result_cursor

	FETCH FROM result_cursor INTO @row,@item,@unit,@qtyord,@lineamt

	WHILE @@FETCH_STATUS = 0

	BEGIN

				EXEC Func_getTrn @zid,'Inventory Transaction','DLC-',@trnlength,@strVar=@trnnum OUTPUT
				print @trnnum
				INSERT INTO imtrn(ztime,zauserid,zid,ximtrnnum,xitem,xwh,xdate,xqty,xval,xvalpost,xdocnum,xdocrow,xnote,
				    xsign,xunit,xrate,xref,xstatusjv,xcostrow)VALUES
				    (GETDATE(),@user,@zid,@trnnum,@item,@wh,@date,@qtyord,0,0,@crnnum,@row,'Transfer From Dealer Closing',
				    1,@unit,0,'','Open',0)

		FETCH NEXT FROM result_cursor INTO @row,@item,@unit,@qtyord,@lineamt
	END

	
	CLOSE result_cursor
	DEALLOCATE result_cursor

	UPDATE opdealshd SET xstatuscrn='Confirmed',zutime=GETDATE(),zuuserid=@user WHERE zid=@zid AND xcrnnum=@crnnum

