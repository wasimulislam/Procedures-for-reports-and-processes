USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_RPT_discwisesales]    Script Date: 1/22/2023 1:21:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC zabsp_RPT_discwisesales 100000,'2023-01-01','2023-01-21','','','',''

Alter PROC [dbo].[zabsp_RPT_discwisesales] 
	  @zid INT 
	 ,@fdate VARCHAR(250)
	 ,@tdate VARCHAR(250) 
     ,@dsm VARCHAR(30)     
     ,@dm VARCHAR(150)     
     ,@tso VARCHAR(150)
	 ,@xcus VARCHAR(50)
	    

AS

DECLARE 
	 @xorg VARCHAR(250)
	,@xitem VARCHAR(250)
	,@zorg VARCHAR(250)
	,@image varbinary(MAX)
	,@row INT
	,@xamt Decimal(20,2)
	,@xdisamt Decimal(20,2)
	,@xdate VARCHAR(50)
	

	DECLARE @table TABLE( zid INT
						,xorg VARCHAR(250) 
						,xitem VARCHAR(250)
						,zorg VARCHAR(250)
	                    ,ximage varbinary(MAX)
	                    ,xrow INT
	                    ,xcus VARCHAR(50)
	                    ,xamt Decimal(20,2)
	                    ,xdisamt Decimal(20,2)
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
				
select distinct xcus from opdoheader where zid=@zid  and xdate between @fdate and @tdate
  AND xdsm>=(CASE when @dsm='' then '' else @dsm end)
  AND xdsm<=(CASE when @dsm='' then 'zz' else @dsm end)
  AND xdm>=(CASE when @dm='' then '' else @dm end)
  AND xdm<=(CASE when @dm='' then 'zz' else @dm end) 
  AND xtso>=(CASE when @tso='' then '' else @tso end)
  AND xtso<=(CASE when @tso='' then 'zz' else @tso end) 
  AND xcus>=(CASE when @xcus='' then '' else @xcus end)
  AND xcus<=(CASE when @xcus='' then 'zz' else @xcus end) 

--select xcus from cacus where zid=@zid


OPEN opcacus_cursor1
FETCH FROM opcacus_cursor1 INTO @xcus
WHILE @@FETCH_STATUS = 0
BEGIN
				
						
						/********** Delivery Order ***********/

      

		    	select @xamt=sum(xtotamt),@xdisamt=sum(xdisc) from opdoheader a
				where zid=@zid and xcus=@xcus and xdate between @fdate and @tdate

				select @xorg=xorg from cacus where zid=@zid and @xcus=xcus



  
	 INSERT INTO @table(zid,xcus,xorg,xamt,xdisamt)

	 VALUES(@zid,@xcus,@xorg,isnull(@xamt,0),isnull(@xdisamt,0))
	
	

FETCH NEXT FROM opcacus_cursor1 INTO @xcus
END
CLOSE opcacus_cursor1
DEALLOCATE opcacus_cursor1

SELECT zid,xcus,xorg,xamt,xdisamt
FROM @table 


SET NOCOUNT OFF