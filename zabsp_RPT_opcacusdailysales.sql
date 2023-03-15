USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opcacusdailysales]    Script Date: 1/4/2023 12:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON 
GO

--EXEC zabsp_RPT_opcacusdailysales 200010,'','','','','','','','2022','12'

ALTER PROC [dbo].[zabsp_RPT_opcacusdailysales] 
	  @zid INT     
     ,@cus VARCHAR(30)      
     ,@gcus VARCHAR(150)     
     ,@subcat VARCHAR(150)     
	 ,@territory VARCHAR(250)
	 ,@area VARCHAR(250)     
	 ,@district VARCHAR(250) 
	 ,@thana VARCHAR(250)
	 ,@year VARCHAR(15)     
     ,@per VARCHAR(15)     

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
	,@amt1 DECIMAL(20,2)
	,@amt2 DECIMAL(20,2)
	,@amt3 DECIMAL(20,2)
	,@amt4 DECIMAL(20,2)
	,@amt5 DECIMAL(20,2)
	,@amt6 DECIMAL(20,2)
	,@amt7 DECIMAL(20,2)
	,@amt8 DECIMAL(20,2)
	,@amt9 DECIMAL(20,2)
	,@amt10 DECIMAL(20,2)
	,@amt11 DECIMAL(20,2)
	,@amt12 DECIMAL(20,2)
	,@amt13 DECIMAL(20,2)
	,@amt14 DECIMAL(20,2)
	,@amt15 DECIMAL(20,2)
	,@amt16 DECIMAL(20,2)
	,@amt17 DECIMAL(20,2)
	,@amt18 DECIMAL(20,2)
	,@amt19 DECIMAL(20,2)
	,@amt20 DECIMAL(20,2)
	,@amt21 DECIMAL(20,2)
	,@amt22 DECIMAL(20,2)
	,@amt23 DECIMAL(20,2)
	,@amt24 DECIMAL(20,2)
	,@amt25 DECIMAL(20,2)
	,@amt26 DECIMAL(20,2)
	,@amt27 DECIMAL(20,2)
	,@amt28 DECIMAL(20,2)
	,@amt29 DECIMAL(20,2)
	,@amt30 DECIMAL(20,2)
	,@amt31 DECIMAL(20,2)
	,@monthttl DECIMAL(20,2)
	,@perint int
	,@monthname VARCHAR(50)

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
						 ,xamt1 DECIMAL(20,2)
						 ,xamt2 DECIMAL(20,2)
						 ,xamt3 DECIMAL(20,2)
						 ,xamt4 DECIMAL(20,2)
						 ,xamt5 DECIMAL(20,2)
						 ,xamt6 DECIMAL(20,2)
						 ,xamt7 DECIMAL(20,2)
						 ,xamt8 DECIMAL(20,2)
						 ,xamt9 DECIMAL(20,2)
						 ,xamt10 DECIMAL(20,2)
						 ,xamt11 DECIMAL(20,2)
						 ,xamt12 DECIMAL(20,2)
						 ,xamt13 DECIMAL(20,2)
						 ,xamt14 DECIMAL(20,2)
						 ,xamt15 DECIMAL(20,2)
						 ,xamt16 DECIMAL(20,2)
						 ,xamt17 DECIMAL(20,2)
						 ,xamt18 DECIMAL(20,2)
						 ,xamt19 DECIMAL(20,2)
						 ,xamt20 DECIMAL(20,2)
						 ,xamt21 DECIMAL(20,2)
						 ,xamt22 DECIMAL(20,2)
						 ,xamt23 DECIMAL(20,2)
						 ,xamt24 DECIMAL(20,2)
						 ,xamt25 DECIMAL(20,2)
						 ,xamt26 DECIMAL(20,2)
						 ,xamt27 DECIMAL(20,2)
						 ,xamt28 DECIMAL(20,2)
						 ,xamt29 DECIMAL(20,2)
						 ,xamt30 DECIMAL(20,2)
						 ,xamt31 DECIMAL(20,2)
						 ,xmonth DECIMAL(20,2)
						 ,xmonthname VARCHAR(50)

							 )

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

set @perint = @per
SET @monthname=DATENAME(MONTH, DATEADD(MONTH, @perint, -1))


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
				
						
						/********** Daily SALES ***********/

				DECLARE @Counter INT 
                SET @Counter=1
                WHILE ( @Counter <= 31)
                BEGIN

		    	select @xnetamt=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.xcus=@xcus and h.xstatusord='Confirmed' and day(h.xdate)=@Counter 
				AND MONTH(h.xdate)=@per and year(h.xdate)=@year

				
				
				if @Counter=1
				begin
				set @amt1=@xnetamt
				end
				else if @Counter=2
				begin
				set @amt2=@xnetamt
				end
				else if @Counter=3
				begin
				set @amt3=@xnetamt
				end
				else if @Counter=4
				begin
				set @amt4=@xnetamt
				end
				else if @Counter=5
				begin
				set @amt5=@xnetamt
				end
				else if @Counter=6
				begin
				set @amt6=@xnetamt
				end
				else if @Counter=7
				begin
				set @amt7=@xnetamt
				end
				else if @Counter=8
				begin
				set @amt8=@xnetamt
				end
				else if @Counter=9
				begin
				set @amt9=@xnetamt
				end
				else if @Counter=10
				begin
				set @amt10=@xnetamt
				end
				else if @Counter=11
				begin
				set @amt11=@xnetamt
				end
				else if @Counter=12
				begin
				set @amt12=@xnetamt
				end
				else if @Counter=13
				begin
				set @amt13=@xnetamt
				end
				else if @Counter=14
				begin
				set @amt14=@xnetamt
				end
				else if @Counter=15
				begin
				set @amt15=@xnetamt
				end
				else if @Counter=16
				begin
				set @amt16=@xnetamt
				end
				else if @Counter=17
				begin
				set @amt17=@xnetamt
				end
				else if @Counter=18
				begin
				set @amt18=@xnetamt
				end
				else if @Counter=19
				begin
				set @amt19=@xnetamt
				end
				else if @Counter=20
				begin
				set @amt20=@xnetamt
				end
				else if @Counter=21
				begin
				set @amt21=@xnetamt
				end
				else if @Counter=22
				begin
				set @amt22=@xnetamt
				end
				else if @Counter=23
				begin
				set @amt23=@xnetamt
				end
				else if @Counter=24
				begin
				set @amt24=@xnetamt
				end
				else if @Counter=25
				begin
				set @amt25=@xnetamt
				end
				else if @Counter=26
				begin
				set @amt26=@xnetamt
				end
				else if @Counter=27
				begin
				set @amt27=@xnetamt
				end
				else if @Counter=28
				begin
				set @amt28=@xnetamt
				end
				else if @Counter=29
				begin
				set @amt29=@xnetamt
				end
				else if @Counter=30
				begin
				set @amt30=@xnetamt
				end
				else if @Counter=31
				begin
				set @amt31=@xnetamt
				end

SET @Counter  = @Counter  + 1
				
				select @tsoname=xname from cappo where xsp=@tso and xterritory=@territory2
				select @division=xdivisionop,@area2=xareaop,@thana2=xthana,@district2=xdistrict,@xsubcat=xsubcat from cacus where zid=@zid and xcus=@xcus
				end

				select @monthttl=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
				from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
				join caitem a on a.zid=d.zid and a.xitem=d.xitem 
				where h.xcus=@xcus and h.xstatusord='Confirmed' 
				AND MONTH(h.xdate)=@per and year(h.xdate)=@year


  
	 INSERT INTO @table(zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtsoname,xamt1,xamt2,xamt3,xamt4,xamt5,xamt6 ,xamt7,xamt8,xamt9,xamt10,xamt11,xamt12,xamt13,xamt14,xamt15,xamt16,xamt17,xamt18,xamt19,xamt20,xamt21,xamt22,xamt23,xamt24,xamt25,xamt26,xamt27,xamt28,xamt29,xamt30,xamt31,xmonth,xmonthname,xsubcat)

	 VALUES(@zid,@zorg,@image,@xcus,@cusname,isnull(@division,''),isnull(@territory2,''),isnull(@area2,''),isnull(@district2,''),isnull(@thana2,''),isnull(@tsoname,''),isnull(@amt1,0),isnull(@amt2,0),isnull(@amt3,0),isnull(@amt4,0),isnull(@amt5,0),isnull(@amt6,0),isnull(@amt7,0),isnull(@amt8,0),isnull(@amt9,0),isnull(@amt10,0),
	 isnull(@amt11,0),isnull(@amt12,0),isnull(@amt13,0),isnull(@amt14,0),isnull(@amt15,0),isnull(@amt16,0),isnull(@amt17,0),isnull(@amt18,0),isnull(@amt19,0),isnull(@amt20,0),
	 isnull(@amt21,0),isnull(@amt22,0),isnull(@amt23,0),isnull(@amt24,0),isnull(@amt25,0),isnull(@amt26,0),isnull(@amt27,0),isnull(@amt28,0),isnull(@amt29,0),isnull(@amt30,0),isnull(@amt31,0),isnull(@monthttl,0),@monthname,isnull(@xsubcat,''))
	
	

FETCH NEXT FROM opcacus_cursor INTO @xcus,@cusname,@territory2,@tso
END
CLOSE opcacus_cursor
DEALLOCATE opcacus_cursor

SELECT zid,zorg,ximage,xcus,xcusname,xdivision,xterritory,xarea,xdistrict,xthana,xtsoname,xamt1,xamt2,xamt3,xamt4,xamt5,xamt6 ,xamt7,xamt8,xamt9,xamt10,xamt11,xamt12,xamt13,xamt14,xamt15,xamt16,xamt17,xamt18,xamt19,xamt20,xamt21,xamt22,xamt23,xamt24,xamt25,xamt26,xamt27,xamt28,xamt29,xamt30,xamt31,xmonth,xmonthname,xsubcat
FROM @table order by xmonth desc


SET NOCOUNT OFF