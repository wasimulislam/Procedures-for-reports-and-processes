USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[CTSORDER_SLR]    Script Date: 3/14/2023 9:44:27 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[CTSORDER_SLR] @zid int,@do varchar(230) -- CTSORDER_SLR 200010 ,'SLR-23000001'

AS
Declare @dchalan varchar(30),@date datetime,@dealer varchar(30),@truckno varchar(30),@plant varchar(30),@action varchar(30),
 	@truckStatusId int  ,@trn VARCHAR(50),@trnlength INT,@dornum VARCHAR(50),
	@productCode1 int  ,@count int  ,@count1 int  ,
	@pC1FilledQuantity decimal(20,5),
	@pC1EmptyQuantity decimal(20,5),
	@pC1SystemQuantity decimal(20,5),
	@productCode2 int ,
	@pC2FilledQuantity decimal(20,5),
	@pC2EmptyQuantity decimal(20,5),
	@pC2SystemQuantity decimal(20,5),
	@productCode3 int  ,
	@pC3FilledQuantity decimal(20,5),
	@pC3EmptyQuantity decimal(20,5),
	@pC3SystemQuantity decimal(20,5),
	@productCode4 int ,
	@pC4FilledQuantity decimal(20,5),
	@pC4EmptyQuantity decimal(20,5),
	@pC4SystemQuantity decimal(20,5)  
   ,@row int ,@type varchar(150),@xitem  varchar(150),@qty decimal(20,5)
   ,@item  int,@xitemRefil  int,@dc varchar(30)	,@ypdshort VARCHAR(6)
	,@ypd INT,@ck varchar(10)
,@fill int =0,@empty int =0
,@xitemtype VARCHAR(60)

set @action=left(@do,3)
/*

sync=0 >> Need to generate CTS order
sync=1 >> Successfully Synced
sync=2 >> Successfully Data pulled from CTS
SYNC=5 >> Pending  for Sync


*/

--select @count1=count(*) from ctsheader where xdocnum=@do

if exists(
select 1 from ctsheader where xdocnum=@do
)
return;

select * from opcrnheader

IF @action='SLR'
and EXISTS(
	select 1 from opcrnheader where xstatus='Approved' and   xcrnnum=@do and zid=@zid
)
AND not Exists(select 1 from ctsheader where xdocnum=@do and zid=@zid)


BEGIN
set @truckStatusId=0
set @dc=@do
--DECLARE cursor_DC CURSOR
--FOR select distinct xdocnum from opdodetail where 
--xdornum=@do and 
--xdocnum<>'' and zid=@zid
--OPEN cursor_DC;

--FETCH NEXT FROM cursor_DC INTO @dc

--WHILE @@FETCH_STATUS = 0
--BEGIN
PRINT @dc	
		
----------------------------Start

if not exists( 	   
    select  ROW_NUMBER() OVER(order by a.xcrnnum) as xrow,h.xsubcat,xitem,sum(isnull(a.xqtyord,0))  
	from opcrndetail a join opcrnheader h on h.zid=a.zid and h.xcrnnum=a.xcrnnum
	where a.xcrnnum=@do and h.xsubcat='LPG Cylinder' ANd isnull(xstatuscrn,'')<>'Confirmed' And xstatus='Approved'
	group by h.xsubcat,xitem,a.xcrnnum
  )
return; 


BEGIN
	DECLARE spdo_cursor CURSOR FORWARD_ONLY FOR

	select  h.xcrnnum,cast(h.xdate as date),h.xcus,'-',cast(isnull(x.xwh,'1') as int) 
	from  opcrnheader h join xcodes x on x.zid=h.zid and x.xcode=h.xwh
    where h.xstatus='Approved' AND  isnull(xstatuscrn,'')<>'Confirmed' and isnull(h.xcus,'')<>'' 
	AND x.xcode<>'' and x.xtype = 'Branch'  and h.xsubcat='LPG Cylinder' 
	AND isnull(h.xcrnnum,'')>=(CASE when @do='' then '' else @do end)
    AND isnull(h.xcrnnum,'')<=(CASE when @do='' then 'zz' else @do end)

	OPEN spdo_cursor
	FETCH FROM spdo_cursor INTO @dchalan,@date,@dealer,@truckno,@plant
	WHILE @@FETCH_STATUS=0
	BEGIN

    set @trn='CTS'
	EXEC Func_getTrn @zid,'CTS Order Number',@trn,6,@strVar=@dornum OUTPUT


 --   SET @ypd = FORMAT(@date, 'yyyyMMdd')
	--SET @ypdshort = RIGHT(CAST(@ypd AS VARCHAR(8)),6)
	--set @trn='SO'
	--EXEC Func_getTrn @zid,'CTS Order Number',@trn,10,@strVar=@dornum OUTPUT
	--SET @dornum = @trn+@ypdshort+RIGHT(@dornum,6)

	--SET @dornum = 'CTS'+@dornum
Print @dchalan
Print @dornum

--If not EXISTS(select * from [CTSHEADER] where xdornum=@dornum)
BEGIN
Insert Into [CTSHEADER](zid,ztime,xdornum,xdocnum,xdate,xcus,xtruckno,xplantno,xsync,xcusold,xiscomplete)
select @zid,getdate(),@dornum,@dchalan,@date,cast(right(@dealer,6) as int),@truckno,@plant,0,@dealer,0
END
----------------------------Start
BEGIN
	DECLARE spdo_cursor2 CURSOR FORWARD_ONLY FOR

    select  ROW_NUMBER() OVER(order by a.xcrnnum) as xrow,h.xsubcat,xitem,sum(isnull(a.xqtyord,0))  
	from opcrndetail a join opcrnheader h on h.zid=a.zid and h.xcrnnum=a.xcrnnum
	where a.xcrnnum=@do and h.xsubcat='LPG Cylinder' And isnull(xstatuscrn,'')<>'Confirmed' And xstatus='Approved'
	group by h.xsubcat,xitem,a.xcrnnum


	OPEN spdo_cursor2
	FETCH FROM spdo_cursor2 INTO @row,@type,@xitem,@qty
	WHILE @@FETCH_STATUS=0
	BEGIN
	print @xitem

	if @type='New Cylinders'
	BEGIN
	select @item=cast(right(xassetitem,5) as int) from caitem where xitem=@xitem and zid=@zid
	END
	else
	BEGIN
	select @item= cast(right(xassetitem,5) as int) from caitem where xitem=@xitem and zid=@zid
	END


	--'New Cylinders' 

select @xitemtype=xitemtype
 from  caitem where xitem =@xitem and zid=@zid
 if @xitemtype='Refilled Cylinders'
 BEGIN
 set @empty=cast(@qty as int)
 set @fill=0
 END
 else 
 BEGIN
 set @empty=cast(@qty as int)
 set @fill=0
 END
  --set @empty=0
  --set @fill=cast(@qty as int)

 set @item= cast(right(@xitem,5) as int) 
	--select * from imtordetail


  --sp_help CTSHEADER

	--*/
	if @row=1  
	BEgin
	update  CTSHEADER set xitem=@xitem,[productCode1]=@item,[pC1FilledQuantity]=@fill ,[pC1EmptyQuantity]=@empty  where xdornum=@dornum
	END
	else if @row=2
	BEgin
	update  CTSHEADER set xitem2=@xitem,[productCode2]=@item,[pC2FilledQuantity]=@fill ,[pC2EmptyQuantity]=@empty  where xdornum=@dornum
	END
	else if @row=3
	BEgin
	update  CTSHEADER set xitem3=@xitem,[productCode35kg22mm]=@item,[pc35kg22mm_filled_quantity]=@fill ,[pc35kg22mm_empty_quantity]=@empty  where xdornum=@dornum
	END
	else if @row=4
	BEgin
	update  CTSHEADER set xitem4=@xitem,[productCode35kg20mm]=@item,[pc35kg20mm_filled_quantity]=@fill ,[pc35kg20mm_empty_quantity]=@empty  where xdornum=@dornum
	END
	else if @row=5
	BEgin
	update  CTSHEADER set xitem6=@xitem,[productCode45kg22mm]=@item,[pc45kg22mm_filled_quantity]=@fill ,[pc45kg22mm_empty_quantity]=@empty  where xdornum=@dornum
	END
	else if @row=6
	BEgin
	update  CTSHEADER set xitem6=@xitem,[productCode45kg20mm]=@item,[pc45kg20mm_filled_quantity]=@fill ,[pc45kg20mm_empty_quantity]=@empty  where xdornum=@dornum
	END


    --select cast((right(h.xcus,6)) as int) as dealerCode,(isnull(d.xqtydoc,0)+isnull(d.xqtybonus,0)) as Qty ,h.xtruckno as truckPlate,cast(right(h.xdocnum,7) as int) as DC,cast(isnull(h.xplantno,'1') as int) as plantId ,* from opdcdetail d join opdcheader h on h.xdocnum=d.xdocnum 
    --where h.xstatusdoc='Confirmed'
	FETCH NEXT FROM spdo_cursor2 INTO  @row,@type,@xitem,@qty
	END
	CLOSE spdo_cursor2
	DEALLOCATE spdo_cursor2
END

select @count=count(*) from ctsheader where xdocnum=@do

if exists (select 1 from CTSHEADER where  xdornum=@dornum)
BEGIN
update imtorheader set xsync=5,xtrnnum=isnull(xtrnnum,'')+','+@dornum,xdocrow=@count  where xstatustor='Approved' and isnull(xcus,'')<>'' and xtornum=@dchalan AND xsubcat='LPG Cylinder' 
and zid=@zid
END
    --select cast((right(h.xcus,6)) as int) as dealerCode,(isnull(d.xqtydoc,0)+isnull(d.xqtybonus,0)) as Qty ,h.xtruckno as truckPlate,cast(right(h.xdocnum,7) as int) as DC,cast(isnull(h.xplantno,'1') as int) as plantId ,* from opdcdetail d join opdcheader h on h.xdocnum=d.xdocnum 
    --where h.xstatusdoc='Confirmed'
	FETCH NEXT FROM spdo_cursor INTO @dchalan,@date,@dealer,@truckno,@plant
	END
	CLOSE spdo_cursor
	DEALLOCATE spdo_cursor
END

if exists
(select 1 from ctsheader where xdocnum=@do)
BEGIN
update opcrnheader set xdocnum=@dornum,xiscomplete=1 where zid=@zid and xcrnnum=@do and isnull(xiscomplete,0)<>1
END

-----------------------------END  select * from CTSHEADER
--		FETCH NEXT FROM cursor_DC INTO @dc
--    END;
--CLOSE cursor_DC;
--DEALLOCATE cursor_DC;
END

--select * from imtorheader  where xstatustor='Approved'  and xtornum=@do AND xsubcat='LPG Cylinder' 
--  delete from CTSHEADER
--update imtorheader set xsync=0  where xstatustor='Approved' and isnull(xcus,'')<>'' and xtornum='SO23020002600' AND xsubcat='LPG Cylinder' 
--and zid=@zid delete from CTSHEADER
--select * from CTSHEADER

--select * from imtordetail where xtornum='SO23020002600'

