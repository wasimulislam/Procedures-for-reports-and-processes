USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opcusinfo]    Script Date: 1/8/2023 4:58:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_opcusinfo 200010,'2022-08-23' 

--   EXEC zabsp_RPT_opcusinfo 200010,'CUSC000107','2023'

ALTER PROC [dbo].[zabsp_RPT_opcusinfo]  
	  @zid INT
     ,@cus VARCHAR(30)  
	 ,@year VARCHAR(15)

AS

DECLARE 
	 @zorg VARCHAR(250) 
	,@xorg VARCHAR(250)
	,@image varbinary(MAX)
	,@row INT
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
    ,@xcstime datetime
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
	,@qty DECIMAL(20,2) 
	,@rate DECIMAL(20,2) 
	,@sal DECIMAL(20,2)
	,@tso VARCHAR(50)
	,@tsoname VARCHAR(50)
	,@territory VARCHAR(250)
	,@target DECIMAL(20,2)
	,@fjtolasttarget DECIMAL(20,2)
	,@pryear VARCHAR(20)
	,@todaysval DECIMAL(20,2)
	,@dsales DECIMAL(20,2)
	,@lastyear int
	,@lastyear2 int
	,@lastyear3 int
	,@lastyear4 int
	,@thisyear int
	,@fmonthname VARCHAR(50)
	,@monthname VARCHAR(50)
	,@lastper int
	,@lastday int
	,@currentday int
	,@thisyincsales DECIMAL(20,2)
	,@thisyincsales1 DECIMAL(20,2)
	,@thisyincsales2 DECIMAL(20,2)
	,@thisyincsales3 DECIMAL(20,2)
	,@thisyincsales4 DECIMAL(20,2)
	,@thisysales DECIMAL(20,2)
	,@lastysales DECIMAL(20,2)
	,@lastysales2 DECIMAL(20,2)
	,@lastysales3 DECIMAL(20,2)
	,@lastysales4 DECIMAL(20,2)
	,@blastysales DECIMAL(20,2)
	,@blastysales2 DECIMAL(20,2)
	,@blastysales3 DECIMAL(20,2)
	,@blastysales4 DECIMAL(20,2)
	,@inctransport DECIMAL(20,2)
	,@inctransport1 DECIMAL(20,2)
	,@inctransport2 DECIMAL(20,2)
	,@inctransport3 DECIMAL(20,2)
	,@inctransport4 DECIMAL(20,2)
	,@lastybudget DECIMAL(20,2)
	,@thismsales DECIMAL(20,2)
	,@bthisysales DECIMAL(20,2)
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
	,@perint int
	,@xcus VARCHAR(50)
	,@cusname VARCHAR(50)
	,@phone VARCHAR(50)
    ,@division VARCHAR(250)
	,@xsubcat VARCHAR(50)
	,@district VARCHAR(100)
	,@thana VARCHAR(100)
	,@area VARCHAR(100)
	,@xgcus VARCHAR(150),
	@lineamt DECIMAL(20,2),
	@lineamt1 DECIMAL(20,2),
	@lineamt2 DECIMAL(20,2),
	@lineamt3 DECIMAL(20,2),
	@lineamt4 DECIMAL(20,2)


	DECLARE @table TABLE( zid INT
						 ,zorg VARCHAR(150)
						 ,xorg VARCHAR(150)
						 ,ximage image
						 ,xwh VARCHAR(50)
						 ,xmadd VARCHAR(250)
						 ,xphone VARCHAR(150)
						 ,xterritory VARCHAR(150)
						 ,xdistrict VARCHAR(150)
						 ,xcontact VARCHAR(150)
						 ,xdivision VARCHAR(150)
						 ,xarea VARCHAR(150)
						 ,xcainstype VARCHAR(150)
						 ,xlandphone VARCHAR(150)
						 ,xsector VARCHAR(150)
						 ,xcstime datetime
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
						 ,xlastyear2 int
						 ,xlastyear3 int
						 ,xlastyear4 int
						 ,xthisyear int
						 ,xthisyincsales DECIMAL(20,2)
						 ,xthisyincsales1 DECIMAL(20,2)
						 ,xthisyincsales2 DECIMAL(20,2)
						 ,xthisyincsales3 DECIMAL(20,2)
						 ,xthisyincsales4 DECIMAL(20,2)
						 ,xlastyearsales1 DECIMAL(20,2)
						 ,xlastyearsales2 DECIMAL(20,2)
						 ,xlastyearsales3 DECIMAL(20,2)
						 ,xlastyearsales4 DECIMAL(20,2)
						 ,xthisyearsales DECIMAL(20,2)
						 ,xinctransport DECIMAL(20,2)
	                     ,xinctransport1 DECIMAL(20,2)
	                     ,xinctransport2 DECIMAL(20,2)
	                     ,xinctransport3 DECIMAL(20,2)
	                     ,xinctransport4 DECIMAL(20,2)
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
						 ,xcus VARCHAR(50)
						 ,xcusname VARCHAR(50)
						 ,xsubcat VARCHAR(50)
						 ,xthana VARCHAR(100)
						 ,xgcus VARCHAR(150),
						 xlineamt DECIMAL(20,2),
						 xlineamt1 DECIMAL(20,2),
						 xlineamt2 DECIMAL(20,2),
						 xlineamt3 DECIMAL(20,2),
						 xlineamt4 DECIMAL(20,2)
							 )


SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

SET @thisyear=@year
SET @lastyear=DATEPART(year,Dateadd(yyyy, -1, @year))
SET @lastyear2=DATEPART(year,Dateadd(yyyy, -2, @year))
SET @lastyear3=DATEPART(year,Dateadd(yyyy, -3, @year))
SET @lastyear4=DATEPART(year,Dateadd(yyyy, -4, @year))


DECLARE opsalesbudget_cursor CURSOR FORWARD_ONLY FOR 

				/********** CUSTOMER QUERY ***********/
				
select xcus from cacus where zactive='1' and xstatus='Approved' and left(xcus,3)='CUS' AND xsubcat='LPG Cylinder' and xcus=@cus  

OPEN opsalesbudget_cursor
FETCH FROM opsalesbudget_cursor INTO @cus
WHILE @@FETCH_STATUS = 0
BEGIN


SET @blastysales=0			
						/********** LAST YEAR SALES ***********/

select @blastysales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusord='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-1,@year))
				and h.xsubcat='LPG Cylinder'  
				and isnull(d.xdocnum,'')=''
				
SET @lastysales=0	
select @lastysales=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusdoc='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-1,@year))
				and h.xsubcat='LPG Cylinder'
				 
SET @lastysales=@lastysales+@blastysales
print @lastysales



SET @blastysales2=0								
						/**********LAST YEAR SALES 2 ***********/

select @blastysales2=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusord='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-2,@year))
				and h.xsubcat='LPG Cylinder'  
				and isnull(d.xdocnum,'')=''
				
SET @lastysales2=0	
select @lastysales2=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusdoc='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-2,@year))
				and h.xsubcat='LPG Cylinder'
				 
SET @lastysales2=@lastysales2+@blastysales2
print @lastysales2



SET @blastysales3=0			
						/**********LAST YEAR SALES 3 ***********/

select @blastysales3=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusord='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-3,@year))
				and h.xsubcat='LPG Cylinder'  
				and isnull(d.xdocnum,'')=''
				
SET @lastysales3=0	
select @lastysales3=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusdoc='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-3,@year))
				and h.xsubcat='LPG Cylinder'
				 
SET @lastysales3=@lastysales3+@blastysales3
print @lastysales3



SET @blastysales4=0				
						/**********LAST YEAR SALES 4 ***********/

select @blastysales4=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusord='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-4,@year))
				and h.xsubcat='LPG Cylinder'  
				and isnull(d.xdocnum,'')=''
				
SET @lastysales4=0	
select @lastysales4=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusdoc='Confirmed' and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-4,@year))
				and h.xsubcat='LPG Cylinder'
				 
SET @lastysales4=@lastysales4+@blastysales4
print @lastysales4



SET @bthisysales=0
					/********** THIS YEAR SALES ***********/
select @bthisysales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusord='Confirmed' and year(h.xdate)=@year
				and h.xsubcat='LPG Cylinder'
				and isnull(d.xdocnum,'')=''
				
SET @thisysales=0
select @thisysales=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@cus and h.xstatusdoc='Confirmed' and year(h.xdate)=@year
				and h.xsubcat='LPG Cylinder'
				 
SET @thisysales=@thisysales+@bthisysales
print @thisysales

--   EXEC zabsp_RPT_opcusinfo 200010,'CUSC000001','2022'	

					/********** Customer Info ***********/  
Select @xorg=c.xorg,@xmadd=c.xmadd,@xphone=c.xphone,@xterritory=c.xterritory,@xdistrict=c.xdistrict,@xcontact=c.xcontact,
               @xdivision=c.xdivisionop,@xarea=c.xareaop,@xlandphone=c.xphone,@xsector=a.xsector, --@xcainstype=c.xcainstype,
               @xcstime=c.xcstime,@xbeginyear=a.xtaxyear,@xshno=a.xshnoqty,@xwhno=a.xwhnoqty,@xtruck=a.xtruckqty,@xpkno=a.xpknoqty,
               @xwrks=a.xwrksqty,@xdealer=a.xdealerqty,@xretailer=a.xretailerqty,@xmtsize=a.xmtsize,@xnote=a.xnote from cacus c
               left join cacusinfo a on a.zid=c.zid and a.xcus=c.xcus
               where c.zid=@zid and c.xcus=@cus

--select @lineamt=sum(xlineamt),@inctransport=sum(xinctransport) from opsalesinc where zid=@zid and xcus=@cus and xyear=@year
--select @lineamt1=sum(xlineamt),@inctransport1=sum(xinctransport) from opsalesinc where zid=@zid and xcus=@cus and xyear=@lastyear
--select @lineamt2=sum(xlineamt),@inctransport2=sum(xinctransport) from opsalesinc where zid=@zid and xcus=@cus and xyear=@lastyear2
--select @lineamt3=sum(xlineamt),@inctransport3=sum(xinctransport) from opsalesinc where zid=@zid and xcus=@cus and xyear=@lastyear3
--select @lineamt4=sum(xlineamt),@inctransport4=sum(xinctransport) from opsalesinc where zid=@zid and xcus=@cus and xyear=@lastyear4


	
	INSERT INTO @table(zid,zorg,ximage,xcus,xorg,xcontact,xdivision,xarea,xdistrict,xterritory,xmadd,xphone,xcainstype,xlandphone,xsector,xcstime,xbeginyear,xshno,xwhno,xtruck,xpkno,xwrks,xdealer,xretailer,xmtsize,xnote,xlastyear,xlastyearsales1,xlastyear2,xlastyearsales2,xlastyear3,xlastyearsales3,xlastyear4,xlastyearsales4,xthisyear,xthisyearsales,xlineamt,xlineamt1,xlineamt2,xlineamt3,xlineamt4,xinctransport,xinctransport1,xinctransport2,xinctransport3,xinctransport4)
					VALUES(@zid,@zorg,@image,@cus,@xorg,isnull(@xcontact,''),isnull(@xdivision,''),isnull(@xarea,''),isnull(@xdistrict,''),isnull(@xterritory,''),isnull(@xmadd,''),isnull(@xphone,''),'',isnull(@xlandphone,''),isnull(@xsector,''),@xcstime,isnull(@xbeginyear,''),isnull(@xshno,0),isnull(@xwhno,0),isnull(@xtruck,0),isnull(@xpkno,0),isnull(@xwrks,0),isnull(@xdealer,0),
					isnull(@xretailer,0),isnull(@xmtsize,0),isnull(@xnote,0),isnull(@lastyear,0),isnull(@lastysales,0),isnull(@lastyear2,0),isnull(@lastysales2,0),isnull(@lastyear3,0),isnull(@lastysales3,0),isnull(@lastyear4,0),isnull(@lastysales4,0),isnull(@thisyear,0),isnull(@thisysales,0),0,0,0,0,0,0,0,0,0,0)
	
	

FETCH NEXT FROM opsalesbudget_cursor INTO @cus

END
CLOSE opsalesbudget_cursor
DEALLOCATE opsalesbudget_cursor

SELECT zid,zorg,ximage,xcus,xorg,xcontact,xdivision,xarea,xdistrict,xterritory,xmadd,xphone,xcainstype,xlandphone,xsector,xcstime,xbeginyear,xshno,xwhno,xtruck,xpkno,xwrks,xdealer,xretailer,xmtsize,xnote,xlastyear,xlastyearsales1,xlastyear2,xlastyearsales2,xlastyear3,xlastyearsales3,xlastyear4,xlastyearsales4,xthisyear,xthisyearsales,xlineamt,xlineamt1,xlineamt2,xlineamt3,xlineamt4,xinctransport,xinctransport1,xinctransport2,xinctransport3,xinctransport4
FROM @table


SET NOCOUNT OFF