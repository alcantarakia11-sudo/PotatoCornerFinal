using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class ActivityLog : Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
                {
                    Response.Redirect("~/AdminLogin.aspx");
                }
                LoadActivityLog();
            }
        }

        protected void lnkSales_Click(object sender, EventArgs e) { Response.Redirect("Sales.aspx"); }
        protected void lnkUpdate_Click(object sender, EventArgs e) { Response.Redirect("Update.aspx"); }
        protected void lnkActivityLog_Click(object sender, EventArgs e) { Response.Redirect("ActivityLog.aspx"); }
        protected void lnkProfile_Click(object sender, EventArgs e) { Response.Redirect("AccountAdmin.aspx"); }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            gvActivityLog.PageIndex = 0;
            LoadActivityLog();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlActionType.SelectedIndex = 0;
            ddlRole.SelectedIndex = 0;
            txtDateFrom.Text = string.Empty;
            txtDateTo.Text = string.Empty;
            gvActivityLog.PageIndex = 0;
            LoadActivityLog();
        }

        protected void gvActivityLog_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvActivityLog.PageIndex = e.NewPageIndex;
            LoadActivityLog();
        }

        private void LoadActivityLog()
        {
            string search = txtSearch.Text.Trim();
            string actionType = ddlActionType.SelectedValue;
            string role = ddlRole.SelectedValue;
            string dateFrom = txtDateFrom.Text;
            string dateTo = txtDateTo.Text;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string where = "WHERE 1=1";
                if (!string.IsNullOrEmpty(search))
                    where += " AND (PerformedBy LIKE @Search OR ActivityType LIKE @Search OR ActivityDescription LIKE @Search)";
                if (!string.IsNullOrEmpty(actionType))
                    where += " AND ActivityType = @ActionType";
                if (!string.IsNullOrEmpty(role))
                    where += " AND Severity = @Role";
                if (!string.IsNullOrEmpty(dateFrom))
                    where += " AND CAST(Timestamp AS DATE) >= @DateFrom";
                if (!string.IsNullOrEmpty(dateTo))
                    where += " AND CAST(Timestamp AS DATE) <= @DateTo";

                string query = @"
                    SELECT LogID, Timestamp,
                           PerformedBy      AS UserID,
                           Severity         AS UserRole,
                           ActivityType     AS ActionType,
                           ActivityType     AS ActionLabel,
                           ActivityDescription,
                           TargetEntity     AS DeviceName,
                           ''               AS IPAddress
                    FROM ActivityLog
                    " + where + @"
                    ORDER BY Timestamp DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
                    if (!string.IsNullOrEmpty(actionType))
                        cmd.Parameters.AddWithValue("@ActionType", actionType);
                    if (!string.IsNullOrEmpty(role))
                        cmd.Parameters.AddWithValue("@Role", role);
                    if (!string.IsNullOrEmpty(dateFrom))
                        cmd.Parameters.AddWithValue("@DateFrom", dateFrom);
                    if (!string.IsNullOrEmpty(dateTo))
                        cmd.Parameters.AddWithValue("@DateTo", dateTo);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    lblLogCount.Text = dt.Rows.Count.ToString();
                    gvActivityLog.DataSource = dt;
                    gvActivityLog.DataBind();
                }
            }
        }

        protected void gvActivityLog_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            DataRowView row = (DataRowView)e.Row.DataItem;

            // Role badge
            Label lblRole = (Label)e.Row.FindControl("lblRole");
            if (lblRole != null)
            {
                string userRole = row["UserRole"].ToString();
                string roleCss;
                if (userRole.ToLower() == "admin")
                    roleCss = "role-admin";
                else if (userRole.ToLower() == "staff")
                    roleCss = "role-staff";
                else
                    roleCss = "role-customer";

                lblRole.Text = userRole;
                lblRole.CssClass = "role-badge " + roleCss;
            }

            // Action cell
            Label lblAction = (Label)e.Row.FindControl("lblAction");
            if (lblAction != null)
            {
                string at = row["ActionType"].ToString().ToLower();
                string label = row["ActionLabel"].ToString();
                string icon, css;

                if (at == "login") { icon = "ti-login"; css = "act-login"; }
                else if (at == "logout") { icon = "ti-logout"; css = "act-logout"; }
                else if (at == "create") { icon = "ti-plus"; css = "act-create"; }
                else if (at == "edit") { icon = "ti-pencil"; css = "act-edit"; }
                else if (at == "delete") { icon = "ti-trash"; css = "act-delete"; }
                else if (at == "message") { icon = "ti-message"; css = "act-message"; }
                else if (at == "upload") { icon = "ti-upload"; css = "act-upload"; }
                else if (at == "settings") { icon = "ti-settings"; css = "act-settings"; }
                else if (at == "cart") { icon = "ti-shopping-cart"; css = "act-cart"; }
                else if (at == "order") { icon = "ti-check"; css = "act-order"; }
                else if (at == "view") { icon = "ti-eye"; css = "act-view"; }
                else { icon = "ti-activity"; css = "act-login"; }

                lblAction.Text =
                    "<div class=\"col-action " + css + "\">" +
                    "<i class=\"ti " + icon + "\" aria-hidden=\"true\"></i>" +
                    System.Web.HttpUtility.HtmlEncode(label) +
                    "</div>";
            }

            // Device / IP cell
            Label lblDevice = (Label)e.Row.FindControl("lblDevice");
            if (lblDevice != null)
            {
                string device = System.Web.HttpUtility.HtmlEncode(row["DeviceName"].ToString());
                string ip = System.Web.HttpUtility.HtmlEncode(row["IPAddress"].ToString());
                lblDevice.Text = "<span class=\"col-device\"><strong>" + device + "</strong> · " + ip + "</span>";
            }

        }
        protected void lnkHome_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin.aspx");
        }
    }
}