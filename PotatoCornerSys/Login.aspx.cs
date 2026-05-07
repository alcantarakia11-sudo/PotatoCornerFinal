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
        private const int FirstLockThreshold = 3;
        private const int SecondLockThreshold = 5;
        private static readonly TimeSpan FirstLockDuration = TimeSpan.FromMinutes(1);
        private static readonly TimeSpan SecondLockDuration = TimeSpan.FromMinutes(3);
        private static readonly object LoginAttemptSync = new object();
        private static readonly Dictionary<string, LoginAttemptState> LoginAttempts = new Dictionary<string, LoginAttemptState>(StringComparer.OrdinalIgnoreCase);

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
                if (IsUserLockedOut(username, out DateTime lockedUntil, out int currentFailedAttempts))
                {
                    TimeSpan remaining = lockedUntil - DateTime.UtcNow;
                    int remainingSeconds = Math.Max(1, (int)Math.Ceiling(remaining.TotalSeconds));
                    lblError.Text = "Account temporarily locked. Try again in " + remainingSeconds + " second(s).";
                    lblError.Visible = true;
                    return;
                }

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT CustomerID, UserName, Fullname, Email, PhoneNumber, [Address], Points, MembershipLevel, [Password]
                        FROM USERS 
                        WHERE (UserName = @Username OR Email = @Username)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedPassword = reader["Password"].ToString();
                                
                                // Check if password is hashed (64 characters for SHA256) or plain text
                                bool isPasswordValid = false;
                                
                                if (storedPassword.Length == 64)
                                {
                                    // Password is hashed, verify using hash
                                    isPasswordValid = PasswordHelper.VerifyPassword(password, storedPassword);
                                }
                                else
                                {
                                    // Password is plain text (backward compatibility)
                                    isPasswordValid = (password == storedPassword);
                                }
                                
                                if (!isPasswordValid)
                                {
                                    int updatedAttempts = RegisterFailedAttempt(username, currentFailedAttempts);
                                    if (updatedAttempts >= SecondLockThreshold)
                                    {
                                        lblError.Text = "Too many failed attempts. Account locked for 3 minutes.";
                                    }
                                    else if (updatedAttempts >= FirstLockThreshold)
                                    {
                                        lblError.Text = "Too many failed attempts. Account locked for 1 minute.";
                                    }
                                    else
                                    {
                                        int remainingBeforeLock = FirstLockThreshold - updatedAttempts;
                                        lblError.Text = "Invalid email or password. " + remainingBeforeLock + " attempt(s) left before temporary lock.";
                                    }
                                    lblError.Visible = true;
                                    return;
                                }
                                ResetFailedAttempts(username);
                                Session["CustomerID"] = reader["CustomerID"].ToString();
                                Session["Username"] = reader["UserName"].ToString();
                                Session["UserName"] = reader["UserName"].ToString();
                                Session["Fullname"] = reader["Fullname"].ToString();
                                Session["Name"] = reader["Fullname"].ToString();
                                Session["Email"] = reader["Email"].ToString();
                                Session["Phone"] = reader["PhoneNumber"].ToString();
                                Session["Address"] = reader["Address"].ToString();
                                Session["Points"] = reader["Points"].ToString();
                                Session["MembershipLevel"] = reader["MembershipLevel"].ToString();
                                Session["IsLoggedIn"] = true;
                                Session["MemberSince"] = DateTime.Now.ToString("MMM dd, yyyy");

                                string membershipLevel = reader["MembershipLevel"].ToString();

                                if (membershipLevel == "Royalty")
                                {
                                    Session["HasRoyaltyMembership"] = true;
                                }

                                // Redirect admin users to Admin.aspx
                                if (membershipLevel == "Admin")
                                {
                                    Response.Redirect("~/Admin.aspx");
                                }
                                else
                                {
                                    Response.Redirect("~/Default.aspx");
                                }
                            }
                            else
                            {
                                int updatedAttempts = RegisterFailedAttempt(username, currentFailedAttempts);
                                if (updatedAttempts >= SecondLockThreshold)
                                {
                                    lblError.Text = "Too many failed attempts. Account locked for 3 minutes.";
                                }
                                else if (updatedAttempts >= FirstLockThreshold)
                                {
                                    lblError.Text = "Too many failed attempts. Account locked for 1 minute.";
                                }
                                else
                                {
                                    int remainingBeforeLock = FirstLockThreshold - updatedAttempts;
                                    lblError.Text = "Invalid email or password. " + remainingBeforeLock + " attempt(s) left before temporary lock.";
                                }
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

        private bool IsUserLockedOut(string username, out DateTime lockedUntilUtc, out int failedAttempts)
        {
            lockedUntilUtc = DateTime.MinValue;
            failedAttempts = 0;

            lock (LoginAttemptSync)
            {
                if (!LoginAttempts.TryGetValue(username, out LoginAttemptState state))
                {
                    return false;
                }

                failedAttempts = state.FailedAttempts;
                if (state.LockedUntilUtc.HasValue && state.LockedUntilUtc.Value > DateTime.UtcNow)
                {
                    lockedUntilUtc = state.LockedUntilUtc.Value;
                    return true;
                }

                state.LockedUntilUtc = null;
                return false;
            }
        }

        private int RegisterFailedAttempt(string username, int currentFailedAttempts)
        {
            lock (LoginAttemptSync)
            {
                if (!LoginAttempts.TryGetValue(username, out LoginAttemptState state))
                {
                    state = new LoginAttemptState();
                    LoginAttempts[username] = state;
                }

                state.FailedAttempts = Math.Max(currentFailedAttempts, state.FailedAttempts) + 1;

                if (state.FailedAttempts >= SecondLockThreshold)
                {
                    state.LockedUntilUtc = DateTime.UtcNow.Add(SecondLockDuration);
                }
                else if (state.FailedAttempts >= FirstLockThreshold)
                {
                    state.LockedUntilUtc = DateTime.UtcNow.Add(FirstLockDuration);
                }
                else
                {
                    state.LockedUntilUtc = null;
                }

                return state.FailedAttempts;
            }
        }

        private void ResetFailedAttempts(string username)
        {
            lock (LoginAttemptSync)
            {
                LoginAttempts.Remove(username);
            }
        }

        private class LoginAttemptState
        {
            public int FailedAttempts { get; set; }
            public DateTime? LockedUntilUtc { get; set; }
        }
    }
}