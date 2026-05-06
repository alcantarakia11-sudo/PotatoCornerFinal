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
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblError.Text = "Please enter your email and password.";
                lblError.Visible = true;
                return;
            }

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT CustomerID, UserName, Fullname, Email, PhoneNumber, [Address], Points, MembershipLevel
                        FROM USERS 
                        WHERE (UserName = @Username OR Email = @Username) AND [Password] = @Password";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Password", password);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["CustomerID"] = reader["CustomerID"].ToString();
                                Session["Username"] = reader["UserName"].ToString();
                                Session["Name"] = reader["Fullname"].ToString();
                                Session["Email"] = reader["Email"].ToString();
                                Session["Phone"] = reader["PhoneNumber"].ToString();
                                Session["Address"] = reader["Address"].ToString();
                                Session["Points"] = reader["Points"].ToString();
                                Session["MembershipLevel"] = reader["MembershipLevel"].ToString();
                                Session["IsLoggedIn"] = true;
                                Session["MemberSince"] = DateTime.Now.ToString("MMM dd, yyyy");

                                if (reader["MembershipLevel"].ToString() == "Royalty")
                                {
                                    Session["HasRoyaltyMembership"] = true;
                                }

                                Response.Redirect("~/Default.aspx");
                            }
                            else
                            {
                                lblError.Text = "Invalid username or password. Please try again.";
                                lblError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Login system temporarily unavailable. Please try again later.";
                lblError.Visible = true;
            }
        }

        protected void lnkRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Register.aspx");
        }
    }
}
