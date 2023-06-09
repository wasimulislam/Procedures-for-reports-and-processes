USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_CylinderTransaction_DC]    Script Date: 3/14/2023 12:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec zabsp_CylinderTransaction_DC 200010,'2368','DC--0000007','update'
ALTER PROC [dbo].[zabsp_CylinderTransaction_DC]
				 @zid  INT
				,@user VARCHAR(50)
				,@docnum VARCHAR(50)
				,@command VARCHAR(50)

AS

DECLARE @item VARCHAR(50)
		,@cyitem VARCHAR(50)
		,@cus VARCHAR(50)
		,@qty  DECIMAL(20,5)
		,@sign VARCHAR(50)
		,@status VARCHAR(50)
		,@note VARCHAR(350)
		,@parentitem VARCHAR(50)
		,@assetitem VARCHAR(50)
		,@fagroup VARCHAR(50)
		,@fatype VARCHAR(50)
		,@facat VARCHAR(50)
		,@trn VARCHAR(50)
		,@trnnum VARCHAR(50)
		,@trnlength INT
		,@wh VARCHAR(50)



--select c.xassetitem,c.xitem,h.xcus,d.xqtyord,* from opdodetail d join opdoheader h on d.zid=h.zid and d.xdornum=h.xdornum 
--join caitem c on d.zid=c.zid and d.xitem=c.xitem where d.xdornum='DO--0000055'

IF @command='update'

SELECT  @cus=xcus,@wh=xfwh from
opdcheader WHERE zid=@zid AND xdocnum=@docnum 


--print @qty	
SET @trn='CYIS'
SET @trnnum=@trn
SET @trnlength=10
if exists(select xstatusdoc from opdcheader where xdocnum=@docnum and zid=@zid and xstatusdoc='Confirmed')
BEGIN
DECLARE cursor_cylindertrans CURSOR
FOR 
select c.xitem,c.xassetitem,o.xqtydoc from opdcdetail o join caitem c on o.zid=c.zid and o.xitem=c.xitem where o.xdocnum=@docnum  and o.zid=@zid and c.xsubcat='LPG Cylinder'

OPEN cursor_cylindertrans;

FETCH NEXT FROM cursor_cylindertrans INTO @parentitem,@assetitem,@qty
--print @parentitem
WHILE @@FETCH_STATUS = 0
   BEGIN

 
SELECT @cyitem=c.xitemref,@fagroup=c.xfagroup,@fatype=c.xfatype,@facat=c.xfacat from
opdcdetail d join opdcheader h on d.zid=h.zid and d.xdocnum=h.xdocnum 
join caitem c on d.zid=c.zid and d.xitem=c.xitem WHERE d.zid=@zid AND d.xdocnum=@docnum and c.xsubcat='LPG Cylinder' and c.xitem=@parentitem

			if not exists(select xparentitem from cytrn where xdornum=@docnum and xparentitem=@parentitem and zid=@zid)
			BEGIN
					EXEC Func_getTrn @zid,'Cylinder Transactions',@trn,@trnlength,@strVar=@trnnum OUTPUT
							
					INSERT INTO cytrn(ztime,zauserid,zid,xdocnum,xitem,xwh,xcus,xqty,xsign,xstatus,xdornum,xnote,xparentitem,xassetitem,xfagroup,xfatype,xfacat)
								VALUES(GETDATE(),@user,@zid,isnull(@trnnum,0),@cyitem,@wh,@cus,@qty,'-1','Confirm',@docnum,@note,@parentitem,@assetitem,@fagroup,@fatype,@facat)
			END

set @cyitem=''
set @fagroup=''
set @fatype=''
set @facat=''

		
		FETCH NEXT FROM cursor_cylindertrans INTO @parentitem,@assetitem,@qty

			
	END
CLOSE cursor_cylindertrans;

DEALLOCATE cursor_cylindertrans;
END

IF @command='opcrnheader'
BEGIN

SELECT  @cus=xcus,@wh=xwh from
opcrnheader WHERE zid=@zid AND xcrnnum=@docnum 

--print @qty	
SET @trn='CYRE'
SET @trnnum=@trn
SET @trnlength=10
if exists(select xstatuscrn from opcrnheader where xcrnnum=@docnum and zid=@zid and xstatuscrn='Confirmed')
BEGIN
DECLARE cursor_cylindertransre CURSOR
FOR 
select c.xitem,c.xassetitem,o.xqtyord from opcrndetail o join caitem c on o.zid=c.zid and o.xitem=c.xitem where o.xcrnnum=@docnum  and o.zid=@zid and c.xsubcat='LPG Cylinder'

OPEN cursor_cylindertransre;

FETCH NEXT FROM cursor_cylindertransre INTO @parentitem,@assetitem,@qty
--print @parentitem
WHILE @@FETCH_STATUS = 0
   BEGIN

 set @note='Received from Sales Return'
SELECT @cyitem=c.xitemref,@fagroup=c.xfagroup,@fatype=c.xfatype,@facat=c.xfacat from
opcrndetail d join opcrnheader h on d.zid=h.zid and d.xcrnnum=h.xcrnnum 
join caitem c on d.zid=c.zid and d.xitem=c.xitem WHERE d.zid=@zid AND d.xcrnnum=@docnum and c.xsubcat='LPG Cylinder' and c.xitem=@parentitem

			if not exists(select xparentitem from cytrn where xdornum=@docnum and xparentitem=@parentitem and zid=@zid)
			BEGIN
					EXEC Func_getTrn @zid,'Cylinder Transactions',@trn,@trnlength,@strVar=@trnnum OUTPUT
							
					INSERT INTO cytrn(ztime,zauserid,zid,xdate,xdocnum,xitem,xwh,xcus,xqty,xsign,xstatus,xdornum,xnote,xparentitem,xassetitem,xfagroup,xfatype,xfacat)
								VALUES(GETDATE(),@user,@zid,getdate(),isnull(@trnnum,0),@cyitem,@wh,@cus,@qty,'1','Confirmed',@docnum,@note,@parentitem,@assetitem,@fagroup,@fatype,@facat)
			END

set @cyitem=''
set @fagroup=''
set @fatype=''
set @facat=''

		
		FETCH NEXT FROM cursor_cylindertransre INTO @parentitem,@assetitem,@qty

			
	END
CLOSE cursor_cylindertransre;

DEALLOCATE cursor_cylindertransre;			
END
--exec zabsp_CylinderReciveTransaction @zid,@user,@trnnum,@assetitem,@qty,'confirm'

END
IF @command='opdealshd'
BEGIN

SELECT  @cus=xcus,@wh=xwh from
opdealshd WHERE zid=@zid AND xcrnnum=@docnum 

--print @qty	
SET @trn='CYRE'
SET @trnnum=@trn
SET @trnlength=10
if exists(select xstatuscrn from opdealshd where xcrnnum=@docnum and zid=@zid and xstatuscrn='Confirmed')
BEGIN
DECLARE cursor_cylindertransdlc CURSOR
FOR 
select c.xitem,c.xassetitem,o.xqtyord from opdealsdt o join caitem c on o.zid=c.zid and o.xitem=c.xitem where o.xcrnnum=@docnum  and o.zid=@zid and c.xsubcat='LPG Cylinder'

OPEN cursor_cylindertransdlc;

FETCH NEXT FROM cursor_cylindertransdlc INTO @parentitem,@assetitem,@qty
--print @parentitem
WHILE @@FETCH_STATUS = 0
   BEGIN

 set @note='Received from Dealer Closing'
SELECT @cyitem=c.xitemref,@fagroup=c.xfagroup,@fatype=c.xfatype,@facat=c.xfacat from
opdealsdt d join opdealshd h on d.zid=h.zid and d.xcrnnum=h.xcrnnum 
join caitem c on d.zid=c.zid and d.xitem=c.xitem WHERE d.zid=@zid AND d.xcrnnum=@docnum and c.xsubcat='LPG Cylinder' and c.xitem=@parentitem

			if not exists(select xparentitem from cytrn where xdornum=@docnum and xparentitem=@parentitem and zid=@zid)
			BEGIN
					EXEC Func_getTrn @zid,'Cylinder Transactions',@trn,@trnlength,@strVar=@trnnum OUTPUT
							
					INSERT INTO cytrn(ztime,zauserid,zid,xdate,xdocnum,xitem,xwh,xcus,xqty,xsign,xstatus,xdornum,xnote,xparentitem,xassetitem,xfagroup,xfatype,xfacat)
								VALUES(GETDATE(),@user,@zid,getdate(),isnull(@trnnum,0),@cyitem,@wh,@cus,@qty,'1','Confirmed',@docnum,@note,@parentitem,@assetitem,@fagroup,@fatype,@facat)
			END

set @cyitem=''
set @fagroup=''
set @fatype=''
set @facat=''

		
		FETCH NEXT FROM cursor_cylindertransdlc INTO @parentitem,@assetitem,@qty

			
	END
CLOSE cursor_cylindertransdlc;

DEALLOCATE cursor_cylindertransdlc;			
END
--exec zabsp_CylinderReciveTransaction @zid,@user,@trnnum,@assetitem,@qty,'confirm'

END
