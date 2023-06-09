USE [ZABDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_payslipprocess]    Script Date: 2/7/2023 4:54:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--   EXEC sp_payslipprocess 100010,'nahid','AKU-0239','AKU-0239','2023','2',''
ALTER PROCEDURE [dbo].[sp_payslipprocess]
										 @zid INT
										,@user VARCHAR(50)
										,@fstaff VARCHAR(50)
										,@tstaff VARCHAR(50)
										,@year INT
										,@per INT
										,@pempcategory VARCHAR(50)
 

AS
SET NOCOUNT OFF

DECLARE @empcategory VARCHAR(50),				@empcate VARCHAR(50),				@staff VARCHAR(50),						@sdate DATE, 
		@edate DATE,							@voucher VARCHAR(50),				@basicamt DECIMAL(20,2),				@hrentamt DECIMAL(20,2),
		@convamt DECIMAL(20,2),					@transportaowance DECIMAL(20,2),	@foodallowance DECIMAL(20,2),			@medamt DECIMAL(20,2),
		@grossamt DECIMAL(20,2),				@otheramt DECIMAL(20,2),			@oploanamt DECIMAL(20,2),				@oploanamt2  DECIMAL(20,2),
		@curloanamt DECIMAL(20,2),				@oppfamt DECIMAL(20,2),				@curpfamt DECIMAL(20,2),				@pfloanpaid DECIMAL(20,2),
		@oppfint DECIMAL(20,2),					@sday INT,							@eday INT,								@DOJ DATETIME,
		@resigndate DATE,						@startdate DATE,					@enddate DATE,							@noofday INT,
		@wdays DECIMAL(20,2),					@weekend INT,						@weeklyhday INT,						@weeklyfestivalhday INT,
		@weeklyotherhday INT,					@naday INT,							@weeklydayoff INT,						@presentdays INT,
		@replv INT,								@lwphours INT,						@sicklvhours INT,						@cl INT,
		@el INT,								@mlv INT,							@lvindayoff INT,						@lvinholiday INT,
		@note NVARCHAR(MAX),					@othours INT,						@ratephr DECIMAL(20,2) ,                @dayssalded INT ,
		@attbon INT,							@saladv INT,						@oldsalary DECIMAL(20,2),				@stamp INT,
		@amtother DECIMAL(20,2),				@arrear	DECIMAL(20,2),				@loanded	DECIMAL(20,2),				@absdedamt DECIMAL (20,2),				   
		@taxamt DECIMAL(20,2),					@otherdeduc DECIMAL(20,2),			@skillallowance DECIMAL(20,2)
		
		--=========Salary Cycle Day from default table pddef============
		SELECT @sday=xstartday,@eday=xendday FROM pddef WHERE zid=@zid
		
		IF @sday>0 AND @eday>0
		BEGIN
			SET @sdate = CAST(Left(CAST(eomonth(dateadd(month, -1, ((Select DATEADD(mm,DATEDIFF(m,0,CAST(CAST(@year AS VARCHAR)+'-'+CAST(@per AS VARCHAR)+'-01' AS DATE)),0))))) AS VARCHAR(50)),8)+cast(@sday AS VARCHAR(40)) AS DATE)
			SET @edate = CAST(CAST(@year AS VARCHAR(10))+'-'+CAST(@per AS VARCHAR(10))+'-'+CAST(@eday AS VARCHAR(10)) AS DATE)
		END
		ELSE
		BEGIN
			SET @sdate = (Select DATEADD(mm,DATEDIFF(m,0,CAST(CAST(@year AS VARCHAR)+'-'+CAST(@per AS VARCHAR)+'-01' AS DATE)),0))	
			SET @edate = DATEADD(dd,-1,DATEADD(mm, DATEDIFF(m,0,DATEADD(mm,0,CAST(CAST(@year AS VARCHAR)+'-'+CAST(@per AS VARCHAR)+'-01' AS DATETIME)))+1,0))
		END
		--=========End of Salary Cycle Day from default table pddef============
		
		--=========Number of days in Salary Cycle============
		SET @noofday = DAtediff(dd,@sdate,@edate)+1
		--=========End of Number of days in Salary Cycle============

		
		--======== Employee Category Getting======================
		DECLARE cur_empcat CURSOR FORWARD_ONLY FOR
		select distinct xempcategory from pdmst WHERE zid=@zid
		AND xempcategory>=(CASE when @pempcategory='' then '' else @pempcategory end)
		AND xempcategory<=(CASE when @pempcategory='' then 'zz' else @pempcategory end)
		AND xempstatus='Normal' AND ISNULL(xempcategory,'')<>'' 

		OPEN cur_empcat
		FETCH FROM cur_empcat INTO @empcategory
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF exists(Select xrow from pdbal WHERE zid=@zid AND xyear=@year AND xper=@per AND xempcategory=@empcategory and xstatusjv='Confirmed')
			BEGIN
				PRINT 'Salary to General Ledger Voucher have been created for '+@empcategory
				GOTO CONT
			END	
			
			----------------------------------------------Salary Transaction Start---------------------------------------------
			IF (SELECT xstatus FROM pdballog WHERE zid=@zid AND xyear=@year AND xper=@per AND xempcategory=@empcategory)='Open'
			BEGIN
				DELETE FROM pdpayslip WHERE zid=@zid AND xyear=@year AND xper=@per AND xempcategory=@empcategory AND xstaff BETWEEN @fstaff AND @tstaff
			
		
				DECLARE cur_pdmst CURSOR FORWARD_ONLY FOR 
				SELECT xstaff, xdatejoin,DATEADD(d,-0,ISNULL(xenddate,'2099-01-01')),xempcategory,xgross
				FROM pdmst WHERE zid=@zid AND xempcategory = @empcategory AND xempstatus = 'Normal' 
				AND xdatejoin <= @edate AND DATEADD(d,-0,ISNULL(xenddate,'2099-01-01')) >= @sdate 
				AND xstaff BETWEEN @fstaff AND @tstaff

				OPEN cur_pdmst 
				FETCH FROM cur_pdmst INTO @staff, @DOJ ,@resigndate, @empcate, @grossamt
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					--============================ start date  ====================			
					IF DATEDIFF(DD,@DOJ,@sdate)<0 
						SET @startdate=@DOJ
					ELSE IF YEAR(@DOJ)=@year AND MONTH(@DOJ)=@per AND @DOJ<>@sdate
						SET @startdate=@DOJ
					ELSE IF @resigndate<@edate
						SET @startdate=@sdate
					ELSE SET @startdate=@sdate
					--======================= End of start date ==================

					--============================ end date  ====================
					IF @resigndate <= @edate SET @enddate = @resigndate
					ELSE SET @enddate = @edate
					--======================= End of end date ==================

					--======================= Employee wise Working day's count ==================
					IF DATEDIFF(DD,@DOJ,@sdate)<0
						SET @wdays=(DATEDIFF(DD,@DOJ,@enddate)+1)
					ELSE IF YEAR(@DOJ)=@year AND MONTH(@DOJ)=@per AND @DOJ<>@sdate
						SET @wdays=(DATEDIFF(DD,@DOJ,@enddate)+1)
					ELSE IF @resigndate<@edate
						SET @wdays=(DATEDIFF(DD,@sdate,@enddate)+1)
					ELSE SET @wdays=@noofday
					--======================= End of Employee wise Working day's count ==================

					--============================present days Count ===============	
					Select @presentdays = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus IN ('OD','Present','Late','Early Leave','Late & Early Leave')
					SET @presentdays = ISNULL(@presentdays,0)
					--=======================End of present days Count ==============
					
					--============================Weekend Count ==================	
					--Select @weekend = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus='Weekend'
					Select @weekend = count (distinct xdate) from pdweekendview WHERE zid = @zid AND xstaff = @staff AND cast(xdate as date) Between @startdate AND @enddate
					SET @weekend = ISNULL(@weekend,0)
					--=======================End of Weekend Count ==================

					--============================leave in day off Count ===============
					select @lvindayoff=COUNT(DISTINCT CAST(d.xdate AS DATE)) from pdleaveheader h join pdleavedetail d on h.zid=d.zid AND h.xyearperdate=d.xyearperdate
					where h.zid=@zid AND h.xstaff=@staff AND CAST(d.xdate as date) between @startdate AND @enddate and h.xstatus='Confirmed'
					--AND CAST(d.xdate as date) in (Select distinct CAST(w.xdate AS DATE) from pdweekendview w WHERE w.zid = h.zid AND w.xstaff = h.xstaff AND cast(w.xdate as date)=cast(d.xdate as date) and w.xhdaytype = 'Day Off')
					--=======================End of leave in day off Count =============

					--============================weekly day off Count ===============		
					--Select @weeklydayoff = count (distinct xdate) from pdweekendview WHERE zid = @zid AND xstaff = @staff AND cast(xdate as date) Between @startdate AND @enddate and xtypeholiday = 'Day Off'
					Select @weeklydayoff = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Weekend' --AND  xdayname='Friday'
					SET @weeklydayoff = ISNULL(@weeklydayoff,0)
					--=======================End of weekly day off Count =============

					--============================leave in holiday Count ===============
					select @lvinholiday=COUNT(DISTINCT CAST(d.xdate AS DATE)) from pdleaveheader h join pdleavedetail d on h.zid=d.zid AND h.xyearperdate=d.xyearperdate
					where h.zid=@zid AND h.xstaff=@staff AND CAST(d.xdate as date) between @startdate AND @enddate and h.xstatus='Confirmed'
					--AND CAST(d.xdate as date) in (Select distinct CAST(w.xdate AS DATE) from pdweekendview w WHERE w.zid = h.zid AND w.xstaff = h.xstaff AND cast(w.xdate as date)=cast(d.xdate as date) and w.xhdaytype = 'Holiday')
					--=======================End of leave in holiday Count =============

					--============================weekly holiday days Count Declared==========	
					--Select @weeklyhday = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate  AND xstatus ='Weekend' AND xdayname<>'Friday'
					Select @weeklyhday = count (distinct xdate) from pdweekendview WHERE zid = @zid AND xstaff = @staff AND cast(xdate as date) Between @startdate AND @enddate AND xstatus ='Weekend' --and xtypeholiday = ('Holiday')
					SET @weeklyhday = ISNULL(@weeklyhday,0)
					--=======================End of weekly holiday days Count ========

					--============================weekly Festival holiday days Count==========	
					--Select @weeklyfestivalhday = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate  AND xstatus ='Weekend' AND xdayname<>'Friday'
					Select @weeklyfestivalhday = count (distinct xdate) from pdweekendview WHERE zid = @zid AND xstaff = @staff AND cast(xdate as date) Between @startdate AND @enddate AND xnote  in ('Festival Holiday','Eid-Ul-Adha','Eid-Ul-Adha-Hindu','Eid-Ul-Adha-Christian') --and xtypeholiday = 'Festival Holiday'
					SET @weeklyfestivalhday = ISNULL(@weeklyfestivalhday,0)
					--=======================End of weekly Festival holiday days Count ========

					--============================weekly Others holiday days Count ==========
					Select @weeklyotherhday = count (distinct xdate) from pdweekendview WHERE zid = @zid AND xstaff = @staff AND cast(xdate as date) Between @startdate AND @enddate  --and xtypeholiday not in ('Day Off','Holiday','Festival Holiday')
					SET @weeklyotherhday = ISNULL(@weeklyotherhday,0)
					--=======================End of weekly Others holiday days Count ========

					--============================RL days Count ====================
					Select @replv = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Replacement Leave'
					SET @replv = ISNULL(@replv,0)
					--=======================End of RL days Count ==================
					
					--============================LWP hours Count ====================
					--SELECT @lwphours=ISNULL(SUM(CASE WHEN DATEDIFF(MINUTE,d.xdate,d.xdateto)>480 THEN 480 ELSE DATEDIFF(MINUTE,d.xdate,d.xdateto) END)/60.0,0)
					--	FROM pdleavedetail d JOIN pdleaveheader h ON d.zid=h.zid AND d.xyearperdate=h.xyearperdate
					--	WHERE h.zid=@zid AND h.xstaff=@staff AND CAST(d.xdate AS DATE) BETWEEN @startdate AND @enddate AND h.xtypeleave='Leave Without Pay' AND xstatus='Confirmed'
					--SET @lwphours = ISNULL(@lwphours,0)
					--=======================End of LWP hours Count ==================

					--============================SL hours Count ====================
					/*****DayWise***/
					Select @sicklvhours = count (distinct xdate) from pdleaveheader WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Sick Leave'
					/*****HourWise
					SELECT @sicklvhours=ISNULL(SUM(CASE WHEN DATEDIFF(MINUTE,d.xdate,d.xdateto)>480 THEN 480 ELSE DATEDIFF(MINUTE,d.xdate,d.xdateto) END)/60.0,0)
						FROM pdleavedetail d JOIN pdleaveheader h ON d.zid=h.zid AND d.xyearperdate=h.xyearperdate
						WHERE h.zid=@zid AND h.xstaff=@staff AND CAST(d.xdate AS DATE) BETWEEN @startdate AND @enddate AND h.xtypeleave='Sick Leave' AND xstatus='Confirmed'*/
					SET @sicklvhours = ISNULL(@sicklvhours,0)
					--=======================End of SL hours Count ==================

					--============================Absent Deduction ====================
					--select  @dayssalded=isnull(xdayssalded,0)  from pdtrndetail where xtype='Absent Deduction' and xstaff=@staff and year(ztime)=@year and month(ztime)=@per
					--SET @dayssalded = ISNULL(@dayssalded,0)

					SELECT @dayssalded=isnull(Max(d.xdayssalded),0) FROM pdtrnheader h 
					INNER JOIN pdtrndetail d ON h.zid=d.zid AND h.xyear=@year and h.xper=@per and h.xvoucher=d.xvoucher
					WHERE h.zid=@zid AND h.xyear=@year AND h.xper=@per and d.xstaff=@staff and d.xtype='Absent Deduction' and xsign<0 --Group by d.xdayssalded
					SET @dayssalded = ISNULL(@dayssalded,0)
					
					--============================CL days Count ====================
					Select @cl = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Casual Leave'
					SET @cl = ISNULL(@cl,0)
					--============================Sicklvhours days Count ====================
					
					Select @sicklvhours = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Sick Leave'
					SET @sicklvhours = ISNULL(@sicklvhours,0)
					

					--============================EL days Count ====================
					Select @el = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Earned Leave'
					SET @el = ISNULL(@el,0)
					--=======================End of EL days Count ==================

					--============================ML days Count ====================
					Select @mlv = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Maternity Leave'
					SET @mlv = ISNULL(@mlv,0)
					--=======================End of ML days Count ==================

					--============================Night All days Count =============
					----Select @naday = count (distinct xdate) from pdattview WHERE zid = @zid AND xstaff = @staff AND xdate Between @startdate AND @enddate AND xstatus ='Earned Leave'
					--Select @naday=COUNT(distinct(CAST(a.xdate as date))) from pdattview a JOIN pdmst p ON a.zid=p.zid AND a.xstaff=p.xstaff
						--WHERE a.zid=@zid AND a.xstaff=@staff AND a.xdate BETWEEN @startdate AND @enddate AND p.xempcategory<>'Officer' and isnull(a.xstatus,'') in ('Weekend','Present','Late','OD','Late & Early Leave','Early Leave','Punch Inactive')
						--AND a.xshift in (select b.xcode from xcodes b where b.zid=@zid AND b.xtype='Shift' and xshiftmode='Night')
						--Check that worktime not less than '06:00:00' --shift wise worktime
						--AND a.xworktime>='06:00:00' --CAST(CONCAT(CASE WHEN LEN(left(s.xwrkhours,LEN(s.xwrkhours)-CHARINDEX('.', REVERSE(s.xwrkhours))))=1 then CONCAT('0',left(s.xwrkhours,LEN(s.xwrkhours)-CHARINDEX('.', REVERSE(s.xwrkhours)))) ELSE left(s.xwrkhours,LEN(s.xwrkhours)-CHARINDEX('.', REVERSE(s.xwrkhours))) END,':',RIGHT(s.xwrkhours,CASE WHEN CHARINDEX('.', REVERSE(s.xwrkhours))<>0 THEN CHARINDEX('.', REVERSE(s.xwrkhours))-1 ELSE 0 end),':00') AS TIME(0))
					--SET @naday = ISNULL(@naday,0)
					--=======================End of Night All days Count ===========*/

					--=======================Getting other amount ==================
					--SELECT @otheramt = SUM(xamount) FROM pdsalarydetail WHERE zid=@zid AND xstaff=@staff AND xtype<>'Basic' AND xsign>0
					SELECT @otheramt = SUM(xamount) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype 
					not in ('Basic','Bonus','House Rent','Medical Allowance','Transport Allowance','Skill Allowance','Dinner Allowance') AND xsign>0
					SET @otheramt = ISNULL(@otheramt,0)
		
					--=======================Getting Basic amount ==================
					SELECT @basicamt = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Basic'
					SET @basicamt = ISNULL(@basicamt,0)

					--=======================Getting House Rent amount ==================
					SELECT @hrentamt = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='House Rent'
					SET @hrentamt = ISNULL(@hrentamt,0)

					--=======================Getting Medical amount ==================
					SELECT @medamt = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Medical Allowance'
					SET @medamt = ISNULL(@medamt,0)

					--=======================Getting Transport Allowance amount ==================
					SELECT @transportaowance = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Transport Allowance'
					SET @transportaowance = ISNULL(@transportaowance,0) 

					--=======================Getting Food Allowance amount ==================
					SELECT @foodallowance = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Dinner Allowance'
					SET @foodallowance = ISNULL(@foodallowance,0) 

					--=======================Skill Allowance amount ==================
					SELECT @skillallowance = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Skill Allowance'
					SET @skillallowance = ISNULL(@skillallowance,0) 

					--=======================Getting Conveyance amount ==================
					SELECT @convamt =sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='Conveyance'
					SET @convamt = ISNULL(@convamt,0) 

					--=======================Getting Conveyance amount ==================
					SELECT @taxamt =sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper=@per AND xtype='IT'
					SET @taxamt = ISNULL(@taxamt,0) 
					--=======================Getting Other amount ==================
					SELECT @amtother=SUM(isnull(d.xamount,0)) FROM pdtrnheader h 
					INNER JOIN pdtrndetail d ON h.zid=d.zid AND h.xyear=@year and h.xper=@per and h.xvoucher=d.xvoucher
					WHERE h.zid=@zid AND h.xyear=@year AND h.xper=@per and d.xstaff=@staff and d.xtype not in 
					('Conveyance','Food Allowance','Transport Allowance','Medical','House Rent','Basic','OT') and xsign>0 
					SET @amtother = ISNULL(@amtother,0) 
					--=======================Getting Other Deductions amount ==================
					SELECT @otherdeduc=SUM(isnull(d.xamount,0)) FROM pdtrnheader h 
					INNER JOIN pdtrndetail d ON h.zid=d.zid AND h.xyear=@year and h.xper=@per and h.xvoucher=d.xvoucher
					WHERE h.zid=@zid AND h.xyear=@year AND h.xper=@per and d.xstaff=@staff and d.xtype not in 
					('Absent Deduction','Late Deduction','IT','Loan Deduction','Loan Interest','Mobile Bill','Salary Advance','Stamp') and xsign<0 
					SET @otherdeduc = ISNULL(@otherdeduc,0) 

					--=======================Getting Stamp amount ==================
					SELECT @stamp = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xtype='Stamp Charge' AND xyear=@year And xper=@per
					SET @stamp = ISNULL(@stamp,0) 

					--=======================Getting Stamp amount ==================
					SELECT @absdedamt = sum(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xtype='Absent Deduction' AND xyear=@year And xper=@per
					SET @absdedamt = ISNULL(@absdedamt,0) 

					--=======================Getting OverTime amount ==================
					SELECT @othours=isnull(sum(d.xothours),0) FROM pdtrnheader h 
					INNER JOIN pdtrndetail d ON h.zid=d.zid AND h.xyear=@year and h.xper=@per and h.xvoucher=d.xvoucher
					WHERE h.zid=@zid AND h.xyear=@year AND h.xper=@per and d.xstaff=@staff and d.xtype='OT' and xsign>0 
					SET @othours = ISNULL(@othours,0) 
					--=======================Getting OverTime Rate amount ==================
					SELECT @ratephr =isnull(((@basicamt/208)*2),0) -- FROM pdbal WHERE zid=@zid AND xstaff=@staff And xtype='OT' AND xyear=@year And xper=@per
					SET @ratephr = ISNULL(@ratephr,0) 
					--=======================Getting Arrear amount ==================
					SELECT @arrear = SUM(isnull(xarrear,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff And xtype='Arrear' AND xyear=@year And xper=@per
					SET @arrear = ISNULL(@arrear,0) 
					--=======================Getting Attendance Bonus amount ==================
					SELECT @attbon = SUM(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff And xtype='Attendance Bonus' AND xyear=@year And xper=@per
					SET @attbon = ISNULL(@attbon,0) 

					--=======================Getting Salary Advance amount ==================
					SELECT @saladv =SUM(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff And xtype='Salary Advance' AND xyear=@year And xper=@per
					SET @saladv = ISNULL(@saladv,0) 
					--=======================Getting Loan Deduction amount ==================
					SELECT @loanded =SUM(isnull(xamount,0)) FROM pdbal WHERE zid=@zid AND xstaff=@staff And xtype='Loan Deduction' AND xyear=@year And xper=@per
					SET @loanded = ISNULL(@loanded,0) 

					--==========Getting Current Loan Deduction amount ===============
					SELECT @pfloanpaid = isnull(xamount,0) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper = @per AND xtype in ('PF Loan')
					SET @pfloanpaid = ISNULL(@pfloanpaid,0)
		
					--=======================opening loan amount ==================
					SELECT @oploanamt = SUM(b.xschamt) FROM pdloantrn a JOIN pdloantrndt b
					ON a.zid=b.zid AND a.xvoucher=b.xvoucher WHERE a.zid=@zid AND  a.xstaff=@staff AND b.xdate>=@sdate
					AND a.xstatus IN ('Open','Continue') 
					AND b.xvoucher not in (SELECT xvoucher FROM pdloantrn a WHERE a.zid=@zid AND a.xstaff=@staff AND  a.xdate BETWEEN @sdate AND @edate
					AND a.xstatus IN ('Open','Continue'))
					SET @oploanamt = ISNULL(@oploanamt,0)
					--=======================end opening loan amount ==============

					--=======================opening loan amount ==================
					--SELECT @oploanamt2 = Isnull(SUM(isnull(xsettledamt,0)),0) FROM pdloantrn WHERE zid=@zid AND  xstaff=@staff AND xstatus IN ('Open','Continue') 
					--AND xvoucher in (SELECT xvoucher FROM pdloantrn WHERE zid=@zid AND xstaff=@staff AND xdate BETWEEN @sdate AND @edate AND xstatus IN ('Open','Continue'))
					--SET @oploanamt2 = ISNULL(@oploanamt2,0)
					--SET @oploanamt =@oploanamt+@oploanamt2
					--=======================end opening loan amount ==============

					--=======================current loan amount ==================
					SELECT @curloanamt = SUM(xloanamt) FROM pdloantrn WHERE zid=@zid AND xstaff=@staff AND   xdate BETWEEN @sdate AND @edate AND xstatus IN ('Open','Continue')
					SET @curloanamt = ISNULL(@curloanamt,0)

					--=======================Opening PF amount ==================
					--SELECT @oppfamt = sum(isnull(xprime,0)) FROM acbal WHERE zid=@zid AND xacc in ('21000101') AND xsub=@staff AND xyear=@year and xper =0
					--SET @oppfamt = ISNULL(@oppfamt,0)
					--IF @oppfamt <0 SET @oppfamt = 0 -(@oppfamt)  -- Provident Fund
					SELECT @oppfamt = SUM(xamount) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper = @per AND xtype='Provident Fund'
					SET @oppfamt = ISNULL(@oppfamt,0)

					--==========Getting This Year PF ===============
					SELECT @curpfamt = sum(isnull(xprime,0)) FROM acbal WHERE zid=@zid AND xacc in ('21000101') AND xsub=@staff AND xyear=@year and xper <> 0 AND xper < @per
					--isnull(xamount,0) FROM pdbal WHERE zid=@zid AND xstaff=@staff AND xyear=@year AND xper < @per AND xtype in ('PF','PF Subscription')
					SET @curpfamt = ISNULL(@curpfamt,0)
					IF @curpfamt <0 SET @curpfamt = 0 -(@curpfamt)

					--==========Getting Previous Year Interest ===============
					--SELECT @oppfint = sum(isnull(xprime,0)) FROM acbal WHERE zid=@zid AND xacc in ('21000101') AND xpfacctype in ('Subscription Interest') AND xper>0 AND xsub=@staff AND xyear=(@year-1)
					--SET @oppfint = ISNULL(@oppfint,0)
					--IF @oppfint <0 SET @oppfint = 0 -(@oppfint)

					--=======================Old Salary amount ==================
					--IF @per=1
					--BEGIN
					--SELECT @oldsalary=ISNULL((xbasic+xhrent+xtransport+xmedical+xfood),0)FROM pdpayslip WHERE zid=@zid AND xstaff=@staff  AND xyear=(@year-1) And xper=(select max(xper) from pdpayslip where xyear=(@year-1))
					--SET @oldsalary = ISNULL(@oldsalary,0) 
					--END
					--SELECT @oldsalary=ISNULL((xbasic+xhrent+xtransport+xmedical+xfood),0)FROM pdpayslip WHERE zid=@zid AND xstaff=@staff  AND xyear=@year And xper=(@per-1)
					--SET @oldsalary = ISNULL(@oldsalary,0) 
					Select @oldsalary = isnull(xgrossold,0.00) from pdpromodt where xstaff=@staff and xrow=(select MAX(xrow) from pdpromodt where xstaff=@staff and zid=@zid) and zid=@zid
					IF @oldsalary=0.00 SET @oldsalary=(select isnull(xgross,0.00) from pdmst where xstaff=@staff and zid=@zid)

					--=======================END Old Salary amount ==================(@wdays-@weekend)+@lvinholiday//--(@wdays-(@weeklydayoff)) --+@sicklvhours+@cl
					
						INSERT INTO pdpayslip(ztime,zauserid,zid,xyear,xper,xstaff,xempcategory,xbasic,xhrent,xmedical,xconveyance,xtransport,xfood,xamount,xabsded,xattbon,xsaladv,xamtother,xarrear,xabsdedamt,xtaxamt,xotherdeduc,
											xoploanamt,xloanamt,xclloanamt,xoppfamount,xoppfint,xpfamount,
											xstartdate,xenddate,xdaywork,xwdays,xpdays,xhday,xdechdays,xfestivalhdays,
											xsuspend,xreplv,xlwphr,xsickleave,xcl,xel,xmlv,xothours,xratephr,xnadays,xnote,xoldsalary,xstamp,xskill)
						VALUES(GETDATE(),@user,@zid,@year,@per,@staff,@empcategory,@basicamt,@hrentamt,@medamt,@convamt,@transportaowance,@foodallowance,@otheramt,@dayssalded,@attbon,(@saladv+@loanded),@amtother,@arrear,@absdedamt,@taxamt,@otherdeduc,
											@oploanamt,@curloanamt,(CASE WHEN ((@oploanamt+@curloanamt)-@pfloanpaid) < 0 THEN 0 ELSE ((@oploanamt+@curloanamt)-@pfloanpaid) END),0,@oppfint,@oppfamt,
											@startdate,@enddate,@noofday,(@wdays-(@weeklydayoff)),(@presentdays+@replv),@weeklydayoff,(@weeklyhday+@weeklyfestivalhday+@weeklyotherhday)-@lvinholiday,@weeklyfestivalhday,
											0,@replv,@lwphours,@sicklvhours,@cl,@el,@mlv,@othours,@ratephr,@naday,@note,@oldsalary,@stamp,@skillallowance)
											

		
					SET @cl = 0
					SET @naday = 0	
					SET @weeklyhday = 0  
					SET @weekend = 0
					SET @wdays = 0
					SET @basicamt = 0 
					SET @hrentamt = 0
					SET @convamt = 0
					SET @medamt = 0 
					SET @grossamt = 0
					SET @otheramt = 0
					SET @oploanamt = 0
					SET @oploanamt2 = 0
					SET @curloanamt = 0
					SET @oppfamt = 0
					SET @curpfamt = 0
					SET @pfloanpaid = 0
					SET @oppfint = 0
					SET @lvindayoff = 0
					SET @lvinholiday = 0

					SET @transportaowance =0 
					SET @foodallowance=0
					SET @othours = 0					
					SET @ratephr =0                       
					SET @dayssalded = 0
					SET @attbon =0							
					SET	@saladv =0	
					SET @oldsalary =0
					SET @stamp =0
					SET @amtother =0	
					SET @arrear = 0	
					SET @taxamt = 0
					
				FETCH NEXT FROM cur_pdmst INTO @staff, @DOJ ,@resigndate, @empcate, @grossamt
				END
				CLOSE cur_pdmst
				DEALLOCATE cur_pdmst
			END

			CONT:
			--==============End Employee Category Looping=========
			FETCH NEXT FROM cur_empcat INTO @empcategory
		END
		CLOSE cur_empcat
		DEALLOCATE cur_empcat
