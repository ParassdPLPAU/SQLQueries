select * from erp.VendPart ORDER BY PartNum ASC;

WITH BASE AS (
	SELECT PartNum, MAX(EffectiveDate) AS "MaxEffectiveDate"
	FROM erp.VendPart
	GROUP BY PartNum
	
)

SELECT DISTINCT erp.VendPart.PartNum, BASE.MaxEffectiveDate AS "LastEffectiveDate", Erp.VendPart.VendorNum,Erp.VendPart.BaseUnitPrice,Erp.VendPart.CurrencyCode FROM BASE 
INNER JOIN erp.VendPart ON
MaxEffectiveDate = EffectiveDate AND BASE.PartNum = erp.VendPart.PartNum
ORDER BY erp.VendPart.PartNum ASC;