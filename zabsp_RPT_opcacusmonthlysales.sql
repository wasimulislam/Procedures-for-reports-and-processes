USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opcacusmonthlysales]    Script Date: 1/4/2023 12:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_opcacusmonthlysales 200010,'','','','','','','','2022' 

ALTER PROC [dbo].[zabsp_RPT_opcacusmonthlysales]  
	  @zid INT     
     ,@cus VARCHAR(30)     
     ,@gcus VARCHAR(150)     
     ,@subcat VARCHAR(150)     
	 ,@territory VARCHAR(250)
	 ,@area VARCHAR(250)     
	 ,@district VARCHAR(250) 
	 ,@thana VARCHAR(250)
	 ,@year VARCHAR(15)     
          

AS

DECLARE 
	 @zorg VARCHAR(250) 
	,@image varbinary(MAX)
	,@row INT
	,@qty DECIMAL(20,3) 
	,@bonusqty DECIMAL(20,2) 
	,@xlineamt DECIMAL(20,2) 
	,@xnetamt DECIMAL(20,2) 
	,@xvatamt DECIMAL(20,2) 
	,@xdiscdetamt DECIMAL(20,2) 
	,@rate DECIMAL(20,2) 
	,@xcus VARCHAR(50)
	,@cusname VARCHAR(50)
	,@tso VARCHAR(50)
	,@tsoname VARCHAR(50)
    ,@division VARCHAR(250)
	,@territory2 VARCHAR(250)
	,@target DECIMAL(20,2)
	,@pryear VARCHAR(20)
	,@xsubcat VARCHAR(50)
	,@todaysval DECIMAL(20,2)
	,@district2 VARCHAR(100)
	,@thana2 VARCHAR(100)
	,@area2 VARCHAR(100)
	,@month1 DECIMAL(20,2)
	,@month2 DECIMAL(20,2)
	,@month3 DECIMAL(20,2)
	,@month4 DECIMAL(20,2)
	,@month5 DECIMAL(20,2)
	,@month6 DECIMAL(20,2)
	,@month7 DECIMAL(20,2)
	,@month8 DECIMAL(20,2)
	,@month9 DECIMAL(20,2)
	,@month10 DECIMAL(20,2)
	,@month11 DECIMAL(20,2)
	,@month12 DECIMAL(20,2)
	,@monthttl DECIMAL(20,2)
	,@per VARCHAR(15)
	DECLARE @table TABLE( zid INT
						 ,zorg VARCHAR(150)
						 ,ximage image
						 ,xwh VARCHAR(50)
					  	 ,xbrname VARCHAR(50)
						 ,xdate VARCHAR(50)
						 ,xqty DECIMAL(20,3)
						 ,xdivision VARCHAR(50)
						 ,xarea VARCHAR(250)
						 ,xbonusqty DECIMAL(20,3) 
						 ,xlineamt DECIMAL(20,2) 
						 ,xnetamt DECIMAL(20,2) 
						 ,xvatamt DECIMAL(20,2) 
						 ,xdiscdetamt DECIMAL(20,2) 
						 ,xrate DECIMAL(20,2) 
						 ,xcus VARCHAR(50)
						 ,xcusname VARCHAR(50)
						 ,xtso VARCHAR(50)
						 ,xtsoname VARCHAR(50)
						 ,xterritory VARCHAR(250)
						 ,xtarget DECIMAL(20,2)
						 ,pryear VARCHAR(20)
						 ,xsubcat VARCHAR(50)
						 ,xtodaysval DECIMAL(20,2)
						 ,xdistrict VARCHAR(100)
						 ,xthana VARCHAR(100)
						 ,xmonth1 DECIMAL(20,2)
					   	 ,xmonth2 DECIMAL(20,2)
					   	 ,xmonth3 DECIMAL(20,2)
					   	 ,xmonth4 DECIMAL(20,2)
					     ,xmonth5 DECIMAL(20,2)
					   	 ,xmonth6 DECIMAL(20,2)
					   	 ,xmonth7 DECIMAL(20,2)
					   	 ,xmonth8 DECIMAL(20,2)
					   	 ,xmonth9 DECIMAL(20,2)
					   	 ,xmonth10 DECIMAL(20,2)
					   	 ,xmonth11 DECIMAL(20,2)
					   	 ,xmonth12 DECIMAL(20,2)
						 ,xmonthttl DECIMAL (20,2)

							 )

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid



DECLARE opcacus_cursor CURSOR FORWARD_ONLY 
FOR 

				/********** CUSTOMER QUERY ***********/
				
select xcus,xorg,xterritory,xso from cacus where zactive='1' and xstatus='Approved' and left(xcus,3)='CUS' --and xgcus='Dealer'
  AND xcus>=(CASE when @cus='' then '' else @cus end)
  AND xcus<=(CASE when @cus='' then 'zz' else @cus end)
  AND xgcus>=(CASE when @gcus='' then '' else @gcus end)
  AND xgcus<=(CASE when @gcus='' then 'zz' else @gcus end)
  AND xterritory>=(CASE when @territory='' then '' else @territory end)
  AND xterritory<=(CASE when @territory='' then 'zz' else @territory end) 
  AND xareaop>=(CASE when @area='' then '' else @area end)
  AND xareaop<=(CASE when @area='' then 'zz' else @area end) 
  AND xdistrict>=(CASE when @district='' then '' else @district end)
  AND xdistrict<=(CASE when @district='' then 'zz' else @district end)  
  AND xthana>=(CASE when @thana='' then '' else @thana end)
  AND xthana<=(CASE when @thana='' then 'zz' else @thana end) 
  AND xsubcat>=(CASE when @subcat='' then '' else @subcat end)
  AND xsubcat<=(CASE when  @subcat='' then 'zz' else @subcat end)
  order by xcus asc



OPEN opcacus_cursor
FETCH FROM opcacus_cursor INTO @xcus,@cusname,@territory2,@tso
WHILE @@FETCH_STATUS = 0
BEGIN
				
						
						/********** Monthly SALES ***********/

				
                SET @per=1
                WHILE ( @per <= 12)
                BEGIN

		    	select @xnetamt=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.xcus=@xcus and h.xstatusord='Confirmed'
				AND MONTH(h.xdate)=@per and year(h.xdate)=@year

				
				
				if @per=1
				begin
				set @month1=@xnetamt
				end
				else if @per=2
				begin
				set @month2=@xnetamt
				end
				else if @per=3
				begin
				set @month3=@xnetamt
				end
				else if @per=4
				begin
				set @month4=@xnetamt
				end
				else if @per=5
				begin
				set @month5=@xnetamt
				end
				else if @per=6
				begin
				set @month6=@xnetamt
				end
				else if @per=7
				begin
				set @month7=@xnetamt
				end
				else if @per=8
				begin
				set @month8=@xnetamt
				end
				else if @per=9
				begin
				set @month9=@xnetamt
				end
				else if @per=10
				begin
				set @month10=@xnetamt
				end
				else if @per=11
				begin
				set @month11=@xnetamt
				end
				else if @per=12
				begin
				set @month12=@xnetamt
				end
				

                SET @per  = @per  + 1
				
				select @tsoname=xname from cappo where xsp=@tso and xterritory=@territory2
				select @division=xdivisionop,@area2=xareaop,@thana2=xthana,@district2=xdistrict,@xsubcat=xsubcat from cacus where zid=@zid and xcus=@xcus
				END

				select @monthttl=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.xcus=@xcus and h.xstatusord='Confirmed' 
				AND year(h.xdate)=@year


  
	 INSERT INTO @table(zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtsoname,xmonth1,xmonth2,xmonth3,xmonth4,xmonth5,xmonth6,xmonth7,xmonth8,xmonth9,xmonth10,xmonth11,xmonth12,xmonthttl,xsubcat)

	 VALUES(@zid,@zorg,@image,@xcus,@cusname,isnull(@division,''),isnull(@territory2,''),isnull(@area2,''),isnull(@district2,''),isnull(@thana2,''),isnull(@tsoname,''),
	 isnull(@month1,0),isnull(@month2,0),isnull(@month3,0),isnull(@month4,0),isnull(@month5,0),isnull(@month6,0),
	 isnull(@month7,0),isnull(@month8,0),isnull(@month9,0),isnull(@month10,0),isnull(@month11,0),isnull(@month12,0),isnull(@monthttl,0),isnull(@xsubcat,''))
	
	

FETCH NEXT FROM opcacus_cursor INTO @xcus,@cusname,@territory2,@tso
END
CLOSE opcacus_cursor
DEALLOCATE opcacus_cursor

SELECT zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtsoname,xmonth1,xmonth2,xmonth3,xmonth4,xmonth5,xmonth6,xmonth7,xmonth8,xmonth9,xmonth10,xmonth11,xmonth12,xmonthttl,xsubcat
FROM @table order by xmonthttl desc


SET NOCOUNT OFF