using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

namespace PotatoCornerSys
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user verified the code
            if (Session["CanResetPassword"] == null || Session["ResetEmail"] == null)
            {
                Response.Redirect("ForgotPassword.aspx");
            }

            if (!IsPostBack)
            {
                // Display the user's email for confirmation
                litEmail.Text = Session["ResetEmail"].ToString();
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            string email = Session["ResetEmail"].ToString();
            string newPassword = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            // Validate passwords
            if (newPassword != confirmPassword)
            {
                ShowMessage("Passwords do not match!", "danger");
                return;
            }

            if (newPassword.Length < 6)
            {
                ShowMessage("Password must be at least 6 characters long!", "danger");
                return;
            }

            // Update password in database
            if (UpdatePassword(email, newPassword))
            {
                // Clear all sessions
                Session.Clear();

                // Show success and redirect to login
                ShowMessage("Password reset successful! Please login with your new password.", "success");

                // Redirect after 3 seconds
                Response.AddHeader("REFRESH", "3;URL=Login.aspx");
            }
            else
            {
                ShowMessage("Failed to reset password. Please try again.", "danger");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        private bool UpdatePassword(string email, string password)
        {
            try
            {
                // Hash the password
                string hashedPassword = HashPassword(password);

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                string query = "UPDATE Users SET Password = @Password WHERE Email = @Email";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                        cmd.Parameters.AddWithValue("@Email", email);
                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating password: " + ex.Message);
                return false;
            }
        }

        private string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hashedBytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(hashedBytes);
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