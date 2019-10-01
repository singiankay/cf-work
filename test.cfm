<cfscript>

function getExpirationRemarks(expiration_date)
{
	if(isDate(arguments.expiration_date)) {
		var d = dateDiff('d', now(), arguments.expiration_date);
		if(d > 14) {
			return "";
		}
		else if(d <= 14 && d > 0) {
			return "Near Expiration";
		}
		else {
			return "Expired";
		}
	}
	else {
		return "";
	}
}

function getExpirationColor(expiration_date)
{
	if(isDate(arguments.expiration_date)) {
		var d = dateDiff('d', now(), arguments.expiration_date);
		if(d > 14) {
			return "";
		}
		else if(d <= 14 && d > 0) {
			return "black";
		}
		else {
			return "red";
		}
	}
	else {
		return "";
	}
}

sqlQuery = new Query();
sqlQuery.setDatasource("sapdb");
sqlQuery.setSQL("
	SELECT rcv.U_ProductLine AS division, itm.U_ProductionLine AS area, rcv.DocEntry AS docentry, rcv.U_IDRecord AS id, U_ItemType AS item_type, itm.ItmsGrpCod AS subgroup_code, itb.ItmsGrpNam classification, isgn.Name AS material_type, rcv.U_ItemCode AS material_no, rcv.U_ItemDescription AS material_name, rcv.U_Reference AS form_number, rcv.U_Fifo AS receive_date, rcv.U_ExpiryDate AS expiration_date, rcv.U_InvNo AS invoice_no, rcv.U_PONo AS po_no, rcv.U_QRcode AS qr_code, rcv.U_LotCode AS supplier_lot, rcv.U_LotCode2 AS npi_lot, rcv.U_LotCode3 AS supplementary_lot, 
	       COALESCE(rcv.U_Quantity, 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0)) iqc_g, 
	       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) iqc_q, 
	       COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) pck_g, 
	       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) whs_g, 
	       COALESCE(itf.[p_WHS-Q], 0) - (COALESCE(itf.[m_WHS-Q], 0) + COALESCE(iss_m.[WHS-Q], 0)) whs_q, 
	       COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) whs_r, 
	       COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) whs_s, 
	       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) iqc_s,
	       COALESCE(rcv.U_Quantity, 0) qty_in,
	       COALESCE(CASE WHEN rcv.u_isinspected = 0 THEN rcv.U_Quantity END, 0) qty_for_iqc,
	       (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
	     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
	     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
	     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
	     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
	     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) qty_balance,
	       COALESCE(itf.[p_IQC-S], 0) - (COALESCE(itf.[m_IQC-S], 0) + COALESCE(iss_m.[IQC-S], 0)) qty_ncp,
	       COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0)) qty_on_hold, 
	       COALESCE(itf.[p_reinspect], 0) - (COALESCE(itf.[m_reinspect], 0) + COALESCE(iss_m.[reinspect], 0)) qty_reinspect,
	       COALESCE(iss_m.issued_qty, 0) qty_issued, 
	       COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G], 0) + COALESCE(iss_m.[WHS-G], 0)) 
	     + COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0)) 
	     + COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0)) 
	     + COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0)) qty_unissued
	  FROM [@FN_ORCV] rcv 
	  LEFT JOIN (
	     SELECT U_BaseRef, 
	        SUM(CASE WHEN U_LocationTo = 3 THEN U_Quantity END) [p_IQC-G], 
	        SUM(CASE WHEN U_LocationTo = 4 THEN U_Quantity END) [p_IQC-Q], 
	        SUM(CASE WHEN U_LocationTo = 6 THEN U_Quantity END) [p_PCK-G], 
	        SUM(CASE WHEN U_LocationTo = 10 THEN U_Quantity END) [p_WHS-G], 
	        SUM(CASE WHEN U_LocationTo = 12 THEN U_Quantity END) [p_WHS-Q], 
	        SUM(CASE WHEN U_LocationTo = 13 THEN U_Quantity END) [p_WHS-R], 
	        SUM(CASE WHEN U_LocationTo = 14 THEN U_Quantity END) [p_WHS-S], 
	        SUM(CASE WHEN U_LocationTo = 15 THEN U_Quantity END) [p_IQC-S],
	        SUM(CASE WHEN U_LocationFrom IN (6,10,13,14) AND U_LocationTo = 4 THEN U_Quantity END) [p_reinspect], 
	        SUM(CASE WHEN U_LocationFrom = 3 THEN U_Quantity END) [m_IQC-G], 
	        SUM(CASE WHEN U_LocationFrom = 4 THEN U_Quantity END) [m_IQC-Q], 
	        SUM(CASE WHEN U_LocationFrom = 6 THEN U_Quantity END) [m_PCK-G], 
	        SUM(CASE WHEN U_LocationFrom = 10 THEN U_Quantity END) [m_WHS-G], 
	        SUM(CASE WHEN U_LocationFrom = 12 THEN U_Quantity END) [m_WHS-Q], 
	        SUM(CASE WHEN U_LocationFrom = 13 THEN U_Quantity END) [m_WHS-R], 
	        SUM(CASE WHEN U_LocationFrom = 14 THEN U_Quantity END) [m_WHS-S], 
	        SUM(CASE WHEN U_LocationFrom = 15 THEN U_Quantity END) [m_IQC-S],
	        SUM(CASE WHEN U_LocationFrom = 4 AND RIGHT(U_Reference, 2) = 're' THEN U_Quantity END) [m_reinspect]
	       FROM [@FN_OITF] 
	      WHERE Canceled = 'N'
	      GROUP BY U_BaseRef 
	     ) itf
	         ON itf.U_BaseRef = rcv.Docentry 
	  LEFT JOIN (
	     SELECT U_BaseRef,
	        SUM(CASE WHEN U_Location = 'IQC-G' THEN U_Quantity END) [IQC-G], 
	        SUM(CASE WHEN U_Location = 'IQC-Q' THEN U_Quantity END) [IQC-Q], 
	        SUM(CASE WHEN U_Location = 'PCK-G' THEN U_Quantity END) [PCK-G], 
	        SUM(CASE WHEN U_Location = 'WHS-G' THEN U_Quantity END) [WHS-G], 
	        SUM(CASE WHEN U_Location = 'WHS-Q' THEN U_Quantity END) [WHS-Q], 
	        SUM(CASE WHEN U_Location = 'WHS-R' THEN U_Quantity END) [WHS-R], 
	        SUM(CASE WHEN U_Location = 'WHS-S' THEN U_Quantity END) [WHS-S], 
	        SUM(CASE WHEN U_Location = 'IQC-S' THEN U_Quantity END) [IQC-S], 
	        SUM(CASE WHEN RIGHT(U_Reference, 2) = 're' THEN U_quantity END) [reinspect], 
	        SUM(U_Quantity) issued_qty
	       FROM [@FN_OISS] 
	      WHERE Canceled = 'N' 
	        AND U_Release = 1 
	      GROUP BY U_BaseRef 
	     ) iss_m
	         ON iss_m.U_BaseRef = rcv.DocEntry 
	 INNER JOIN dbo.OITM itm 
	         ON itm.Itemcode = rcv.U_ItemCode 
	 INNER JOIN dbo.[@ITEMSUBGROUPNAME] isgn 
	         ON isgn.Code = itm.U_ItemSubGroup 
	 INNER JOIN dbo.OITB itb 
	         ON itb.ItmsGrpCod = itm.ItmsGrpCod 
	 WHERE rcv.Canceled = 'N'  
	   AND rcv.Status = 'O' 
	   AND (0 = 0 OR rcv.Docentry = 0)
	   AND (0 = 0 OR rcv.U_IDRecord = 0)
	   AND itm.ItmsgrpCod IN (116,149,156,122,124,129,138,139,113,148) 
	   AND (0 = -1 OR itm.U_ProductionLine IN ('UT-CT1','UT-CT2','UT-CT3','UT-CT4','UT-OT','UT-PZT','UT-PNT','UT-TRADED','UT-COMMON'))
	   AND (NULL IS NULL OR itm.ItemCode LIKE NULL)
	   AND (NULL IS NULL OR itm.ItemName LIKE NULL)
	   AND (NULL IS NULL OR rcv.U_LotCode = NULL)
	   AND (NULL IS NULL OR rcv.U_LotCode2 = NULL)
	   AND (NULL IS NULL OR rcv.U_LotCode3 = NULL)
	   AND (COALESCE(rcv.U_Quantity, 0) + COALESCE(itf.[p_IQC-G], 0) - (COALESCE(itf.[m_IQC-G], 0) + COALESCE(iss_m.[IQC-G], 0))) 
	     + (COALESCE(itf.[p_WHS-G], 0) - (COALESCE(itf.[m_WHS-G],0) + COALESCE(iss_m.[WHS-G], 0))) 
	     + (COALESCE(itf.[p_PCK-G], 0) - (COALESCE(itf.[m_PCK-G], 0) + COALESCE(iss_m.[PCK-G], 0))) 
	     + (COALESCE(itf.[p_IQC-Q], 0) - (COALESCE(itf.[m_IQC-Q], 0) + COALESCE(iss_m.[IQC-Q], 0))) 
	     + (COALESCE(itf.[p_WHS-R], 0) - (COALESCE(itf.[m_WHS-R], 0) + COALESCE(iss_m.[WHS-R], 0))) 
	     + (COALESCE(itf.[p_WHS-S], 0) - (COALESCE(itf.[m_WHS-S], 0) + COALESCE(iss_m.[WHS-S], 0))) <> 0 
	 ORDER BY rcv.U_ExpiryDate ASC, rcv.U_FIFO ASC, rcv.U_ItemCode, rcv.DocEntry DESC 
");
	search.full = sqlQuery.execute().getResult();

	spreadsheetObj = spreadsheetNew('RM Inventory Balance');
	spreadsheetAddFreezePane(spreadsheetObj, 8, 4);
	SpreadSheetAddAutofilter(Spreadsheetobj, "A4:AA4");

	spreadsheetAddRow(spreadsheetObj, 'RM Inventory Balance');
	spreadsheetSetCellValue(spreadsheetObj, 'Generated Last', 2, 1);
	spreadsheetSetCellValue(spreadsheetObj, #dateFormat(now(), 'm/d/yyyy')#, 2, 4);

	spreadsheetMergeCells(spreadsheetObj, 1, 1, 1, 3);
	spreadsheetMergeCells(spreadsheetObj, 2, 2, 1, 3);
	SpreadsheetformatCell(spreadsheetObj,{bold=true,alignment='left'},1,1);
	SpreadsheetformatCell(spreadsheetObj,{bold=true,alignment='left'},2,1);
	SpreadsheetformatCell(spreadsheetObj,{dataformat='m/d/yyyy'},2,4);

	spreadsheetSetCellValue(spreadsheetObj, 'Material Information', 3, 1);
	spreadsheetSetCellValue(spreadsheetObj, 'Lot Codes', 3, 11);
	spreadsheetSetCellValue(spreadsheetObj, 'Balance', 3, 14);
	spreadsheetSetCellValue(spreadsheetObj, 'Location', 3, 21);
	spreadsheetSetCellValue(spreadsheetObj, 'Others', 3, 28);
	spreadsheetMergeCells(spreadsheetObj, 3, 3, 1, 10);
	spreadsheetMergeCells(spreadsheetObj, 3, 3, 11, 13);
	spreadsheetMergeCells(spreadsheetObj, 3, 3, 14, 20);
	spreadsheetMergeCells(spreadsheetObj, 3, 3, 21, 27);
	spreadsheetMergeCells(spreadsheetObj, 3, 3, 28, 29);
	
	headerList = "Division,Area,Material No,Material Name,Classification,Material type,Date Received,Expiration Date,Remarks,QR Code,Supplier Lot,NPI Lot,Supplementary Lot,Qty In,Qty Out,Qty Balance,Qty NCP,Qty Reinspect,Qty On Hold,Qty for IQC,IQC-G,IQC-Q,IQC-S,WHS-G,WHS-R,WHS-S,PCK-G,Docentry,ID record";
	spreadsheetAddRow(spreadsheetObj, headerList);
	spreadsheetformatrow(spreadsheetObj,{ bold=true, alignment='center_selection', textwrap=true },3);
	spreadsheetformatrow(spreadsheetObj,{ bold=true, alignment='center_selection', textwrap=true },4);
	spreadsheetSetRowHeight(spreadsheetObj, 3, 24);
	spreadsheetSetRowHeight(spreadsheetObj, 4, 24);

	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 3, 1);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 1);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 2);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 3);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 4);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 5);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 6);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 7);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 8);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 9);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='aqua', color='grey_80_percent' }, 4, 10);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='lemon_chiffon', color='grey_80_percent' }, 3, 11);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='lemon_chiffon', color='grey_80_percent' }, 4, 11);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='lemon_chiffon', color='grey_80_percent' }, 4, 12);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='lemon_chiffon', color='grey_80_percent' }, 4, 13);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='white' }, 3, 14);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='white' }, 4, 14);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='white' }, 4, 15);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='white' }, 4, 16);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='red' }, 4, 17);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='red' }, 4, 18);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='red' }, 4, 19);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='teal', color='white' }, 4, 20);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 3, 21);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 21);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 22);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 23);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 24);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 25);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 26);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='royal_blue', color='white' }, 4, 27);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='turquoise', color='grey_80_percent' }, 3, 28);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='turquoise', color='grey_80_percent' }, 4, 28);
	spreadsheetFormatCell(spreadsheetObj, { fgcolor='turquoise', color='grey_80_percent' }, 4, 29);

	for(row in search.full) {
		spreadsheetSetCellValue(spreadsheetObj, row.division, search.full.currentRow+4, 1);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 1);
		spreadsheetSetCellValue(spreadsheetObj, row.area, search.full.currentRow+4, 2);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 2);
		spreadsheetSetCellValue(spreadsheetObj, row.material_no, search.full.currentRow+4, 3);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 3);
		spreadsheetSetCellValue(spreadsheetObj, row.material_name, search.full.currentRow+4, 4);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 4);
		spreadsheetSetCellValue(spreadsheetObj, row.classification, search.full.currentRow+4, 5);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 5);
		spreadsheetSetCellValue(spreadsheetObj, row.material_type, search.full.currentRow+4, 6);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='left' }, search.full.currentRow+4, 6);
		spreadsheetSetCellValue(spreadsheetObj, dateFormat(row.receive_date, 'm/d/yyyy'), search.full.currentRow+4, 7);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='m/d/yyyy', alignment='right' }, search.full.currentRow+4, 7);
		spreadsheetSetCellValue(spreadsheetObj, dateFormat(row.expiration_date, 'm/d/yyyy'), search.full.currentRow+4, 8);
			if(row.expiration_date <= now()) {
				spreadsheetFormatCell(spreadsheetObj, { dataformat='m/d/yyyy', alignment='right', color:'red' }, search.full.currentRow+4, 8);
			}
			else {
				spreadsheetFormatCell(spreadsheetObj, { dataformat='m/d/yyyy', alignment='right' }, search.full.currentRow+4, 8);
			}
		spreadsheetSetCellValue(spreadsheetObj, getExpirationRemarks(row.expiration_date), search.full.currentRow+4, 9);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center', color:getExpirationColor(row.expiration_date) }, search.full.currentRow+4, 9);
		spreadsheetSetCellValue(spreadsheetObj, row.qr_code, search.full.currentRow+4, 10);
			spreadsheetFormatCell(spreadsheetObj, { textwrap=false, alignment="fill" }, search.full.currentRow+4, 10);
		spreadsheetSetCellValue(spreadsheetObj, row.supplier_lot, search.full.currentRow+4, 11);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, search.full.currentRow+4, 11);
		spreadsheetSetCellValue(spreadsheetObj, row.npi_lot, search.full.currentRow+4, 12);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, search.full.currentRow+4, 12);
		spreadsheetSetCellValue(spreadsheetObj, row.supplementary_lot, search.full.currentRow+4, 13);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='@', alignment='center' }, search.full.currentRow+4, 13);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_in, search.full.currentRow+4, 14);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 14);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_issued, search.full.currentRow+4, 15);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 15);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_balance, search.full.currentRow+4, 16);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 16);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_ncp, search.full.currentRow+4, 17);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 17);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_reinspect, search.full.currentRow+4, 18);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 18);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_on_hold, search.full.currentRow+4, 19);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 19);
		spreadsheetSetCellValue(spreadsheetObj, row.qty_for_iqc, search.full.currentRow+4, 20);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 20);
		spreadsheetSetCellValue(spreadsheetObj, row.iqc_g, search.full.currentRow+4, 21);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 21);
		spreadsheetSetCellValue(spreadsheetObj, row.iqc_q, search.full.currentRow+4, 22);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 22);
		spreadsheetSetCellValue(spreadsheetObj, row.iqc_s, search.full.currentRow+4, 23);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 23);
		spreadsheetSetCellValue(spreadsheetObj, row.whs_g, search.full.currentRow+4, 24);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 24);
		spreadsheetSetCellValue(spreadsheetObj, row.whs_r, search.full.currentRow+4, 25);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 25);
		spreadsheetSetCellValue(spreadsheetObj, row.whs_s, search.full.currentRow+4, 26);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 26);
		spreadsheetSetCellValue(spreadsheetObj, row.pck_g, search.full.currentRow+4, 27);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='##,####0.00', alignment='right' }, search.full.currentRow+4, 27);
		spreadsheetSetCellValue(spreadsheetObj, row.docentry, search.full.currentRow+4, 28);
			spreadsheetFormatCell(spreadsheetObj, { dataformat='0', alignment='right' }, search.full.currentRow+4, 28);
		spreadsheetSetCellFormula(spreadsheetObj, 'HYPERLINK("http://npi-appserver/erpx/api/index.cfm/wms/rmbalance/#row.id#","#row.id#")', search.full.currentRow+4, 29);
			spreadsheetFormatCell(spreadsheetObj, { color= 'teal', dataformat='0', alignment='left' }, search.full.currentRow+4, 29);
	}

	spreadsheetSetColumnWidth(spreadsheetObj, 1, 8);
	spreadsheetSetColumnWidth(spreadsheetObj, 2, 8);
	spreadsheetSetColumnWidth(spreadsheetObj, 3, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 4, 48);
	spreadsheetSetColumnWidth(spreadsheetObj, 5, 15);
	spreadsheetSetColumnWidth(spreadsheetObj, 6, 15);
	spreadsheetSetColumnWidth(spreadsheetObj, 7, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 8, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 9, 14);
	spreadsheetSetColumnWidth(spreadsheetObj, 10, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 11, 24);
	spreadsheetSetColumnWidth(spreadsheetObj, 12, 20);
	spreadsheetSetColumnWidth(spreadsheetObj, 13, 26);
	spreadsheetSetColumnWidth(spreadsheetObj, 14, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 15, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 16, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 17, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 18, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 19, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 20, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 21, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 22, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 23, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 24, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 25, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 26, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 27, 12);
	spreadsheetSetColumnWidth(spreadsheetObj, 28, 10);
	spreadsheetSetColumnWidth(spreadsheetObj, 29, 12);

	cfheader(name="Content-Disposition", value="inline; filename=rmbalance.xls");
	cfcontent(type="application/vnd.ms-excel", variable="#SpreadSheetReadBinary(spreadsheetObj)#");
</cfscript>
<!DOCTYPE html>
<html>
<head>
	<title></title>
</head>
<body>

</body>
</html>