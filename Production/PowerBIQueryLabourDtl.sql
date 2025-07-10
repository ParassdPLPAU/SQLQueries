SELECT          [SubHoursAvail].[Calculated_YPayrolldate]  AS [Calculated_YPayrolldate],
                [SubHoursAvail].[Calculated_MPayrolldate]  AS [Calculated_MPayrolldate],
                [SubHoursAvail].[Calculated_HoursAvail]    AS [Calculated_HoursAvail],
                [SubHoursAvail].[OT1_c]                    AS ot1_c,
                [SubHoursAvail].[OT2_c]                    AS ot2_c,
                [SubHoursAvail].[RegTime_c]                AS regtime_c,
                [SubProdHours].[Calculated_SumEarnedProd]  AS [Calculated_SumEarnedProd],
                [SubProdHours].[Calculated_SumEarnedSetup] AS [Calculated_SumEarnedSetup],
                [SubProdHours].[Calculated_SumLoggedProd]  AS [Calculated_SumLoggedProd],
                [SubProdHours].[Calculated_SumLoggedSetup] AS [Calculated_SumLoggedSetup],
                [SubProdHours].[LaborDtl_Company]          AS company,
                [SubProdHours].[PayrollDate]               AS payrolldate,
                [SubProdHours].[ProductionHrs]             AS productionhrs,
                [SubProdHours].[GrossEarnedHours]          AS grossearnedhours,
                [SubProdHours].[DspClockInTime]            AS dspclockintime,
                [SubProdHours].[DspClockOutTime]           AS dspclockouttime,
                [SubProdHours].[EarnedHrs]                 AS earnedhrs,
                [SubProdHours].[LaborHrs]                  AS laborhrs,
                [SubProdHours].[LaborType]                 AS labortype,
                [SubProdHours].[JCDept]                    AS jcdept
FROM            (
                           SELECT     [UD01].[Company]                        AS [UD01_Company],
                                      (CONVERT(NVARCHAR(6),ud01.date01, 112)) AS [Calculated_MappingKey],
                                      (Ltrim(Rtrim(Year(ud01.date01))))       AS [Calculated_YPayrolldate],
                                      (Ltrim(Rtrim(Month(ud01.date01))))      AS [Calculated_MPayrolldate],
                                      Sum(ud01.ot1_c)                         AS ot1_c,
                                      Sum(ud01.ot2_c)                         AS ot2_c,
                                      Sum(ud01.regtime_c)                     AS regtime_c,
                                      (Sum(
                                      CASE
                                                 WHEN ud01.acttime_c = 0 THEN 0
                                                 WHEN ud01.ot1_c <> 0 THEN 0 #(lf)
                                                 WHEN ud01.ot2_c <> 0 THEN 0
                                                 WHEN (
                                                                       Datepart(weekday,date01) = 1
                                                            OR         Datepart(weekday,date01) = 7)
                                                 AND        ud01.number01 > 6.05 THEN 0
                                                 WHEN (
                                                                       Datepart(weekday,date01) = 6
                                                            AND        (
                                                                                  ud01.number01 > jcshift.fridaystarttime_c )) THEN 0
                                                 ELSE
                                                            CASE
                                                                       WHEN (
                                                                                             Datepart(weekday,date01) = 6 ) THEN (jcshift.fridayendtime_c - jcshift.fridaystarttime_c)
                                                                       ELSE (jcshift.endtime                                                              - jcshift.starttime)
                                                            END
                                      END))        AS [Calculated_HoursAvail]
                           FROM       dbo.ud01     AS ud01
                           INNER JOIN erp.empbasic AS empbasic
                           ON         ud01.company = empbasic.company
                           AND        ud01.key1 = empbasic.empid
                           INNER JOIN ice.udcodes AS udcodes
                           ON         ud01.company = udcodes.company
                           AND        ud01.shortchar03 = udcodes.codeid
                           INNER JOIN dbo.jcshift AS jcshift
                           ON         ud01.company = jcshift.company
                           AND        ud01.number02 = jcshift.shift
                           WHERE      (
                                                 ud01.date01 >= Dateadd(month, -11, Getdate()))
                           GROUP BY   [UD01].[Company],
                                      (CONVERT(NVARCHAR(6),ud01.date01, 112)),
                                      (Ltrim(Rtrim(Year(ud01.date01)))),
                                      (Ltrim(Rtrim(Month(ud01.date01))))) AS subhoursavail
LEFT OUTER JOIN
                (
                           SELECT     [LaborDtl].[Company]                             AS [LaborDtl_Company],
                                      labordtl.payrolldate                             AS payrolldate,
                                      labordtl.labortype                               AS labortype,
                                      labordtl.jcdept                                  AS jcdept,
                                      Sum(labordtl.earnedhrs)                          AS earnedhrs,
                                      Sum(labordtl.laborhrs)                           AS laborhrs,
                                      (CONVERT(NVARCHAR(6),labordtl.payrolldate, 112)) AS [Calculated_KeyMap],
                                      (Ltrim(Rtrim(Year(labordtl.payrolldate))))       AS [Calculated_YYPayrolldate],
                                      (Ltrim(Rtrim(Month(labordtl.payrolldate))))      AS [Calculated_MMPayrolldate],
                                      (sum(
                                      CASE
                                                 WHEN labordtl.labortype = 'P' THEN #(lf) #(tab)#(tab)#(tab)
                                                            case
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 1
                                                                                  OR         datepart(weekday,labordtl.payrolldate) = 7)
                                                                       AND        labordtl.clockintime > 6.05 THEN 0
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 6
                                                                                  AND        (
                                                                                                        labordtl.clockintime > jcshift1.fridaystarttime_c )) THEN 0 
                                                                       ELSE labordtl.earnedhrs
                                                            END #(lf)
                                                 ELSE 0
                                      END)) AS [Calculated_SumEarnedProd],
                                      (sum(
                                      CASE
                                                 WHEN labordtl.labortype = 'S' THEN 
                                                            CASE
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 1
                                                                                  OR         datepart(weekday,labordtl.payrolldate) = 7)
                                                                       AND        labordtl.clockintime > 6.05 THEN 0
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 6
                                                                                  AND        (
                                                                                                        labordtl.clockintime > jcshift1.fridaystarttime_c )) THEN 0 
                                                                       ELSE labordtl.earnedhrs
                                                            END #(lf)
                                                 ELSE 0
                                      END)) AS [Calculated_SumEarnedSetup],
                                      (sum(
                                      CASE
                                                 WHEN labordtl.labortype = 'P' THEN 
                                                            CASE
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 1
                                                                                  OR         datepart(weekday,labordtl.payrolldate) = 7)
                                                                       AND        labordtl.clockintime > 6.05 THEN 0
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 6
                                                                                  AND        (
                                                                                                        labordtl.clockintime > jcshift1.fridaystarttime_c )) THEN 0 
                                                                       ELSE labordtl.laborhrs
                                                            END #(lf)
                                                 ELSE 0
                                      END)) AS [Calculated_SumLoggedProd],
                                      (sum(
                                      CASE
                                                 WHEN labordtl.labortype = 'S' THEN 
                                                            CASE
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 1
                                                                                  OR         datepart(weekday,labordtl.payrolldate) = 7)
                                                                       AND        labordtl.clockintime > 6.05 THEN 0
                                                                       WHEN (
                                                                                             datepart(weekday,labordtl.payrolldate) = 6
                                                                                  AND        (
                                                                                                        labordtl.clockintime > jcshift1.fridaystarttime_c )) THEN 0 
                                                                       ELSE labordtl.laborhrs
                                                            END 
                                                 ELSE 0
                                      END)) AS [Calculated_SumLoggedSetup],
                                      
                                      CASE
                                                 WHEN labordtl.payrolldate >= '2022-03-01'
                                                 AND        labordtl.labortype='P' THEN labordtl.laborhrs
                                                 ELSE 0
                                      END) AS productionhrs,
                                      
                                      CASE
                                                 WHEN labordtl.payrolldate >= '2022-03-01'
                                                 AND        labordtl.labortype='P'
                                                 AND        labordtl.jcdept <>'WHOUSE' THEN labordtl.laborhrs
                                                 ELSE 0
                                      END)                           AS grossearnedhours,
                                      labordtl.dspclockintime  AS dspclockintime,
                                      labordtl.dspclockouttime AS dspclockouttime
                           FROM       erp.labordtl                   AS labordtl
                           INNER JOIN erp.empbasic                   AS empbasic1
                           ON         labordtl.company = empbasic1.company
                           AND        labordtl.employeenum = empbasic1.empid
                           INNER JOIN dbo.jcshift AS jcshift1
                           ON         labordtl.company = jcshift1.company
                           AND        labordtl.shift = jcshift1.shift
                           WHERE      (
                                                 labordtl.payrolldate >= dateadd(month, -11, getdate())
                                      AND        labordtl.labortype <> 'I'
                                      AND        labordtl.laborhrs > 0)
                           GROUP BY   [LaborDtl].[Company],
                                      labordtl.payrolldate,
                                      labordtl.dspclockintime,
                                      labordtl.dspclockouttime,
                                      labordtl.labortype,
                                      (CONVERT(nvarchar(6),labordtl.payrolldate, 112)),
                                      (ltrim(rtrim(year(labordtl.payrolldate)))),
                                      (ltrim(rtrim(month(labordtl.payrolldate))))) AS subprodhours
ON              subhoursavail.ud01_company = subprodhours.labordtl_company
AND             subhoursavail.calculated_mappingkey = subprodhours.calculated_keymap