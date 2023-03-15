USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opsalesincyear]    Script Date: 2/27/2023 9:42:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_opsalesincyear 200010,'','','','','','','','12','2022'
ALTER PROC [dbo].[zabsp_RPT_opsalesincyear] 

	  @zid INT 
	 ,@cus VARCHAR(30)
	 ,@area VARCHAR(250)
	 ,@district VARCHAR(250)
	 ,@division VARCHAR(250)
	 ,@territory VARCHAR(250)
	 ,@thana VARCHAR(100)
	 ,@tso VARCHAR(50)
	 ,@tper VARCHAR(20)
	 ,@tyear VARCHAR(20) 
	 
	 
AS

DECLARE 
	 @zorg VARCHAR(250),
	 @user VARCHAR(50),
	 @image varbinary(MAX),
	 @row INT,@xcus VARCHAR(50),
	 @cusname VARCHAR(50),
	 @tso2 VARCHAR(50),
	 @tsoname VARCHAR(50),
	 @monthname VARCHAR(50)
	 ,@territory2 VARCHAR(250),
	 @area2 VARCHAR(100),
	 @thana2 VARCHAR(100),
	 @target DECIMAL(20,2),
	 @xsubcat VARCHAR(50),
	 @tper2 int
	 ,@cusinctype VARCHAR(100),
	 @cusspinctype VARCHAR(100),
	 @incgeneral DECIMAL(20,3),
	 @incexclusive DECIMAL(20,3),
	 @incspecial DECIMAL(20,2)
	 ,@incadditional DECIMAL(20,2),
	 @lastday INT ,
	 @fadiday INT ,
	 @tadiday INT ,
	 @lastyear INT
	 ,@inctarget DECIMAL(20,2),
	 @discdetamt DECIMAL(20,2),
	 @inctranscus DECIMAL(20,2)
	 ,@aitamt DECIMAL(20,2),
	 @inctarcus DECIMAL(20,2)
	 ,@kgamt DECIMAL(20,2),
	 @kgqty DECIMAL(20,2),
	 @fdate VARCHAR(25),
	 @tdate VARCHAR(25),
	 @additonaltrn VARCHAR(50)
	 ,@kgtarget DECIMAL(20,2),
	 @kgsales DECIMAL(20,2),
	 @kgacv DECIMAL(20,2),
	 @kgcaamt DECIMAL(20,2),
	 @kggamt DECIMAL(20,2)
	 ,@newcyqty DECIMAL(20,2),
	 @refcyqty DECIMAL(20,2),
	 @newadicyqty DECIMAL(20,2),
	 @newadicyqtyj DECIMAL(20,2),
	 @refadicyqty DECIMAL(20,2),
	 @refadicyqtyj DECIMAL(20,2),
	 @totcyqty DECIMAL(20,2),
	 @district2 VARCHAR(250),
	 @division2 VARCHAR(250),
	 @madd VARCHAR(250),
	 --@cylindertype VARCHAR(20),
	 @totadqty DECIMAL(20,2),
	 @addition DECIMAL(20,2),
	 @inc DECIMAL(20,2),
	 @totinc DECIMAL(20,2),
	 @lpginc DECIMAL(20,2),
	 @transportinc DECIMAL(20,2),
	 @lineamt DECIMAL(20,2),
	 @inctransport DECIMAL(20,2),
	 @qtyord DECIMAL(20,2),
	 @totalinc DECIMAL(20,2),
	 @lineamt1 DECIMAL(20,2),
	 @inctransport1 DECIMAL(20,2),
	 @qtyord1 DECIMAL(20,2),
	 @totalinc1 DECIMAL(20,2),
	 @perint int

	 DECLARE @table TABLE( zid INT 
						 ,zorg VARCHAR(150)
						 ,xyear VARCHAR(150)
						 ,xper VARCHAR(150)
						 ,xrfacat VARCHAR(150)
						 ,ximage image
						 ,xwh VARCHAR(50)
					  	 ,xcus VARCHAR(50)
					  	 ,xcusname VARCHAR(50)
					  	 ,xcusinctype VARCHAR(50)
					  	 ,xtso VARCHAR(50)
					  	 ,xtsoname VARCHAR(50)
						 ,xterritory VARCHAR(50)
						 ,xarea VARCHAR(50)
						 ,xsubcat VARCHAR(50)
						 ,xtarget DECIMAL(20,2) 
						 ,xdistrict VARCHAR(250)
						 ,xdivision VARCHAR(250)
						 ,xmadd VARCHAR(250),
						 xthana VARCHAR(250),
						 xlineamt DECIMAL(20,2),
	                     xinctransport DECIMAL(20,2),
	                     xqtyord DECIMAL(20,2),
	                     xtotalinc DECIMAL(20,2),
	                     xlineamt1 DECIMAL(20,2),
	                     xinctransport1 DECIMAL(20,2),
	                     xqtyord1 DECIMAL(20,2),
	                     xtotalinc1 DECIMAL(20,2)
						 ,xmonthname VARCHAR(50)
						 ,xlastyear int

						 )


SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid
set @xsubcat='LPG Cylinder'
DECLARE opinc_cursor CURSOR FORWARD_ONLY 
FOR 

select distinct xcus from opdoheader where xsubcat=@xsubcat
and xstatusord='Confirmed' and month(xdate)=@tper and year(xdate)=@tyear
  AND xcus>=(CASE when @cus='' then '' else @cus end)
  AND xcus<=(CASE when @cus='' then 'zz' else @cus end)
  AND xarea>=(CASE when @area='' then '' else @area end)
  AND xarea<=(CASE when @area='' then 'zz' else @area end) 
  AND xterritory>=(CASE when @territory='' then '' else @territory end)
  AND xterritory<=(CASE when @territory='' then 'zz' else @territory end) 
  AND xdivisionop>=(CASE when @division='' then '' else @division end)
  AND xdivisionop<=(CASE when @division='' then 'zz' else @division end) 
  AND xdistrictop>=(CASE when @district='' then '' else @district end)
  AND xdistrictop<=(CASE when @district='' then 'zz' else @district end)  
  AND xtso>=(CASE when @tso='' then '' else @tso end)
  AND xtso<=(CASE when @tso='' then 'zz' else @tso end)
  AND xthanaop>=(CASE when @thana='' then '' else @thana end)
  AND xthanaop<=(CASE when  @thana='' then 'zz' else @thana end)

OPEN opinc_cursor
FETCH FROM opinc_cursor INTO @xcus
WHILE @@FETCH_STATUS = 0
BEGIN
select @cusname=xorg,@area2=xareaop,@district2=xdistrict,@division2=xdivisionop,@madd=xmadd,@thana2=xthana,@tso2=xso,@territory2=xterritory from cacus where xcus=@xcus
select @tsoname=xname from cappo where xsp=@tso2
print @xcus

set @perint = @tper
SET @monthname=DATENAME(MONTH, DATEADD(MONTH, @perint, -1))
SET @lastyear=DATEPART(year,Dateadd(yyyy, -1, @tyear))

select @lineamt=sum(xlineamt),@inctransport=sum(xinctransport),@qtyord=sum(xqtyord),@totalinc=sum(xlineamt+xinctransport) from opsalesinc where zid=@zid and xcus=@xcus and xper=@tper and xyear=@tyear
select @lineamt1=sum(xlineamt),@inctransport1=sum(xinctransport),@qtyord1=sum(xqtyord),@totalinc1=sum(xlineamt+xinctransport) from opsalesinc where zid=@zid and xcus=@xcus and xper=@tper and xyear=@lastyear

                             

INSERT INTO @table(zid,ximage,xyear,xper,xcus,xcusname,xarea,xdistrict,xdivision,xmadd,xtso,xthana,xterritory,xtsoname,xlineamt,xinctransport,xqtyord,xtotalinc,xlineamt1,xinctransport1,xqtyord1,xtotalinc1,xmonthname,xlastyear)
			VALUES(@zid,@image,@tyear,@tper,@xcus,@cusname,isnull(@area2,''),isnull(@district2,''),isnull(@division2,''),isnull(@madd,''),isnull(@tso2,''),isnull(@thana2,''),isnull(@territory2,''),isnull(@tsoname,''),isnull(@lineamt,0),isnull(@inctransport,0),isnull(@qtyord,0),isnull(@totalinc,0),isnull(@lineamt1,0),isnull(@inctransport1,0),isnull(@qtyord1,0),isnull(@totalinc1,0),@monthname,@lastyear)
					 
FETCH NEXT FROM opinc_cursor INTO @xcus
END
CLOSE opinc_cursor
DEALLOCATE opinc_cursor

SELECT zid,ximage,xyear,xper,xcus,xcusname,xarea,xdistrict,xdivision,xmadd,xtso,xthana,xterritory,xtsoname,xlineamt,xinctransport,xqtyord,xtotalinc,xlineamt1,xinctransport1,xqtyord1,xtotalinc1,xmonthname,xlastyear
FROM @table 

SET NOCOUNT OFF

