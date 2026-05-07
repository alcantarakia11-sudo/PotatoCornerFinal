using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class ActivityLog : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is admin
                if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
                {
                    Response.Redirect("~/Login.aspx");
                }

                // Set default date range (last 30 days)
                txtDateFrom.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
                txtDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");

                LoadActivityLogs();
            }
        }

        private void LoadActivityLogs()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Build query with filters
                string query = @"SELECT LogID, ActivityType, ActivityDescription, PerformedBy, 
                                TargetEntity, IPAddress, Timestamp, Severity
                                FROM ActivityLog
                                WHERE 1=1";

                // Add filters
                if (!string.IsNullOrEmpty(ddlActivityType.SelectedValue))
                {
                    query += " AND ActivityType = @ActivityType";
                }

                if (!string.IsNullOrEmpty(ddlSeverity.SelectedValue))
                {
                    query += " AND Severity = @Severity";
                }

                if (!string.IsNullOrEmpty(txtDateFrom.Text))
                {
                    query += " AND Timestamp >= @DateFrom";
                }

                if (!string.IsNullOrEmpty(txtDateTo.Text))
                {
                    query += " AND Timestamp <= @DateTo";
                }

                query += " ORDER BY Timestamp DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);

                // Add parameters
                if (!string.IsNullOrEmpty(ddlActivityType.SelectedValue))
                {
                    da.SelectCommand.Parameters.AddWithValue("@ActivityType", ddlActivityType.SelectedValue);
                }

                if (!string.IsNullOrEmpty(ddlSeverity.SelectedValue))
                {
                    da.SelectCommand.Parameters.AddWithValue("@Severity", ddlSeverity.SelectedValue);
                }

                if (!string.IsNullOrEmpty(txtDateFrom.Text))
                {
                    da.SelectCommand.Parameters.AddWithValue("@DateFrom", DateTime.Parse(txtDateFrom.Text));
                }

                if (!string.IsNullOrEmpty(txtDateTo.Text))
                {
                    DateTime dateTo = DateTime.Parse(txtDateTo.Text).AddDays(1).AddSeconds(-1);
                    da.SelectCommand.Parameters.AddWithValue("@DateTo", dateTo);
                }

                DataTable dt = new DataTable();
                da.Fill(dt);

                gvActivityLog.DataSource = dt;
                gvActivityLog.DataBind();

                lblLogCount.Text = dt.Rows.Count.ToString();
            }
        }

        protected void gvActivityLog_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string severity = DataBinder.Eval(e.Row.DataItem, "Severity").ToString();
                Label lblSeverity = (Label)e.Row.FindControl("lblSeverity");

                if (lblSeverity != null)
                {
                    switch (severity)
                    {
                        case "Info":
                            lblSeverity.Text = "<span class='severity-badge severity-info'>Info</span>";
                            break;
                        case "Warning":
                            lblSeverity.Text = "<span class='severity-badge severity-warning'>Warning</span>";
                            break;
                        case "Critical":
                            lblSeverity.Text = "<span class='severity-badge severity-critical'>Critical</span>";
                            break;
                        default:
                            lblSeverity.Text = "<span class='severity-badge severity-info'>" + severity + "</span>";
                            break;
                    }
                }
            }
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            gvActivityLog.PageIndex = 0;
            LoadActivityLogs();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ddlActivityType.SelectedIndex = 0;
            ddlSeverity.SelectedIndex = 0;
            txtDateFrom.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
            txtDateTo.Text = DateTime.Now.ToString("yyyy-MM-dd");
            gvActivityLog.PageIndex = 0;
            LoadActivityLogs();
        }

        protected void gvActivityLog_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvActivityLog.PageIndex = e.NewPageIndex;
            LoadActivityLogs();
        }

        // Navigation methods
        protected void lnkSales_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sales.aspx");
        }

        protected void lnkUpdate_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Update.aspx");
        }

        protected void lnkActivityLog_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ActivityLog.aspx");
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ProfileAdmin.aspx");
        }

        // Helper method to log activities (can be called from other pages)
        public static void LogActivity(string activityType, string description, string performedBy, 
            string targetEntity, string severity = "Info")
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"INSERT INTO ActivityLog (ActivityType, ActivityDescription, PerformedBy, 
                                    TargetEntity, Severity, Timestamp)
                                    VALUES (@ActivityType, @Description, @PerformedBy, @TargetEntity, @Severity, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ActivityType", activityType);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@PerformedBy", performedBy ?? "System");
                        cmd.Parameters.AddWithValue("@TargetEntity", targetEntity ?? "N/A");
                        cmd.Parameters.AddWithValue("@Severity", severity);

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error logging activity: " + ex.Message);
            }
        }
    }
}
