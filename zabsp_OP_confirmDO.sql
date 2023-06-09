USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[zabsp_OP_confirmDO]    Script Date: 1/26/2023 1:26:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec zabsp_OP_confirmDO 100010,'','DO--000010','','2014-10-01','01','CUS-000004','61','Cash'

ALTER PROC [dbo].[zabsp_OP_confirmDO] --#id,#user,xdornum,xordernum,xdate,xwh,xcus

	 @zid INT
	,@user VARCHAR(50)
	,@dornum VARCHAR(50)
	,@ordernum VARCHAR(50)
	,@date datetime
	,@wh VARCHAR(50)
	,@cus VARCHAR(50)
	,@type VARCHAR(50)
	
AS
--BEGIN TRAN @user
SET NOCOUNT ON
DECLARE 
		 @datedue DATETIME
		,@maxdate DATETIME
		,@glwh VARCHAR(50)
		,@invnum VARCHAR(50)
	    ,@row INT
	    ,@offset INT
	    ,@trnlength INT
		,@year INT
		,@per INT
	    ,@orderrow INT
	    ,@dorrow INT
	    ,@item VARCHAR(50)
	    ,@lcno VARCHAR(50)
	    ,@messege VARCHAR(250)
	    ,@voucher VARCHAR(50)
	    ,@unit VARCHAR(50)
		,@qtyord DECIMAL(20,2)
		,@lineamt DECIMAL(20,2)
		,@totamt DECIMAL(20,2)
		,@trn VARCHAR(50)
		,@imtrnnum VARCHAR(50)
		,@vatrate DECIMAL(20,2)
		,@vatamt DECIMAL(20,2)
		,@prime DECIMAL(20,2)
		,@gitem VARCHAR(50)
		,@cusgroup VARCHAR(50)
		,@acc VARCHAR(50)
		,@piref VARCHAR(50)
		,@saletype VARCHAR(50)

	SET @prime = 0
	SET @datedue = '2999-01-01'

	IF EXISTS(SELECT xdornum from opdoheader WHERE zid=@zid AND xdornum=@dornum AND xstatusdor='Confirmed')
		RETURN

			SELECT @cusgroup = xgcus
			FROM cacus
			WHERE zid=@zid
			AND xcus=@cus

			SELECT @piref = ISNULL(xpiref,'')
			FROM opordheader
			WHERE zid=@zid
			AND xordernum=@ordernum

			
			SELECT @trn = xrel 
			FROM xtrnp			--*****Find out Inventory trn code 
			WHERE zid=@zid 
			AND xtypetrn='DO Number' 
			AND xtrn=LEFT(@dornum,4) 
			AND xtyperel='Inventory Transaction' 
			AND zactive=1

			DECLARE dodt_cursor_im CURSOR FORWARD_ONLY

			FOR SELECT o.xdorrow,o.xitem,o.xqtydel,c.xunitsel,ISNULL(o.xorderrow,0),ISNULL(o.xlineamt,0)
			FROM opdodetail o
			JOIN caitem c ON o.zid=c.zid 
			AND o.xitem=c.xitem
			WHERE o.zid=@zid
			AND o.xdornum=@dornum 
		--	AND c.xstype='Stock-N-Sell'

			OPEN dodt_cursor_im
			FETCH FROM dodt_cursor_im INTO @row,@item,@qtyord,@unit,@orderrow,@lineamt
			WHILE @@FETCH_STATUS = 0
			BEGIN


				EXEC Func_getTrn @zid,'Inventory Transaction',@trn,6,@strVar=@imtrnnum OUTPUT

				INSERT INTO imtrn(ztime,zauserid,zid,ximtrnnum, xitem,xwh,xdate,xqty,xval,xvalpost,xdocnum,xdocrow,xnote,
   										xsign,xunit,xrate,xref,xstatusjv,xpiref,xordernum,xorderrow,xdornum,xdorrow)
   						   VALUES(GETDATE(),@user,@zid,@imtrnnum,@item,@wh,@date,@qtyord,@lineamt,@lineamt,@dornum,@row,'Transfer From Sales',
   										-1,@unit,0,'','Open',@piref,@ordernum,@orderrow,@dornum,@dorrow)
   										

			FETCH NEXT FROM dodt_cursor_im INTO @row,@item,@qtyord,@unit,@orderrow,@lineamt
			END
			CLOSE dodt_cursor_im
			DEALLOCATE dodt_cursor_im


		/*********************************************END INVENTORY TRANSFER**********************************************************/
	
		/*********************************************START AR TRANSFER*************************************************************
		IF (@type = 'Cash') 
		BEGIN
			IF EXISTS(SELECT * FROM opdodetail WHERE zid=@zid AND xdornum=@dornum)
			BEGIN
				
			-- initialization 

			SET @year = YEAR(@date)
			SET @per = MONTH(@date)
			SET @row = 0
			SET @acc = ''
			--SET @messege = 'Transfer from AR, From Transaction ' +@ftrn+' To '+@ttrn+' and Date from '+CAST(@date AS VARCHAR(50))+' To '+CAST(@dateto AS VARCHAR(50))

			/********* GETTING GL YEAR & PERIOD *************/

			SELECT @offset = xoffset,@trnlength=xlength
			FROM acdef 
			WHERE zid=@zid

			SET @per = 12+@per-@offset

			IF @per <= 12
				SET @year = @year-1
			ELSE
				SET @per = @per-12


			SELECT @trn = xrel 
			FROM xtrnp			--*****Find out GL Voucher
			WHERE zid=@zid 
			AND xtypetrn='DO Number' 
			AND xtrn=LEFT(@dornum,4) 
			AND xtyperel='GL Voucher' 
			AND zactive=1

			SELECT @lcno = xlcno
			FROM opordheader
			WHERE zid=@zid
			AND xordernum=@ordernum


			IF @lcno = ISNULL(@lcno,'')
			SET @voucher=''
			SET @totamt =0
				--EXEC Func_getTrn @zid,'Inventory Transaction',@trn,6,@strVar=@imtrnnum OUTPUT
				EXEC Func_getTrn @zid,'GL Voucher',@trn,@trnlength,@strVar=@voucher OUTPUT

				INSERT INTO acheader(ztime,zid,zauserid,xvoucher,xref,xdate,xlong,xstatusjv,xyear,xper,xtype,xlcno,xsub,xwh)VALUES
							(GETDATE(),@zid,@user,@voucher,'',@date,@messege,'Balanced',@year,@per,'AR',@lcno,@cus,@glwh)	
		
	
				IF @@ERROR = 0
				BEGIN

					/*****INSERT INTO AR TRANSACTION*****/
					
					DECLARE dodt_cursor_ar CURSOR FORWARD_ONLY
					FOR SELECT ca.xgitem,dohd.xtype,SUM(op.xlineamt)as xlineamt 
					FROM opdodetail op 
					INNER JOIN caitem ca 
					ON ca.zid=op.zid 
					AND op.xitem=ca.xitem 
					INNER JOIN opdoheader dohd
					ON dohd.zid=op.zid
					AND dohd.xdornum=op.xdornum
					WHERE op.zid=@zid
					AND op.xdornum = @dornum 
					GROUP BY ca.xgitem,dohd.xtype
					OPEN dodt_cursor_ar

					FETCH FROM dodt_cursor_ar INTO @gitem,@saletype,@lineamt
					WHILE @@FETCH_STATUS = 0
					BEGIN

						SET @row = @row + 1

						SELECT @acc=xacc 
						FROM optoari 
						WHERE xtype=@type
					--	AND xgitem = @gitem 
						AND xgcus=@cusgroup

						SET @row = @row+1	
		
						INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xlong,xsub,xwh)VALUES
										(GETDATE(),@zid,@user,@voucher,@row,@acc,0-@lineamt,'','',@glwh)

						SET @totamt = @totamt+@lineamt

						FETCH NEXT FROM dodt_cursor_ar INTO @gitem,@saletype,@lineamt
					END
					CLOSE dodt_cursor_ar
					DEALLOCATE dodt_cursor_ar

				END
			END

			SELECT @acc=xacc
			FROM optoari 
			WHERE xtype=@type
		--	AND xgitem = @gitem 
			AND xgcus=@cusgroup

			SET @row = @row+1	
	
			INSERT INTO acdetail(ztime,zid,zauserid,xvoucher,xrow,xacc,xprime,xlong,xsub,xwh)VALUES
								(GETDATE(),@zid,@user,@voucher,@row,@acc,@totamt,'',@cus,@glwh)

		END

			-- **************** CHECKING FOR Suspended Status Flag IN ACHEADER ******************

			SELECT @totamt = SUM(xprime) FROM acdetail WHERE zid=@zid AND xvoucher=@voucher
			IF @totamt <> 0
				UPDATE acheader SET xstatusjv='Suspended' WHERE xvoucher=@voucher
			IF @totamt = 0
				UPDATE acheader SET xstatusjv='Balanced' WHERE xvoucher=@voucher
			
		/*********************************************END AR TRANSFER**************************************************************/
*/
UPDATE opdoheader 
SET xstatusdor='Confirmed',xstatusar='Open',xvoucher=@voucher
WHERE zid=@zid 
AND xdornum=@dornum

SELECT @invnum = xinvnum 
FROM opdoheader 
WHERE zid=@zid 
AND xdornum = @dornum

SELECT @maxdate = max(xdate) 
FROM opdoheader 
WHERE xinvnum = @invnum

UPDATE opinvheader
SET xdatedo = @maxdate 
WHERE zid=@zid 
AND xinvnum=@invnum


--COMMIT TRAN @user
