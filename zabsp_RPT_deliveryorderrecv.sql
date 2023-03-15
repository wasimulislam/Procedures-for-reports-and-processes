USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_deliveryorderrecv]    Script Date: 1/22/2023 1:21:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_deliveryorderrecv 100000,'2023-01-01','2023-01-21','','',''

Alter PROC [dbo].[zabsp_RPT_deliveryorderrecv] 
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
	,@xcus VARCHAR(50)
	,@xsoamt Decimal(20,2)
	,@xdoamt Decimal(20,2)
	,@xundamt Decimal(20,2)
	,@xdate VARCHAR(50)
	

	DECLARE @table TABLE( zid INT
						,xorg VARCHAR(250) 
						,zorg VARCHAR(250)
	                    ,ximage varbinary(MAX)
	                    ,xrow INT
	                    ,xcus VARCHAR(50)
	                    ,xsoamt Decimal(20,2)
	                    ,xdoamt Decimal(20,2)
	                    ,xundamt Decimal(20,2)
						,xdsm VARCHAR(30)     
                        ,xdm VARCHAR(150)     
                        ,xtso VARCHAR(150)
						,xdate VARCHAR(50)

							 )

SELECT @zorg=zorg,@image=ximage
FROM zbusiness
WHERE zid=@zid



DECLARE opcacus_cursor1 CURSOR FORWARD_ONLY 
FOR 

				/********** QUERY ***********/
				
select distinct xcus from opsoheader where zid=@zid and xstatus='4' and xdate between @fdate and @tdate
  AND xdsm>=(CASE when @dsm='' then '' else @dsm end)
  AND xdsm<=(CASE when @dsm='' then 'zz' else @dsm end)
  AND xdm>=(CASE when @dm='' then '' else @dm end)
  AND xdm<=(CASE when @dm='' then 'zz' else @dm end) 
  AND xtso>=(CASE when @tso='' then '' else @tso end)
  AND xtso<=(CASE when @tso='' then 'zz' else @tso end) 

--select xcus from cacus where zid=@zid


OPEN opcacus_cursor1
FETCH FROM opcacus_cursor1 INTO @xcus
WHILE @@FETCH_STATUS = 0
BEGIN
				
						
						/********** Delivery Order ***********/

      

		    	select @xsoamt=sum(b.xlineamt) from opsoheader a  
				join opsodetail b on b.zid=a.zid and b.xsonumber=a.xsonumber
				where a.zid=@zid and a.xcus=@xcus and a.xdate between @fdate and @tdate

				select @xorg=xorg from cacus where zid=@zid and @xcus=xcus

				select @xdoamt=sum(b.xlineamt) from opdoheader a  
				join opdodetail b on b.zid=a.zid and b.xdornum=a.xdornum
				where a.zid=@zid and a.xcus=@xcus and a.xdate between @fdate and @tdate

				set @xundamt = @xsoamt-@xdoamt

  
	 INSERT INTO @table(zid,xcus,xorg,xsoamt,xdoamt,xundamt)

	 VALUES(@zid,@xcus,@xorg,isnull(@xsoamt,0),isnull(@xdoamt,0),isnull(@xundamt,0))
	
	

FETCH NEXT FROM opcacus_cursor1 INTO @xcus
END
CLOSE opcacus_cursor1
DEALLOCATE opcacus_cursor1

SELECT zid,xcus,xorg,xsoamt,xdoamt,xundamt
FROM @table 


SET NOCOUNT OFF