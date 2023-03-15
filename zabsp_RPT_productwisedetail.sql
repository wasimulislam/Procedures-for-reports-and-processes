USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_productwisedetail]    Script Date: 1/8/2023 4:58:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_productwisedetail 100000,'2023-01-01','2023-02-12','','','',''


ALTER PROC [dbo].[zabsp_RPT_productwisedetail] 
	  @zid INT 
	 ,@fdate VARCHAR(250)
	 ,@tdate VARCHAR(250) 
     ,@dsm VARCHAR(30)     
     ,@dm VARCHAR(150)     
     ,@tso VARCHAR(150) 
	 ,@cus VARCHAR(150)   

AS

DECLARE 
	 @xorg VARCHAR(250)
	,@zorg VARCHAR(250)
	,@image varbinary(MAX)
	,@row INT
	,@xitem VARCHAR(250)
	,@xdesc VARCHAR(250)
	,@xitemdesc VARCHAR(250)
	,@soqty Decimal(20,2)
	,@doqty Decimal(20,2)
	,@sovalue Decimal(20,2)
	,@dovalue Decimal(20,2)
	,@pendingqty Decimal(20,2)
	,@pendingvalue Decimal(20,2)


	DECLARE @table TABLE( zid INT
						,xorg VARCHAR(250)
	                    ,zorg VARCHAR(250)
	                    ,image varbinary(MAX)
	                    ,xrow INT
	                    ,xitem VARCHAR(250)
						,xdesc VARCHAR(250)
	                    ,xitemdesc VARCHAR(250)
	                    ,soqty Decimal(20,2)
	                    ,doqty Decimal(20,2)
	                    ,sovalue Decimal(20,2)
	                    ,dovalue Decimal(20,2)
	                    ,pendingqty Decimal(20,2)
	                    ,pendingvalue Decimal(20,2)
						,xdsm VARCHAR(30)     
                        ,xdm VARCHAR(150)     
                        ,xtso VARCHAR(150)
						,xcus VARCHAR(150)
							 )

--SET @tso='' SET @tsoname='' SET @territory=''

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid


DECLARE optarget_cursor CURSOR FORWARD_ONLY FOR 

				/********** item QUERY ***********/
				
select b.xitem from opsoheader a 
  join opsodetail b on b.zid=a.zid and b.xsonumber=a.xsonumber
  where a.zid=@zid and  a.xdate between @fdate and @tdate 
  AND a.xdsm>=(CASE when @dsm='' then '' else @dsm end)
  AND a.xdsm<=(CASE when @dsm='' then 'zz' else @dsm end)
  AND a.xdm>=(CASE when @dm='' then '' else @dm end)
  AND a.xdm<=(CASE when @dm='' then 'zz' else @dm end) 
  AND a.xtso>=(CASE when @tso='' then '' else @tso end)
  AND a.xtso<=(CASE when @tso='' then 'zz' else @tso end) 
  AND a.xcus>=(CASE when @cus='' then '' else @cus end)
  AND a.xcus<=(CASE when @cus='' then 'zz' else @cus end) 


OPEN optarget_cursor
FETCH FROM optarget_cursor INTO @xitem
WHILE @@FETCH_STATUS = 0
BEGIN



	/**********SO qty ***********/

	select @soqty=sum(xqtyreq) from opsodetail where xitem=@xitem

    /**********DC qty ***********/

	select @doqty=sum(xqtyord) from opdodetail where xitem=@xitem

	/**********S0 value ***********/

	select @sovalue=sum(xlineamt) from opsodetail where xitem=@xitem

    /**********DO value ***********/

	select @dovalue=sum(xlineamt) from opdodetail where xitem=@xitem

	/**********Pending Qty ***********/

	set @pendingqty = @doqty-@soqty

	/**********Pending Value ***********/

	set @pendingvalue = @dovalue-@sovalue

	select @xdesc= xdesc from caitem 
	where zid=@zid and xitem=@xitem
		

	
	INSERT INTO @table(zid,xitem,xdesc,soqty,doqty,sovalue,dovalue,pendingqty,pendingvalue)
		   VALUES(@zid,@xitem,@xdesc,isnull(@soqty,0),isnull(@doqty,0),isnull(@sovalue,0),isnull(@dovalue,0),isnull(@pendingqty,0),isnull(@pendingvalue,0))
	
	

FETCH NEXT FROM optarget_cursor INTO @xitem

END
CLOSE optarget_cursor
DEALLOCATE optarget_cursor

SELECT zid,xitem,xdesc,soqty,doqty,sovalue,dovalue,pendingqty,pendingvalue
FROM @table


SET NOCOUNT OFF