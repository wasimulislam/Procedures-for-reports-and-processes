USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opsalescomprehention]    Script Date: 1/8/2023 4:58:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_opsalescomprehention 200010,'2022-08-23'

--   EXEC zabsp_RPT_opsalescomprehention 200010,'CUSC000045','','','','','','','01','2023'

ALTER PROC [dbo].[zabsp_RPT_opsalescomprehention] 
	  @zid INT
	 ,@cus VARCHAR(30)
	 ,@area VARCHAR(250)
	 ,@district VARCHAR(250)
	 ,@division VARCHAR(250)
	 ,@territory VARCHAR(250)
	 ,@thana VARCHAR(100)
	 ,@tso VARCHAR(50)
     ,@per VARCHAR(15)  
	 ,@year VARCHAR(15)

AS

DECLARE 
	 @zorg VARCHAR(250) 
	,@image varbinary(MAX)
	,@row INT
	,@qty DECIMAL(20,4) 
	,@rate DECIMAL(20,4) 
	,@sal DECIMAL(20,4)
	,@tso2 VARCHAR(50)
	,@tsoname VARCHAR(50)
	,@territory2 VARCHAR(250)
	,@target DECIMAL(20,2)
	,@fjtolasttarget DECIMAL(20,4)
	,@pryear VARCHAR(20)
	,@todaysval DECIMAL(20,4)
	,@dsales DECIMAL(20,4)
	,@lastyear int
	,@thisyear int
	,@fmonthname VARCHAR(50)
	,@monthname VARCHAR(50)
	,@lastper int
	,@lastday int
	,@currentday int
	,@lastysales DECIMAL(20,4)
	,@blastysales DECIMAL(20,4)
	,@lastybudget DECIMAL(20,4)
	,@thismsales DECIMAL(20,4)
	,@bthismsales DECIMAL(20,4)
	,@thismonthgap DECIMAL(20,4)
	,@thisyeargap DECIMAL(20,4)
	,@thismonthtargetgap DECIMAL(20,4)
	,@thisyeartargetgap DECIMAL(20,4)
	,@thismbudget DECIMAL(20,4)
	,@thismtotalbudget DECIMAL(20,4)
	,@todaysales DECIMAL(20,4)
	,@btodaysales DECIMAL(20,4)
	,@todaybudget DECIMAL(20,4)
	,@daybudget DECIMAL(20,4)
	,@ftodaysales DECIMAL(20,4)
	,@beforesales DECIMAL(20,4)
	,@ftodaybudget DECIMAL(20,4)
	,@ftototalbudget DECIMAL(20,4)
	,@fjtolastsales DECIMAL(20,4)
	,@bfjtolastsales DECIMAL(20,4)
	,@fjtolastbudget DECIMAL(20,4)
	,@fjtolasttotalbudget DECIMAL(20,4)
	,@perint int
	,@xcus VARCHAR(50)
	,@cusname VARCHAR(50)
    ,@division2 VARCHAR(250)
	,@xsubcat VARCHAR(50)
	,@district2 VARCHAR(100)
	,@thana2 VARCHAR(100)
	,@area2 VARCHAR(100)
	,@xgcus VARCHAR(150)


	DECLARE @table TABLE( zid INT
						 ,zorg VARCHAR(150)
						 ,ximage image
						 ,xwh VARCHAR(50)
					  	 ,xbrname VARCHAR(50)
						 ,xqty DECIMAL(20,4) 
						 ,xsal DECIMAL(20,4)
						 ,xtso VARCHAR(50)
						 ,xtsoname VARCHAR(50)
						 ,xterritory VARCHAR(50)
						 ,xtarget DECIMAL(20,4)
						 ,xfjtolasttarget DECIMAL(20,4)
						 ,xtransale DECIMAL(20,4)
						 ,xtotsales DECIMAL(20,4)
						 ,xlastyear int
						 ,xthisyear int
					  	 ,xfmonthname VARCHAR(50)
					  	 ,xmonthname VARCHAR(50)
						 ,xlastysales DECIMAL(20,4)
						 ,xlastybudget DECIMAL(20,4)
						 ,xthismsales DECIMAL(20,4)
						 ,xthismbudget DECIMAL(20,4)
						 ,xthismtotalbudget DECIMAL(20,4)
						 ,xtodaysales DECIMAL(20,4)
						 ,xtodaybudget DECIMAL(20,4)
						 ,xftodaysales DECIMAL(20,4)
						 ,xthismonthgap DECIMAL(20,4)
						 ,xthisyeargap DECIMAL(20,4)
						 ,xthismonthtargetgap DECIMAL(20,4)
						 ,xthisyeartargetgap DECIMAL(20,4)
						 ,xftodaybudget DECIMAL(20,4)
						 ,xftototalbudge DECIMAL(20,4)
						 ,xfjtolastsales DECIMAL(20,4)
						 ,xfjtolastbudget DECIMAL(20,4)
						 ,xfjtolasttotalbudget DECIMAL(20,4)
						 ,xcus VARCHAR(50)
						 ,xcusname VARCHAR(50)
						 ,xdivision VARCHAR(50)
						 ,xsubcat VARCHAR(50)
						 ,xdistrict VARCHAR(100)
						 ,xthana VARCHAR(100)
						 ,xgcus VARCHAR(150)
						 ,xarea VARCHAR(100)
							 )

--SET @tso='' SET @tsoname='' SET @territory=''

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

set @perint = @per

SET @lastyear=DATEPART(year,Dateadd(yyyy, -1, @year))
SET @monthname=DATENAME(MONTH, DATEADD(MONTH, @perint, -1))
set @fmonthname=DATENAME(MONTH,DATEADD(year, DATEDIFF(yy, 0,@year), 0))


--print @perint
DECLARE opsalesbudget_cursor CURSOR FORWARD_ONLY FOR 

				/********** CUSTOMER QUERY ***********/
				
select xcus,xorg,xterritory,xso from cacus where zactive='1' and xstatus='Approved' and left(xcus,3)='CUS'  --and xgcus='Dealer'
  AND xcus>=(CASE when @cus='' then '' else @cus end)
  AND xcus<=(CASE when @cus='' then 'zz' else @cus end)
  --AND xgcus>=(CASE when @xgcus='' then '' else @xgcus end)
  --AND xgcus<=(CASE when @xgcus='' then 'zz' else @xgcus end)
  AND xterritory>=(CASE when @territory='' then '' else @territory end)
  AND xterritory<=(CASE when @territory='' then 'zz' else @territory end) 
  AND xareaop>=(CASE when @area='' then '' else @area end)
  AND xareaop<=(CASE when @area='' then 'zz' else @area end) 
  AND xdivisionop>=(CASE when @division='' then '' else @division end)
  AND xdivisionop<=(CASE when @division='' then 'zz' else @division end) 
  AND xdistrict>=(CASE when @district='' then '' else @district end)
  AND xdistrict<=(CASE when @district='' then 'zz' else @district end)  
  AND xso>=(CASE when @tso='' then '' else @tso end)
  AND xso<=(CASE when @tso='' then 'zz' else @tso end) 
  AND xthana>=(CASE when @thana='' then '' else @thana end)
  AND xthana<=(CASE when  @thana='' then 'zz' else @thana end)
  AND xsubcat='LPG Cylinder'  


OPEN opsalesbudget_cursor
FETCH FROM opsalesbudget_cursor INTO @xcus,@cusname,@territory2,@tso2
WHILE @@FETCH_STATUS = 0
BEGIN
--print @xcus
SET @blastysales=0			
						
						/********** LAST YEAR THIS MONTH SALES ***********/

select @blastysales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@xcus and h.xstatusord='Confirmed' and month(h.xdate)=@per and year(h.xdate)=DATEPART(year, Dateadd(yyyy,-1,@year))
				and h.xsubcat='LPG Cylinder'  

				 
SET @lastysales=@blastysales
print @lastysales
					/********** LAST YEAR BUDGET **********
select @lastybudget =isnull(isnull(@lastysales/isnull(b.xqty,0),0)*100,0)
				from opdoheader h
				join opsalesbudget b on b.zid=h.zid and b.xterritory=h.xterritory
				where h.xterritory=@territory and h.xstatusord='Confirmed' and b.xper=DATEPART(MONTH, @tdate) and b.xyear=DATEPART(year, Dateadd(yyyy,-1,@tdate))*/


SET @bthismsales=0
					/********** THIS MONTH SALES ***********/
select @bthismsales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@xcus and h.xstatusord='Confirmed' and month(h.xdate)=@per and year(h.xdate)=@year
				and h.xsubcat='LPG Cylinder'

				 
SET @thismsales=@bthismsales
print @thismsales
				/********** THIS MONTH BUDGET **********
select @thismtotalbudget=b.xqty,@thismbudget =isnull(isnull(@thismsales/isnull(b.xqty,0),0)*100,0)
				from opdoheader h
				join opsalesbudget b on b.zid=h.zid and b.xterritory=h.xterritory
				where h.xterritory=@territory and h.xstatusord='Confirmed' and b.xper=DATEPART(MONTH,@tdate) and b.xyear=DATEPART(year, @tdate)
				group by b.xqty

print @thismtotalbudget		
			*/
			/********** TODAY SALES ***********/
--set @btodaysales=0
--select @btodaysales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
--				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
--				join cappo c on c.zid=h.zid and c.xsp=h.xtso 
--				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
--				where h.zid=@zid and h.xterritory=@territory and h.xstatusord='Confirmed' and h.xdate=@tdate
--				and h.xsubcat='LPG Cylinder'
--				and isnull(d.xdocnum,'')=''
				
--set @todaysales=0
--select @todaysales=isnull(sum((isnull(d.xqtydoc*isnull(a.xpackqty,0),0)/1000)),0)
--				from opdcheader h join opdcdetail d on d.zid=h.zid and d.xdocnum=h.xdocnum 
--				join cappo c on c.zid=h.zid and c.xsp=h.xtso 
--				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
--				where h.zid=@zid and h.xterritory=@territory and h.xstatusdoc='Confirmed' and h.xdate=@tdate
--				and h.xsubcat='LPG Cylinder'
				
--SET @todaysales=@todaysales+@btodaysales	

				/********** TODAY BUDGET **********

set @daybudget=isnull(@thismtotalbudget/@lastday,0)
print @daybudget
select @todaybudget =isnull(isnull(@todaysales/nullif(@daybudget,0),0)*100,0)
				from opdoheader h
				--join opsalesbudget b on b.zid=h.zid and b.xterritory=h.xterritory
				where  h.xterritory=@territory and h.xstatusord='Confirmed' and h.xdate=@tdate*/
	
				/********** JANUARY TO TODAY SALES ***********/

set @beforesales=0
select @beforesales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum  
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@xcus and h.xstatusord='Confirmed' and month(h.xdate) BETWEEN '1' AND @per AND year(h.xdate)=@year
				and h.xsubcat='LPG Cylinder'

					
SET @ftodaysales=@beforesales
print @ftodaysales	

				/********** JANUARY TO TODAY BUDGET **********
select @ftototalbudget=isnull(sum(b.xqty),0)+(@daybudget*@currentday)
				from opsalesbudget b 
				where b.xterritory=@territory and (b.xper BETWEEN DATEPART(MONTH, DATEADD(year, DATEDIFF(yy, 0, @tdate), 0)) and DATEPART(MONTH,Dateadd(MONTH,-1,@tdate)))
				and b.xyear= DATEPART(year, Dateadd(yyyy,0,@tdate))
				
set @ftodaybudget=(@ftodaysales/nullif(@ftototalbudget,0))*100
--select @ftototalbudget=sum(b.xqty)
--				from opdoheader h
--				join opsalesbudget b on b.zid=h.zid and b.xterritory=h.xterritory
--				where h.xterritory=@territory and (b.xper=DATEPART(MONTH,DATEADD(year, DATEDIFF(yy, 0, @tdate), 0)) and b.xyear=DATEPART(year, @tdate)) BETWEEN (b.xper=01 and b.xyear=2022) and ((b.xper=01 and b.xyear=2022)
--				--group by b.xqty
print @ftototalbudget*/
	
				/********** LAST YEAR JANUARY TO SALES ***********/
set @bfjtolastsales=0
select @bfjtolastsales=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.zid=@zid and h.xcus=@xcus and h.xstatusord='Confirmed' and  month(h.xdate) BETWEEN '1' AND @per AND year(h.xdate)=@lastyear
				and h.xsubcat='LPG Cylinder'


SET @fjtolastsales=@bfjtolastsales
print @fjtolastsales	

				/********** LAST YEAR JANUARY TO BUDGET **********
select @fjtolasttotalbudget= sum(b.xqty) 
						from opsalesbudget b
				where b.xterritory=@territory and (b.xper BETWEEN DATEPART(MONTH, DATEADD(year, DATEDIFF(yy, 0, @tdate), 0)) and DATEPART(MONTH, getdate())) and b.xyear= DATEPART(year, Dateadd(yyyy,-1,@tdate))
				
select @fjtolastbudget =isnull(isnull(@fjtolastsales/nullif(@fjtolasttotalbudget,0),0)*100,0)
				from opdoheader h
				where  h.xterritory=@territory and h.xstatusord='Confirmed' and h.xdate BETWEEN DATEADD(year, DATEDIFF(yy, 0, @tdate)-1, 0) AND eomonth(DATEADD(year,0, Dateadd(yyyy,-1,@tdate)))*/


	/**********THIS MONTH TARGET ***********/
	set @target=0
		SELECT @target = ISNULL(SUM(b.xdphqty),0)
		FROM optargetheader a Join optargetdetail b on b.zid=a.zid and b.xcus = a.xcus
		WHERE a.zid=@zid AND a.xcus = @xcus AND a.xyear = @year
		AND a.xper = @per

	/**********LAST YEAR JANUARY TO TARGET ***********/
	set @fjtolasttarget =0
		SELECT @fjtolasttarget = ISNULL(SUM(b.xdphqty),0)
		FROM optargetheader a Join optargetdetail b on b.zid=a.zid and b.xcus = a.xcus
		WHERE a.zid=@zid AND a.xcus=@xcus and month(a.xdate) BETWEEN '1' AND @per AND year(a.xdate)=@year
--	--/********** Branch Name ***********/
	
--	--	SELECT @brname = xlong
--	--	FROM branchview
--	--	WHERE xcode=@wh
set @thismonthgap=0
set @thisyeargap=0
set @thismonthtargetgap=0
set @thisyeartargetgap=0
        select @tsoname=xname from cappo where xsp=@tso2 and xterritory=@territory2
		select @division2=xdivisionop,@area2=xareaop,@thana2=xthana,@district2=xdistrict from cacus where zid=@zid and xcus=@xcus

		if @lastysales<>0
		begin
		set @thismonthgap= ((@thismsales/@lastysales)-1)*100
		end
		if @fjtolastsales<>0
		begin
		set @thisyeargap= ((@ftodaysales/@fjtolastsales)-1)*100
		end
		if @target<>0
		begin
		set @thismonthtargetgap= ((@thismsales/@target)-1)*100
		end
		if @fjtolasttarget<>0
		begin
		set @thisyeartargetgap= ((@ftodaysales/@fjtolasttarget)-1)*100
		end

	
	INSERT INTO @table(zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtso,xtsoname,xqty,xtarget,xfjtolasttarget,xlastysales,xlastybudget,xthismsales,xthismonthgap,xthisyeargap,xthismonthtargetgap,xthisyeartargetgap,
						xthismbudget,xthismtotalbudget,xfjtolastsales,xfjtolastbudget,xftodaysales,xftodaybudget,xftototalbudge,
						xfjtolasttotalbudget,xfmonthname,xmonthname,xthisyear,xlastyear)
					VALUES(@zid,@zorg,@image,@xcus,@cusname,isnull(@division2,''),isnull(@territory2,''),isnull(@area2,''),isnull(@district2,''),isnull(@thana2,''),@tso2,@tsoname,isnull(@qty,0),isnull(@target,0),isnull(@fjtolasttarget,0),isnull(@lastysales,0),isnull(@lastybudget,0),isnull(@thismsales,0),isnull(@thismonthgap,0),isnull(@thisyeargap,0),isnull(@thismonthtargetgap,0),isnull(@thisyeartargetgap,0),
					isnull(@thismbudget,0),isnull(@thismtotalbudget,0),isnull(@fjtolastsales,0),isnull(@fjtolastbudget,0),isnull(@ftodaysales,0),isnull(@ftodaybudget,0),isnull(@ftototalbudget,0),
					isnull(@fjtolasttotalbudget,0),@fmonthname,@monthname,@thisyear,@lastyear)
	
	

FETCH NEXT FROM opsalesbudget_cursor INTO @xcus,@cusname,@territory,@tso2

END
CLOSE opsalesbudget_cursor
DEALLOCATE opsalesbudget_cursor

SELECT zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtso,xtsoname,xtarget,xfjtolasttarget,xlastysales,xlastybudget,xthismsales,xthismonthgap,xthisyeargap,xthismonthtargetgap,xthisyeartargetgap,xthismbudget,xthismtotalbudget,xftototalbudge,
		xfjtolastsales,xfjtolastbudget,xfjtolasttotalbudget,xftodaysales,xftodaybudget,xfmonthname,xmonthname,xthisyear,xlastyear--xqty,xtarget,
FROM @table order by xthismsales desc


SET NOCOUNT OFF