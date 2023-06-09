USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_validateAfterDetailCRN]    Script Date: 3/14/2023 12:15:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_validateAfterDetailCRN 200010,shajjad,'SLR-23000001','1','1','1000',
ALTER PROC [dbo].[sp_validateAfterDetailCRN] --#id,#user,xcrnnum,xrow,xqtyord,xrate,xvatrate,xitem,xdocrow
	
	@zid INT,
	@user VARCHAR(50),
	@crnnum VARCHAR(50),
	@row INT,
	@qtyord DECIMAL(20,2),
	@rate DECIMAL(20,2),
	@vatrate DECIMAL(20,5),
	@item VARCHAR(50)

  AS

DECLARE @vatamt DECIMAL(20,2),
	@aitamt DECIMAL(20,2),
	@totamt DECIMAL(20,2),
	@invamt DECIMAL(20,2),
	@discamt DECIMAL(20,2),
	@disc DECIMAL(20,2),
	@lineamt DECIMAL(20,2),
	@appdisc DECIMAL(20,2),
	@amount DECIMAL(20,2),
	@ordernum VARCHAR(50),
	@gitem VARCHAR(50),
	@cus VARCHAR(50),
	@gcus VARCHAR(50),
	@date VARCHAR(50),
	@assetitem VARCHAR(50),
	@ratedeposit DECIMAL(20,2)
	
	--********* INTIALIZATION ****************	
	SET @vatamt = 0
	SET @lineamt = 0
	SET @aitamt = 0
	SET @totamt = 0
	SET @invamt = 0
	SET @amount = 0
	SET @appdisc = 0
	SET @gitem = ''
	SET @ordernum = ''

--	SET @vatamt = @vatrate*@qtyord
	SELECT @disc=isnull(xdiscdet,0), @assetitem=isnull(xassetitem,'') from opcrndetail where zid =@zid AND xcrnnum=@crnnum
	SELECT @aitamt = isnull(xait,0),@cus=xcus,@date=xdate FROM opcrnheader WHERE zid =@zid AND xcrnnum=@crnnum
	SELECT @gitem = xgitem FROM caitem WHERE zid =@zid AND xitem=@item
	SELECT @gcus = xgcus FROM cacus WHERE zid =@zid AND xcus=@cus

		--********* GETTING TOTAL DEPOSIT RETURN AMT **************
		IF EXISTS (Select xitem from cacusopdeposit where zid = @zid AND xcus = @cus AND xitem = @assetitem and @date between xdateeff AND xdateexp)
				Select @ratedeposit =isnull(xrate,0) from cacusopdeposit where zid = @zid AND xcus = @cus  AND xitem = @assetitem and @date between xdateeff AND xdateexp
		ELSE IF EXISTS (Select xitem from opdeposit where zid = @zid AND xgcus = @gcus AND xitem = @assetitem and @date between xdateeff AND xdateexp)
				Select @ratedeposit =isnull(xrate,0) from opdeposit where zid = @zid AND xgcus = @gcus  AND xitem = @assetitem and @date between xdateeff AND xdateexp
				
				IF @ratedeposit =0
				SET @assetitem =''


	--********* UPDATING DETAIL ****************	
	SET @vatamt=(@qtyord*@rate)*@vatrate/100
	SET @discamt=(@qtyord*@rate)*@disc/100

	UPDATE opcrndetail SET xlineamt = Round(((@qtyord*@rate)),2),xvatamt=Round(@vatamt,2),xdiscdetamt=@discamt,xratedeposit=@ratedeposit,xassetitem=@assetitem WHERE xcrnnum=@crnnum AND xrow=@row	

	--********* UPDATING HEADER ****************	
	SELECT @totamt = SUM(xlineamt) FROM opcrndetail WHERE xcrnnum=@crnnum
	SELECT @vatamt = SUM(xvatamt) FROM opcrndetail WHERE xcrnnum=@crnnum
	SET @aitamt = (@totamt*@aitamt)/100

	--********* UPDATING DISCOUNT ****************	
	IF @discamt > 0
	BEGIN
		SELECT @amount = xamount FROM cadiscount WHERE zid =@zid AND xgitem=@gitem
		SET @amount = ISNULL(@amount,0)
		IF @amount > 0
		BEGIN

			SELECT @disc = xdisc FROM cadiscount WHERE zid =@zid AND xgitem=@gitem
			SET @disc = ISNULL(@disc,0)
		
		
			--********* GETTING TOTAL RETURN AMT **************
			--SELECT @lineamt = SUM(xlineamt) FROM opcrndetailview WHERE zid = @zid AND xcrnnum=@crnnum AND xgitem=@gitem		
			--SET @appdisc = (@lineamt*@disc)/100

			--********* GETTING INVOICE AMT **************
			--SELECT @invamt = SUM(xlineamt) FROM opdodetailview WHERE zid=@zid AND xdornum=@ordernum AND xgitem=@gitem
			--SET @invamt = ISNULL(@invamt,0)								
			--IF (@invamt-@lineamt) < @amount
			--BEGIN
			--	SELECT @appdisc = xdiscamt FROM opdoheader WHERE zid=@zid AND xdornum=@ordernum
			--	SET @appdisc = ISNULL(@appdisc,0)								
			--END
		END
		ELSE 
			SET @appdisc = 0
	END

--	SET @discamt = (@totamt*@discamt)/100
--	UPDATE opcrnheader SET xtotamt=@totamt,xvatamt=@vatamt,xaitamt=@aitamt,xdiscamt=@appdisc WHERE xcrnnum=@crnnum
		UPDATE opcrnheader SET xtotamt=@totamt,xvatamt=@vatamt,xaitamt=@aitamt,xdiscamt=@discamt WHERE zid=@zid and xcrnnum=@crnnum

