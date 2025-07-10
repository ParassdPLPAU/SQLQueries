SELECT          *, (
                CASE
                                WHEN stp.exception = '' THEN
                                                CASE
                                                                WHEN stp.spr = stp.stockingtype_c THEN 'N'
                                                                ELSE 'Y'
                                                END
                                ELSE
                                                CASE
                                                                WHEN stp.stockingtype_c = stp.exception THEN 'N'
                                                                ELSE 'Y'
                                                END
                END) AS changeyn , (
                CASE
                                WHEN stp.salesmonth > 10 THEN stp.service95
                                WHEN stp.salesmonth > 8 THEN stp.service90
                                WHEN stp.salesmonth > 6 THEN stp.service85
                                WHEN stp.salesmonth > 2 THEN Ceiling(stp.large3)
                                ELSE 0
                END) AS suggestsafety , (
                CASE
                                WHEN stp.salesmonth > 10 THEN stp.service95
                                WHEN stp.salesmonth > 8 THEN stp.service90
                                WHEN stp.salesmonth > 6 THEN stp.service85
                                WHEN stp.salesmonth > 2 THEN Ceiling(stp.large3)
                                ELSE 0
                END * stp.totavgcost) AS suggestedss , ((
                CASE
                                WHEN stp.salesmonth > 10 THEN stp.service95
                                WHEN stp.salesmonth > 8 THEN stp.service90
                                WHEN stp.salesmonth > 6 THEN stp.service85
                                WHEN stp.salesmonth > 2 THEN Ceiling(stp.large3)
                                ELSE 0
                END * stp.totavgcost) - stp.currentss) AS change ,
                (stp.safetyqty1 - (
                CASE
                                WHEN stp.salesmonth > 10 THEN stp.service95
                                WHEN stp.salesmonth > 8 THEN stp.service90
                                WHEN stp.salesmonth > 6 THEN stp.service85
                                WHEN stp.salesmonth > 2 THEN Ceiling(stp.large3)
                                ELSE 0
                END)) AS ssreduction , (
                CASE
                                WHEN ((
                                                                                CASE
                                                                                                WHEN stp.sourcetype = 'P' THEN stp.leadtime
                                                                                                ELSE 42
                                                                                END) * (stp.total / 360)) = 0 THEN 1
                                ELSE (
                                                CASE
                                                                WHEN stp.salesmonth > 10 THEN stp.service95
                                                                WHEN stp.salesmonth > 8 THEN stp.service90
                                                                WHEN stp.salesmonth > 6 THEN stp.service85
                                                                WHEN stp.salesmonth > 2 THEN Ceiling(stp.large3)
                                                                ELSE 0
                                                END) / ((
                                                CASE
                                                                WHEN stp.sourcetype = 'P' THEN stp.leadtime
                                                                ELSE 42
                                                END) * (stp.total / 360))
                END) AS ssl1 ,
                p11.mtlanalysiscode ,
                Isnull(pw11.onhandqty,0) AS onhandqty ,
                Isnull(pw11.demandqty,0) AS demandqty,
                y.unconfirmedjobsqty,
                y.orderqty,
                y.intransit,
                y.intransit * stp.totavgcost AS intransitval ,
                y.duedate,
                y.docunitcost,
                y.currencycode,
                Isnull(pw11.onhandqty,0) * stp.totavgcost AS totalavgcost,
                Isnull(pw11.onhandqty,0) * y.standardcost AS totalstdcost,
                y.orderdate,
                y.receiptdate,
                y.standardcost,
                y.unitcost,
                y.totalcost
FROM            (
                       SELECT tt1.*, (
                              CASE
                                     WHEN tt1.sourcetype = 'K' THEN ''
                                     ELSE
                                            CASE
                                                   WHEN tt1.sourcetype = 'M' THEN
                                                          CASE
                                                                 WHEN tt1.salesmonth < 3 THEN 'MTO'
                                                                 WHEN tt1.salesmonth < 7 THEN 'RP'
                                                                 ELSE 'MTS'
                                                          END
                                                   ELSE
                                                          CASE
                                                                 WHEN tt1.salesmonth < 3 THEN 'PTO'
                                                                 WHEN tt1.salesmonth < 7 THEN 'RP'
                                                                 ELSE 'PTS'
                                                          END
                                            END
                              END ) AS spr , (
                              CASE
                                     WHEN tt1.sourcetype = 'M' THEN
                                            CASE
                                                   WHEN tt1.stockingexception_c = 'AlwaysMTO' THEN 'MTO'
                                                   WHEN tt1.stockingexception_c = 'AlwaysRP' THEN 'RP'
                                                   WHEN tt1.stockingexception_c = 'Project' THEN 'MTO'
                                                   WHEN tt1.stockingexception_c = 'Contract' THEN 'RP'
                                                   ELSE ''
                                            END
                                     WHEN tt1.sourcetype = 'P' THEN
                                            CASE
                                                   WHEN tt1.stockingexception_c = 'AlwaysPTO' THEN 'PTO'
                                                   WHEN tt1.stockingexception_c = 'AlwaysRP' THEN 'RP'
                                                   WHEN tt1.stockingexception_c = 'Project' THEN 'PTO'
                                                   WHEN tt1.stockingexception_c = 'Contract' THEN 'RP'
                                                   ELSE ''
                                            END
                                     ELSE ''
                              END)                              AS exception ,
                              (tt1.safetyqty1 * tt1.totavgcost) AS currentss , (
                              CASE
                                     WHEN ((
                                                          CASE
                                                                 WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                                                 ELSE 42
                                                          END) * (tt1.total / 360)) = 0 THEN 1
                                     ELSE tt1.safetyqty1 / ((
                                            CASE
                                                   WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                                   ELSE 42
                                            END) * (tt1.total / 360))
                              END) AS csl ,
                              Ceiling(1.28 * (
                              CASE
                                     WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                     ELSE 42
                              END * (tt1.total / 360))) AS service90 ,
                              Ceiling(1.64 * (
                              CASE
                                     WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                     ELSE 42
                              END * (tt1.total / 360))) AS service95 ,
                              Ceiling(0.84 * (
                              CASE
                                     WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                     ELSE 42
                              END * (tt1.total / 360))) AS service85 ,
                              ((Ceiling(0.84 * (
                              CASE
                                     WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                     ELSE 42
                              END * (tt1.total / 360))) * tt1.totavgcost) - (tt1.safetyqty1 * tt1.totavgcost)) AS change85 ,
                              ((Ceiling(1.28 * (
                              CASE
                                     WHEN tt1.sourcetype = 'P' THEN tt1.leadtime
                                     ELSE 42
                              END * (tt1.total / 360))) * tt1.totavgcost) - (tt1.safetyqty1 * tt1.totavgcost)) AS change90
                       FROM   (
                                              SELECT          t2.partnum,
                                                              t2.partdescription,
                                                              t4.plant,
                                                              t2.calc_groupingwhsecode,
                                                              t4.sourcetype,
                                                              t1.supplymdc_c,
                                                              t4.buyerid,
                                                              t4.leadtime AS leadtime,
                                                              t4.minorderqty,
                                                              t5.vendorid ,
                                                              (t4.minimumqty + t4.safetyqty) AS safetyqty1,
                                                              t4.stockingexception_c ,
                                                              t4.stockingtype_c,
                                                              (t6.avgburdencost + t6.avglaborcost + t6.avgmaterialcost + t6.avgmtlburcost + t6.avgsubcontcost) AS totavgcost ,
                                                              t1.sellmdc_c,
                                                              t4.lqe_c,
                                                              t2.calc_bucket1,
                                                              t2.calc_bucket2,
                                                              t2.calc_bucket3,
                                                              t2.calc_bucket4,
                                                              t2.calc_bucket5,
                                                              t2.calc_bucket6,
                                                              t2.calc_bucket7,
                                                              t2.calc_bucket8,
                                                              t2.calc_bucket9,
                                                              t2.calc_bucket10,
                                                              t2.calc_bucket11,
                                                              t2.calc_bucket12 ,
                                                              (t2.calc_bucket1 + t2.calc_bucket2 + t2.calc_bucket3 + t2.calc_bucket4 + t2.calc_bucket5 + t2.calc_bucket6 + t2.calc_bucket7 + t2.calc_bucket8 + t2.calc_bucket9 + t2.calc_bucket10 + t2.calc_bucket11 + t2.calc_bucket12) AS total ,
                                                              Isnull(t7.large3,0)                                                                                                                                                                                                        AS large3 , (
                                                              CASE
                                                                              WHEN t2.calc_bucket1 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket2 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket3 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket4 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket5 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket6 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket7 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket8 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket9 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket10 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket11 <> 0 THEN 1
                                                                              ELSE 0
                                                              END +
                                                              CASE
                                                                              WHEN t2.calc_bucket12 <> 0 THEN 1
                                                                              ELSE 0
                                                              END)                                                       AS salesmonth ,
                                                              t3.calc_month1  + Format(Dateadd(m, -11, Getdate()), '-yy') AS m1,
                                                              t3.calc_month2  + Format(Dateadd(m, -10, Getdate()), '-yy') AS m2,
                                                              t3.calc_month3  + Format(Dateadd(m, -9, Getdate()), '-yy')  AS m3 ,
                                                              t3.calc_month4  + Format(Dateadd(m, -8, Getdate()), '-yy')  AS m4,
                                                              t3.calc_month5  + Format(Dateadd(m, -7, Getdate()), '-yy')  AS m5,
                                                              t3.calc_month6  + Format(Dateadd(m, -6, Getdate()), '-yy')  AS m6 ,
                                                              t3.calc_month7  + Format(Dateadd(m, -5, Getdate()), '-yy')  AS m7,
                                                              t3.calc_month8  + Format(Dateadd(m, -4, Getdate()), '-yy')  AS m8,
                                                              t3.calc_month9  + Format(Dateadd(m, -3, Getdate()), '-yy')  AS m9 ,
                                                              t3.calc_month10 + Format(Dateadd(m, -2, Getdate()), '-yy')  AS m10,
                                                              t3.calc_month11 + Format(Dateadd(m, -1, Getdate()), '-yy')  AS m11,
                                                              t3.calc_month12 + Format(Dateadd(m, 0, Getdate()), '-yy')   AS m12
                                              FROM            (
                                                                     SELECT p2.company,
                                                                            p2.acttransuom,
                                                                            p2.partdescription,
                                                                            p2.partnum,
                                                                            p2.um,
                                                                            p2.calc_bucket1,
                                                                            p2.calc_bucket2,
                                                                            p2.calc_bucket3,
                                                                            p2.calc_bucket4,
                                                                            p2.calc_bucket5,
                                                                            p2.calc_bucket6,
                                                                            p2.calc_bucket7 ,
                                                                            p2.calc_bucket8,
                                                                            p2.calc_bucket9,
                                                                            p2.calc_bucket10,
                                                                            p2.calc_bucket11,
                                                                            p2.calc_bucket12,
                                                                            p2.calc_groupingwhsecode,
                                                                            p2.calc_whsedesc
                                                                     FROM   parttran_" + Parameters!TableGuid.Value + " p2
                                                                     UNION
                                                                     SELECT     p1.company COLLATE         database_default,
                                                                                p1.ium COLLATE             database_default,
                                                                                p1.partdescription COLLATE database_default,
                                                                                p1.partnum COLLATE         database_default,
                                                                                p1.ium COLLATE             database_default ,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                ' 190'               AS whsecode,
                                                                                '190 Main Warehouse' AS whsedesc
                                                                     FROM       [PLP_LIVE].[dbo].[Part] p1
                                                                     INNER JOIN [PLP_LIVE].erp.partwhse pw1
                                                                     ON         pw1.partnum = p1.partnum
                                                                     WHERE      p1.inactive = 0
                                                                     AND        pw1.warehousecode = '190'
                                                                     AND        NOT p1.partnum COLLATE database_default IN
                                                                                (
                                                                                       SELECT partnum
                                                                                       FROM   parttran_" + Parameters!TableGuid.Value + ")) T2
                                              LEFT OUTER JOIN part_" + Parameters!TableGuid.Value + " t1
                                              ON              t1.company = t2.company
                                              AND             t1.partnum = t2.partnum
                                              LEFT JOIN       company_" + Parameters!TableGuid.Value + " t3
                                              ON              t2.company = t3.company
                                              LEFT JOIN       [PLP_LIVE].[dbo].[PartPlant] T4
                                              ON              t2.company = t4.company COLLATE database_default
                                              AND             t2.partnum = t4.partnum COLLATE database_default
                                              AND             Trim(t2.calc_groupingwhsecode) = t4.primwhse COLLATE database_default
                                              LEFT JOIN       [PLP_LIVE].[ERP].vendor T5
                                              ON              t4.vendornum = t5.vendornum
                                              LEFT JOIN       [PLP_LIVE].[Erp].[PartCost] T6
                                              ON              t2.company = t6.company COLLATE database_default
                                              AND             t2.partnum = t6.partnum COLLATE database_default
                                              LEFT JOIN
                                                              (
                                                                     SELECT partnum,
                                                                            large3
                                                                     FROM   (
                                                                                     SELECT   Row_number() OVER(partition BY partnum ORDER BY partnum, value DESC) AS r1,
                                                                                              partnum,
                                                                                              value AS large3
                                                                                     FROM     (
                                                                                                     SELECT partnum,
                                                                                                            val1,
                                                                                                            value
                                                                                                     FROM   (
                                                                                                                   SELECT partnum,
                                                                                                                          calc_bucket1,
                                                                                                                          calc_bucket2,
                                                                                                                          calc_bucket3,
                                                                                                                          calc_bucket4,
                                                                                                                          calc_bucket5,
                                                                                                                          calc_bucket6,
                                                                                                                          calc_bucket7,
                                                                                                                          calc_bucket8,
                                                                                                                          calc_bucket9,
                                                                                                                          calc_bucket10,
                                                                                                                          calc_bucket11,
                                                                                                                          calc_bucket12
                                                                                                                   FROM   parttran_" + Parameters!TableGuid.Value + ") TT UNPIVOT (value FOR val1 IN (calc_bucket1,
                                                                                                                                                                                                      calc_bucket2,
                                                                                                                                                                                                      calc_bucket3,
                                                                                                                                                                                                      calc_bucket4,
                                                                                                                                                                                                      calc_bucket5,
                                                                                                                                                                                                      calc_bucket6,
                                                                                                                                                                                                      calc_bucket7,
                                                                                                                                                                                                      calc_bucket8,
                                                                                                                                                                                                      calc_bucket9,
                                                                                                                                                                                                      calc_bucket10,
                                                                                                                                                                                                      calc_bucket11,
                                                                                                                                                                                                      calc_bucket12)) AS u ) AS tbl ) AS l3
                                                                     WHERE  r1 = 3) T7
                                              ON              t2.partnum = t7.partnum
                                              WHERE           Trim(t2.calc_groupingwhsecode) = '190' ) TT1 ) stp
LEFT JOIN       [PLP_LIVE].[dbo].[Part] p11
ON              stp.partnum = p11.partnum
LEFT JOIN       [PLP_LIVE].erp.partwhse pw11
ON              pw11.partnum = p11.partnum
AND             pw11.warehousecode = '190'
LEFT OUTER JOIN
                (
                                SELECT          xxx.*,
                                                yyy.orderqty,
                                                yyy.duedate,
                                                zzz.standardcost,
                                                bbb.intransit,
                                                eee.unconfirmedjobsqty
                                FROM            (
                                                       SELECT xx.partnum,
                                                              xx.receiptdate,
                                                              xx.docunitcost,
                                                              xx.unitcost,
                                                              xx.totalcost,
                                                              xx.orderdate,
                                                              xx.currencycode
                                                       FROM   (
                                                                              SELECT          a1.partnum,
                                                                                              CONVERT( varchar(10), a.receiptdate,103) AS receiptdate,
                                                                                              c.docunitcost,
                                                                                              c.unitcost,
                                                                                              c.unitcost * c.orderqty                 AS totalcost,
                                                                                              CONVERT( varchar(10), d.orderdate, 103) AS orderdate,
                                                                                              d.currencycode,
                                                                                              row_number() OVER ( partition BY a1.partnum ORDER BY d.orderdate DESC ) row_num
                                                                              FROM            [PLP_LIVE].erp.part a1
                                                                              LEFT OUTER JOIN [PLP_LIVE].erp.rcvdtl a
                                                                              ON              a.company = a1.company
                                                                              AND             a.partnum = a1.partnum
                                                                              LEFT OUTER JOIN [PLP_LIVE].erp.rcvhead b
                                                                              ON              a.packslip = b.packslip
                                                                              AND             a.company = b.company
                                                                              AND             a.purpoint = b.purpoint
                                                                              AND             a.vendornum = b.vendornum
                                                                              LEFT OUTER JOIN [PLP_LIVE].erp.podetail c
                                                                              ON              a.ponum = c.ponum
                                                                              AND             a.poline = c.poline
                                                                              AND             b.company = c.company
                                                                              LEFT OUTER JOIN [PLP_LIVE].erp.poheader d
                                                                              ON              c.ponum = d.ponum
                                                                              AND             c.company = d.company ) xx
                                                       WHERE  row_num=1 ) xxx
                                LEFT OUTER JOIN
                                                (
                                                           SELECT     b.partnum,
                                                                      sum(xrelqty - arrivedqty) AS orderqty,
                                                                      min(d.duedate)            AS duedate
                                                           FROM       [PLP_LIVE].erp.poheader a
                                                           INNER JOIN [PLP_LIVE].erp.podetail b
                                                           ON         a.ponum = b.ponum
                                                           AND        a.company = b.company
                                                           INNER JOIN [PLP_LIVE].erp.partdtl c
                                                           ON         a.company = c.company
                                                           AND        a.ponum = c.ponum
                                                           AND        b.poline = c.poline
                                                           AND        b.partnum = c.partnum
                                                           INNER JOIN [PLP_LIVE].erp.porel d
                                                           ON         a.company = d.company
                                                           AND        a.ponum = d.ponum
                                                           AND        c.poline = d.poline
                                                           AND        c.porelnum = d.porelnum
                                                           AND        c.plant = d.plant
                                                           WHERE      a.openorder =1
                                                           AND        d.plant IN
                                                                      (
                                                                             SELECT plant
                                                                             FROM   [PLP_LIVE].erp.warehse
                                                                             WHERE  warehousecode ='190')
                                                           AND        c.type ='Mtl'
                                                           GROUP BY   b.partnum ) yyy
                                ON              xxx.partnum = yyy.partnum
                                LEFT OUTER JOIN
                                                (
                                                       SELECT partnum,
                                                              stdburdencost + stdlaborcost + stdmaterialcost + stdmtlburcost + stdsubcontcost AS standardcost
                                                       FROM   [PLP_LIVE].erp.partcost )zzz
                                ON              xxx.partnum = zzz.partnum
                                LEFT OUTER JOIN
                                                (
                                                                SELECT          partdtl.partnum,
                                                                                sum(
                                                                                CASE
                                                                                                WHEN porel.xrelqty >= 0 THEN porel.xrelqty
                                                                                                ELSE 0
                                                                                END)                   AS intransit
                                                                FROM            [PLP_LIVE].erp.partdtl AS partdtl
                                                                LEFT OUTER JOIN [PLP_LIVE].erp.porel   AS porel
                                                                ON              partdtl.company = porel.company
                                                                AND             partdtl.ponum = porel.ponum
                                                                AND             partdtl.poline = porel.poline
                                                                AND             partdtl.porelnum = porel.porelnum
                                                                AND             partdtl.plant = porel.plant
                                                                AND             (
                                                                                                porel.containerid <> 0
                                                                                AND             porel.containerid IS NOT NULL )
                                                                AND             porel.plant IN
                                                                                (
                                                                                       SELECT plant
                                                                                       FROM   [PLP_LIVE].erp.warehse
                                                                                       WHERE  warehousecode ='190')
                                                                WHERE           partdtl.type ='Mtl'
                                                                GROUP BY        partdtl.partnum )bbb
                                ON              xxx.partnum = bbb.partnum
                                LEFT OUTER JOIN
                                                (
                                                         SELECT   partnum,
                                                                  sum(requiredqty) AS unconfirmedjobsqty
                                                         FROM     [PLP_LIVE].erp.jobmtl
                                                         WHERE    jobnum LIKE 'U%'
                                                         GROUP BY partnum )eee
                                ON              xxx.partnum = eee.partnum ) y
ON              stp.partnum = y.partnum