component extends="Model" output="false"
{
	function config() {

		datasource("employee_db");
		table("m_employee");

		property(name="fullname", sql="CONCAT(EMP3,' ',EMP2)");
		property(name="id", column="EMP33");
		property(name="employee_number", column="EMP1");
		property(name="lastname", column="EMP2");
		property(name="firstname", column="EMP3");
		property(name="middlename", column="EMP4");
		property(name="position_id_record", column="EMP5_ID");
		property(name="position", column="EMP5");
		property(name="date_hired", column="EMP6");
		property(name="status_id", column="EMP7");
		property(name="sbma_id_type", column="EMP8");
		property(name="sbma_id_expiration_date", column="EMP9");
		property(name="birth_date", column="EMP10");
		property(name="gender", column="EMP11");
		property(name="blood_type", column="EMP12");
		property(name="contact_number", column="EMP13");
		property(name="marital_status", column="EMP14");
		property(name="address", column="EMP15");
		property(name="contact_person", column="EMP16");
		property(name="contact_person_number", column="EMP17");
		property(name="emergency_address", column="EMP18");
		property(name="tin_number", column="EMP19");
		property(name="sss_number", column="EMP20");
		property(name="philhealth_number", column="EMP21");
		property(name="pagibig_number", column="EMP22");
		property(name="image_path", column="EMP23");
		property(name="department_id", column="EMP24");
		property(name="update_date", column="EMP25");
		property(name="encoder", column="EMP26");
		property(name="is_active", column="EMP27");
		property(name="end_of_contract", column="EMP28");
		property(name="course", column="EMP29");
		property(name="eforms_id", column="EMP34");
		property(name="position_id", column="EMP37");
		property(name="section_id", column="EMP38");
		property(name="hris_not_viewable", column="EMP39");
		property(name="job_grade", column="EMP40");
		property(name="building_number", column="EMP41");
		property(name="area", column="EMP42");
		property(name="location", column="EMP43");
		property(name="contact_2", column="EMP44");
		
	}
	
}