using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class ProfileAdmin : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
                {
                    Response.Redirect("~/Login.aspx");
                }
                LoadAdminProfile();
            }
        }

        private void LoadAdminProfile()
        {
            string username = Session["UserName"].ToString();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"SELECT UserName, Fullname, Email, PhoneNumber, [Address], MembershipLevel
                                FROM USERS
                                WHERE UserName = @UserName";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@UserName", username);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    lblUsername.Text = reader["UserName"].ToString();
                    lblFullname.Text = reader["Fullname"].ToString();
                    lblEmail.Text = reader["Email"].ToString();
                    lblPhone.Text = reader["PhoneNumber"].ToString();
                    lblAddress.Text = reader["Address"].ToString();
                    lblRole.Text = reader["MembershipLevel"].ToString();
                }
                reader.Close();
                
                // Load statistics
                LoadStatistics(conn);
            }
        }

        private void LoadStatistics(SqlConnection conn)
        {
            // Total Users (excluding admins)
            string queryUsers = "SELECT COUNT(*) FROM USERS WHERE MembershipLevel != 'Admin'";
            SqlCommand cmdUsers = new SqlCommand(queryUsers, conn);
            lblTotalUsers.Text = cmdUsers.ExecuteScalar().ToString();

            // Total Orders
            string queryOrders = "SELECT COUNT(*) FROM Orders";
            SqlCommand cmdOrders = new SqlCommand(queryOrders, conn);
            lblTotalOrders.Text = cmdOrders.ExecuteScalar().ToString();

            // Pending Orders
            string queryPending = "SELECT COUNT(*) FROM Orders WHERE OrderStatus = 'Pending'";
            SqlCommand cmdPending = new SqlCommand(queryPending, conn);
            lblPendingOrders.Text = cmdPending.ExecuteScalar().ToString();

            // Total Revenue (includes No Show orders - customer paid but didn't pick up)
            string queryRevenue = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE OrderStatus NOT IN ('Cancelled')";
            SqlCommand cmdRevenue = new SqlCommand(queryRevenue, conn);
            decimal totalRevenue = Convert.ToDecimal(cmdRevenue.ExecuteScalar());
            lblTotalRevenue.Text = totalRevenue.ToString("N2");
        }

        protected void lnkSales_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sales.aspx");
        }

        protected void lnkUpdate_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Update.aspx");
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ProfileAdmin.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }

        protected void btnBackToDashboard_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin.aspx");
        }

        protected void btnDatabaseBackup_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/DatabaseBackup.aspx");
        }
    }
}
