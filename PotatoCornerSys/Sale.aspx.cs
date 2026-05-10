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
    public partial class Sales : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // ✅ Only check UserName, remove MembershipLevel check
                if (Session["AdminID"] == null)
                {
                    Response.Redirect("~/AdminLogin.aspx");
                    return;
                }
                LoadSalesData();
            }
        }

        private void LoadSalesData()
        {
            LoadStatistics();
            LoadOrders();
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
                o.TotalAmount, o.OrderStatus, o.DeliveryType
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

                if (status == "Cancelled")
                {
                    e.Row.CssClass = "cancelled";
                }
                else if (status == "No Show")
                {
                    e.Row.CssClass = "no-show";
                }
            }
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
        protected void lnkActivityLog_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ActivityLog.aspx");
        }
        protected void gvMembershipRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ApproveMembership")
            {
                int userID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = "UPDATE USERS SET MembershipLevel = 'Member' WHERE CustomerID = @UserID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                LoadSalesData();
            }
            else if (e.CommandName == "RejectMembership")
            {
                int userID = Convert.ToInt32(e.CommandArgument);
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = "UPDATE USERS SET MembershipLevel = 'Regular' WHERE CustomerID = @UserID";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                LoadSalesData();
            }
        }
    }
}