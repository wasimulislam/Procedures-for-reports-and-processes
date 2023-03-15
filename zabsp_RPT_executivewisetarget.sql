USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_executivewisetarget]    Script Date: 1/8/2023 4:58:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_executivewisetarget 100000,'2023-01-01','2023-01-24','','','EID-0007'

--EXEC zabsp_RPT_executivewisetarget 100000,'2022-11-01','2022-12-24','','','EID-0007'


ALTER PROC [dbo].[zabsp_RPT_executivewisetarget] 
	  @zid INT 
	 ,@fdate VARCHAR(250)
	 ,@tdate VARCHAR(250) 
     ,@dsm VARCHAR(30)     
     ,@dm VARCHAR(150)     
     ,@tso VARCHAR(150) 

AS

DECLARE 
	 @xorg VARCHAR(250)
	,@zorg VARCHAR(250)
	,@image varbinary(MAX)
	,@row INT
	,@xitem VARCHAR(250)
	,@xitemdesc VARCHAR(250)
	,@xsalesqty Decimal(20,2)
	,@xcus VARCHAR(50)
	,@xtarget Decimal(20,2)
	,@xachieve Decimal(20,2)
	,@xpercentage Decimal(20,2)
	,@xdate VARCHAR(50)
	,@xyear VARCHAR(50)
	,@xper VARCHAR(50)
	,@fyear VARCHAR(50)
	,@tyear VARCHAR(50)
	,@fper VARCHAR(50)
	,@tper VARCHAR(50)


	DECLARE @table TABLE( zid INT
						,xorg VARCHAR(250)
	                    ,zorg VARCHAR(250)
	                    ,ximage varbinary(MAX)
	                    ,xrow INT
	                    ,xitem VARCHAR(250)
						,xitemdesc VARCHAR(250)
	                    ,xsalesqty Decimal(20,2)
	                    ,xcus VARCHAR(50)
	                    ,xtarget Decimal(20,2)
	                    ,xachieve Decimal(20,2)
	                    ,xpercentage Decimal(20,2)
	                    ,xdate VARCHAR(50)
						,xyear VARCHAR(50)
						,xper VARCHAR(50)
						,xdsm VARCHAR(30)     
                        ,xdm VARCHAR(150)     
                        ,xtso VARCHAR(150)
							 )

--SET @tso='' SET @tsoname='' SET @territory=''

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

set @fper=month(@fdate)
set @tper=month(@tdate)
set @fyear=year(@fdate)
set @tyear=year(@tdate)



DECLARE optarget_cursor CURSOR FORWARD_ONLY FOR 

				/********** ISO QUERY ***********/
				
select b.xitem from optargetheader a 
  join optargetdetail b on b.zid=a.zid and b.xper=a.xper and b.xyear=a.xyear and b.xtso=a.xtso
  where a.zid=@zid and  a.xper between @fper and @tper and a.xyear between @fyear and @tyear --xstatus='1'
  AND a.xdsm>=(CASE when @dsm='' then '' else @dsm end)
  AND a.xdsm<=(CASE when @dsm='' then 'zz' else @dsm end)
  AND a.xdm>=(CASE when @dm='' then '' else @dm end)
  AND a.xdm<=(CASE when @dm='' then 'zz' else @dm end) 
  AND a.xtso>=(CASE when @tso='' then '' else @tso end)
  AND a.xtso<=(CASE when @tso='' then 'zz' else @tso end) 


OPEN optarget_cursor
FETCH FROM optarget_cursor INTO @xitem
WHILE @@FETCH_STATUS = 0
BEGIN



	/**********Product Name ***********/

	select @xitemdesc=xdesc from  caitem where zid=@zid and xitem=@xitem-- and a.xper between @fper and @tper and a.xyear between @fyear and @tyear

	/**********TARGET ***********/
	set @xtarget=0
		SELECT @xtarget = xqty
		FROM optargetdetail a
		WHERE a.zid=@zid AND a.xitem = @xitem and a.xper between @fper and @tper and a.xyear between @fyear and @tyear

	/**********Sales Qty ***********/
		SELECT @xsalesqty = d.xqtyord
		FROM opdodetail d 
		join opdoheader h on h.zid=d.zid and h.xdornum=d.xdornum
		WHERE h.zid=@zid AND d.xitem=@xitem and cast(h.xdate as date) between @fdate and @tdate

	--/********** Achievement ***********/
	    Begin
		if @xtarget <> 0
	    set @xachieve=@xsalesqty/@xtarget
		end

		--/********** percentage ***********/

		set @xpercentage=@xachieve*1000
		

	
	INSERT INTO @table(zid,xitem,xtso,xitemdesc,xtarget,xsalesqty,xachieve,xpercentage,xyear,xper)
		   VALUES(@zid,@xitem,@tso,@xitemdesc,isnull(@xtarget,0),isnull(@xsalesqty,0),isnull(@xachieve,0),isnull(@xpercentage,0),@xyear,@xper)
	
	

FETCH NEXT FROM optarget_cursor INTO @xitem

END
CLOSE optarget_cursor
DEALLOCATE optarget_cursor

SELECT zid,xitem,xtso,xitemdesc,xtarget,xsalesqty,xachieve,xpercentage,xyear,xper
FROM @table


SET NOCOUNT OFF