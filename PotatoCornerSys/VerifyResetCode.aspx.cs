using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class VerifyResetCode : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user came from ForgotPassword page
            if (Session["ResetEmail"] == null)
            {
                Response.Redirect("ForgotPassword.aspx");
            }
        }

        protected void btnVerifyCode_Click(object sender, EventArgs e)
        {
            string email = Session["ResetEmail"].ToString();
            string enteredCode = txtResetCode.Text.Trim();

            // Validate code format
            if (string.IsNullOrEmpty(enteredCode) || enteredCode.Length != 6)
            {
                ShowMessage("Please enter a valid 6-digit verification code.", "danger");
                return;
            }

            if (IsValidCode(email, enteredCode))
            {
                // Mark code as used so it can't be reused
                MarkCodeAsUsed(email, enteredCode);

                // Store in session that user can reset password
                Session["CanResetPassword"] = true;
                Session["ResetEmail"] = email;

                // Redirect to reset password page
                Response.Redirect("ResetPassword.aspx");
            }
            else
            {
                ShowMessage("Invalid or expired verification code. Please request a new code.", "danger");
            }
        }

        protected void lnkResendCode_Click(object sender, EventArgs e)
        {
            // Redirect back to ForgotPassword to resend code
            Response.Redirect("ForgotPassword.aspx");
        }

        protected void lnkBackToLogin_Click(object sender, EventArgs e)
        {
            // Clear sessions and go back to login
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private bool IsValidCode(string email, string code)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                // Check for code that is NOT used and expiry date is still valid (30 minutes)
                string query = @"SELECT COUNT(*) FROM PasswordResetCodes 
                               WHERE Email = @Email 
                               AND ResetCode = @Code 
                               AND IsUsed = 0 
                               AND ExpiryDate > GETDATE()";  // This checks if code is still valid (30 min expiry)

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Code", code);
                        conn.Open();
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error validating code: " + ex.Message);
                ShowMessage("An error occurred. Please try again.", "danger");
                return false;
            }
        }

        private void MarkCodeAsUsed(string email, string code)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                string query = @"UPDATE PasswordResetCodes 
                               SET IsUsed = 1 
                               WHERE Email = @Email AND ResetCode = @Code AND IsUsed = 0";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Code", code);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error marking code as used: " + ex.Message);
            }
        }

        private void ShowMessage(string message, string type)
        {
            litMessage.Text = string.Format(@"
                <div class='alert alert-{0} alert-dismissible fade show' role='alert'>
                    {1}
                    <button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
                </div>
            ", type, message);
        }
    }
}