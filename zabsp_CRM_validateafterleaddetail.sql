USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_CRM_validateafterleaddetail]    Script Date: 12/29/2022 1:34:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--  exec zabsp_CRM_validateafterleaddetail 100060,'1010025','LD--000016','IC--000311',1,'Lead'

ALTER PROCEDURE [dbo].[zabsp_CRM_validateafterleaddetail]
				@zid INT,
				@user varchar(150),
				@leadno varchar(150),
				@item varchar(150),
				@row int,
				@type varchar(150)
AS
	DECLARE  
			
			@typeobj VARCHAR(50),
			@size VARCHAR(50),
			@color VARCHAR(50),
			@article VARCHAR(50),
			@voucher VARCHAR(50),
			@year int,
			@per int,
			@tornum VARCHAR(50),
			@itemcode VARCHAR(50),
			@grsweight VARCHAR(50),
			@descrip VARCHAR(250),
			@qtypor decimal(20,3),
			@prepqty decimal(20,2),
			@otctotal decimal(20,2),
			@mrctotal decimal(20,2),
			@mrcvatrate decimal(20,2),
			@otcvatrate decimal(20,2),
			@mrcvatamt decimal(20,2),
			@otcvatamt decimal(20,2),
			@mrclineamt decimal(20,2),
			@otclineamt decimal(20,2),

			@mrcdiscrate decimal(20,2),
			@otcdisrate decimal(20,2),

			@mrcdiscount decimal(20,2),
			@otcdiscount decimal(20,2),

			@netotc decimal(20,2),
			@netmrc decimal(20,2),
			@price decimal(20,2),
			@loandate DATE,
			@party VARCHAR(50)
			


IF @type='Lead'
BEGIN
Select @mrctotal=xtotmrc,@otctotal=xtototc,@mrcdiscrate=xmrcdisc,@otcdisrate=xotcdisc, @mrcvatrate=xmrcvatrate,@otcvatrate=xotcvatrate from crmleadsdetail where zid=@zid and xleadno=@leadno and xitem=@item and xrow=@row

		SET @mrcdiscount=(@mrctotal*@mrcdiscrate)/100
		SET @otcdiscount=(@otctotal*@otcdisrate)/100

		SET @mrcdiscount=isnull(@mrcdiscount,0)
		SET @otcdiscount=isnull(@otcdiscount,0)

		print @mrctotal
		print @otctotal
		print '-------------------------------Disrate'
		print @mrcdiscrate
		print @otcdisrate

		print '-------------------------------Disamt'
		print @mrcdiscount
		print @otcdiscount
		----------------/// Calculate Discount Amount--------------//

		SET @netmrc=@mrctotal-@mrcdiscount
		SET @netotc=@otctotal-@otcdiscount

		SET @netmrc=isnull(@netmrc,0)
		SET @netotc=isnull(@netotc,0)
		print '-------------------------------netamt'
print @netmrc
print @netotc
		----------------/// Calculate VAT Amount--------------//
		SET @mrcvatamt=(@netmrc*@mrcvatrate)/100
		SET @otcvatamt=(@netotc*@otcvatrate)/100


		SET @mrcvatamt=isnull(@mrcvatamt,0)
		SET @otcvatamt=isnull(@otcvatamt,0)
		print '-------------------------------vatamt'
print @mrcvatamt
print @otcvatamt
print '-------------------------------line'
		----------------/// Calculate Total Amount--------------//
		SET @mrclineamt=(@netmrc+@mrcvatamt)
		SET @otclineamt=(@netotc+@otcvatamt)

		SET @mrclineamt=isnull(@mrclineamt,0)
		SET @otclineamt=isnull(@otclineamt,0)

print @mrclineamt
print @otclineamt

		update crmleadsdetail set xmrcvatamt=@mrcvatamt,xotcvatamt=@otcvatamt,xmrcdiscamt=@mrcdiscount,xotcdiscamt=@otcdiscount,xnetmrc=@mrclineamt,xnetotc=@otclineamt  where zid=@zid and xleadno=@leadno and xitem=@item and xrow=@row
		print 'test'
		Select @mrctotal=sum(xnetmrc) from crmleadsdetail where zid=@zid and xleadno=@leadno --and xpaymenttype='MRC'
		Select @otctotal=sum(xnetotc) from crmleadsdetail where zid=@zid and xleadno=@leadno --and xpaymenttype='OTC'
		print 'test2'
		Update crmleadsheader set xtotmrc=@mrctotal,xtototc=@otctotal,xnetmrc=@mrctotal,xnetotc=@otctotal where zid=@zid and xleadno=@leadno
END
ELSE IF @type='Quotation'
BEGIN
Select @typeobj=isnull(xtypeobj,'') from poreqheader where zid=@zid and xporeqnum=@leadno
IF @typeobj='Fiber'

BEGIN
Select @mrctotal=xtotmrc,@otctotal=xtototc,@mrcvatrate=xmrcvatrate,@otcvatrate=xotcvatrate from poquotdetail where zid=@zid and xporeqnum=@leadno and xitem=@item and xrow=@row

		--SET @mrcdiscount=(@mrctotal*@mrcdiscrate)/100
		--SET @otcdiscount=(@otctotal*@otcdisrate)/100

		SET @mrcdiscount=isnull(@mrcdiscount,0)
		SET @otcdiscount=isnull(@otcdiscount,0)

		print @mrctotal
		print @otctotal
		print '-------------------------------Disrate'
		print @mrcdiscrate
		print @otcdisrate
		print @mrcvatrate
		print '-------------------------------Disamt'
		print @mrcdiscount
		print @otcdiscount
		----------------/// Calculate Discount Amount--------------//

		SET @netmrc=@mrctotal-@mrcdiscount
		SET @netotc=@otctotal-@otcdiscount

		SET @netmrc=isnull(@netmrc,0)
		SET @netotc=isnull(@netotc,0)
		print '-------------------------------netamt'
print @netmrc
print @netotc
		----------------/// Calculate VAT Amount--------------//
		SET @mrcvatamt=(@netmrc*@mrcvatrate)/100
		SET @otcvatamt=(@netotc*@otcvatrate)/100


		SET @mrcvatamt=isnull(@mrcvatamt,0)
		SET @otcvatamt=isnull(@otcvatamt,0)
		print '-------------------------------vatamt'
print @mrcvatamt
print @otcvatamt
print '-------------------------------line'
		----------------/// Calculate Total Amount--------------//
		SET @mrclineamt=(@netmrc+@mrcvatamt)
		SET @otclineamt=(@netotc+@otcvatamt)

		SET @mrclineamt=isnull(@mrclineamt,0)
		SET @otclineamt=isnull(@otclineamt,0)

print @mrclineamt
print @otclineamt

		update poquotdetail set xmrcvatamt=@mrcvatamt,xotcvatamt=@otcvatamt,xnetmrc=@mrclineamt,xnetotc=@otclineamt,xlineamt=@mrclineamt+@otclineamt  where zid=@zid and xporeqnum=@leadno and xitem=@item and xrow=@row
	
END
	
END

		
		