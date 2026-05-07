using System;
using System.Configuration;
using System.Data.SqlClient;

namespace PotatoCornerSys
{
    public partial class AdminLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in as admin, go straight to Admin.aspx
            if (Session["UserName"] != null)
            {
                Response.Redirect("Admin.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter both username and password.";
                lblError.Visible = true;
                return;
            }

            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string query = "SELECT UserName, Fullname FROM Admins WHERE UserName = @Username AND Password = @Password";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Password", password);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        if (reader.Read())
                        {
                            Session["UserName"] = reader["UserName"].ToString();
                            Session["Fullname"] = reader["Fullname"].ToString();
                            Response.Redirect("Admin.aspx");
                        }
                        else
                        {
                            lblError.Text = "Invalid username or password.";
                            lblError.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Error: " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}