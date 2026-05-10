using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class RegisterForm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (IsAlreadyRoyaltyMember())
                {
                    string script = @"
                        document.addEventListener('DOMContentLoaded', function() {
                            showAlreadyMemberModal();
                        });
                    ";
                    ClientScript.RegisterStartupScript(this.GetType(), "AlreadyMember", script, true);
                    return;
                }

                // Pre-fill from session if available, otherwise load from DB
                string fullName = Session["Name"]?.ToString()
                               ?? Session["Fullname"]?.ToString();
                string email    = Session["Email"]?.ToString();
                string phone    = Session["Phone"]?.ToString();

                if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
                {
                    LoadUserDataFromDb(out fullName, out email, out phone);
                }

                txtFullName.Text = fullName ?? "";
                txtEmail.Text    = email    ?? "";
                txtContact.Text  = phone    ?? "";
            }

            // Keep read-only on every load/postback
            txtFullName.ReadOnly = true;
            txtEmail.ReadOnly    = true;
            txtContact.ReadOnly  = true;
        }

        private void LoadUserDataFromDb(out string fullName, out string email, out string phone)
        {
            fullName = email = phone = "";
            try
            {
                int customerID = 0;
                if (Session["CustomerID"] != null)
                    int.TryParse(Session["CustomerID"].ToString(), out customerID);
                if (customerID == 0) return;

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT Fullname, Email, PhoneNumber FROM USERS WHERE CustomerID = @CustomerID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                fullName = reader["Fullname"]?.ToString() ?? "";
                                email    = reader["Email"]?.ToString()    ?? "";
                                phone    = reader["PhoneNumber"]?.ToString() ?? "";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading user data: " + ex.Message);
            }
        }

        private bool IsAlreadyRoyaltyMember()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);

                    if (customerID == 0) return false;

                    // Block re-submission if already confirmed OR still pending
                    string query = @"
                        SELECT COUNT(*) 
                        FROM Membership
                        WHERE CustomerID = @CustomerID
                          AND RequestStatus IN ('Confirmed', 'Pending')";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking membership: " + ex.Message);
                return false;
            }
        }



        // ── STEP 1: Validate fields, then route to correct payment flow ────────
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Field validation
            if (string.IsNullOrWhiteSpace(txtFullName.Text) ||
                string.IsNullOrWhiteSpace(txtEmail.Text) ||
                string.IsNullOrWhiteSpace(txtContact.Text))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            // ✅ FIX: Only require a new upload if nothing is saved in Session yet
            bool hasNewFile = fileUploadPicture.HasFile;
            bool hasSessionFile = Session["UploadedFileBytes"] != null;

            if (!hasNewFile && !hasSessionFile)
            {
                ShowMessage("Please upload your profile picture.", false);
                return;
            }

            // ✅ FIX: Validate and save file to Session immediately on first postback
            if (hasNewFile)
            {
                string fileExtension = Path.GetExtension(fileUploadPicture.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
                if (!allowedExtensions.Contains(fileExtension))
                {
                    ShowMessage("Please upload a valid image file (JPG, JPEG, PNG, GIF).", false);
                    return;
                }

                // Save to Session so it survives subsequent postbacks
                Session["UploadedFileBytes"] = fileUploadPicture.FileBytes;
                Session["UploadedFileExtension"] = fileExtension;
            }

            if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
            {
                ShowMessage("Please select a payment method.", false);
                return;
            }

            // Route: QR-based payment — show modal
            ScriptManager.RegisterStartupScript(this, GetType(), "showQR",
                $"showQRCodeModal('{hdnPaymentMethod.Value}', '100.00');", true);
        }

        // ── STEP 2A: QR payment confirmed (GoTyme, Maya, GCash) ───────────────
        protected void btnSubmitPaymentModal_Click(object sender, EventArgs e)
        {
            string enteredReference = txtPaymentReferenceModal.Text.Trim().ToUpper();
            string generatedReference = hdnGeneratedReference.Value;

            // Validate format
            if (!enteredReference.StartsWith("REF-") || enteredReference.Length < 15)
            {
                ShowMessage("Invalid reference number format. Please scan the QR code and enter the correct reference.", false);
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    $"showQRCodeModal('{hdnPaymentMethod.Value}', '100.00');", true);
                return;
            }

            // Validate it matches the generated reference
            if (enteredReference != generatedReference)
            {
                ShowMessage("Reference number does not match. Please scan the QR code and enter the correct reference.", false);
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    $"showQRCodeModal('{hdnPaymentMethod.Value}', '100.00');", true);
                return;
            }

            // Check DB for duplicate reference
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string checkQuery = "SELECT COUNT(*) FROM Membership WHERE PaymentReference = @Reference";
                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Reference", enteredReference);
                        int count = (int)cmd.ExecuteScalar();

                        if (count > 0)
                        {
                            ShowMessage("This reference number has already been used. Please generate a new QR code.", false);
                            ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                                $"showQRCodeModal('{hdnPaymentMethod.Value}', '100.00');", true);
                            return;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error validating reference: " + ex.Message, false);
                return;
            }

            // All checks passed — process registration with reference
            ProcessRegistration(enteredReference);
        }

        // ── STEP 3: Save everything to DB ─────────────────────────────────────
        private void ProcessRegistration(string paymentReference)
        {
            try
            {
                decimal amountPaid = 100.00m;
                decimal change = 0;

                // ✅ FIX: Read file bytes from Session instead of the file upload control
                byte[] imageBytes = Session["UploadedFileBytes"] as byte[];
                string fileExtension = Session["UploadedFileExtension"]?.ToString() ?? ".jpg";

                if (imageBytes == null || imageBytes.Length == 0)
                {
                    ShowMessage("Profile picture was lost. Please re-upload your picture and try again.", false);
                    return;
                }

                // Generate unique royalty number
                Random random = new Random();
                string royaltyNumber = "PC" + random.Next(10000, 99999).ToString();

                string fileName = royaltyNumber + fileExtension;

                string uploadsFolder = Server.MapPath("~/Uploads/");
                if (!Directory.Exists(uploadsFolder))
                    Directory.CreateDirectory(uploadsFolder);

                // ✅ FIX: Write bytes from Session instead of using SaveAs (which requires HasFile)
                File.WriteAllBytes(Path.Combine(uploadsFolder, fileName), imageBytes);

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);

                    if (customerID == 0)
                    {
                        string insertGuestQuery = @"
                            INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                            VALUES (@UserName, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Guest');
                            SELECT SCOPE_IDENTITY();";

                        using (SqlCommand guestCmd = new SqlCommand(insertGuestQuery, conn))
                        {
                            guestCmd.Parameters.AddWithValue("@UserName", "member_" + txtContact.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Fullname", txtFullName.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Address", "Not provided");
                            guestCmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Phone", txtContact.Text.Trim());
                            guestCmd.Parameters.AddWithValue("@Password", "member123");
                            customerID = Convert.ToInt32(guestCmd.ExecuteScalar());
                            Session["CustomerID"] = customerID.ToString();
                        }
                    }

                    // Insert membership record with Pending status — admin must confirm via Sales.aspx
                    string insertQuery = @"
                        INSERT INTO Membership 
                            (CustomerID, MembershipNumber, Points, RegistrationDate, 
                             ProfilePicture, PictureFileName, PaymentMethod, PaymentReference,
                             RequestStatus, RequestedDate)
                        VALUES 
                            (@CustomerID, @MembershipNumber, @Points, @RegistrationDate, 
                             @ProfilePicture, @PictureFileName, @PaymentMethod, @PaymentReference,
                             'Pending', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.Parameters.AddWithValue("@MembershipNumber", royaltyNumber);
                        cmd.Parameters.AddWithValue("@Points", 0);
                        cmd.Parameters.AddWithValue("@RegistrationDate", DateTime.Now);
                        cmd.Parameters.Add("@ProfilePicture", System.Data.SqlDbType.VarBinary).Value = imageBytes;
                        cmd.Parameters.AddWithValue("@PictureFileName", "PotatoCornerSys/Uploads/" + fileName);
                        cmd.Parameters.AddWithValue("@PaymentMethod", hdnPaymentMethod.Value);
                        cmd.Parameters.AddWithValue("@PaymentReference",
                            !string.IsNullOrEmpty(paymentReference) ? (object)paymentReference : DBNull.Value);

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            // DO NOT upgrade to Royalty yet — admin must confirm via Sales.aspx
                            // MembershipLevel stays as-is until ApproveMembershipRequest is called

                            // Clean up file bytes from Session after successful registration
                            Session.Remove("UploadedFileBytes");
                            Session.Remove("UploadedFileExtension");

                            // Store session — pending state
                            Session["RoyaltyNumber"] = royaltyNumber;
                            Session["MemberFullName"] = txtFullName.Text.Trim();
                            Session["MemberEmail"] = txtEmail.Text.Trim();
                            Session["MemberContact"] = txtContact.Text.Trim();
                            Session["MemberPicture"] = "~/Uploads/" + fileName;
                            Session["RegistrationDate"] = DateTime.Now.ToString("MMMM dd, yyyy");
                            Session["RegistrationFee"] = "100.00";
                            Session["PaymentMethod"] = hdnPaymentMethod.Value;
                            Session["AmountPaid"] = amountPaid.ToString("0.00");
                            Session["ChangeAmount"] = change.ToString("0.00");
                            Session["HasRoyaltyMembership"] = false;
                            Session["MembershipRequestPending"] = true;

                            // Add activity log
                            string fullName = txtFullName.Text.Trim();
                            ActivityLogHelper.LogActivity(
                                "Membership Registration",
                                "Membership registration submitted (pending admin approval): " + fullName + " (Card #" + royaltyNumber + ")",
                                fullName,
                                "Royalty Membership",
                                "Info"
                            );

                            ShowMessage("Registration submitted! Your application is pending admin confirmation. You will be notified once approved.", true);
                            Response.AddHeader("REFRESH", "3;URL=Profile.aspx");
                        }
                        else
                        {
                            ShowMessage("Registration failed. Please try again.", false);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Registration error: " + ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "success-msg" : "error-msg";
            lblMessage.Visible = true;
        }
    }
}