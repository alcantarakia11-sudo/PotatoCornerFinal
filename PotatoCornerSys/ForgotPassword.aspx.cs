using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        // EmailJS Configuration - UPDATE THESE WITH YOUR ACTUAL VALUES
        private const string EMAILJS_SERVICE_ID = "service_z4kba64";
        private const string EMAILJS_TEMPLATE_ID = "template_rry3787"; // Replace with your actual template ID
        private const string EMAILJS_PUBLIC_KEY = "8VGysqqOfqOmHXgyR"; // Replace with your actual public key

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnSendCode_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            if (IsValidEmail(email))
            {
                // Generate random 6-digit code
                string resetCode = GenerateResetCode();

                // Get user name from database
                string userName = GetUserNameByEmail(email);

                if (string.IsNullOrEmpty(userName))
                {
                    ShowMessage("Email not found in our records.", "danger");
                    return;
                }

                // Store code in database with LONGER expiry (30 minutes)
                if (StoreResetCodeInDatabase(email, resetCode))
                {
                    // Store email in session
                    Session["ResetEmail"] = email;

                    // Register JavaScript to trigger EmailJS
                    string script = $@"
                        <script src='https://cdn.jsdelivr.net/npm/@emailjs/browser@3/dist/email.min.js'></script>
                        <script>
                            (function() {{
                                emailjs.init('{EMAILJS_PUBLIC_KEY}');
                                
                                const templateParams = {{
                                    to_email: '{email}',
                                    user_name: '{userName.Replace("'", "\\'")}',
                                    reset_code: '{resetCode}',
                                    email: '{email}'
                                }};
                                
                                emailjs.send('{EMAILJS_SERVICE_ID}', '{EMAILJS_TEMPLATE_ID}', templateParams)
                                    .then(function(response) {{
                                        console.log('Email sent successfully!', response);
                                        window.location.href = 'VerifyResetCode.aspx';
                                    }}, function(error) {{
                                        console.error('Failed to send email:', error);
                                        alert('Failed to send reset code. Error: ' + error.text);
                                    }});
                            }})();
                        </script>
                    ";

                    ClientScript.RegisterStartupScript(this.GetType(), "SendCode", script);
                }
                else
                {
                    ShowMessage("Failed to generate reset code. Please try again.", "danger");
                }
            }
            else
            {
                ShowMessage("Please enter a valid email address.", "danger");
            }
        }

        private string GenerateResetCode()
        {
            Random random = new Random();
            return random.Next(100000, 999999).ToString();
        }

        private bool StoreResetCodeInDatabase(string email, string code)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // First, mark any existing unused codes as expired
                    string cleanupQuery = @"UPDATE PasswordResetCodes 
                                          SET IsUsed = 1 
                                          WHERE Email = @Email AND IsUsed = 0";

                    using (SqlCommand cleanupCmd = new SqlCommand(cleanupQuery, conn))
                    {
                        cleanupCmd.Parameters.AddWithValue("@Email", email);
                        cleanupCmd.ExecuteNonQuery();
                    }

                    // Insert new code with 30 MINUTES expiry
                    string insertQuery = @"INSERT INTO PasswordResetCodes 
                                          (Email, ResetCode, ExpiryDate, IsUsed) 
                                          VALUES 
                                          (@Email, @Code, DATEADD(MINUTE, 30, GETDATE()), 0)";  // Changed to 30 minutes

                    using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@Email", email);
                        insertCmd.Parameters.AddWithValue("@Code", code);
                        return insertCmd.ExecuteNonQuery() > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error storing code: " + ex.Message);
                return false;
            }
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private string GetUserNameByEmail(string email)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                string query = "SELECT Username FROM Users WHERE Email = @Email";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        return result != null ? result.ToString() : "";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error getting username: " + ex.Message);
                return "";
            }
        }

        private void ShowMessage(string message, string type)
        {
            litMessage.Text = $@"
                <div class='alert alert-{type} alert-dismissible fade show' role='alert'>
                    {message}
                    <button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button>
                </div>
            ";
        }
    }
}