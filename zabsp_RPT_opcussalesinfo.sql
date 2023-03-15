USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opcussalesinfo]    Script Date: 1/4/2023 12:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_opcussalesinfo 200010,'','','','','','','','2022','12'

ALTER PROC [dbo].[zabsp_RPT_opcussalesinfo] 
	  @zid INT  
     ,@cus VARCHAR(30)
    

AS

DECLARE 
	 @zorg VARCHAR(250)
	,@image varbinary(MAX)
	,@row INT
    ,@xorg VARCHAR(150)
    ,@xmadd VARCHAR(250)
    ,@xphone VARCHAR(150)
    ,@xterritory VARCHAR(150)
    ,@xdistrict VARCHAR(150)
    ,@xcontact VARCHAR(150)
    ,@xdivision VARCHAR(150)
    ,@xarea VARCHAR(150)
    ,@xcainstype VARCHAR(150)
    ,@xlandphone VARCHAR(150)
    ,@xsector VARCHAR(150)
    ,@xcstime VARCHAR(150)
    ,@xbeginyear VARCHAR(150)
    ,@xshno VARCHAR(150)
    ,@xwhno VARCHAR(150)
    ,@xtruck VARCHAR(150)
    ,@xpkno VARCHAR(150)
    ,@xwrks VARCHAR(150)
    ,@xdealer VARCHAR(150)
    ,@xretailer VARCHAR(150)
    ,@xmtsize VARCHAR(150)
    ,@xnote VARCHAR(50)
	,@year VARCHAR(50)
	,@prevyear VARCHAR(50)
	,@prevyear2 VARCHAR(50)
	,@prevyear3 VARCHAR(50)
	,@prevyear4 VARCHAR(50)
	,@cr VARCHAR(50)
	,@pr1 VARCHAR(50)
	,@pr2 VARCHAR(50)
	,@pr3 VARCHAR(50)
	,@pr4 VARCHAR(50)

	,@target DECIMAL(20,2)
	,@fjtolasttarget DECIMAL(20,2)
	,@pryear VARCHAR(20)
	,@todaysval DECIMAL(20,2)
	,@dsales DECIMAL(20,2)
	,@lastyear int
	,@thisyear int
	,@fmonthname VARCHAR(50)
	,@monthname VARCHAR(50)
	,@lastper int
	,@lastday int
	,@currentday int
	,@lastysales DECIMAL(20,2)
	,@blastysales DECIMAL(20,2)
	,@lastybudget DECIMAL(20,2)
	,@thismsales DECIMAL(20,2)
	,@bthismsales DECIMAL(20,2)
	,@thismonthgap DECIMAL(20,2)
	,@thisyeargap DECIMAL(20,2)
	,@thismonthtargetgap DECIMAL(20,2)
	,@thisyeartargetgap DECIMAL(20,2)
	,@thismbudget DECIMAL(20,2)
	,@thismtotalbudget DECIMAL(20,2)
	,@todaysales DECIMAL(20,2)
	,@btodaysales DECIMAL(20,2)
	,@todaybudget DECIMAL(20,2)
	,@daybudget DECIMAL(20,2)
	,@ftodaysales DECIMAL(20,2)
	,@beforesales DECIMAL(20,2)
	,@ftodaybudget DECIMAL(20,2)
	,@ftototalbudget DECIMAL(20,2)
	,@fjtolastsales DECIMAL(20,2)
	,@bfjtolastsales DECIMAL(20,2)
	,@fjtolastbudget DECIMAL(20,2)
	,@fjtolasttotalbudget DECIMAL(20,2)
	,@dphqty DECIMAL(20,2)
	,@bprice DECIMAL(20,2)
	,@sprice DECIMAL(20,2)
	,@perint int
	,@xcus VARCHAR(50)
	,@cusname VARCHAR(50)
    ,@division VARCHAR(250)
	,@xsubcat VARCHAR(50)
	,@thana VARCHAR(100)
	,@xgcus VARCHAR(150)


	DECLARE @table TABLE( zid INT
						 ,zorg VARCHAR(150)
						 ,xorg VARCHAR(150)
						 ,xmadd VARCHAR(250)
						 ,ximage image
						 ,xphone VARCHAR(150)
						 ,xterritory VARCHAR(150)
						 ,xdistrict VARCHAR(150)
						 ,xcontact VARCHAR(150)
						 ,xdivision VARCHAR(150)
						 ,xarea VARCHAR(150)
						 ,xcainstype VARCHAR(150)
						 ,xlandphone VARCHAR(150)
						 ,xsector VARCHAR(150)
						 ,xcstime VARCHAR(150)
						 ,xbeginyear VARCHAR(150)
						 ,xshno VARCHAR(150)
						 ,xwhno VARCHAR(150)
						 ,xtruck VARCHAR(150)
						 ,xpkno VARCHAR(150)
						 ,xwrks VARCHAR(150)
						 ,xdealer VARCHAR(150)
						 ,xretailer VARCHAR(150)
						 ,xmtsize VARCHAR(150)
						 ,xnote VARCHAR(50)

					  	 ,xbrname VARCHAR(50)
						 ,xqty DECIMAL(20,2) 
						 ,xsal DECIMAL(20,2)
						 ,xtso VARCHAR(50)
						 ,xtsoname VARCHAR(50)
						 ,xtarget DECIMAL(20,2)
						 ,xfjtolasttarget DECIMAL(20,2)
						 ,xtransale DECIMAL(20,2)
						 ,xtotsales DECIMAL(20,2)
						 ,xlastyear int
						 ,xthisyear int
					  	 ,xfmonthname VARCHAR(50)
					  	 ,xmonthname VARCHAR(50)
						 ,xlastysales DECIMAL(20,2)
						 ,xlastybudget DECIMAL(20,2)
						 ,xthismsales DECIMAL(20,2)
						 ,xthismbudget DECIMAL(20,2)
						 ,xthismtotalbudget DECIMAL(20,2)
						 ,xtodaysales DECIMAL(20,2)
						 ,xtodaybudget DECIMAL(20,2)
						 ,xftodaysales DECIMAL(20,2)
						 ,xthismonthgap DECIMAL(20,2)
						 ,xthisyeargap DECIMAL(20,2)
						 ,xthismonthtargetgap DECIMAL(20,2)
						 ,xthisyeartargetgap DECIMAL(20,2)
						 ,xftodaybudget DECIMAL(20,2)
						 ,xftototalbudge DECIMAL(20,2)
						 ,xfjtolastsales DECIMAL(20,2)
						 ,xfjtolastbudget DECIMAL(20,2)
						 ,xfjtolasttotalbudget DECIMAL(20,2)
						 ,xdphqty DECIMAL(20,2)
	                     ,xbprice DECIMAL(20,2)
	                     ,xsprice DECIMAL(20,2)
						 ,xcus VARCHAR(50)
						 ,xcusname VARCHAR(50)
						 ,xsubcat VARCHAR(50)
						 ,xthana VARCHAR(100)
						 ,xgcus VARCHAR(150)
						)


SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

SET @year=YEAR(GETDATE())
SET @prevyear=DATEPART(year,Dateadd(yyyy, -1, @year))
SET @prevyear2=DATEPART(year,Dateadd(yyyy, -2, @year))
SET @prevyear3=DATEPART(year,Dateadd(yyyy, -3, @year))
SET @prevyear4=DATEPART(year,Dateadd(yyyy, -4, @year))

DECLARE opsales_cursor CURSOR FORWARD_ONLY FOR 


				/********** Customer QUERY ***********/
select xcus from cacus where zactive='1' and xstatus='Approved' and left(xcus,3)='CUS' AND xsubcat='LPG Cylinder' and xcus=@cus


OPEN opsales_cursor
FETCH FROM opsales_cursor INTO @cus
WHILE @@FETCH_STATUS = 0
BEGIN
		
						
						/********** Aygaz Sales MT/YEAR ***********/

select @cr=  SUM((d.xqtyord*c.xpackqty)/1000) 
               from opdoheader a
               join opdodetail d on d.zid=a.zid and d.xdornum=a.xdornum
               join caitem c on c.zid=d.zid and c.xitem=d.xitem 
               where a.zid=@zid and year(a.xdate)=@year and a.xcus=@cus

						/********** Aygaz Sales MT/prevyear ***********/

select @pr1 = SUM((d.xqtyord*c.xpackqty)/1000) 
               from opdoheader a
               join opdodetail d on d.zid=a.zid and d.xdornum=a.xdornum
               join caitem c on c.zid=d.zid and c.xitem=d.xitem 
               where a.zid=@zid and year(a.xdate)=@prevyear and a.xcus=@cus

						/********** Aygaz Sales MT/prevyear2 ***********/

select @pr2 = SUM((d.xqtyord*c.xpackqty)/1000) 
               from opdoheader a
               join opdodetail d on d.zid=a.zid and d.xdornum=a.xdornum
               join caitem c on c.zid=d.zid and c.xitem=d.xitem 
               where a.zid=@zid and year(a.xdate)=@prevyear2 and a.xcus=@cus

						/********** Aygaz Sales MT/prevyear3 ***********/

select @pr3 = SUM((d.xqtyord*c.xpackqty)/1000) 
               from opdoheader a
               join opdodetail d on d.zid=a.zid and d.xdornum=a.xdornum
               join caitem c on c.zid=d.zid and c.xitem=d.xitem 
               where a.zid=@zid and year(a.xdate)=@prevyear3 and a.xcus=@cus

						/********** Aygaz Sales MT/prevyear4 ***********/

select @pr4 = SUM((d.xqtyord*c.xpackqty)/1000) 
               from opdoheader a
               join opdodetail d on d.zid=a.zid and d.xdornum=a.xdornum
               join caitem c on c.zid=d.zid and c.xitem=d.xitem 
               where a.zid=@zid and year(a.xdate)=@prevyear4 and a.xcus=@cus





					/********** Customer Info ***********/
Select @xorg=c.xorg,@xmadd=c.xmadd,@xphone=c.xphone,@xterritory=c.xterritory,@xdistrict=c.xdistrict,@xcontact=c.xcontact,
               @xdivision=c.xdivisionop,@xarea=c.xareaop,@xcainstype=c.xcainstype,@xlandphone=a.xlandphone,@xsector=a.xsector,
               @xcstime=a.xcstime,@xbeginyear=a.xtaxyear,@xshno=a.xshno,@xwhno=a.xwhno,@xtruck=a.xtruck,@xpkno=a.xpkno,
               @xwrks=a.xwrks,@xdealer=a.xdealer,@xretailer=a.xretailer,@xmtsize=a.xmtsize,@xnote=a.xnote from cacus c
               join cacusinfo a on a.zid=c.zid and a.xcus=c.xcus
               where c.zid=@zid and c.xcus=@cus


				

	
	INSERT INTO @table(zid,zorg,ximage,xcus,xcusname,xdivision,xthana,xtarget,xfjtolasttarget,xlastysales,xlastybudget,xthismsales,xthismonthgap,xthisyeargap,xthismonthtargetgap,xthisyeartargetgap,
						xthismbudget,xthismtotalbudget,xfjtolastsales,xfjtolastbudget,xftodaysales,xftodaybudget,xftototalbudge,
						xfjtolasttotalbudget,xfmonthname,xmonthname,xthisyear,xlastyear)
					VALUES(@zid,@zorg,@image,@xcus,@cusname,isnull(@division,''),isnull(@thana,''),isnull(@target,0),isnull(@fjtolasttarget,0),isnull(@lastysales,0),isnull(@lastybudget,0),isnull(@thismsales,0),isnull(@thismonthgap,0),isnull(@thisyeargap,0),isnull(@thismonthtargetgap,0),isnull(@thisyeartargetgap,0),
					isnull(@thismbudget,0),isnull(@thismtotalbudget,0),isnull(@fjtolastsales,0),isnull(@fjtolastbudget,0),isnull(@ftodaysales,0),isnull(@ftodaybudget,0),isnull(@ftototalbudget,0),
					isnull(@fjtolasttotalbudget,0),@fmonthname,@monthname,@thisyear,@lastyear)
	
	

FETCH NEXT FROM opsalesbudget_cursor INTO @cus

END
CLOSE opsales_cursor
DEALLOCATE opsales_cursor

SELECT zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtso,xtsoname,xtarget,xfjtolasttarget,xlastysales,xlastybudget,xthismsales,xthismonthgap,xthisyeargap,xthismonthtargetgap,xthisyeartargetgap,xthismbudget,xthismtotalbudget,xftototalbudge,
		xfjtolastsales,xfjtolastbudget,xfjtolasttotalbudget,xftodaysales,xftodaybudget,xfmonthname,xmonthname,xthisyear,xlastyear--xqty,xtarget,
FROM @table


SET NOCOUNT OFF