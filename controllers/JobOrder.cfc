component extends="Controller"
{
	PageTitle = "Job Order";

	function index() {
		joborder = model("JobOrder").new();
	}

}