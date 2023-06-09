USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_OP_transferOPtoAR]    Script Date: 3/14/2023 12:16:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec zabsp_OP_transferOPtoAR 200010,'System.zab','DO--0000571','opdoheader'


ALTER PROC [dbo].[zabsp_OP_transferOPtoAR] --#id,#user,xdate,xinvnum,"opinvheader"
	 @zid INT
	,@user VARCHAR(50)
--	,@date DATETIME
	,@invnum VARCHAR(50)
	,@screen VARCHAR(50)	

AS

--BEGIN TRAN @user
SET NOCOUNT ON
DECLARE 

		 @datedue DATETIME
		,@date DATETIME
		,@wh VARCHAR(50)
		,@ordernum VARCHAR(50)
		,@voucherno VARCHAR(50)
		,@gcus VARCHAR(50)
		,@cus VARCHAR(50)
		,@type VARCHAR(50)
		,@acccr VARCHAR(50)
		,@accdr VARCHAR(50)
	    ,@row INT
	    ,@offset INT
	    ,@trnlength INT
		,@year INT
		,@per INT
	    ,@orderrow INT
	    ,@dorrow INT
	    ,@item VARCHAR(50)
	    ,@lcno VARCHAR(50)
	    ,@messege VARCHAR(250)
		,@long VARCHAR(500) =''
	    ,@voucher VARCHAR(50)
	    ,@unit VARCHAR(50)
		,@qtyord DECIMAL(20,2)
		,@lineamt DECIMAL(20,2)
		,@totamt DECIMAL(20,2)
		,@trn VARCHAR(50)
		,@imtrnnum VARCHAR(50)
		,@exch DECIMAL(20,2)
		,@vatamt DECIMAL(20,2)
		,@vatrate DECIMAL(20,5)
		,@advadj DECIMAL(20,2)
		,@vatadj DECIMAL(20,2)
		,@taxadj DECIMAL(20,2)
		,@prime DECIMAL(20,2)
		,@base DECIMAL(20,2)
		,@gitem VARCHAR(50)
		,@cusgroup VARCHAR(50)
		,@acc VARCHAR(50)
		,@piref VARCHAR(50)
		,@stype VARCHAR(50)
		,@sp VARCHAR(50)
		,@sm VARCHAR(50)
		,@rsm VARCHAR(50)
		,@fm VARCHAR(50)
		,@pp VARCHAR(50)
		,@crnnum VARCHAR(50)
		,@paymenttype VARCHAR(50)
		,@desc  VARCHAR(100) =''
		,@qtysale  DECIMAL(20,2) = 0, @depositrate  DECIMAL(20,2) = 0, @depositamt  DECIMAL(20,2) = 0

	SET @prime = 0	SET @vatadj = 0		SET @taxadj = 0		SET @advadj = 0
	SET @row = 0
	SET @vatamt= 0
	SET @vatrate = 0

	SET @datedue = '2999-01-01'

IF @screen = 'opdoheader'
	BEGIN
		IF EXISTS(SELECT xdornum from opdoheader WHERE zid=@zid AND xdornum=@invnum AND xstatusar='Confirmed')
			RETURN

		SELECT @gcus=cus.xgcus,@cus=a.xcus,@date=a.xdate,@sp=a.xsp,@sm=a.xsm,@rsm=a.xrsm,@fm=a.xfm,@pp=a.xpp,@wh = a.xwh,@prime=SUM(b.xlineamt),@long = isnull(a.xnote,'') --,@vatamt=SUM(a.xvatamt)
		FROM opdoheader a
		JOIN opdodetail b
		ON a.zid=b.zid
		AND a.xdornum=b.xdornum
		JOIN cacus cus
		ON a.zid=cus.zid
		AND a.xcus=cus.xcus
		WHERE a.zid=@zid 
		AND a.xdornum=@invnum
		AND a.xstatusar='Open'
		GROUP BY cus.xgcus,a.xcus,a.xdate,a.xsp,a.xsm,a.xrsm,a.xfm,a.xpp,a.xwh,isnull(a.xnote,'')

		SET @stype='Other'

		Select @vatamt= isnull(xvatamt,0),@vatrate = isnull(xvatrate,0),@advadj = isnull(xadamount,0),
		@vatadj=isnull(xadvat,0),@taxadj=isnull(xadtax,0) from opdoheader  WHERE zid=@zid AND xdornum=@invnum AND xstatusar='Open'
		
		SET @base = @prime+ISNULL(@vatamt,0)-(isnull(@advadj,0)+isnull(@vatadj,0)+isnull(@taxadj,0))
		IF @base > 0
		BEGIN

		/******************** INSERT INOT ARHED ********************/
		
			INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xbase,xdiscprime,xchgsprime,xnote,xstatusjv,xsign,xbalprime,xdocnum,xvatamt,xaitamt,
																xwh,xdatedue,xpaymentterm,xtype,xlcno,xordernum,xtypetrn,
																a.xsp,a.xsm,a.xrsm,a.xfm,a.xpp,xdornum)
					   VALUES(GETDATE(),@zid,@user,@invnum,@cus,@date,'','Inv',@base,@base,0,0,'Transfer From Invoice. '+@long,'Confirmed',1,@base,'',0,0,
																@wh,@date,'',@stype,@lcno,@ordernum,'Sale',@sp,@sm,@rsm,@fm,@pp,@invnum)


-- exec zabsp_OP_transferOPtoAR 200010,'System.zab','DO--0000571','opdoheader'
---------------------- Deposit Voucher--------------------------------
			DECLARE deposit_cursor CURSOR FORWARD_ONLY FOR
			Select isnull(d.xassetitem,''),d.xqtyord,isnull(c.xdesc,''),isnull(d.xratedeposit,0) from opdodetail d join opdoheader h on d.zid = h.zid AND d.xdornum = h.xdornum 
			left join caitem c on c.zid = d.zid AND d.xassetitem =c.xitem
			WHERE h.zid = @zid AND h.xdornum = @invnum AND  isnull(xstatusar,'')<>'Confirmed'
			
			OPEN deposit_cursor
			FETCH FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate

			WHILE @@FETCH_STATUS = 0
			BEGIN
			IF @depositrate>0
			BEGIN
			SET @depositamt =(@depositrate*@qtysale)
			SET @long = @desc +' @'+CAST(@depositrate as varchar(50)) +' X '+CAST(CAST(@qtysale AS INT) as VARCHAR(20))+', '
			SET @depositrate = 0
			SET @qtysale = 0

						Select @row = isnull(count(xvoucher),0)+1 from arhed where zid = @zid AND isnull(xdornum,'') = @invnum
						INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xdiscprime,xchgsprime,xnote,xstatusjv,xsign,xbalprime,xvatrate,
						xait,xdocnum,xtotamt,xvatamt,xaitamt,xwh,xsp,xsm,xrsm,xfm,xpp,xdatedue,xpaymentterm,xtype,xtypetrn,xpaymenttype,xsubcat,xtso,xdornum)
						VALUES(GETDATE(),@zid,@user,@invnum+'-'+CAST(@row as varchar(10)),@cus,@date,'','Deposit',@depositamt,0,0,'Deposit for '+@long,
						'Open',1,@depositamt,0,0,'',@depositamt,0,0,@wh,@sp,@sm,@rsm,@fm,@pp,@date,'Cash',@type,'Sale',@paymenttype,'','',@invnum) 
			END
			SET @depositamt = 0
			SET @long =''	
			FETCH NEXT FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate
			END
			CLOSE deposit_cursor
			DEALLOCATE deposit_cursor

-------------------------------End of Deposit Transaction -----------------------------------
			
		Select @voucherno=isnull(xdepositvoucher,''),@voucher=isnull(xvoucher,'') from opdoheader WHERE zid=@zid AND xdornum = @invnum
		IF @voucherno <> ''
		Update arhed SET xdocnum = @voucherno WHERE zid=@zid AND xvoucher in  (@invnum+'-2',@invnum+'-3',@invnum+'-4')

		IF @voucher <> ''
		Update arhed SET xdocnum = @voucher WHERE zid=@zid AND xvoucher =@invnum
		
	--	EXEC zabsp_AR_AutoAllocation @zid,@user,@invnum,'Allocate MR'	
	END -- END OF screen = 'opdoheader'
END

		/*********************************************END AR TRANSFER**************************************************************/
--zabsp_OP_transferOPtoAR'100090','zabadmin','SLR-17000001','opcrnheader'
	IF @screen = 'opcrnheader'
	BEGIN
	
	SET @crnnum=@invnum
	
		/******** checking for confirmed grn **********/

		IF EXISTS(SELECT xcrnnum from opcrnheader WHERE zid=@zid AND xcrnnum=@crnnum AND xstatusar='Confirmed')
			RETURN

		SELECT @ordernum=xordernum,@cus=xcus,@date=xdate,@type=xtype,@wh = xwh--,@paymenttype=xpaymenttype
		FROM opcrnheader 
		WHERE zid=@zid 
		AND xcrnnum=@crnnum

		if @ordernum<>''
		BEGIN

		SELECT @gcus=xgcus FROM cacus WHERE zid=@zid AND xcus=@cus
		/*
		SELECT @balamt = xbalprime,@prime=xprime
		FROM arhed 
		WHERE zid=@zid
		AND xvoucher=@ordernum
		*/
		SELECT @totamt = ISNULL(SUM(xlineamt),0)+isnull(sum(isnull(xvatamt,0)),0)-isnull(sum(isnull(xdiscdetamt,0)),0)
		FROM opcrndetail
		WHERE zid=@zid
		AND xcrnnum=@crnnum
	--	print @crnnum
	--	print @totamt
		IF @totamt>0			
		BEGIN
		INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xbase,xdiscprime,
							xchgsprime,xnote,xstatusjv,xsign,xbalprime,xdocnum,xvatamt,xaitamt,xwh,xdatedue,
						xpaymentterm,xtype,xlcno,xtypetrn,xordernum,xgrnnum,xpornum,xpaymenttype,xcur,xexch,xdornum)
					   VALUES(GETDATE(),@zid,@user,@crnnum,@cus,@date,'','',@totamt,@totamt,0,
								 0,'Transfer From SR','Open',-1,@totamt,'',0,0,@wh,@date,
	     						'',@type,'','Sale','',@ordernum,'',@paymenttype,'BDT',1.00,@crnnum)

						--======================= insert aralc  ====================

				/*	INSERT INTO aralc(ztime,zauserid,zid,xvoucher,xinvnum,xdate,xdatedue,xbalance,xamount)
								VALUES(GETDATE(),@user,@zid,@invnum,@ordernum,@date,@date,@balamt,@totamt) */

		
		EXEC zabsp_SR_AutoCollection @zid,@user,@cus,@totamt,@crnnum,@date,@ordernum

---------------------- Deposit Voucher--------------------------------
-- EXEC zabsp_OP_transferOPtoAR '200010','System','SLR-22000001','opcrnheader'
	DECLARE deposit_cursor CURSOR FORWARD_ONLY FOR
	Select isnull(d.xassetitem,''),d.xqtyord,ca.xdesc,d.xratedeposit from opcrndetail d join opcrnheader h on d.zid = h.zid AND d.xcrnnum = h.xcrnnum 
	join caitem c on c.zid = d.zid AND d.xitem =c.xitem
	left join caitem ca on ca.zid = d.zid AND ca.xassetitem =d.xassetitem
	WHERE h.zid = @zid AND h.xcrnnum = @crnnum AND  isnull(xstatusar,'')<>'Confirmed'
			
	OPEN deposit_cursor
	FETCH FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @depositrate>0
		BEGIN
		SET @depositamt =(@depositrate*@qtysale)
		SET @long = @desc +' @'+CAST(@depositrate as varchar(50)) +' X '+CAST(CAST(@qtysale AS INT) as VARCHAR(20))+', '
		SET @depositrate = 0
		SET @qtysale = 0	
				
				Select @row = isnull(count(xvoucher),0)+1 from arhed where zid = @zid AND isnull(xdornum,'') = @crnnum
				INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xbase,xdiscprime,
						xchgsprime,xnote,xstatusjv,xsign,xbalprime,xdocnum,xvatamt,xaitamt,xwh,xdatedue,
					xpaymentterm,xtype,xlcno,xtypetrn,xordernum,xgrnnum,xpornum,xpaymenttype,xcur,xexch,xdornum)
					VALUES(GETDATE(),@zid,@user,@crnnum+'-'+CAST(@row as varchar(10)),@cus,@date,'','',@depositamt,@depositamt,0,
								0,'Deposit return '+@long,'Open',-1,@depositamt,'',0,0,@wh,@date,
	     					'',@type,'','Sale','',@ordernum,'',@paymenttype,'BDT',1.00,@crnnum)
		END
		SET @depositamt = 0
		SET @long =''

	FETCH NEXT FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate
	END
	CLOSE deposit_cursor
	DEALLOCATE deposit_cursor

	END 
	END
	ELSE
	BEGIN
	SELECT @gcus=xgcus FROM cacus WHERE zid=@zid AND xcus=@cus
		/*
		SELECT @balamt = xbalprime,@prime=xprime
		FROM arhed 
		WHERE zid=@zid
		AND xvoucher=@ordernum
		*/
		SELECT @totamt = ISNULL(SUM(xlineamt),0)+isnull(sum(isnull(xvatamt,0)),0)-isnull(sum(isnull(xdiscdetamt,0)),0)
		FROM opcrndetail
		WHERE zid=@zid
		AND xcrnnum=@crnnum
	--	print @crnnum
	--	print @totamt
		IF @totamt>0			
		BEGIN
		INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xbase,xdiscprime,
							xchgsprime,xnote,xstatusjv,xsign,xbalprime,xdocnum,xvatamt,xaitamt,xwh,xdatedue,
						xpaymentterm,xtype,xlcno,xtypetrn,xordernum,xgrnnum,xpornum,xpaymenttype,xcur,xexch,xdornum)
					   VALUES(GETDATE(),@zid,@user,@crnnum,@cus,@date,'','',@totamt,@totamt,0,
								 0,'Transfer From SR','Open',-1,@totamt,'',0,0,@wh,@date,
	     						'',@type,'','Sale','','','',@paymenttype,'BDT',1.00,@crnnum)

						--======================= insert aralc  ====================

				/*	INSERT INTO aralc(ztime,zauserid,zid,xvoucher,xinvnum,xdate,xdatedue,xbalance,xamount)
								VALUES(GETDATE(),@user,@zid,@invnum,@ordernum,@date,@date,@balamt,@totamt) */

		
		EXEC zabsp_SR_AutoCollection @zid,@user,@cus,@totamt,@crnnum,@date,@ordernum

---------------------- Deposit Voucher--------------------------------
-- EXEC zabsp_OP_transferOPtoAR '200010','System','SLR-22000001','opcrnheader'
	DECLARE deposit_cursor CURSOR FORWARD_ONLY FOR
	Select isnull(d.xassetitem,''),d.xqtyord,ca.xdesc,d.xratedeposit from opcrndetail d join opcrnheader h on d.zid = h.zid AND d.xcrnnum = h.xcrnnum 
	join caitem c on c.zid = d.zid AND d.xitem =c.xitem
	left join caitem ca on ca.zid = d.zid AND ca.xassetitem =d.xassetitem
	WHERE h.zid = @zid AND h.xcrnnum = @crnnum AND  isnull(xstatusar,'')<>'Confirmed'
			
	OPEN deposit_cursor
	FETCH FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @depositrate>0
		BEGIN
		SET @depositamt =(@depositrate*@qtysale)
		SET @long = @desc +' @'+CAST(@depositrate as varchar(50)) +' X '+CAST(CAST(@qtysale AS INT) as VARCHAR(20))+', '
		SET @depositrate = 0
		SET @qtysale = 0	
				
				Select @row = isnull(count(xvoucher),0)+1 from arhed where zid = @zid AND isnull(xdornum,'') = @crnnum
				INSERT INTO arhed(ztime,zid,zauserid,xvoucher,xcus,xdate,xbank,xref,xprime,xbase,xdiscprime,
						xchgsprime,xnote,xstatusjv,xsign,xbalprime,xdocnum,xvatamt,xaitamt,xwh,xdatedue,
					xpaymentterm,xtype,xlcno,xtypetrn,xordernum,xgrnnum,xpornum,xpaymenttype,xcur,xexch,xdornum)
					VALUES(GETDATE(),@zid,@user,@crnnum+'-'+CAST(@row as varchar(10)),@cus,@date,'','',@depositamt,@depositamt,0,
								0,'Deposit return '+@long,'Open',-1,@depositamt,'',0,0,@wh,@date,
	     					'',@type,'','Sale','','','',@paymenttype,'BDT',1.00,@crnnum)
		END
		SET @depositamt = 0
		SET @long =''

	FETCH NEXT FROM deposit_cursor INTO @item,@qtysale,@desc,@depositrate
	END
	CLOSE deposit_cursor
	DEALLOCATE deposit_cursor

	END
-------------------------------End of Deposit Transaction -----------------------------------
		--======================= update arhed balprime  ====================

		/*SELECT @balamt = SUM(xamount)
		FROM aralc
		WHERE zid=@zid
		AND xinvnum=@ordernum

		UPDAtE arhed
		SET xbalprime=@prime-@balamt
		WHERE zid=@zid
		AND xvoucher=@ordernum
		*/
		UPDATE opcrnheader
		SET xstatusar='Confirmed'
		WHERE zid=@zid
		AND xcrnnum=@invnum

	END
	
	END -- end of pogrnheaderac



--COMMIT TRAN @user
