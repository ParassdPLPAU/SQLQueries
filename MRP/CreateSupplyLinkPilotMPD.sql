USE [PLP_PowerBI]
GO

/****** Object:  View [dbo].[OrderSupplyLink_9L]    Script Date: 23/09/2024 10:03:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[OrderSupplyLink_9L_PILOT]
AS
SELECT        TOP (100) PERCENT PegDmdMst.DemandType AS PegDmdMst_DemandType, PegDmdMst.DemandOrdNum AS PegDmdMst_DemandOrdNum, PegDmdMst.DemandOrdLine AS PegDmdMst_DemandOrdLine, 
                         PegDmdMst.DemandOrdRel AS PegDmdMst_DemandOrdRel, PegDmdMst.PartNum AS PegDmdMst_PartNum, PegDmdMst.DemandDate AS PegDmdMst_DemandDate, 
                         PegSupMst.SupplyType AS PegSupMst_SupplyType, PegSupMst.SupplyOrdNum AS PegSupMst_SupplyOrdNum, PegSupMst.SupplyOrdLine AS PegSupMst_SupplyOrdLine, 
                         PegSupMst.SupplyOrdRel AS PegSupMst_SupplyOrdRel, PegSupMst.SupplyDate AS PegSupMst_SupplyDate, PegSupMst1.SupplyType AS PegSupMst1_SupplyType, 
                         PegSupMst1.PartNum AS PegSupMst1_PartNum, PegSupMst1.SupplyOrdNum AS PegSupMst1_SupplyOrdNum, PegSupMst1.SupplyOrdLine AS PegSupMst1_SupplyOrdLine, 
                         PegSupMst1.SupplyOrdRel AS PegSupMst1_SupplyOrdRel, PegSupMst1.SupplyDate AS PegSupMst1_SupplyDate, PegSupMst2.SupplyType AS PegSupMst2_SupplyType, 
                         PegSupMst2.PartNum AS PegSupMst2_PartNum, PegSupMst2.SupplyOrdNum AS PegSupMst2_SupplyOrdNum, PegSupMst2.SupplyOrdLine AS PegSupMst2_SupplyOrdLine, 
                         PegSupMst2.SupplyOrdRel AS PegSupMst2_SupplyOrdRel, PegSupMst2.SupplyDate AS PegSupMst2_SupplyDate, PegSupMst3.SupplyType AS PegSupMst3_SupplyType, 
                         PegSupMst3.PartNum AS PegSupMst3_PartNum, PegSupMst3.SupplyOrdNum AS PegSupMst3_SupplyOrdNum, PegSupMst3.SupplyOrdLine AS PegSupMst3_SupplyOrdLine, 
                         PegSupMst3.SupplyOrdRel AS PegSupMst3_SupplyOrdRel, PegSupMst3.SupplyDate AS PegSupMst3_SupplyDate, PegSupMst4.SupplyType AS PegSupMst4_SupplyType, 
                         PegSupMst4.PartNum AS PegSupMst4_PartNum, PegSupMst4.SupplyOrdNum AS PegSupMst4_SupplyOrdNum, PegSupMst4.SupplyOrdLine AS PegSupMst4_SupplyOrdLine, 
                         PegSupMst4.SupplyOrdRel AS PegSupMst4_SupplyOrdRel, PegSupMst4.SupplyDate AS PegSupMst4_SupplyDate, PegSupMst5.SupplyType AS PegSupMst5_SupplyType, 
                         PegSupMst5.PartNum AS PegSupMst5_PartNum, PegSupMst5.SupplyOrdNum AS PegSupMst5_SupplyOrdNum, PegSupMst5.SupplyOrdLine AS PegSupMst5_SupplyOrdLine, 
                         PegSupMst5.SupplyOrdRel AS PegSupMst5_SupplyOrdRel, PegSupMst5.SupplyDate AS PegSupMst5_SupplyDate, PegSupMst6.SupplyType AS PegSupMst6_SupplyType, 
                         PegSupMst6.PartNum AS PegSupMst6_PartNum, PegSupMst6.SupplyOrdNum AS PegSupMst6_SupplyOrdNum, PegSupMst6.SupplyOrdLine AS PegSupMst6_SupplyOrdLine, 
                         PegSupMst6.SupplyOrdRel AS PegSupMst6_SupplyOrdRel, PegSupMst6.SupplyDate AS PegSupMst6_SupplyDate, PegSupMst7.SupplyType AS PegSupMst7_SupplyType, 
                         PegSupMst7.PartNum AS PegSupMst7_PartNum, PegSupMst7.SupplyOrdNum AS PegSupMst7_SupplyOrdNum, PegSupMst7.SupplyOrdLine AS PegSupMst7_SupplyOrdLine, 
                         PegSupMst7.SupplyOrdRel AS PegSupMst7_SupplyOrdRel, PegSupMst7.SupplyDate AS PegSupMst7_SupplyDate, PegSupMst8.SupplyType AS PegSupMst8_SupplyType, 
                         PegSupMst8.PartNum AS PegSupMst8_PartNum, PegSupMst8.SupplyOrdNum AS PegSupMst8_SupplyOrdNum, PegSupMst8.SupplyOrdLine AS PegSupMst8_SupplyOrdLine, 
                         PegSupMst8.SupplyOrdRel AS PegSupMst8_SupplyOrdRel, PegSupMst8.SupplyDate AS PegSupMst8_SupplyDate
FROM            PLP_PILOT.Erp.PegDmdMst AS PegDmdMst LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink ON PegDmdMst.Company = PegLink.Company AND PegDmdMst.Plant = PegLink.Plant AND PegDmdMst.PartNum = PegLink.PartNum AND 
                         PegDmdMst.DemandSeq = PegLink.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst ON PegLink.Company = PegSupMst.Company AND PegLink.Plant = PegSupMst.Plant AND PegLink.PartNum = PegSupMst.PartNum AND 
                         PegLink.SupplySeq = PegSupMst.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst1 ON PegSupMst.Company = PegDmdMst1.Company AND PegSupMst.Plant = PegDmdMst1.Plant AND PegSupMst.SupplyOrdNum = PegDmdMst1.DemandOrdNum AND 
                         PegSupMst.SupplyOrdLine = PegDmdMst1.DemandOrdLine AND NOT (PegDmdMst1.DemandOrdNum = '') AND NOT (PegDmdMst1.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink1 ON PegDmdMst1.Company = PegLink1.Company AND PegDmdMst1.Plant = PegLink1.Plant AND PegDmdMst1.PartNum = PegLink1.PartNum AND 
                         PegDmdMst1.DemandSeq = PegLink1.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst1 ON PegLink1.Company = PegSupMst1.Company AND PegLink1.Plant = PegSupMst1.Plant AND PegLink1.PartNum = PegSupMst1.PartNum AND 
                         PegLink1.SupplySeq = PegSupMst1.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst2 ON PegSupMst1.Company = PegDmdMst2.Company AND PegSupMst1.Plant = PegDmdMst2.Plant AND 
                         PegSupMst1.SupplyOrdNum = PegDmdMst2.DemandOrdNum AND PegSupMst1.SupplyOrdLine = PegDmdMst2.DemandOrdLine AND NOT (PegDmdMst2.DemandOrdNum = '') AND 
                         NOT (PegDmdMst2.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink2 ON PegDmdMst2.Company = PegLink2.Company AND PegDmdMst2.Plant = PegLink2.Plant AND PegDmdMst2.PartNum = PegLink2.PartNum AND 
                         PegDmdMst2.DemandSeq = PegLink2.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst2 ON PegLink2.Company = PegSupMst2.Company AND PegLink2.Plant = PegSupMst2.Plant AND PegLink2.PartNum = PegSupMst2.PartNum AND 
                         PegLink2.SupplySeq = PegSupMst2.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst3 ON PegSupMst2.Company = PegDmdMst3.Company AND PegSupMst2.Plant = PegDmdMst3.Plant AND 
                         PegSupMst2.SupplyOrdNum = PegDmdMst3.DemandOrdNum AND PegSupMst2.SupplyOrdLine = PegDmdMst3.DemandOrdLine AND NOT (PegDmdMst3.DemandOrdNum = '') AND 
                         NOT (PegDmdMst3.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink3 ON PegDmdMst3.Company = PegLink3.Company AND PegDmdMst3.Plant = PegLink3.Plant AND PegDmdMst3.PartNum = PegLink3.PartNum AND 
                         PegDmdMst3.DemandSeq = PegLink3.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst3 ON PegLink3.Company = PegSupMst3.Company AND PegLink3.Plant = PegSupMst3.Plant AND PegLink3.PartNum = PegSupMst3.PartNum AND 
                         PegLink3.SupplySeq = PegSupMst3.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst4 ON PegSupMst3.Company = PegDmdMst4.Company AND PegSupMst3.Plant = PegDmdMst4.Plant AND 
                         PegSupMst3.SupplyOrdNum = PegDmdMst4.DemandOrdNum AND PegSupMst3.SupplyOrdLine = PegDmdMst4.DemandOrdLine AND NOT (PegDmdMst4.DemandOrdNum = '') AND 
                         NOT (PegDmdMst4.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink4 ON PegDmdMst4.Company = PegLink4.Company AND PegDmdMst4.Plant = PegLink4.Plant AND PegDmdMst4.PartNum = PegLink4.PartNum AND 
                         PegDmdMst4.DemandSeq = PegLink4.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst4 ON PegLink4.Company = PegSupMst4.Company AND PegLink4.Plant = PegSupMst4.Plant AND PegLink4.PartNum = PegSupMst4.PartNum AND 
                         PegLink4.SupplySeq = PegSupMst4.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst5 ON PegSupMst4.Company = PegDmdMst5.Company AND PegSupMst4.Plant = PegDmdMst5.Plant AND 
                         PegSupMst4.SupplyOrdNum = PegDmdMst5.DemandOrdNum AND PegSupMst4.SupplyOrdLine = PegDmdMst5.DemandOrdLine AND NOT (PegDmdMst5.DemandOrdNum = '') AND 
                         NOT (PegDmdMst5.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink5 ON PegDmdMst5.Company = PegLink5.Company AND PegDmdMst5.Plant = PegLink5.Plant AND PegDmdMst5.PartNum = PegLink5.PartNum AND 
                         PegDmdMst5.DemandSeq = PegLink5.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst5 ON PegLink5.Company = PegSupMst5.Company AND PegLink5.Plant = PegSupMst5.Plant AND PegLink5.PartNum = PegSupMst5.PartNum AND 
                         PegLink5.SupplySeq = PegSupMst5.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst6 ON PegSupMst5.Company = PegDmdMst6.Company AND PegSupMst5.Plant = PegDmdMst6.Plant AND 
                         PegSupMst5.SupplyOrdNum = PegDmdMst6.DemandOrdNum AND PegSupMst5.SupplyOrdLine = PegDmdMst6.DemandOrdLine AND NOT (PegDmdMst6.DemandOrdNum = '') AND 
                         NOT (PegDmdMst6.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink6 ON PegDmdMst6.Company = PegLink6.Company AND PegDmdMst6.Plant = PegLink6.Plant AND PegDmdMst6.PartNum = PegLink6.PartNum AND 
                         PegDmdMst6.DemandSeq = PegLink6.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst6 ON PegLink6.Company = PegSupMst6.Company AND PegLink6.Plant = PegSupMst6.Plant AND PegLink6.PartNum = PegSupMst6.PartNum AND 
                         PegLink6.SupplySeq = PegSupMst6.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst7 ON PegSupMst6.Company = PegDmdMst6.Company AND PegSupMst6.Plant = PegDmdMst7.Plant AND 
                         PegSupMst6.SupplyOrdNum = PegDmdMst7.DemandOrdNum AND PegSupMst6.SupplyOrdLine = PegDmdMst7.DemandOrdLine AND NOT (PegDmdMst7.DemandOrdNum = '') AND 
                         NOT (PegDmdMst7.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink7 ON PegDmdMst7.Company = PegLink7.Company AND PegDmdMst7.Plant = PegLink7.Plant AND PegDmdMst7.PartNum = PegLink7.PartNum AND 
                         PegDmdMst7.DemandSeq = PegLink7.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst7 ON PegLink7.Company = PegSupMst7.Company AND PegLink7.Plant = PegSupMst7.Plant AND PegLink7.PartNum = PegSupMst7.PartNum AND 
                         PegLink7.SupplySeq = PegSupMst7.SupplySeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegDmdMst AS PegDmdMst8 ON PegSupMst7.Company = PegDmdMst8.Company AND PegSupMst7.Plant = PegDmdMst8.Plant AND 
                         PegSupMst7.SupplyOrdNum = PegDmdMst8.DemandOrdNum AND PegSupMst7.SupplyOrdLine = PegDmdMst8.DemandOrdLine AND NOT (PegDmdMst8.DemandOrdNum = '') AND 
                         NOT (PegDmdMst8.DemandType = 'S') LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegLink AS PegLink8 ON PegDmdMst8.Company = PegLink8.Company AND PegDmdMst8.Plant = PegLink8.Plant AND PegDmdMst8.PartNum = PegLink8.PartNum AND 
                         PegDmdMst8.DemandSeq = PegLink8.DemandSeq LEFT OUTER JOIN
                         PLP_PILOT.Erp.PegSupMst AS PegSupMst8 ON PegLink8.Company = PegSupMst8.Company AND PegLink8.Plant = PegSupMst8.Plant AND PegLink8.PartNum = PegSupMst8.PartNum AND 
                         PegLink8.SupplySeq = PegSupMst8.SupplySeq
WHERE        (PegDmdMst.DemandType = 'S') AND (PegDmdMst.Plant = 'GLENDN')
ORDER BY PegDmdMst_DemandDate, PegDmdMst_DemandOrdNum, PegDmdMst_DemandOrdLine, PegDmdMst_DemandOrdRel
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[52] 4[3] 2[27] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PegDmdMst"
            Begin Extent = 
               Top = 5
               Left = 28
               Bottom = 135
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink"
            Begin Extent = 
               Top = 6
               Left = 257
               Bottom = 136
               Right = 433
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst"
            Begin Extent = 
               Top = 6
               Left = 471
               Bottom = 136
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst1"
            Begin Extent = 
               Top = 6
               Left = 685
               Bottom = 136
               Right = 866
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink1"
            Begin Extent = 
               Top = 6
               Left = 904
               Bottom = 136
               Right = 1080
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst1"
            Begin Extent = 
               Top = 6
               Left = 1118
               Bottom = 136
               Right = 1294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst2"
            Begin Extent = 
               Top = 6
               Left = 1332
               Bottom = 136
               Right = 1513
            End
            DisplayFl' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrderSupplyLink_9L_PILOT'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'ags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink2"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst2"
            Begin Extent = 
               Top = 138
               Left = 252
               Bottom = 268
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst3"
            Begin Extent = 
               Top = 138
               Left = 466
               Bottom = 268
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink3"
            Begin Extent = 
               Top = 138
               Left = 685
               Bottom = 268
               Right = 861
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst3"
            Begin Extent = 
               Top = 138
               Left = 899
               Bottom = 268
               Right = 1075
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst4"
            Begin Extent = 
               Top = 138
               Left = 1113
               Bottom = 268
               Right = 1294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink4"
            Begin Extent = 
               Top = 138
               Left = 1332
               Bottom = 268
               Right = 1508
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst4"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst5"
            Begin Extent = 
               Top = 270
               Left = 252
               Bottom = 400
               Right = 433
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink5"
            Begin Extent = 
               Top = 270
               Left = 471
               Bottom = 400
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst5"
            Begin Extent = 
               Top = 270
               Left = 685
               Bottom = 400
               Right = 861
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst6"
            Begin Extent = 
               Top = 266
               Left = 907
               Bottom = 396
               Right = 1088
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink6"
            Begin Extent = 
               Top = 270
               Left = 1118
               Bottom = 400
               Right = 1294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst6"
            Begin Extent = 
               Top = 270
               Left = 1332
               Bottom = 400
               Right = 1508
            End
            DisplayFlags = 280
            TopC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrderSupplyLink_9L_PILOT'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane3', @value=N'olumn = 0
         End
         Begin Table = "PegDmdMst7"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 219
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink7"
            Begin Extent = 
               Top = 402
               Left = 257
               Bottom = 532
               Right = 433
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst7"
            Begin Extent = 
               Top = 402
               Left = 471
               Bottom = 532
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegDmdMst8"
            Begin Extent = 
               Top = 402
               Left = 685
               Bottom = 532
               Right = 866
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegLink8"
            Begin Extent = 
               Top = 402
               Left = 904
               Bottom = 532
               Right = 1080
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PegSupMst8"
            Begin Extent = 
               Top = 402
               Left = 1118
               Bottom = 532
               Right = 1294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 10
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrderSupplyLink_9L_PILOT'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=3 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'OrderSupplyLink_9L_PILOT'
GO


