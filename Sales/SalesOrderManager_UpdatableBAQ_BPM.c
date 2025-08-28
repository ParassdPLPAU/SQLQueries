// Author: Paras Sood
// Date updated: 28 August 2025
// Developed by Matt Britton (Epicor)
// Auto generated code copied from the BPM update only option to be able to comment out lines that are updating bad data through the dashboard
// Bad data means the old data present in dashboard which has changed on SO level but because an update has been passed through the 
// updatable dashboard without refreshing to bring the latest data. Therefore if Qty Shipped has gone down to 0 but the Qty Shipped on Dashboard is still say 5, 
// then the data from BAQ goes and updates your SO record which causes the line to get released again. This code fixes this issue by commenting the lines out
// which are passing this update.
// Manually add the reference back to erp.contracts.bo.salesorder

using (var updater = this.getDataUpdater("Erp", "SalesOrder"))
{
    var ttResultQuery = ttResults
        .Where(row => !string.IsNullOrEmpty(row.RowMod) && row.RowMod != "P");

    foreach (var ttResult in ttResultQuery)
    {
        var ds = new Erp.Tablesets.UpdExtSalesOrderTableset();

        // Query to object mapping
        {
            var OrderDtl = new Erp.Tablesets.OrderDtlRow
            {
                Company = Constants.CurrentCompany,
                LineDesc = ttResult.OrderDtl_LineDesc,
                //NeedByDate = ttResult.OrderDtl_NeedByDate,
                //OrdBasedPrice = ttResult.OrderDtl_OrdBasedPrice,
                //OrderComment = ttResult.OrderDtl_OrderComment,
                OrderLine = ttResult.OrderDtl_OrderLine,
                OrderNum = ttResult.OrderDtl_OrderNum,
                //PartNum = ttResult.OrderDtl_PartNum,
                PickListComment = ttResult.OrderDtl_PickListComment,
                //ProdCode = ttResult.OrderDtl_ProdCode,
                //ProjectID = ttResult.OrderDtl_ProjectID,
                //SalesUM = ttResult.OrderDtl_SalesUM,
                //ShipComment = ttResult.OrderDtl_ShipComment,
                //UnitPrice = ttResult.OrderDtl_UnitPrice,
                //XPartNum = ttResult.OrderDtl_XPartNum,
            };

            OrderDtl.SetUDField<System.DateTime?>("Promise_Date_c", ttResult.OrderDtl_Promise_Date_c);
            OrderDtl.SetUDField<System.String>("ReasonCode_c", ttResult.OrderDtl_ReasonCode_c);

            ds.OrderDtl.Add(OrderDtl);

            var OrderHed = new Erp.Tablesets.OrderHedRow
            {
                Company = Constants.CurrentCompany,
                //EntryPerson = ttResult.OrderHed_EntryPerson,
                //OpenOrder = ttResult.OrderHed_OpenOrder,
                //OrderComment = ttResult.OrderHed_OrderComment,
                //OrderDate = ttResult.OrderHed_OrderDate,
                OrderNum = ttResult.OrderHed_OrderNum,
                PickListComment = ttResult.OrderHed_PickListComment,
                PONum = ttResult.OrderHed_PONum,
                //RequestDate = ttResult.OrderHed_RequestDate,
                ShipComment = ttResult.OrderHed_ShipComment,
            };

            OrderHed.SetUDField<System.String>("ConsolidateOrder_c", ttResult.OrderHed_ConsolidateOrder_c);

            ds.OrderHed.Add(OrderHed);

            var OrderRel = new Erp.Tablesets.OrderRelRow
            {
                //BuyToOrder = ttResult.OrderRel_BuyToOrder,
                Company = Constants.CurrentCompany,
                //Make = ttResult.OrderRel_Make,
                //OpenRelease = ttResult.OrderRel_OpenRelease,
                OrderLine = ttResult.OrderRel_OrderLine,
                OrderNum = ttResult.OrderRel_OrderNum,
                OrderRelNum = ttResult.OrderRel_OrderRelNum,
                /*OurJobShippedQty = ttResult.OrderRel_OurJobShippedQty,
                OurReqQty = ttResult.OrderRel_OurReqQty,
                OurStockQty = ttResult.OrderRel_OurStockQty,
                OurStockShippedQty = ttResult.OrderRel_OurStockShippedQty,*/
                PONum = ttResult.OrderRel_PONum,
                /*ReqDate = ttResult.OrderRel_ReqDate,
                SellingReqQty = ttResult.OrderRel_SellingReqQty,
                ShipToNum = ttResult.OrderRel_ShipToNum,
                ShipViaCode = ttResult.OrderRel_ShipViaCode,*/
                WarehouseCode = ttResult.OrderRel_WarehouseCode,
            };

            ds.OrderRel.Add(OrderRel);
        }

        BOUpdErrorTableset boUpdateErrors = updater.Update(ref ds);
        if (this.BpmDataFormIsPublished()) return;

        ttResult.RowMod = "P";

        // Object to query mapping
        {
            var OrderDtl = ds.OrderDtl.FirstOrDefault(
                tableRow => tableRow.Company == Constants.CurrentCompany
                    && tableRow.OrderLine == ttResult.OrderDtl_OrderLine
                    && tableRow.OrderNum == ttResult.OrderDtl_OrderNum);
            if (OrderDtl == null)
            {
                OrderDtl = ds.OrderDtl.LastOrDefault();
            }

            var OrderHed = ds.OrderHed.FirstOrDefault(
                tableRow => tableRow.Company == Constants.CurrentCompany
                    && tableRow.OrderNum == ttResult.OrderHed_OrderNum);
            if (OrderHed == null)
            {
                OrderHed = ds.OrderHed.LastOrDefault();
            }

            var OrderRel = ds.OrderRel.FirstOrDefault(
                tableRow => tableRow.Company == Constants.CurrentCompany
                    && tableRow.OrderLine == ttResult.OrderRel_OrderLine
                    && tableRow.OrderNum == ttResult.OrderRel_OrderNum
                    && tableRow.OrderRelNum == ttResult.OrderRel_OrderRelNum);
            if (OrderRel == null)
            {
                OrderRel = ds.OrderRel.LastOrDefault();
            }

            if (OrderDtl != null)
            {
                ttResult.OrderDtl_LineDesc = OrderDtl.LineDesc;
                ttResult.OrderDtl_NeedByDate = OrderDtl.NeedByDate;
                ttResult.OrderDtl_OrdBasedPrice = OrderDtl.OrdBasedPrice;
                ttResult.OrderDtl_OrderComment = OrderDtl.OrderComment;
                ttResult.OrderDtl_OrderLine = OrderDtl.OrderLine;
                ttResult.OrderDtl_OrderNum = OrderDtl.OrderNum;
                ttResult.OrderDtl_PartNum = OrderDtl.PartNum;
                ttResult.OrderDtl_PickListComment = OrderDtl.PickListComment;
                ttResult.OrderDtl_ProdCode = OrderDtl.ProdCode;
                ttResult.OrderDtl_ProjectID = OrderDtl.ProjectID;
                ttResult.OrderDtl_Promise_Date_c = OrderDtl.UDField<System.DateTime?>("Promise_Date_c", throwIfNull:false);
                ttResult.OrderDtl_ReasonCode_c = OrderDtl.UDField<System.String>("ReasonCode_c", throwIfNull:false);
                ttResult.OrderDtl_SalesUM = OrderDtl.SalesUM;
                ttResult.OrderDtl_ShipComment = OrderDtl.ShipComment;
                ttResult.OrderDtl_UnitPrice = OrderDtl.UnitPrice;
                ttResult.OrderDtl_XPartNum = OrderDtl.XPartNum;
            }

            if (OrderHed != null)
            {
                ttResult.OrderHed_ConsolidateOrder_c = OrderHed.UDField<System.String>("ConsolidateOrder_c", throwIfNull:false);
                ttResult.OrderHed_EntryPerson = OrderHed.EntryPerson;
                ttResult.OrderHed_OpenOrder = OrderHed.OpenOrder;
                ttResult.OrderHed_OrderComment = OrderHed.OrderComment;
                ttResult.OrderHed_OrderDate = OrderHed.OrderDate;
                ttResult.OrderHed_OrderNum = OrderHed.OrderNum;
                ttResult.OrderHed_PickListComment = OrderHed.PickListComment;
                ttResult.OrderHed_PONum = OrderHed.PONum;
                ttResult.OrderHed_RequestDate = OrderHed.RequestDate;
                ttResult.OrderHed_ShipComment = OrderHed.ShipComment;
            }

            if (OrderRel != null)
            {
                ttResult.OrderRel_BuyToOrder = OrderRel.BuyToOrder;
                ttResult.OrderRel_Make = OrderRel.Make;
                ttResult.OrderRel_OpenRelease = OrderRel.OpenRelease;
                ttResult.OrderRel_OrderLine = OrderRel.OrderLine;
                ttResult.OrderRel_OrderNum = OrderRel.OrderNum;
                ttResult.OrderRel_OrderRelNum = OrderRel.OrderRelNum;
                ttResult.OrderRel_OurJobShippedQty = OrderRel.OurJobShippedQty;
                ttResult.OrderRel_OurReqQty = OrderRel.OurReqQty;
                ttResult.OrderRel_OurStockQty = OrderRel.OurStockQty;
                ttResult.OrderRel_OurStockShippedQty = OrderRel.OurStockShippedQty;
                ttResult.OrderRel_PONum = OrderRel.PONum;
                ttResult.OrderRel_ReqDate = OrderRel.ReqDate;
                ttResult.OrderRel_SellingReqQty = OrderRel.SellingReqQty;
                ttResult.OrderRel_ShipToNum = OrderRel.ShipToNum;
                ttResult.OrderRel_ShipViaCode = OrderRel.ShipViaCode;
                ttResult.OrderRel_WarehouseCode = OrderRel.WarehouseCode;
            }
        }

        if (boUpdateErrors?.BOUpdError?.Count > 0)
        {
            ttErrors
                .AddRange(
                    boUpdateErrors.BOUpdError
                        .Select(
                            e => new ErrorsUbaqRow
                            {
                                TableName = e.TableName,
                                ErrorRowIdent = ttResult.RowIdent,
                                ErrorText = e.ErrorText,
                                ErrorType = e.ErrorType
                            }));
        }
    }
}

var ttResultsForDelete = ttResults
    .Where(row => row.RowMod != "P")
    .ToArray();

foreach (var ttResult in ttResultsForDelete)
{
    ttResults.Remove(ttResult);
}

foreach (var ttResult in ttResults)
{
    ttResult.RowMod = "";
}
