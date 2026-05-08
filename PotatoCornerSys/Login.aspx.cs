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
        // Track failed attempts (in production, store in database)
        private static Dictionary<string, LoginAttempt> failedAttempts = new Dictionary<string, LoginAttempt>();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear any existing session on page load
            if (!IsPostBack)
            {
                Session.Clear();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Check if account is locked
            if (IsAccountLocked(username))
            {
                lblError.Text = "Account is temporarily locked due to multiple failed attempts. Please try again later.";
                lblError.Visible = true;
                return;
            }

            // Validate login
            if (ValidateUser(username, password))
            {
                // Clear failed attempts on successful login
                ClearFailedAttempts(username);

                // Set session variables
                Session["Username"] = username;
                Session["UserRole"] = GetUserRole(username);
                Session["LoggedIn"] = true;

                // Redirect to dashboard or sales page
                Response.Redirect("Sales.aspx");
            }
            else
            {
                // Record failed attempt
                RecordFailedAttempt(username);

                // Show error message
                int remainingAttempts = GetRemainingAttempts(username);
                lblError.Text = $"Invalid username or password. You have {remainingAttempts} attempt(s) remaining before lockout.";
                lblError.Visible = true;
            }
        }

        protected void lnkRegister_Click(object sender, EventArgs e)
        {
            Response.Redirect("Register.aspx");
        }

        // Forgot password is handled by HyperLink control - no code needed in code-behind
        // The HyperLink NavigateUrl="~/ForgotPassword.aspx" handles the redirect automatically

        private bool ValidateUser(string username, string password)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                string query = "SELECT COUNT(*) FROM Users WHERE Username = @Username AND Password = @Password";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Password", password); // In production, use hashed password
                        conn.Open();
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login error: " + ex.Message);
                return false;
            }
        }

        private string GetUserRole(string username)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                string query = "SELECT Role FROM Users WHERE Username = @Username";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        return result != null ? result.ToString() : "User";
                    }
                }
            }
            catch
            {
                return "User";
            }
        }

        private bool IsAccountLocked(string username)
        {
            if (failedAttempts.ContainsKey(username))
            {
                var attempt = failedAttempts[username];
                if (attempt.FailedCount >= 5) // Lock after 5 attempts
                {
                    // Check if lock duration has passed (3 minutes for 5+ attempts)
                    if (DateTime.Now < attempt.LockUntil)
                    {
                        return true;
                    }
                    else
                    {
                        // Lock expired, reset attempts
                        failedAttempts.Remove(username);
                    }
                }
                else if (attempt.FailedCount >= 3) // Lock after 3 attempts (1 minute)
                {
                    if (DateTime.Now < attempt.LockUntil)
                    {
                        return true;
                    }
                    else
                    {
                        // Lock expired, reset attempts
                        failedAttempts.Remove(username);
                    }
                }
            }
            return false;
        }

        private void RecordFailedAttempt(string username)
        {
            if (failedAttempts.ContainsKey(username))
            {
                var attempt = failedAttempts[username];
                attempt.FailedCount++;

                // Set lock duration based on attempt count
                if (attempt.FailedCount >= 5)
                {
                    attempt.LockUntil = DateTime.Now.AddMinutes(3); // 3 minutes lock
                }
                else if (attempt.FailedCount >= 3)
                {
                    attempt.LockUntil = DateTime.Now.AddMinutes(1); // 1 minute lock
                }
            }
            else
            {
                var attempt = new LoginAttempt
                {
                    FailedCount = 1,
                    LockUntil = DateTime.Now
                };
                failedAttempts.Add(username, attempt);
            }
        }

        private void ClearFailedAttempts(string username)
        {
            if (failedAttempts.ContainsKey(username))
            {
                failedAttempts.Remove(username);
            }
        }

        private int GetRemainingAttempts(string username)
        {
            if (failedAttempts.ContainsKey(username))
            {
                var attempt = failedAttempts[username];
                if (attempt.FailedCount >= 3)
                {
                    return 0;
                }
                return 3 - attempt.FailedCount;
            }
            return 3;
        }

        // Inner class to track login attempts
        private class LoginAttempt
        {
            public int FailedCount { get; set; }
            public DateTime LockUntil { get; set; }
        }
    }
}