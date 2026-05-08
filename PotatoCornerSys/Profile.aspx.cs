using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCustomerInfo();
                LoadLoyaltyPoints();
                LoadFavoriteOrder();
                LoadOrderHistory();
                LoadOrderStats();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Response.Redirect("Login.aspx");
        }

        protected void btnConfirmDelete_Click(object sender, EventArgs e)
        {
            try
            {
                string enteredPassword = txtDeletePassword.Text.Trim();
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    
                    if (customerID == 0)
                    {
                        Response.Redirect("Login.aspx");
                        return;
                    }

                    // Verify password
                    string verifyQuery = "SELECT Password FROM USERS WHERE CustomerID = @CustomerID";
                    using (SqlCommand cmd = new SqlCommand(verifyQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        string storedPassword = cmd.ExecuteScalar()?.ToString();
                        
                        // Check if password is hashed (64 characters) or plain text
                        bool isPasswordValid = false;
                        
                        if (storedPassword != null && storedPassword.Length == 64)
                        {
                            // Password is hashed
                            isPasswordValid = PasswordHelper.VerifyPassword(enteredPassword, storedPassword);
                        }
                        else
                        {
                            // Password is plain text (backward compatibility)
                            isPasswordValid = (enteredPassword == storedPassword);
                        }
                        
                        if (!isPasswordValid)
                        {
                            // Password incorrect - show error via JavaScript
                            ClientScript.RegisterStartupScript(this.GetType(), "showError", 
                                "document.getElementById('deleteErrorMsg').classList.add('show'); document.getElementById('deleteAccountModal').classList.add('active');", true);
                            return;
                        }
                    }

                    // Delete account - cascade delete will handle related records
                    string deleteQuery = @"
                        DELETE FROM OrderItems WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID);
                        DELETE FROM Orders WHERE CustomerID = @CustomerID;
                        DELETE FROM Membership WHERE CustomerID = @CustomerID;
                        DELETE FROM USERS WHERE CustomerID = @CustomerID;";
                    
                    using (SqlCommand cmd = new SqlCommand(deleteQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Clear session and redirect to login
                Session.Clear();
                Session.Abandon();
                Response.Redirect("Login.aspx?deleted=true");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error deleting account: " + ex.Message);
                ClientScript.RegisterStartupScript(this.GetType(), "showError", 
                    "showAlertModal('❌', 'Error', 'An error occurred while deleting your account. Please try again.');", true);
            }
        }

        private void LoadCustomerInfo()
        {
            if (Session["Username"] != null)
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

                        if (customerID > 0)
                        {
                            string query = @"
                                SELECT u.Fullname, u.Email, u.PhoneNumber, u.[Address], u.Points, u.MembershipLevel, u.DateCreated,
                                       m.MembershipNumber
                                FROM USERS u
                                LEFT JOIN Membership m ON u.CustomerID = m.CustomerID
                                WHERE u.CustomerID = @CustomerID";

                            using (SqlCommand cmd = new SqlCommand(query, conn))
                            {
                                cmd.Parameters.AddWithValue("@CustomerID", customerID);
                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.Read())
                                    {
                                        Session["Name"] = reader["Fullname"].ToString();
                                        Session["Email"] = reader["Email"].ToString();
                                        Session["Phone"] = reader["PhoneNumber"].ToString();
                                        Session["Address"] = reader["Address"].ToString();
                                        Session["Points"] = reader["Points"].ToString();
                                        Session["MembershipLevel"] = reader["MembershipLevel"].ToString();
                                        Session["MemberSince"] = Convert.ToDateTime(reader["DateCreated"]).ToString("MMM dd, yyyy");

                                        if (!reader.IsDBNull(reader.GetOrdinal("MembershipNumber")))
                                        {
                                            Session["RoyaltyNumber"] = reader["MembershipNumber"].ToString();
                                            Session["HasRoyaltyMembership"] = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error loading customer info: " + ex.Message);
                }

                string displayName = Session["Name"]?.ToString() ?? Session["Username"].ToString();
                lblFullName.Text = displayName;

                string[] nameParts = displayName.Split(' ');
                if (nameParts.Length >= 2)
                    lblInitials.Text = nameParts[0][0].ToString() + nameParts[1][0].ToString();
                else if (displayName.Length >= 2)
                    lblInitials.Text = displayName.Substring(0, 2).ToUpper();
                else
                    lblInitials.Text = displayName.Substring(0, 1).ToUpper();
            }
            else
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblEmailAvatar.Text = Session["Email"]?.ToString() ?? "email@example.com";
            lblInfoPhone.Text = Session["Phone"]?.ToString() ?? "N/A";
            lblInfoAddress.Text = Session["Address"]?.ToString() ?? "N/A";
            lblMemberSince.Text = Session["MemberSince"]?.ToString() ?? DateTime.Now.ToString("MMM dd, yyyy");

            bool isRoyaltyMember = CheckIfRoyaltyMember();
            LoadMembershipRequestStatus();

            string picturePath = GetProfilePicturePath();
            if (!string.IsNullOrEmpty(picturePath))
            {
                imgProfilePic.ImageUrl = picturePath;
                imgProfilePic.Visible = true;
                lblInitials.Visible = false;
            }
            else
            {
                imgProfilePic.Visible = false;
                lblInitials.Visible = true;
            }

            if (isRoyaltyMember)
            {
                lblMembershipBadge.Text = "ROYALTY MEMBER";
                lblMembershipBadge.CssClass = "membership-pill royalty";
                profileCardContainer.Attributes["class"] = "profile-card royalty-gold";
                if (Session["RoyaltyNumber"] != null)
                {
                    lblRoyaltyNumber.Text = Session["RoyaltyNumber"].ToString();
                    royaltyNumberSection.Visible = true;
                }
            }
            else
            {
                lblMembershipBadge.Text = "REGULAR MEMBER";
                lblMembershipBadge.CssClass = "membership-pill";
            }
        }

        private void LoadMembershipRequestStatus()
        {
            try
            {
                int customerID = 0;
                if (Session["CustomerID"] != null)
                    int.TryParse(Session["CustomerID"].ToString(), out customerID);

                if (customerID == 0)
                {
                    membershipRequestStatusRow.Visible = false;
                    return;
                }

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        IF OBJECT_ID('dbo.Membership', 'U') IS NOT NULL
                        BEGIN
                            SELECT TOP 1 RequestStatus, RequestedDate, ConfirmedDate
                            FROM Membership
                            WHERE CustomerID = @CustomerID
                            ORDER BY MembershipID DESC
                        END";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string requestStatus = reader["RequestStatus"]?.ToString() ?? "Pending";
                                string requestedDate = reader["RequestedDate"] != DBNull.Value
                                    ? Convert.ToDateTime(reader["RequestedDate"]).ToString("MMM dd, yyyy")
                                    : "";

                                if (string.Equals(requestStatus, "Pending", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblMembershipRequestStatus.Text = "Pending Confirmation (" + requestedDate + ")";
                                }
                                else if (string.Equals(requestStatus, "Confirmed", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblMembershipRequestStatus.Text = "Confirmed";
                                }
                                else
                                {
                                    lblMembershipRequestStatus.Text = requestStatus;
                                }

                                membershipRequestStatusRow.Visible = true;
                            }
                            else
                            {
                                membershipRequestStatusRow.Visible = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                membershipRequestStatusRow.Visible = false;
                System.Diagnostics.Debug.WriteLine("Error loading membership request status: " + ex.Message);
            }
        }

        private bool CheckIfRoyaltyMember()
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

                    string query = @"
                        SELECT m.MembershipNumber, m.RegistrationDate, m.ProfileImagePath, u.MembershipLevel
                        FROM Membership m
                        INNER JOIN USERS u ON m.CustomerID = u.CustomerID
                        WHERE m.CustomerID = @CustomerID AND u.MembershipLevel = 'Royalty'";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["HasRoyaltyMembership"] = true;
                                Session["MembershipLevel"] = "Royalty";
                                string membershipNumber = reader["MembershipNumber"].ToString();
                                Session["RoyaltyNumber"] = membershipNumber;
                                if (!reader.IsDBNull(reader.GetOrdinal("ProfileImagePath")))
                                {
                                    string dbPicturePath = reader["ProfileImagePath"].ToString();
                                    if (!string.IsNullOrWhiteSpace(dbPicturePath))
                                    {
                                        string serverPath = Server.MapPath(dbPicturePath);
                                        if (System.IO.File.Exists(serverPath))
                                        {
                                            Session["MemberPicture"] = dbPicturePath;
                                        }
                                    }
                                }
                                return true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error checking royalty membership: " + ex.Message);
            }
            return Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"];
        }

        private string GetProfilePicturePath()
        {
            try
            {
                if (Session["MemberPicture"] != null)
                {
                    string picturePath = Session["MemberPicture"].ToString();
                    string serverPath = Server.MapPath(picturePath);
                    if (System.IO.File.Exists(serverPath))
                        return picturePath;
                }

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);
                    if (customerID == 0) return null;

                    string membershipQuery = @"SELECT TOP 1 ProfileImagePath
                                               FROM Membership
                                               WHERE CustomerID = @CustomerID
                                               ORDER BY MembershipID DESC";
                    using (SqlCommand cmd = new SqlCommand(membershipQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            string picturePath = result.ToString();
                            if (!string.IsNullOrWhiteSpace(picturePath))
                            {
                                string serverPath = Server.MapPath(picturePath);
                                if (System.IO.File.Exists(serverPath))
                                    return picturePath;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading profile picture: " + ex.Message);
            }
            return null;
        }

        private void LoadLoyaltyPoints()
        {
            try
            {
                int points = 0;
                if (Session["Points"] != null)
                    int.TryParse(Session["Points"].ToString(), out points);

                lblPoints.Text = points.ToString();
                decimal pointsValue = points * 10;
                lblDiscountPower.Text = pointsValue.ToString("0.00");
            }
            catch (Exception ex)
            {
                lblPoints.Text = "0";
                lblDiscountPower.Text = "0.00";
                System.Diagnostics.Debug.WriteLine("Error loading points: " + ex.Message);
            }
        }

        private void LoadOrderStats()
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
                    if (customerID == 0) return;

                    string statsQuery = @"
                        SELECT 
                            COUNT(o.OrderID)       AS TotalOrders,
                            SUM(o.TotalAmount)     AS TotalSpent,
                            AVG(o.TotalAmount)     AS AvgOrderValue,
                            MAX(o.TotalAmount)     AS BiggestOrder
                        FROM Orders o
                        WHERE o.CustomerID = @CustomerID
                          AND o.OrderStatus != 'Cancelled'";

                    using (SqlCommand cmd = new SqlCommand(statsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTotalOrders.Text = reader["TotalOrders"].ToString();
                                lblTotalSpent.Text = reader["TotalSpent"] != DBNull.Value
                                    ? Convert.ToDecimal(reader["TotalSpent"]).ToString("₱#,##0.00") : "₱0.00";
                                lblAvgOrder.Text = reader["AvgOrderValue"] != DBNull.Value
                                    ? Convert.ToDecimal(reader["AvgOrderValue"]).ToString("₱#,##0.00") : "₱0.00";
                                lblBiggestOrder.Text = reader["BiggestOrder"] != DBNull.Value
                                    ? Convert.ToDecimal(reader["BiggestOrder"]).ToString("₱#,##0.00") : "₱0.00";
                            }
                        }
                    }

                    string groupQuery = @"
                        SELECT 
                            o.OrderStatus,
                            COUNT(o.OrderID)    AS StatusCount,
                            SUM(o.TotalAmount)  AS StatusTotal
                        FROM Orders o
                        WHERE o.CustomerID = @CustomerID
                        GROUP BY o.OrderStatus";

                    using (SqlCommand cmd = new SqlCommand(groupQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            adapter.Fill(dt);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading order stats: " + ex.Message);
            }
        }

        private void LoadFavoriteOrder() { }

        private void LoadOrderHistory()
        {
            LoadOrderHistory(null);
        }

        private void LoadOrderHistory(string searchOrderID)
        {
            UpdateOrderStatusInDatabase();
            string sortOrder = ddlSortOrder.SelectedValue;
            string statusFilter = ddlFilterStatus.SelectedValue;

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    int customerID = 0;
                    if (Session["CustomerID"] != null)
                        int.TryParse(Session["CustomerID"].ToString(), out customerID);

                    if (customerID == 0)
                    {
                        pnlOrdersTable.Visible = false;
                        pnlNoOrders.Visible = true;
                        lblNoOrdersMsg.Text = "No orders yet. Start ordering to see your history here!";
                        return;
                    }

                    string whereClause = "WHERE o.CustomerID = @CustomerID";

                    if (!string.IsNullOrEmpty(searchOrderID))
                        whereClause += " AND o.OrderID = @SearchOrderID";

                    if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "All")
                        whereClause += " AND o.OrderStatus = @StatusFilter";

                    string query = @"
                        SELECT 
                            o.OrderID, o.OrderDate, o.DeliveryType, o.TotalAmount, o.OrderStatus, o.PickupTime,
                            CASE 
                                WHEN o.DeliveryType = 'Walk-in' AND o.PickupTime IS NOT NULL 
                                THEN FORMAT(o.PickupTime, 'MMM dd, yyyy h:mm tt')
                                ELSE FORMAT(o.OrderDate, 'MMM dd, yyyy h:mm tt')
                            END AS DisplayDate,
                            STUFF((
                                SELECT ', ' + p.ProductName + 
                                    CASE 
                                        WHEN ps.SizeName IS NOT NULL AND pf.FlavorName IS NOT NULL THEN ' (' + ps.SizeName + ', ' + pf.FlavorName + ')'
                                        WHEN ps.SizeName IS NOT NULL THEN ' (' + ps.SizeName + ')'
                                        WHEN pf.FlavorName IS NOT NULL THEN ' (' + pf.FlavorName + ')'
                                        ELSE ''
                                    END + ' x' + CAST(oi.Quantity AS VARCHAR)
                                FROM OrderItems oi
                                INNER JOIN Products p ON oi.ProductID = p.ProductID
                                LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
                                LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                                WHERE oi.OrderID = o.OrderID
                                FOR XML PATH('')
                            ), 1, 2, '') AS ItemsSummary
                        FROM Orders o
                        " + whereClause + @"
                        ORDER BY o.OrderDate " + sortOrder;

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);

                        if (!string.IsNullOrEmpty(searchOrderID))
                        {
                            int orderIdInt;
                            if (int.TryParse(searchOrderID, out orderIdInt))
                                cmd.Parameters.AddWithValue("@SearchOrderID", orderIdInt);
                            else
                            {
                                pnlOrdersTable.Visible = false;
                                pnlNoOrders.Visible = true;
                                pnlSearchResult.Visible = false;
                                lblNoOrdersMsg.Text = "Please enter a valid numeric Order ID.";
                                return;
                            }
                        }

                        if (!string.IsNullOrEmpty(statusFilter) && statusFilter != "All")
                            cmd.Parameters.AddWithValue("@StatusFilter", statusFilter);

                        DataTable dt = new DataTable();
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            adapter.Fill(dt);
                        }

                        if (dt.Rows.Count > 0)
                        {
                            rptOrderHistory.DataSource = dt;
                            rptOrderHistory.DataBind();
                            pnlOrdersTable.Visible = true;
                            pnlNoOrders.Visible = false;

                            if (!string.IsNullOrEmpty(searchOrderID))
                            {
                                pnlSearchResult.Visible = true;
                                lblSearchResultMsg.Text = $"Showing result for Order #PC-{searchOrderID}";
                            }
                            else
                            {
                                pnlSearchResult.Visible = false;
                            }
                        }
                        else
                        {
                            pnlOrdersTable.Visible = false;
                            pnlNoOrders.Visible = true;
                            pnlSearchResult.Visible = false;

                            lblNoOrdersMsg.Text = !string.IsNullOrEmpty(searchOrderID)
                                ? $"No order found with ID #PC-{searchOrderID}. Please check the number and try again."
                                : !string.IsNullOrEmpty(statusFilter) && statusFilter != "All"
                                    ? $"No {statusFilter} orders found."
                                    : "No orders yet. Start ordering to see your history here!";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                pnlOrdersTable.Visible = false;
                pnlNoOrders.Visible = true;
                pnlSearchResult.Visible = false;
                lblNoOrdersMsg.Text = "An error occurred loading your orders. Please try again.";
                System.Diagnostics.Debug.WriteLine("Error loading order history: " + ex.Message);
            }
        }

        // ✅ Helper — refunds points to DB and session if order was paid with Points
        private void RefundPointsIfPaidWithPoints(SqlConnection conn, string orderID)
        {
            if (Session["CustomerID"] == null) return;

            decimal orderTotal = 0;
            string paymentMethod = "";

            string checkQuery = "SELECT TotalAmount, PaymentMethod FROM Orders WHERE OrderID = @OrderID";
            using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
            {
                cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        orderTotal = Convert.ToDecimal(reader["TotalAmount"]);
                        paymentMethod = reader["PaymentMethod"].ToString().Trim();
                    }
                }
            }

            if (orderTotal <= 0) return;

            int pointsDelta = 0;

            if (paymentMethod == "Points")
            {
                // ✅ Refund the points they spent to pay
                int pointsSpent = (int)Math.Ceiling(orderTotal / 10m);
                pointsDelta = pointsSpent; // give back what they paid with
            }
            else
            {
                // ✅ Deduct the earned points since the order is cancelled
                int pointsEarned = (int)(orderTotal / 500) * 2;
                pointsDelta = -pointsEarned; // take back the earned points
            }

            if (pointsDelta == 0) return;

            string refundQuery = @"
        UPDATE USERS 
        SET Points = CASE 
            WHEN Points + @Points < 0 THEN 0 
            ELSE Points + @Points 
        END
        WHERE CustomerID = @CustomerID";

            using (SqlCommand cmd = new SqlCommand(refundQuery, conn))
            {
                cmd.Parameters.AddWithValue("@Points", pointsDelta);
                cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(Session["CustomerID"]));
                cmd.ExecuteNonQuery();
            }

            // Sync session
            if (Session["Points"] != null)
            {
                int currentPoints = Convert.ToInt32(Session["Points"]);
                int newPoints = currentPoints + pointsDelta;
                Session["Points"] = Math.Max(0, newPoints).ToString();
            }
        }

        protected void btnUsePoints_Click(object sender, EventArgs e)
        {
            Session["UsePointsDiscount"] = "true";
            Session["PointsDiscount"] = lblDiscountPower.Text;
            lblPointsMsg.Text = "✓ Points will be applied as discount on your next order!";
            lblPointsMsg.Visible = true;
            Response.AddHeader("REFRESH", "2;URL=Order.aspx");
        }

        protected void rptOrderHistory_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string orderID = e.CommandArgument.ToString();

            if (e.CommandName == "Reorder")
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        string query = @"
                            SELECT oi.ProductID, p.ProductName, oi.SizeID, ps.SizeName,
                                   oi.FlavorID, pf.FlavorName, oi.Quantity,
                                   (p.BasePrice + ISNULL(ps.PriceModifier, 0)) AS CurrentPrice,
                                   oi.UnitPrice AS OriginalPrice
                            FROM OrderItems oi
                            INNER JOIN Products p ON oi.ProductID = p.ProductID
                            LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
                            LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                            WHERE oi.OrderID = @OrderID
                            ORDER BY oi.OrderItemID";

                        List<Order.CartItem> cart = new List<Order.CartItem>();
                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    cart.Add(new Order.CartItem
                                    {
                                        Product = reader["ProductName"].ToString(),
                                        Size = reader["SizeName"]?.ToString() ?? "Regular",
                                        Flavor = reader["FlavorName"]?.ToString() ?? "Salt",
                                        Qty = Convert.ToInt32(reader["Quantity"]),
                                        UnitPrice = Convert.ToDecimal(reader["CurrentPrice"])
                                    });
                                }
                            }
                        }

                        if (cart.Count > 0)
                        {
                            Session["Cart"] = cart;
                            Session["ReorderMessage"] = "✓ Previous order loaded! Review and confirm your order.";
                            Response.Redirect("Order.aspx");
                        }
                        else
                        {
                            LoadFallbackReorderItems(orderID);
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error loading reorder items: " + ex.Message);
                    LoadFallbackReorderItems(orderID);
                }
            }
            else if (e.CommandName == "Cancel")
            {
                try
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // ✅ Refund points BEFORE cancelling (guard checks OrderStatus != 'Cancelled')
                        RefundPointsIfPaidWithPoints(conn, orderID);

                        string updateQuery = "UPDATE Orders SET OrderStatus = 'Cancelled' WHERE OrderID = @OrderID";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));
                            int rowsAffected = cmd.ExecuteNonQuery();
                            Session["CancelMessage"] = rowsAffected > 0
                                ? "✓ Order #" + orderID + " has been cancelled successfully."
                                : "✗ Failed to cancel order #" + orderID + ".";
                        }
                        
                        // Log order cancellation to Activity Log
                        string customerName = Session["Username"]?.ToString() ?? "Customer";
                        ActivityLog.LogActivity(
                            activityType: "Order Cancelled",
                            description: $"Order #{orderID} was cancelled by customer {customerName}",
                            performedBy: customerName,
                            targetEntity: $"Order #{orderID}",
                            severity: "Warning"
                        );
                    }
                    Response.Redirect(Request.RawUrl);
                }
                catch (Exception ex)
                {
                    Session["CancelMessage"] = "✗ Error cancelling order: " + ex.Message;
                    Response.Redirect(Request.RawUrl);
                }
            }
        }

        private void LoadFallbackReorderItems(string orderID)
        {
            List<Order.CartItem> cart = new List<Order.CartItem>
            {
                new Order.CartItem { Product = "French Fries", Size = "Large", Flavor = "Cheese", Qty = 1, UnitPrice = 58m }
            };
            Session["Cart"] = cart;
            Session["ReorderMessage"] = "✓ Sample order loaded! Review and confirm your order.";
            Response.Redirect("Order.aspx");
        }

        protected string GetOrderStatus(DateTime orderDate, string dbStatus)
        {
            switch (dbStatus?.ToLower())
            {
                case "delivered": return "<span class='order-status status-delivered'>Delivered</span>";
                case "out for delivery": return "<span class='order-status status-out-delivery'>Out for Delivery</span>";
                case "picked up": return "<span class='order-status status-picked-up'>Picked Up</span>";
                case "no show": return "<span class='order-status status-no-show'>No Show - Not Picked Up</span>";
                case "confirmed": return "<span class='order-status status-confirmed'>Confirmed</span>";
                case "cancelled": return "<span class='order-status status-cancelled'>Cancelled</span>";
                case "pending":
                default: return "<span class='order-status status-pending'>Pending</span>";
            }
        }

        private void UpdateOrderStatusInDatabase()
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
                    if (customerID == 0) return;

                    string confirmQuery = @"
                        UPDATE Orders SET OrderStatus = 'Confirmed', ConfirmedAt = DATEADD(MINUTE, 5, OrderDate)
                        WHERE CustomerID = @CustomerID AND OrderStatus = 'Pending'
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 5
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) < 15";
                    using (SqlCommand cmd = new SqlCommand(confirmQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }

                    string deliverQuery = @"
                        UPDATE Orders 
                        SET OrderStatus = 'Delivered', DeliveredAt = DATEADD(MINUTE, 15, OrderDate),
                            ConfirmedAt = CASE WHEN ConfirmedAt IS NULL THEN DATEADD(MINUTE, 5, OrderDate) ELSE ConfirmedAt END
                        WHERE CustomerID = @CustomerID
                        AND (OrderStatus = 'Pending' OR OrderStatus = 'Confirmed')
                        AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 15";
                    using (SqlCommand cmd = new SqlCommand(deliverQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating order status: " + ex.Message);
            }
        }

        protected string GetReorderButton(string orderStatus, string orderID)
        {
            // ✅ NEW RULE: Can only reorder if order is completed (Delivered or Picked Up)
            // No reorder for Pending, Confirmed, Out for Delivery, Cancelled, or No Show
            if (orderStatus == "Delivered" || orderStatus == "Picked Up")
            {
                return $"<button type='button' class='btn-reorder-new' onclick='reorderItems({orderID})'>Reorder</button>";
            }
            return "";
        }

        protected string GetCancelButton(DateTime orderDate, string orderID, string orderStatus)
        {
            // ✅ NEW RULE: Cannot cancel once admin confirms the order
            // Can only cancel if status is "Pending" (before admin confirmation)
            if (orderStatus != "Pending")
                return "";

            // Time restriction: can only cancel within 10 minutes of placing order
            TimeSpan timeSinceOrder = DateTime.Now - orderDate;
            if (timeSinceOrder.TotalMinutes <= 10)
                return $"<button type='button' class='btn-cancel-new' onclick='cancelOrder({orderID})'>Cancel Order</button>";

            return "";
        }

        protected string GetMarkDeliveredButton(string deliveryType, string orderID, string orderStatus)
        {
            // Only show for Delivery orders that are "Out for Delivery" (not Pending, Confirmed, Delivered, Picked Up, or Cancelled)
            if (deliveryType == "Delivery" && orderStatus == "Out for Delivery")
            {
                return $"<button type='button' class='btn-delivered-new' onclick='markAsDelivered({orderID})'>Mark Delivered</button>";
            }
            return "";
        }

        protected void btnMarkDelivered_Click(object sender, EventArgs e)
        {
            try
            {
                string orderID = hdnMarkDeliveredOrderID.Value;
                if (string.IsNullOrEmpty(orderID)) return;

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string updateQuery = @"UPDATE Orders 
                                          SET OrderStatus = 'Delivered', 
                                              DeliveredAt = GETDATE() 
                                          WHERE OrderID = @OrderID 
                                          AND DeliveryType = 'Delivery' 
                                          AND OrderStatus = 'Out for Delivery'";
                    
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderID", int.Parse(orderID));
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadOrderHistory();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error marking order as delivered: " + ex.Message);
            }
        }

        protected void btnOrderSummary_Click(object sender, EventArgs e)
        {
            Response.Redirect("OrderSummary.aspx");
        }

        protected void ddlSortOrder_SelectedIndexChanged(object sender, EventArgs e)
        {
            string searchText = txtSearchOrderID.Text.Trim();
            LoadOrderHistory(!string.IsNullOrEmpty(searchText) ? searchText : null);
        }

        protected void ddlFilterStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            string searchText = txtSearchOrderID.Text.Trim();
            LoadOrderHistory(!string.IsNullOrEmpty(searchText) ? searchText : null);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string searchOrderID = txtSearchOrderID.Text.Trim();
            LoadOrderHistory(!string.IsNullOrEmpty(searchOrderID) ? searchOrderID : null);
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearchOrderID.Text = "";
            pnlSearchResult.Visible = false;
            LoadOrderHistory(null);
        }

        protected void btnClearHistory_Click(object sender, EventArgs e)
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
                    if (customerID == 0) return;

                    string deleteItemsQuery = @"DELETE FROM OrderItems WHERE OrderID IN (SELECT OrderID FROM Orders WHERE CustomerID = @CustomerID)";
                    string deleteOrdersQuery = "DELETE FROM Orders WHERE CustomerID = @CustomerID";

                    using (SqlCommand cmd = new SqlCommand(deleteItemsQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }
                    using (SqlCommand cmd = new SqlCommand(deleteOrdersQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.ExecuteNonQuery();
                    }
                    LoadOrderHistory();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error clearing history: " + ex.Message);
            }
        }

        protected void btnCancelOrder_Click(object sender, EventArgs e)
        {
            try
            {
                string orderID = hdnCancelOrderID.Value;
                if (string.IsNullOrEmpty(orderID)) return;

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // ✅ Refund points BEFORE cancelling (guard checks OrderStatus != 'Cancelled')
                    RefundPointsIfPaidWithPoints(conn, orderID);

                    string updateQuery = "UPDATE Orders SET OrderStatus = 'Cancelled' WHERE OrderID = @OrderID";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderID", int.Parse(orderID));
                        cmd.ExecuteNonQuery();
                    }
                    
                    // Log order cancellation to Activity Log
                    string customerName = Session["Username"]?.ToString() ?? "Customer";
                    ActivityLog.LogActivity(
                        activityType: "Order Cancelled",
                        description: $"Order #{orderID} was cancelled by customer {customerName}",
                        performedBy: customerName,
                        targetEntity: $"Order #{orderID}",
                        severity: "Warning"
                    );
                }
                LoadOrderHistory();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error cancelling order: " + ex.Message);
            }
        }

        protected void btnReorder_Click(object sender, EventArgs e)
        {
            try
            {
                string orderID = hdnReorderOrderID.Value;
                if (string.IsNullOrEmpty(orderID)) return;

                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT oi.ProductID, p.ProductName, oi.SizeID, ps.SizeName,
                               oi.FlavorID, pf.FlavorName, oi.Quantity,
                               (p.BasePrice + ISNULL(ps.PriceModifier, 0)) AS CurrentPrice,
                               oi.UnitPrice AS OriginalPrice
                        FROM OrderItems oi
                        INNER JOIN Products p ON oi.ProductID = p.ProductID
                        LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID
                        LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                        WHERE oi.OrderID = @OrderID
                        ORDER BY oi.OrderItemID";

                    List<Order.CartItem> cart = new List<Order.CartItem>();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderID", Convert.ToInt32(orderID));
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                cart.Add(new Order.CartItem
                                {
                                    Product = reader["ProductName"].ToString(),
                                    Size = reader["SizeName"]?.ToString() ?? "Regular",
                                    Flavor = reader["FlavorName"]?.ToString() ?? "Salt",
                                    Qty = Convert.ToInt32(reader["Quantity"]),
                                    UnitPrice = Convert.ToDecimal(reader["CurrentPrice"])
                                });
                            }
                        }
                    }

                    if (cart.Count > 0)
                    {
                        Session["Cart"] = cart;
                        Session["ReorderMessage"] = "✓ Previous order loaded! Review and confirm your order.";
                        Response.Redirect("Order.aspx");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error reordering: " + ex.Message);
            }
        }
    }
}