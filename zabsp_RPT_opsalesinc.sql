USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_opsalesinc]    Script Date: 2/27/2023 9:42:40 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--delete from cacusincentive
--select * from cacusincentive
--EXEC zabsp_RPT_opsalesinc 200010,'12 Kg Cylinder','12','2022'
ALTER PROC [dbo].[zabsp_RPT_opsalesinc] 

	  @zid INT 
	  ,@cylindertype VARCHAR(20)   
	 ,@tper VARCHAR(20)
	 ,@tyear VARCHAR(20)       
	 
AS

DECLARE 
	 @zorg VARCHAR(250),
	 @user VARCHAR(50),
	 @image varbinary(MAX),
	 @row INT,@xcus VARCHAR(50),
	 @cusname VARCHAR(50),
	 @tso VARCHAR(50),
	 @tsoname VARCHAR(50),
	 @monthname VARCHAR(50)
	 ,@territory VARCHAR(250),
	 @area VARCHAR(100),
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
	 @inctransport DECIMAL(20,2),
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
	 @district VARCHAR(250),
	 @division VARCHAR(250),
	 @madd VARCHAR(250),
	 --@cylindertype VARCHAR(20),
	 @totadqty DECIMAL(20,2),
	 @addition DECIMAL(20,2),
	 @inc DECIMAL(20,2),
	 @totinc DECIMAL(20,2),
	 @lpginc DECIMAL(20,2),
	 @transportinc DECIMAL(20,2)




SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid

--if not exists(select xper from cacusincentive where xper=@tper and xyear=@tyear and xrfacat=@cylindertype)
--return
/*DATE,DAY,MONTH*/
set @tper2=@tper
SET @lastyear=DATEPART(year,Dateadd(yyyy, -1, @tyear))
SET @lastday=DATEPART(day,eomonth(DATEADD( MONTH, @tper2, -1)))
SET @monthname=DATENAME( MONTH, DATEADD( MONTH, @tper2, -1))

if @cylindertype<>''
set @xsubcat='LPG Cylinder'

if exists(select 1 from opsalesinc where zid=@zid and xper=@tper and xyear=@tyear)
delete from opsalesinc where xper=@tper and xyear=@tyear

DECLARE opincprocess_cursor CURSOR FORWARD_ONLY 
FOR 

				/********** CUSTOMER QUERY ***********/

select distinct xcus from opdoheader dh where dh.xsubcat=@xsubcat
and dh.xstatusord='Confirmed' and month(dh.xdate)=@tper and year(dh.xdate)=@tyear

OPEN opincprocess_cursor
FETCH FROM opincprocess_cursor INTO @xcus
WHILE @@FETCH_STATUS = 0
BEGIN

set @incexclusive=0	
set @incgeneral=0	
set @incadditional=0
select @cusname=xorg,@area=xareaop,@district=xdistrict,@division=xdivisionop,@madd=xmadd,@tso=xso,@cusinctype=isnull(xcainstype,'') from cacus where xcus=@xcus
select @tsoname=xname from cappo where xsp=@tso

						/********** QTY Count ***********/ 
set @kgqty=0
								
select @kgqty=isnull(sum((isnull(d.xqtyord*isnull(a.xpackqty,0),0)/1000)),0)
from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
join caitem a on a.zid=d.zid and a.xitem=d.xitem 
where h.xstatusord='Confirmed' and month(h.xdate)=@tper and year(h.xdate)=@tyear 
and h.xcus=@xcus and isnull(a.xcatitemacc,'')=@cylindertype

print @kgqty
								

							/********** Total Cylinder QTY A ***********/

set @inc=0
select @inc=sum(isnull(xincgeneral,0)+isnull(xincexclusive,0)+isnull(xincspecial,0)+isnull(xinctarget,0)) from cacusincentive where xcus=@xcus and xrfacat=@cylindertype  and xper=@tper and xyear=@tyear
set @totinc=0
set @totinc=@inc*@kgqty


									/********** Additional ***********/
set @incadditional=0
DECLARE rptopincprocessAdditional_cursor CURSOR FORWARD_ONLY  
FOR
		select xfdate,xtdate from opincadditionalh where xper=@tper and xyear=@tyear and xcus=@xcus and xrfacat=@cylindertype
OPEN rptopincprocessAdditional_cursor
FETCH FROM rptopincprocessAdditional_cursor INTO @fdate,@tdate
WHILE @@FETCH_STATUS = 0
BEGIN	
		set @fadiday=DAY(@fdate)
		set @tadiday=DAY(@tdate)


							/********** Additional CY Count ***********/
set @refadicyqtyj=0

select @refadicyqtyj=isnull(sum(d.xqtyord),0)
from opdoheader h join opdodetail d on d.zid=h.zid and d.xdornum=h.xdornum 
join caitem a on a.zid=d.zid and a.xitem=d.xitem 
where h.zid=@zid and h.xcus=@xcus and h.xstatusord='Confirmed' and cast(h.xdate as date) between @fdate and @tdate
AND a.xcatitemacc=@cylindertype

set @refadicyqty=isnull(@refadicyqtyj,0)+isnull(@refadicyqty,0)
						FETCH NEXT FROM rptopincprocessAdditional_cursor INTO @fdate,@tdate
								END
								CLOSE rptopincprocessAdditional_cursor
								DEALLOCATE rptopincprocessAdditional_cursor

								/********** Total Additional QTY B ***********/
set @totadqty=@refadicyqty
select @incadditional=xincadditional from cacusincentive where xcus=@xcus and xper=@tper and xyear=@tyear and xrfacat=@cylindertype

set @addition=@incadditional*@totadqty

                                /********** LPG Incentive ***********/
set @lpginc=0
set @lpginc = @totinc+@addition

                                /********** Transport Cost ***********/
set @inctransport=0
select @inctransport=xinctransport from cacusincentive where xcus=@xcus and xrfacat=@cylindertype and xper=@tper and xyear=@tyear
set @transportinc=0
set @transportinc=@inctransport*@kgqty


                                 
  
	
	INSERT INTO opsalesinc(ztime,zauserid,zid,ximage,xyear,xper,xcus,xcusname,xarea,xdistrict,xdivision,xmadd,xtso,xtsoname,xrfacat,xqtyord,xtotamt,xincadditional,xaddition,xlineamt,xinctransport)

					VALUES(GETDATE(),@user,@zid,@image,@tyear,@tper,@xcus,@cusname,isnull(@area,''),isnull(@district,''),isnull(@division,''),isnull(@madd,''),isnull(@tso,''),isnull(@tsoname,''),isnull(@cylindertype,''),isnull(@kgqty,0),isnull(@totinc,0),isnull(@totadqty,0),isnull(@addition,0),isnull(@lpginc,0),isnull(@transportinc,0))
					 
					 set @incexclusive=0	
					 set @incgeneral=0	
					 set @incadditional=0
					 set @newadicyqty=0
					 set @refadicyqty=0
					 set @totadqty=0
					 set @addition=0

FETCH NEXT FROM opincprocess_cursor INTO @xcus
END
CLOSE opincprocess_cursor
DEALLOCATE opincprocess_cursor

SELECT ztime,zauserid,zid,ximage,xyear,xper,xcus,xcusname,xarea,xdistrict,xdivision,xmadd,xtso,xtsoname,xrfacat,xqtyord,xtotamt,xincadditional,xaddition,xlineamt,xinctransport
FROM opsalesinc --order by xcus desc

SET NOCOUNT OFF

