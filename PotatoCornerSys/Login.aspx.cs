using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

namespace PotatoCornerSys
{
    public partial class Login : System.Web.UI.Page
    {
        private static Dictionary<string, LoginAttempt> failedAttempts = new Dictionary<string, LoginAttempt>();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Only clear session if user is not already logged in
                if (Session["CustomerID"] == null)
                    Session.Clear();

                if (Request.QueryString["deleted"] == "true")
                {
                    lblError.Text = "Your account has been successfully deleted.";
                    lblError.Visible = true;
                }

                // Redirect already-logged-in users away from login page
                if (Session["CustomerID"] != null)
                    Response.Redirect("~/Profile.aspx");
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

            if (IsAccountLocked(username))
            {
                var attempt = failedAttempts[username];
                int secondsLeft = (int)Math.Ceiling((attempt.LockUntil - DateTime.Now).TotalSeconds);
                lblError.Text = $"Account suspended. Too many failed attempts. Please try again in {secondsLeft} second(s).";
                lblError.Visible = true;
                return;
            }

            int customerID = 0;
            string userRole = "Customer";

            if (ValidateUser(username, password, out customerID, out userRole))
            {
                ClearFailedAttempts(username);

                Session["Username"] = username;
                Session["CustomerID"] = customerID;
                Session["UserRole"] = userRole;
                Session["LoggedIn"] = true;
                Session["IsLoggedIn"] = true;

                if (userRole == "Admin" || userRole == "Staff")
                    Response.Redirect("Sales.aspx");
                else
                    Response.Redirect("Profile.aspx");
            }
            else
            {
                RecordFailedAttempt(username);
                int remaining = GetRemainingAttempts(username);

                if (remaining <= 0)
                    lblError.Text = "Account suspended for 1 minute due to 5 failed login attempts. Please try again later.";
                else
                    lblError.Text = $"Incorrect username or password. {remaining} attempt(s) remaining before account is suspended.";

                lblError.Visible = true;
            }
        }

        protected void lnkRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("Register.aspx");
        }

        private bool ValidateUser(string username, string password, out int customerID, out string role)
        {
            customerID = 0;
            role = "Customer";

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                // Check USERS table first (customers)
                string query = @"
                    SELECT CustomerID, [Password], 'Customer' AS Role
                    FROM USERS
                    WHERE UserName = @Username OR Email = @Username";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            customerID = Convert.ToInt32(reader["CustomerID"]);
                            role = reader["Role"].ToString();
                            string storedPassword = reader["Password"].ToString();

                            System.Diagnostics.Debug.WriteLine($"Stored:  {storedPassword}");
                            System.Diagnostics.Debug.WriteLine($"Entered: {PasswordHelper.HashPassword(password)}");

                            return PasswordHelper.VerifyPassword(password, storedPassword);
                        }
                    }
                }

                // If not found in USERS, check Admins table
                string adminQuery = @"
    SELECT AdminID, [Password], 'Admin' AS Role
    FROM Admins
    WHERE Username = @Username";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(adminQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            customerID = Convert.ToInt32(reader["AdminID"]);
                            role = reader["Role"].ToString();
                            string storedPassword = reader["Password"].ToString();

                            return PasswordHelper.VerifyPassword(password, storedPassword);
                        }
                    }
                }

                return false;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login validation error: " + ex.Message);
                lblError.Text = "Error: " + ex.Message; // ← shows exact error on screen
                lblError.Visible = true;
                return false;
            }
        }

        private bool IsAccountLocked(string username)
        {
            if (!failedAttempts.ContainsKey(username)) return false;

            var attempt = failedAttempts[username];

            if (attempt.FailedCount >= 5 && DateTime.Now < attempt.LockUntil)
                return true;

            // Lock expired — reset
            if (attempt.FailedCount >= 5 && DateTime.Now >= attempt.LockUntil)
                failedAttempts.Remove(username);

            return false;
        }

        private void RecordFailedAttempt(string username)
        {
            if (!failedAttempts.ContainsKey(username))
            {
                failedAttempts[username] = new LoginAttempt { FailedCount = 1, LockUntil = DateTime.Now };
                return;
            }

            var attempt = failedAttempts[username];
            attempt.FailedCount++;

            if (attempt.FailedCount >= 5)
                attempt.LockUntil = DateTime.Now.AddMinutes(1);
        }

        private void ClearFailedAttempts(string username)
        {
            if (failedAttempts.ContainsKey(username))
                failedAttempts.Remove(username);
        }

        private int GetRemainingAttempts(string username)
        {
            if (!failedAttempts.ContainsKey(username)) return 5;
            return Math.Max(0, 5 - failedAttempts[username].FailedCount);
        }

        private class LoginAttempt
        {
            public int FailedCount { get; set; }
            public DateTime LockUntil { get; set; }
        }
    }
}