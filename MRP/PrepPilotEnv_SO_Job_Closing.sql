--Find list of orders to be closed

SELECT 1 as 'VoidOrder',OrderHed.Company,OrderHed.OrderNum,Customer.CustNum,Customer.CustID AS 'CustomerCustID'
FROM OrderHed
INNER JOIN Customer ON Customer.CustNum = Orderhed.CustNum
WHERE OpenOrder = 1

--List of firmed jobs to be closed

SELECT Company,Plant,JobNum,PartNum,'TRUE' as 'JobClosed','TRUE' as JobComplete, GETDATE() AS JobCompletionDate, GETDATE() AS ClosedDate FROM JobHead
WHERE JobClosed = 0 AND JobFirm = 1

--AEM Assembly parts to be made non-stock part plant table
SELECT Company,PartNum,Plant,NonStock,1 as 'NonStock' FROM erp.PartPlant
WHERE PersonID = 'ASSY_AEM' AND SourceType = 'M'

--AEM Assembly parts to be made non-stock part table
SELECT Part.Company,Part.PartNum,1 as 'NonStock' FROM erp.Part
INNER JOIN PartPlant ON PartPlant.PartNum = Part.PartNum
WHERE PersonID = 'ASSY_AEM'

--Void open releases that belong to AEM
SELECT OrderRel.Company,OrderNum,OrderLine,OrderRelNum,OrderRel.PartNum,OpenRelease,VoidRelease,1 as 'VVoidRelease' FROM OrderRel INNER JOIN PartPlant on 
PartPlant.PartNum = ORderRel.PartNum where openrelease = 1 and personid like '%AEM%'

SELECT * FROM OrderRel where ordernum = '2358214'


--PTF for AEM parts
SELECT Company,Plant,Partnum,PlantimeFence,PersonID FROM PartPlant WHERE PERSONID LIKE '%AEM%' 
AND PlanTimeFence <> 60 AND SourceType = 'M'