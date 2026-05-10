using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web.UI;

namespace PotatoCornerSys
{
    public partial class DatabaseBackup : System.Web.UI.Page
    {
        private string backupFolder = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
            {
                Response.Redirect("~/AdminLogin.aspx");
            }

            backupFolder = Server.MapPath("~/Backups/");

            if (!Directory.Exists(backupFolder))
                Directory.CreateDirectory(backupFolder);

            if (!IsPostBack)
                LoadBackupHistory();
        }

        protected void btnBackup_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager
                    .ConnectionStrings["PotatoCornerDB"].ConnectionString;

                SqlConnectionStringBuilder builder =
                    new SqlConnectionStringBuilder(connectionString);
                string dbName = builder.InitialCatalog;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // ✅ Export ALL tables into one Excel-friendly CSV
                    StringBuilder csv = new StringBuilder();
                    string timestamp = DateTime.Now.ToString("yyyyMMdd_HHmmss");

                    // ======== USERS ========
                    csv.AppendLine("=== USERS ===");
                    csv.AppendLine("CustomerID,UserName,Fullname,Email,PhoneNumber," +
                        "Address,Points,MembershipLevel,DateCreated");

                    string usersQuery = @"
                SELECT CustomerID, UserName, Fullname, Email, PhoneNumber,
                       [Address], Points, MembershipLevel, DateCreated
                FROM USERS
                ORDER BY DateCreated DESC";

                    using (SqlCommand cmd = new SqlCommand(usersQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["CustomerID"]}," +
                                $"{reader["UserName"]}," +
                                $"\"{reader["Fullname"]}\"," +
                                $"{reader["Email"]}," +
                                $"{reader["PhoneNumber"]}," +
                                $"\"{reader["Address"]}\"," +
                                $"{reader["Points"]}," +
                                $"{reader["MembershipLevel"]}," +
                                $"{reader["DateCreated"]}");
                        }
                    }

                    csv.AppendLine();

                    // ======== ORDERS ========
                    csv.AppendLine("=== ORDERS ===");
                    csv.AppendLine("OrderID,OrderDate,CustomerName,Email,PhoneNumber," +
                        "DeliveryType,TotalAmount,Discount,AmountPaid,ChangeAmount," +
                        "PaymentMethod,OrderStatus,TotalQuantity");

                    string ordersQuery = @"
                SELECT o.OrderID, o.OrderDate, u.Fullname AS CustomerName,
                       u.Email, u.PhoneNumber, o.DeliveryType, o.TotalAmount,
                       o.Discount, o.AmountPaid, o.ChangeAmount,
                       o.PaymentMethod, o.OrderStatus, o.TotalQuantity
                FROM Orders o
                INNER JOIN USERS u ON o.CustomerID = u.CustomerID
                ORDER BY o.OrderDate DESC";

                    using (SqlCommand cmd = new SqlCommand(ordersQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["OrderID"]}," +
                                $"{reader["OrderDate"]}," +
                                $"\"{reader["CustomerName"]}\"," +
                                $"{reader["Email"]}," +
                                $"{reader["PhoneNumber"]}," +
                                $"{reader["DeliveryType"]}," +
                                $"{reader["TotalAmount"]}," +
                                $"{reader["Discount"]}," +
                                $"{reader["AmountPaid"]}," +
                                $"{reader["ChangeAmount"]}," +
                                $"{reader["PaymentMethod"]}," +
                                $"{reader["OrderStatus"]}," +
                                $"{reader["TotalQuantity"]}");
                        }
                    }

                    csv.AppendLine();

                    // ======== ORDER ITEMS ========
                    csv.AppendLine("=== ORDER ITEMS ===");
                    csv.AppendLine("OrderItemID,OrderID,ProductName,SizeName," +
                        "FlavorName,Quantity,UnitPrice,TotalPrice");

                    string itemsQuery = @"
                SELECT oi.OrderItemID, oi.OrderID, p.ProductName,
                       ps.SizeName, pf.FlavorName,
                       oi.Quantity, oi.UnitPrice, oi.TotalPrice
                FROM OrderItems oi
                INNER JOIN Products p ON oi.ProductID = p.ProductID
                LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
                LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                ORDER BY oi.OrderID";

                    using (SqlCommand cmd = new SqlCommand(itemsQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["OrderItemID"]}," +
                                $"{reader["OrderID"]}," +
                                $"\"{reader["ProductName"]}\"," +
                                $"{(reader["SizeName"] == DBNull.Value ? "N/A" : reader["SizeName"])}," +
                                $"{(reader["FlavorName"] == DBNull.Value ? "N/A" : reader["FlavorName"])}," +
                                $"{reader["Quantity"]}," +
                                $"{reader["UnitPrice"]}," +
                                $"{reader["TotalPrice"]}");
                        }
                    }

                    csv.AppendLine();

                    // ======== MEMBERSHIP ========
                    csv.AppendLine("=== MEMBERSHIP ===");
                    csv.AppendLine("CustomerID,Fullname,MembershipNumber," +
                        "MembershipLevel,RegistrationDate,Points");

                    string memberQuery = @"
                SELECT m.CustomerID, u.Fullname, m.MembershipNumber,
                       u.MembershipLevel, m.RegistrationDate, m.Points
                FROM Membership m
                INNER JOIN USERS u ON m.CustomerID = u.CustomerID
                ORDER BY m.RegistrationDate DESC";

                    using (SqlCommand cmd = new SqlCommand(memberQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["CustomerID"]}," +
                                $"\"{reader["Fullname"]}\"," +
                                $"{reader["MembershipNumber"]}," +
                                $"{reader["MembershipLevel"]}," +
                                $"{reader["RegistrationDate"]}," +
                                $"{reader["Points"]}");
                        }
                    }

                    // ✅ Save to project Backups folder for Recent Backups display
                    string backupFileName = $"PotatoCorner_Backup_{timestamp}.csv";
                    string savePath = Path.Combine(backupFolder, backupFileName);
                    File.WriteAllText(savePath, csv.ToString(), Encoding.UTF8);

                    // ✅ Download to user's computer
                    Response.Clear();
                    Response.ContentType = "application/vnd.ms-excel";
                    Response.AddHeader("Content-Disposition",
                        $"attachment; filename={backupFileName}");
                    Response.Write(csv.ToString());
                    Response.End();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(lblBackupMessage,
                    $"✗ Backup failed: {ex.Message}", "error");
            }
        }



        protected void btnExportOrders_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager
                    .ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Export ALL orders for admin
                    string query = @"
                SELECT o.OrderID, o.OrderDate, u.Fullname AS CustomerName,
                       u.Email, u.PhoneNumber, o.DeliveryType, o.TotalAmount,
                       o.Discount, o.AmountPaid, o.ChangeAmount,
                       o.PaymentMethod, o.OrderStatus, o.TotalQuantity
                FROM Orders o
                INNER JOIN USERS u ON o.CustomerID = u.CustomerID
                ORDER BY o.OrderDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        StringBuilder csv = new StringBuilder();
                        csv.AppendLine("OrderID,OrderDate,CustomerName,Email," +
                            "PhoneNumber,DeliveryType,TotalAmount,Discount," +
                            "AmountPaid,ChangeAmount,PaymentMethod,OrderStatus,TotalQuantity");

                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["OrderID"]}," +
                                $"{reader["OrderDate"]}," +
                                $"\"{reader["CustomerName"]}\"," +
                                $"{reader["Email"]}," +
                                $"{reader["PhoneNumber"]}," +
                                $"{reader["DeliveryType"]}," +
                                $"{reader["TotalAmount"]}," +
                                $"{reader["Discount"]}," +
                                $"{reader["AmountPaid"]}," +
                                $"{reader["ChangeAmount"]}," +
                                $"{reader["PaymentMethod"]}," +
                                $"{reader["OrderStatus"]}," +
                                $"{reader["TotalQuantity"]}");
                        }

                        string filename = $"AllOrders_Export_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                        Response.Clear();
                        Response.ContentType = "text/csv";
                        Response.AddHeader("Content-Disposition", $"attachment; filename={filename}");
                        Response.Write(csv.ToString());
                        Response.End();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(lblExportMessage, $"✗ Export Orders failed: {ex.Message}", "error");
            }
        }

        protected void btnExportUsers_Click(object sender, EventArgs e)
        {
            try
            {
                string connectionString = ConfigurationManager
                    .ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Export ALL users for admin
                    string query = @"
                SELECT u.CustomerID, u.UserName, u.Fullname, u.Email,
                       u.PhoneNumber, u.[Address], u.Points,
                       u.MembershipLevel, u.DateCreated,
                       m.MembershipNumber
                FROM USERS u
                LEFT JOIN Membership m ON u.CustomerID = m.CustomerID
                ORDER BY u.DateCreated DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        StringBuilder csv = new StringBuilder();
                        csv.AppendLine("CustomerID,UserName,Fullname,Email," +
                            "PhoneNumber,Address,Points,MembershipLevel," +
                            "DateCreated,MembershipNumber");

                        while (reader.Read())
                        {
                            csv.AppendLine(
                                $"{reader["CustomerID"]}," +
                                $"{reader["UserName"]}," +
                                $"\"{reader["Fullname"]}\"," +
                                $"{reader["Email"]}," +
                                $"{reader["PhoneNumber"]}," +
                                $"\"{reader["Address"]}\"," +
                                $"{reader["Points"]}," +
                                $"{reader["MembershipLevel"]}," +
                                $"{reader["DateCreated"]}," +
                                $"{(reader["MembershipNumber"] == DBNull.Value ? "N/A" : reader["MembershipNumber"])}");
                        }

                        string filename = $"AllUsers_Export_{DateTime.Now:yyyyMMdd_HHmmss}.csv";
                        Response.Clear();
                        Response.ContentType = "text/csv";
                        Response.AddHeader("Content-Disposition", $"attachment; filename={filename}");
                        Response.Write(csv.ToString());
                        Response.End();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage(lblExportMessage, $"✗ Export Users failed: {ex.Message}", "error");
            }
        }

        protected void btnRestore_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fileRestore.HasFile)
                {
                    ShowMessage(lblRestoreMessage,
                        "✗ Please select a backup file to restore.", "error");
                    return;
                }

                string fileExtension = Path.GetExtension(fileRestore.FileName).ToLower();
                if (fileExtension != ".bak")
                {
                    ShowMessage(lblRestoreMessage,
                        "✗ Invalid file type. Please select a .bak file.", "error");
                    return;
                }

                string tempPath = Path.Combine(backupFolder, "temp_restore.bak");
                fileRestore.SaveAs(tempPath);

                string connectionString = ConfigurationManager
                    .ConnectionStrings["PotatoCornerDB"].ConnectionString;

                SqlConnectionStringBuilder builder =
                    new SqlConnectionStringBuilder(connectionString);
                string dbName = builder.InitialCatalog;

                // ✅ Must connect to master to restore
                SqlConnectionStringBuilder masterBuilder =
                    new SqlConnectionStringBuilder(connectionString);
                masterBuilder.InitialCatalog = "master";

                using (SqlConnection conn = new SqlConnection(masterBuilder.ConnectionString))
                {
                    conn.Open();

                    string restoreQuery = $@"
                        ALTER DATABASE [{dbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                        RESTORE DATABASE [{dbName}] 
                        FROM DISK = @TempPath 
                        WITH REPLACE;
                        ALTER DATABASE [{dbName}] SET MULTI_USER;";

                    using (SqlCommand cmd = new SqlCommand(restoreQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TempPath", tempPath);
                        cmd.CommandTimeout = 300;
                        cmd.ExecuteNonQuery();
                    }
                }

                if (File.Exists(tempPath))
                    File.Delete(tempPath);

                ShowMessage(lblRestoreMessage,
                    "✓ Database restored successfully!", "success");
            }
            catch (Exception ex)
            {
                ShowMessage(lblRestoreMessage,
                    $"✗ Restore failed: {ex.Message}", "error");
            }
        }

        private void LoadBackupHistory()
        {
            try
            {
                DirectoryInfo dir = new DirectoryInfo(backupFolder);
                FileInfo[] files = dir.GetFiles("*.bak");

                if (files.Length == 0)
                {
                    litBackupHistory.Text =
                        "<div class='info message'>No backups found. " +
                        "Create your first backup above.</div>";
                    return;
                }

                StringBuilder html = new StringBuilder();
                Array.Sort(files, (x, y) =>
                    y.LastWriteTime.CompareTo(x.LastWriteTime));

                foreach (FileInfo file in files)
                {
                    html.AppendLine("<div class='backup-item'>");
                    html.AppendLine("  <div class='backup-info'>");
                    html.AppendLine(
                        $"    <div class='backup-name'>{file.Name}</div>");
                    html.AppendLine(
                        $"    <div class='backup-date'>Created: " +
                        $"{file.LastWriteTime:MMM dd, yyyy h:mm tt} | " +
                        $"Size: {FormatFileSize(file.Length)}</div>");
                    html.AppendLine("  </div>");
                    html.AppendLine("</div>");
                }

                litBackupHistory.Text = html.ToString();
            }
            catch (Exception ex)
            {
                litBackupHistory.Text =
                    $"<div class='error message'>" +
                    $"Error loading backup history: {ex.Message}</div>";
            }
        }

        private string FormatFileSize(long bytes)
        {
            string[] sizes = { "B", "KB", "MB", "GB" };
            double len = bytes;
            int order = 0;

            while (len >= 1024 && order < sizes.Length - 1)
            {
                order++;
                len = len / 1024;
            }

            return $"{len:0.##} {sizes[order]}";
        }

        private void ShowMessage(System.Web.UI.WebControls.Label label,
            string message, string type)
        {
            label.Text = message;
            label.CssClass = $"message {type}";
            label.Visible = true;
        }
    }
}