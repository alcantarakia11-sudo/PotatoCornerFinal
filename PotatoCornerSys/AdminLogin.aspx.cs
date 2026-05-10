using System;
using System.Configuration;
using System.Data.SqlClient;

namespace PotatoCornerSys
{
    public partial class AdminLogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, skip the login page
            if (Session["AdminID"] != null)
            {
                Response.Redirect("Admin.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT UserName, Fullname FROM Admins WHERE UserName = @Username AND Password = @Password", conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", txtUsername.Text.Trim());
                        cmd.Parameters.AddWithValue("@Password", txtPassword.Text.Trim());

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["AdminID"] = reader["UserName"].ToString();
                                Session["AdminName"] = reader["Fullname"].ToString();
                                Session["AdminRole"] = "Administrator";

                                // Also set these so Admin.aspx can read them
                                Session["UserName"] = reader["UserName"].ToString();
                                Session["Fullname"] = reader["Fullname"].ToString();
                                Session["MembershipLevel"] = "Admin";

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
            }
            catch (Exception ex)
            {
                lblError.Text = "FULL ERROR: " + ex.GetType().Name + " — " + ex.Message;
                if (ex.InnerException != null)
                    lblError.Text += " | INNER: " + ex.InnerException.Message;
                lblError.Visible = true;
            }
        }
    }
}