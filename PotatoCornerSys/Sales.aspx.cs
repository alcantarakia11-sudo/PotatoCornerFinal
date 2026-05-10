using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Sales : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
                {
                    Response.Redirect("~/AdminLogin.aspx");
                }
                LoadSalesData();
            }
        }

        private void LoadSalesData()
        {
            LoadStatistics();
            LoadOrders();
            LoadPendingMembershipRequests();
        }

        private void LoadStatistics()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                string queryUsers = "SELECT COUNT(*) FROM USERS WHERE MembershipLevel != 'Admin'";
                SqlCommand cmdUsers = new SqlCommand(queryUsers, conn);
                lblTotalUsers.Text = cmdUsers.ExecuteScalar().ToString();

                // Revenue includes No Show orders (customer paid but didn't pick up)
                string queryRevenue = "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE OrderStatus NOT IN ('Cancelled')";
                SqlCommand cmdRevenue = new SqlCommand(queryRevenue, conn);
                decimal totalRevenue = Convert.ToDecimal(cmdRevenue.ExecuteScalar());
                lblTotalRevenue.Text = totalRevenue.ToString("N2");

                string queryOrders = "SELECT COUNT(*) FROM Orders";
                SqlCommand cmdOrders = new SqlCommand(queryOrders, conn);
                lblTotalOrders.Text = cmdOrders.ExecuteScalar().ToString();
            }
        }

        private void LoadOrders()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                
                // First, auto-update walk-in orders to "No Show" if not picked up within 60 minutes
                // and refund the stock
                string findNoShowQuery = @"SELECT OrderID FROM Orders 
                                          WHERE DeliveryType = 'Walk-in' 
                                          AND OrderStatus = 'Confirmed' 
                                          AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 60";
                
                List<int> noShowOrders = new List<int>();
                using (SqlCommand findCmd = new SqlCommand(findNoShowQuery, conn))
                {
                    using (SqlDataReader reader = findCmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            noShowOrders.Add(reader.GetInt32(0));
                        }
                    }
                }

                // Refund stock for each no-show order
                foreach (int orderID in noShowOrders)
                {
                    RefundStockForNoShow(conn, orderID);
                }

                // Update status to No Show
                if (noShowOrders.Count > 0)
                {
                    string autoNoShowQuery = @"UPDATE Orders 
                                              SET OrderStatus = 'No Show' 
                                              WHERE DeliveryType = 'Walk-in' 
                                              AND OrderStatus = 'Confirmed' 
                                              AND DATEDIFF(MINUTE, OrderDate, GETDATE()) >= 60";
                    
                    SqlCommand autoCmd = new SqlCommand(autoNoShowQuery, conn);
                    autoCmd.ExecuteNonQuery();
                }

                conn.Close();

                // Build query with optional status filter
                string statusFilter = ddlStatusFilter.SelectedValue;
                string whereClause = string.IsNullOrEmpty(statusFilter) ? "" : "WHERE o.OrderStatus = @StatusFilter";

                string query = $@"SELECT o.OrderID, u.Fullname AS CustomerName, o.OrderDate, 
                                o.TotalAmount, o.OrderStatus, o.DeliveryType, o.PaymentReference
                                FROM Orders o
                                INNER JOIN USERS u ON o.CustomerID = u.CustomerID
                                {whereClause}
                                ORDER BY o.OrderID DESC";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                if (!string.IsNullOrEmpty(statusFilter))
                {
                    da.SelectCommand.Parameters.AddWithValue("@StatusFilter", statusFilter);
                }
                
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvOrders.DataSource = dt;
                gvOrders.DataBind();

                // Update order count
                lblOrderCount.Text = dt.Rows.Count.ToString();
            }
        }

        private void EnsureMembershipColumnsExist(SqlConnection conn)
        {
            string query = @"
                IF COL_LENGTH('dbo.Membership', 'PaymentMethod') IS NULL
                    ALTER TABLE dbo.Membership ADD PaymentMethod NVARCHAR(50) NULL;

                IF COL_LENGTH('dbo.Membership', 'AmountPaid') IS NULL
                    ALTER TABLE dbo.Membership ADD AmountPaid DECIMAL(10,2) NULL;

                IF COL_LENGTH('dbo.Membership', 'PaymentReference') IS NULL
                    ALTER TABLE dbo.Membership ADD PaymentReference NVARCHAR(50) NULL;

                IF COL_LENGTH('dbo.Membership', 'RequestStatus') IS NULL
                    ALTER TABLE dbo.Membership ADD RequestStatus NVARCHAR(30) NOT NULL CONSTRAINT DF_Membership_RequestStatus DEFAULT('Confirmed');

                IF COL_LENGTH('dbo.Membership', 'RequestedDate') IS NULL
                    ALTER TABLE dbo.Membership ADD RequestedDate DATETIME NOT NULL CONSTRAINT DF_Membership_RequestedDate DEFAULT(GETDATE());

                IF COL_LENGTH('dbo.Membership', 'ConfirmedDate') IS NULL
                    ALTER TABLE dbo.Membership ADD ConfirmedDate DATETIME NULL;";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.ExecuteNonQuery();
            }
        }

        private void LoadPendingMembershipRequests()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                EnsureMembershipColumnsExist(conn);

                string query = @"
                    SELECT m.MembershipID AS RequestID, m.CustomerID,
                           u.Fullname AS FullName, u.Email, u.PhoneNumber AS ContactNumber,
                           m.PaymentMethod, m.AmountPaid, m.PaymentReference, m.RequestedDate, m.MembershipNumber
                    FROM Membership m
                    INNER JOIN USERS u ON m.CustomerID = u.CustomerID
                    WHERE m.RequestStatus = 'Pending'
                    ORDER BY m.RequestedDate ASC";

                using (SqlDataAdapter da = new SqlDataAdapter(query, conn))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvMembershipRequests.DataSource = dt;
                    gvMembershipRequests.DataBind();
                    lblMembershipPendingCount.Text = dt.Rows.Count.ToString();
                }
            }
        }

        private void RefundStockForNoShow(SqlConnection conn, int orderID)
        {
            try
            {
                // Get order items
                string itemsQuery = @"SELECT ProductID, SizeID, FlavorID, Quantity 
                                     FROM OrderItems 
                                     WHERE OrderID = @OrderID";

                using (SqlCommand cmd = new SqlCommand(itemsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@OrderID", orderID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        List<(int ProductID, int? SizeID, int? FlavorID, int Quantity)> items = new List<(int, int?, int?, int)>();
                        
                        while (reader.Read())
                        {
                            items.Add((
                                reader.GetInt32(0),
                                reader.IsDBNull(1) ? (int?)null : reader.GetInt32(1),
                                reader.IsDBNull(2) ? (int?)null : reader.GetInt32(2),
                                reader.GetInt32(3)
                            ));
                        }
                        reader.Close();

                        // Refund stock for each item
                        foreach (var item in items)
                        {
                            // Refund size stock (1:1 ratio)
                            if (item.SizeID.HasValue)
                            {
                                string refundSizeQuery = @"UPDATE ProductSizeStock 
                                                          SET StockQuantity = StockQuantity + @Quantity 
                                                          WHERE ProductID = @ProductID AND SizeID = @SizeID";
                                using (SqlCommand refundCmd = new SqlCommand(refundSizeQuery, conn))
                                {
                                    refundCmd.Parameters.AddWithValue("@Quantity", item.Quantity);
                                    refundCmd.Parameters.AddWithValue("@ProductID", item.ProductID);
                                    refundCmd.Parameters.AddWithValue("@SizeID", item.SizeID.Value);
                                    refundCmd.ExecuteNonQuery();
                                }
                            }

                            // Refund flavor stock (1:10 ratio)
                            if (item.FlavorID.HasValue)
                            {
                                int flavorRefund = (int)Math.Ceiling(item.Quantity / 10.0);
                                string refundFlavorQuery = @"UPDATE FlavorStock 
                                                            SET StockQuantity = StockQuantity + @Quantity 
                                                            WHERE FlavorID = @FlavorID";
                                using (SqlCommand refundCmd = new SqlCommand(refundFlavorQuery, conn))
                                {
                                    refundCmd.Parameters.AddWithValue("@Quantity", flavorRefund);
                                    refundCmd.Parameters.AddWithValue("@FlavorID", item.FlavorID.Value);
                                    refundCmd.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error refunding stock for no-show: " + ex.Message);
            }
        }

        protected void gvOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ConfirmOrder")
            {
                int orderID = Convert.ToInt32(e.CommandArgument);
                ConfirmOrder(orderID);
                LoadSalesData();
            }
            else if (e.CommandName == "OutForDelivery")
            {
                int orderID = Convert.ToInt32(e.CommandArgument);
                UpdateOrderStatus(orderID, "Out for Delivery");
                LoadSalesData();
            }
            else if (e.CommandName == "MarkPickedUp")
            {
                int orderID = Convert.ToInt32(e.CommandArgument);
                UpdateOrderStatus(orderID, "Picked Up");
                LoadSalesData();
            }
        }

        private void ConfirmOrder(int orderID)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Orders SET OrderStatus = 'Confirmed' WHERE OrderID = @OrderID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@OrderID", orderID);

                conn.Open();
                cmd.ExecuteNonQuery();
                
                // Log activity
                string adminUser = Session["UserName"]?.ToString() ?? "Admin";
                ActivityLogHelper.LogActivity("Order Status Change", 
                    $"Order #{orderID} status changed from Pending to Confirmed", 
                    adminUser, 
                    $"Order #{orderID}", 
                    "Info");
            }
        }

        private void UpdateOrderStatus(int orderID, string status)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = "UPDATE Orders SET OrderStatus = @Status WHERE OrderID = @OrderID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@OrderID", orderID);
                cmd.Parameters.AddWithValue("@Status", status);

                conn.Open();
                cmd.ExecuteNonQuery();
                
                // Log activity
                string adminUser = Session["UserName"]?.ToString() ?? "Admin";
                ActivityLogHelper.LogActivity("Order Status Change",
                    $"Order #{orderID} status changed to {status}", 
                    adminUser, 
                    $"Order #{orderID}", 
                    "Info");
            }
        }

        protected void gvOrders_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                string status = DataBinder.Eval(e.Row.DataItem, "OrderStatus").ToString();
                Label lblStatus = (Label)e.Row.FindControl("lblStatus");

                if (lblStatus != null)
                {
                    switch (status)
                    {
                        case "Pending":
                            lblStatus.Text = "<span class='status-badge status-pending'>Pending</span>";
                            break;
                        case "Confirmed":
                            lblStatus.Text = "<span class='status-badge status-confirmed'>Confirmed</span>";
                            break;
                        case "Out for Delivery":
                            lblStatus.Text = "<span class='status-badge status-out-for-delivery'>Out for Delivery</span>";
                            break;
                        case "Delivered":
                            lblStatus.Text = "<span class='status-badge status-delivered'>Delivered</span>";
                            break;
                        case "Picked Up":
                            lblStatus.Text = "<span class='status-badge status-picked-up'>Picked Up</span>";
                            break;
                        case "No Show":
                            lblStatus.Text = "<span class='status-badge status-no-show'>No Show</span>";
                            e.Row.CssClass = "no-show";
                            break;
                        case "Cancelled":
                            lblStatus.Text = "<span class='status-badge status-cancelled'>Cancelled</span>";
                            e.Row.CssClass = "cancelled";
                            break;
                        default:
                            lblStatus.Text = "<span class='status-badge status-pending'>" + status + "</span>";
                            break;
                    }
                }

                // Load inline order items summary
                int orderID = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "OrderID"));
                Label lblOrderItems = (Label)e.Row.FindControl("lblOrderItems");
                if (lblOrderItems != null)
                {
                    lblOrderItems.Text = GetOrderItemsSummary(orderID);
                }

                if (status == "Cancelled")
                    e.Row.CssClass = "cancelled";
                else if (status == "No Show")
                    e.Row.CssClass = "no-show";
            }
        }

        private string GetOrderItemsSummary(int orderID)
        {
            var lines = new System.Text.StringBuilder();
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"SELECT p.ProductName, ps.SizeName, pf.FlavorName, oi.Quantity
                                     FROM OrderItems oi
                                     INNER JOIN Products p ON oi.ProductID = p.ProductID
                                     LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID AND ps.ProductID = oi.ProductID
                                     LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                                     WHERE oi.OrderID = @OrderID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@OrderID", orderID);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string product = reader["ProductName"].ToString();
                            string size = reader["SizeName"] == DBNull.Value ? "" : " " + reader["SizeName"].ToString();
                            string flavor = reader["FlavorName"] == DBNull.Value ? "" : " (" + reader["FlavorName"].ToString() + ")";
                            int qty = Convert.ToInt32(reader["Quantity"]);
                            lines.Append($"<div class='item-line'><span class='item-qty'>{qty}×</span> {product}{size}{flavor}</div>");
                        }
                    }
                }
            }
            catch { }
            return lines.Length > 0 ? lines.ToString() : "<span style='color:#aaa;font-size:12px;'>—</span>";
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<OrderItemDto> GetOrderItems(int orderID)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
            var items = new List<OrderItemDto>();
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"SELECT p.ProductName, ps.SizeName, pf.FlavorName, oi.Quantity,
                                        (p.BasePrice + ISNULL(ps.PriceModifier, 0)) AS UnitPrice
                                 FROM OrderItems oi
                                 INNER JOIN Products p ON oi.ProductID = p.ProductID
                                 LEFT JOIN ProductSizes ps ON oi.SizeID = ps.SizeID AND ps.ProductID = oi.ProductID
                                 LEFT JOIN ProductFlavors pf ON oi.FlavorID = pf.FlavorID
                                 WHERE oi.OrderID = @OrderID";
                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@OrderID", orderID);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        items.Add(new OrderItemDto
                        {
                            ProductName = reader["ProductName"].ToString(),
                            SizeName = reader["SizeName"] == DBNull.Value ? null : reader["SizeName"].ToString(),
                            FlavorName = reader["FlavorName"] == DBNull.Value ? null : reader["FlavorName"].ToString(),
                            Quantity = Convert.ToInt32(reader["Quantity"]),
                            UnitPrice = Convert.ToDecimal(reader["UnitPrice"])
                        });
                    }
                }
            }
            return items;
        }

        public class OrderItemDto
        {
            public string ProductName { get; set; }
            public string SizeName { get; set; }
            public string FlavorName { get; set; }
            public int Quantity { get; set; }
            public decimal UnitPrice { get; set; }
        }

        protected void lnkSales_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sales.aspx");
        }

        protected void lnkUpdate_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Update.aspx");
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/AccountAdmin.aspx");
        }

        protected void lnkActivityLog_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ActivityLog.aspx");
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            gvOrders.PageIndex = 0; // Reset to first page when filter changes
            LoadOrders();
        }

        protected void gvOrders_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvOrders.PageIndex = e.NewPageIndex;
            LoadOrders();
        }

        protected void gvMembershipRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ApproveMembership")
            {
                int requestID = Convert.ToInt32(e.CommandArgument);
                ApproveMembershipRequest(requestID);
                LoadPendingMembershipRequests();
            }
        }
        protected void lnkHome_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Admin.aspx");
        }

        private void ApproveMembershipRequest(int requestID)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                EnsureMembershipColumnsExist(conn);

                string fetchQuery = @"
                    SELECT MembershipID, CustomerID, MembershipNumber
                    FROM Membership
                    WHERE MembershipID = @RequestID AND RequestStatus = 'Pending'";

                int customerID = 0;

                using (SqlCommand fetchCmd = new SqlCommand(fetchQuery, conn))
                {
                    fetchCmd.Parameters.AddWithValue("@RequestID", requestID);
                    using (SqlDataReader reader = fetchCmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return;
                        }

                        customerID = Convert.ToInt32(reader["CustomerID"]);
                    }
                }

                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        string updateUserQuery = "UPDATE USERS SET MembershipLevel = 'Royalty' WHERE CustomerID = @CustomerID";
                        using (SqlCommand userCmd = new SqlCommand(updateUserQuery, conn, tx))
                        {
                            userCmd.Parameters.AddWithValue("@CustomerID", customerID);
                            userCmd.ExecuteNonQuery();
                        }

                        string completeRequestQuery = @"
                            UPDATE Membership
                            SET RequestStatus = 'Confirmed',
                                ConfirmedDate = GETDATE()
                            WHERE MembershipID = @RequestID";
                        using (SqlCommand completeCmd = new SqlCommand(completeRequestQuery, conn, tx))
                        {
                            completeCmd.Parameters.AddWithValue("@RequestID", requestID);
                            completeCmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }
    }
}
