component extends="Model" output="false"
{
	function config() {
		
		//set database name for the model
		datasource("iposxdb");

		//set table name for the model
		table("tbl_model");

		// hasMany(name="salesorderline",foreignKey="so_id");

		//standardize column names of the table
		property(name="id", column="id_record");
		property(name="model_id", column="mSap");
		property(name="revision_no", column="mRevision");
		property(name="is_active", column="mActive");
		property(name="division", column="mDivision");
		property(name="rework", column="mRework");
		property(name="yield", column="mYield");

	}
}