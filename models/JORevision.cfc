component extends="Model" output="false"
{

	function config()
	{
		datasource("erpdb_fg");
		table("tbl_erpx_jo_revision");
		validatesPresenceOf(properties="jo_id,revision_no,designation,type,document_date,model_no,model_name,qty_to_produce,total_shipment_qty,production_month,requested_start_date,requested_end_date,status");
		validatesNumericalityOf(properties="jo_id, qty_to_produce, total_shipment_qty", onlyInteger=true);
		validatesFormatOf(properties="document_date, requested_start_date, requested_end_date, production_month", type="date");

		belongsTo(name="jo", foreignKey="jo_id");
	}
}