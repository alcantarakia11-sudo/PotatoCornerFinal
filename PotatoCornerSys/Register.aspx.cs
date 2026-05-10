using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e) { }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            ClearAllErrors();

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string username = txtUsername.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            bool hasError = false;
            hasError |= Validate(string.IsNullOrEmpty(name), lblNameError, "Full name is required.");
            hasError |= Validate(name.Length < 2, lblNameError, "Full name must be at least 2 characters.");
            hasError |= Validate(!Regex.IsMatch(name, @"^[a-zA-Z\s]+$"), lblNameError, "Full name can only contain letters and spaces.");
            hasError |= Validate(string.IsNullOrEmpty(email), lblEmailError, "Email is required.");
            hasError |= Validate(!Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"), lblEmailError, "Please enter a valid email (e.g. user@email.com).");
            hasError |= Validate(string.IsNullOrEmpty(username), lblUsernameError, "Username is required.");
            hasError |= Validate(username.Length < 3, lblUsernameError, "Username must be at least 3 characters.");
            hasError |= Validate(username.Contains(" "), lblUsernameError, "Username cannot contain spaces.");
            hasError |= Validate(!Regex.IsMatch(username, @"^[a-zA-Z0-9_]+$"), lblUsernameError, "Username can only contain letters, numbers, and underscores.");
            hasError |= Validate(string.IsNullOrEmpty(phone), lblPhoneError, "Phone number is required.");
            hasError |= Validate(!phone.All(char.IsDigit), lblPhoneError, "Phone number can only contain numbers.");
            hasError |= Validate(phone.Length != 11, lblPhoneError, "Phone number must be exactly 11 digits.");
            hasError |= Validate(!phone.StartsWith("09"), lblPhoneError, "Phone number must start with 09.");
            hasError |= Validate(string.IsNullOrEmpty(address), lblAddressError, "Address is required.");
            hasError |= Validate(address.Length < 10, lblAddressError, "Please enter a complete address (at least 10 characters).");
            hasError |= Validate(Regex.IsMatch(address, @"[;'\-\-]"), lblAddressError, "Address contains invalid characters.");
            hasError |= Validate(string.IsNullOrEmpty(password), lblPasswordError, "Password is required.");
            hasError |= Validate(password.Length < 8, lblPasswordError, "Password must be at least 8 characters.");
            hasError |= Validate(!password.Any(char.IsLetter), lblPasswordError, "Password must contain at least one letter.");
            hasError |= Validate(!password.Any(char.IsDigit), lblPasswordError, "Password must contain at least one number.");
            hasError |= Validate(string.IsNullOrEmpty(confirmPassword), lblConfirmPasswordError, "Please confirm your password.");
            hasError |= Validate(password != confirmPassword, lblConfirmPasswordError, "Passwords do not match.");

            if (hasError) return;

            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    conn.Open();

                    if (IsDuplicate(conn, "UserName", username)) { ShowFieldError(lblUsernameError, "Username already taken. Please choose another."); return; }
                    if (IsDuplicate(conn, "Email", email)) { ShowFieldError(lblEmailError, "Email already registered. Please use a different one."); return; }
                    if (IsDuplicate(conn, "PhoneNumber", phone)) { ShowFieldError(lblPhoneError, "Phone number already registered."); return; }

                    string insertQuery = @"
                        INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                        VALUES (@Username, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Regular')";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Fullname", name);
                        cmd.Parameters.AddWithValue("@Address", address);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@Password", PasswordHelper.HashPassword(password));

                        if (cmd.ExecuteNonQuery() > 0)
                        {
                            // Add activity log for user registration
                            ActivityLogHelper.LogActivity(
                                "User Registration",
                                "New user registered: " + name,
                                name,
                                "USERS",
                                "Info"
                            );

                            lblMessage.Text = "✓ Registration successful! Redirecting to login...";
                            lblMessage.CssClass = "success-msg";
                            lblMessage.Visible = true;
                            txtName.Text = txtEmail.Text = txtUsername.Text = "";
                            txtPhone.Text = txtAddress.Text = "";
                            txtPassword.Text = txtConfirmPassword.Text = "";
                            Response.AddHeader("REFRESH", "3;URL=Login.aspx");
                        }
                        else
                        {
                            lblMessage.Text = "Registration failed. Please try again.";
                            lblMessage.CssClass = "error-msg";
                            lblMessage.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Database Error: " + ex.Message;
                lblMessage.CssClass = "error-msg";
                lblMessage.Visible = true;
                if (ex.InnerException != null)
                    lblMessage.Text += "<br/>Inner Error: " + ex.InnerException.Message;
            }
        }

        // ── HELPERS ────────────────────────────────────────────────

        private bool Validate(bool condition, Label lbl, string message)
        {
            if (condition && !lbl.Visible)
                ShowFieldError(lbl, message);
            return condition;
        }

        private bool IsDuplicate(SqlConnection conn, string column, string value)
        {
            string query = $"SELECT COUNT(*) FROM USERS WHERE {column} = @Value";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Value", value);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private void ShowFieldError(Label lbl, string message)
        {
            lbl.Text = "⚠ " + message;
            lbl.Visible = true;
        }

        private void ClearAllErrors()
        {
            lblNameError.Visible = false;
            lblEmailError.Visible = false;
            lblUsernameError.Visible = false;
            lblPhoneError.Visible = false;
            lblAddressError.Visible = false;
            lblPasswordError.Visible = false;
            lblConfirmPasswordError.Visible = false;
            lblMessage.Visible = false;
        }

        protected void lnkLogin_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx");
        }
    }
}