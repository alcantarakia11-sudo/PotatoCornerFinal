using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web.UI;

namespace PotatoCorner
{
    public partial class AdminDashboard : Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

        // ── Page Load ─────────────────────────────────────────────────────────
        protected void Page_Load(object sender, EventArgs e)
        {
            // Removed: session guard that redirected to ~/AdminLogin.aspx
            // if (Session["AdminID"] == null) { Response.Redirect("~/AdminLogin.aspx"); return; }

            if (!IsPostBack)
            {
                LoadSummaryCards();
                LoadRecentOrders();
                LoadLowStockAlerts();
                LoadSalesOverview();
                LoadActivityLogs();
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        // 1. SUMMARY CARDS
        // Tables used: Orders, USERS
        // ══════════════════════════════════════════════════════════════════════
        private void LoadSummaryCards()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // Orders Today
                int ordersToday = Convert.ToInt32(GetScalar(conn, @"
                    SELECT COUNT(*)
                    FROM   Orders
                    WHERE  CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)"));

                lblOrdersToday.Text = ordersToday.ToString();

                // Sales Today  (OrderStatus column, not Status)
                decimal salesToday = Convert.ToDecimal(GetScalar(conn, @"
                    SELECT ISNULL(SUM(TotalAmount), 0)
                    FROM   Orders
                    WHERE  CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
                      AND  OrderStatus <> 'Cancelled'"));

                lblSalesToday.Text = "₱" + salesToday.ToString("N0");

                // Pending Orders
                lblPendingOrders.Text = GetScalar(conn, @"
                    SELECT COUNT(*)
                    FROM   Orders
                    WHERE  OrderStatus = 'Pending'").ToString();

                // Ready for Pick-up
                lblReadyPickup.Text = GetScalar(conn, @"
                    SELECT COUNT(*)
                    FROM   Orders
                    WHERE  OrderStatus = 'Ready'").ToString();

                // Trend vs yesterday
                int yesterday = Convert.ToInt32(GetScalar(conn, @"
                    SELECT COUNT(*)
                    FROM   Orders
                    WHERE  CAST(OrderDate AS DATE) =
                           CAST(DATEADD(DAY,-1,GETDATE()) AS DATE)"));

                if (yesterday > 0)
                {
                    double pct = ((double)(ordersToday - yesterday) / yesterday) * 100;
                    string sign = pct >= 0 ? "+" : "";
                    lblOrdersTrend.Text = sign + pct.ToString("F0") + "% vs yesterday";
                }
                else
                {
                    lblOrdersTrend.Text = ordersToday > 0
                        ? "New orders today!" : "No orders yet today";
                }
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        // 2. RECENT ORDERS
        // Tables used: Orders, USERS
        // ══════════════════════════════════════════════════════════════════════
        private void LoadRecentOrders()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string sql = @"
                    SELECT TOP 10
                        o.OrderID,
                        ISNULL(u.Fullname, 'Walk-in')  AS Customer,
                        o.TotalAmount,
                        o.TotalQuantity,
                        o.DeliveryType,
                        o.PaymentMethod,
                        o.OrderStatus,
                        o.OrderDate
                    FROM  Orders o
                    LEFT  JOIN USERS u ON o.CustomerID = u.CustomerID
                    ORDER BY o.OrderDate DESC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvRecentOrders.DataSource = dt;
                gvRecentOrders.DataBind();
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        // 3. LOW STOCK ALERTS
        // Tables used: FlavorStock + ProductFlavors, ProductSizeStock + Products + ProductSizes
        // Threshold: Critical ≤ 5 | Low Stock ≤ 15
        // ══════════════════════════════════════════════════════════════════════
        private void LoadLowStockAlerts()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string sql = @"
                    SELECT ItemName, Quantity, StockType, StockStatus, LastUpdated
                    FROM (

                        -- Flavor-level stock
                        SELECT
                            pf.FlavorName                               AS ItemName,
                            fs.StockQuantity                            AS Quantity,
                            'Flavor'                                    AS StockType,
                            CASE
                                WHEN fs.StockQuantity <= 5  THEN 'Critical'
                                WHEN fs.StockQuantity <= 15 THEN 'Low Stock'
                            END                                         AS StockStatus,
                            fs.LastUpdated
                        FROM FlavorStock fs
                        INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
                        WHERE fs.StockQuantity <= 15

                        UNION ALL

                        -- Product-size-level stock
                        SELECT
                            p.ProductName + ' (' + ps.SizeName + ')'   AS ItemName,
                            pss.StockQuantity                           AS Quantity,
                            'Product'                                   AS StockType,
                            CASE
                                WHEN pss.StockQuantity <= 5  THEN 'Critical'
                                WHEN pss.StockQuantity <= 15 THEN 'Low Stock'
                            END                                         AS StockStatus,
                            pss.LastUpdated
                        FROM ProductSizeStock pss
                        INNER JOIN Products     p  ON pss.ProductID = p.ProductID
                        INNER JOIN ProductSizes ps ON pss.SizeID    = ps.SizeID
                        WHERE pss.StockQuantity <= 15

                    ) AS Combined
                    ORDER BY Quantity ASC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptLowStock.DataSource = dt;
                rptLowStock.DataBind();

                lblNoAlerts.Visible = (dt.Rows.Count == 0);
                rptLowStock.Visible = (dt.Rows.Count > 0);
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        // 4. SALES OVERVIEW  →  JSON strings written to HiddenFields
        //    Front-end Chart.js reads hfDailyData.value / hfWeeklyData.value
        // Tables used: Orders
        // ══════════════════════════════════════════════════════════════════════
        private void LoadSalesOverview()
        {
            string dailySql = @"
        SELECT
            DATEPART(HOUR, OrderDate)   AS [Hour],
            ISNULL(SUM(TotalAmount), 0) AS Sales,
            COUNT(*)                    AS Orders
        FROM  Orders
        WHERE CAST(OrderDate AS DATE) = CAST(GETDATE() AS DATE)
          AND OrderStatus <> 'Cancelled'
        GROUP BY DATEPART(HOUR, OrderDate)
        ORDER BY [Hour]";

            hfDailyData.Value = BuildChartJson(dailySql, isHour: true);

            string weeklySql = @"
        SELECT
            CAST(OrderDate AS DATE)     AS [Day],
            ISNULL(SUM(TotalAmount), 0) AS Sales,
            COUNT(*)                    AS Orders
        FROM  Orders
        WHERE OrderDate >= DATEADD(DAY, -6, CAST(GETDATE() AS DATE))
          AND OrderStatus <> 'Cancelled'
        GROUP BY CAST(OrderDate AS DATE)
        ORDER BY [Day]";

            hfWeeklyData.Value = BuildChartJson(weeklySql, isHour: false);
        }

        private string BuildChartJson(string sql, bool isHour)
        {
            var labels = new List<string>();
            var sales = new List<string>();
            var orders = new List<string>();

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    while (dr.Read())
                    {
                        if (isHour)
                        {
                            int h = Convert.ToInt32(dr["Hour"]);
                            string label = h == 0 ? "12am"
                                         : h < 12 ? h + "am"
                                         : h == 12 ? "12pm"
                                         : (h - 12) + "pm";
                            labels.Add(label);
                        }
                        else
                        {
                            DateTime day = Convert.ToDateTime(dr["Day"]);
                            labels.Add(day.ToString("ddd MM/dd"));
                        }

                        sales.Add(Convert.ToDecimal(dr["Sales"]).ToString("F0"));
                        orders.Add(dr["Orders"].ToString());
                    }
                }
            }

            return "{" +
                "\"labels\":[\"" + string.Join("\",\"", labels) + "\"]," +
                "\"sales\":[" + (sales.Count > 0 ? string.Join(",", sales) : "0") + "]," +
                "\"orders\":[" + (orders.Count > 0 ? string.Join(",", orders) : "0") + "]}";
        }

        private string BuildChartJson(SqlConnection conn, string sql, bool isHour)
        {
            var labels = new List<string>();
            var sales = new List<string>();
            var orders = new List<string>();

            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    if (isHour)
                    {
                        int h = Convert.ToInt32(dr["Hour"]);
                        string label = h == 0 ? "12am"
                                     : h < 12 ? h + "am"
                                     : h == 12 ? "12pm"
                                     : (h - 12) + "pm";
                        labels.Add(label);
                    }
                    else
                    {
                        DateTime day = Convert.ToDateTime(dr["Day"]);
                        labels.Add(day.ToString("ddd MM/dd"));
                    }

                    sales.Add(Convert.ToDecimal(dr["Sales"]).ToString("F0"));
                    orders.Add(dr["Orders"].ToString());
                }
            }

            // Return a safe JSON object
            return "{" +
                "\"labels\":[\"" + string.Join("\",\"", labels) + "\"]," +
                "\"sales\":[" + (sales.Count > 0 ? string.Join(",", sales) : "0") + "]," +
                "\"orders\":[" + (orders.Count > 0 ? string.Join(",", orders) : "0") + "]}";
        }

        // ══════════════════════════════════════════════════════════════════════
        // 5. ACTIVITY LOGS
        // Built from Orders (status events) + Membership registrations
        // (No separate AdminActivityLog table in current DB)
        // Tables used: Orders, USERS, Membership
        // ══════════════════════════════════════════════════════════════════════
        private void LoadActivityLogs()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                string sql = @"
                    SELECT TOP 10
                        Activity,
                        ActivityDate
                    FROM (

                        -- Recent order events
                        SELECT
                            'Order #' + CAST(o.OrderID AS NVARCHAR)
                                + ' [' + o.DeliveryType + '] — '
                                + o.OrderStatus
                                + ' | ' + ISNULL(u.Fullname, 'Walk-in')    AS Activity,
                            o.OrderDate                                     AS ActivityDate
                        FROM  Orders o
                        LEFT  JOIN USERS u ON o.CustomerID = u.CustomerID

                        UNION ALL

                        -- New membership registrations
                        SELECT
                            'Membership registered: '
                                + u.Fullname
                                + ' — Card# ' + m.MembershipNumber         AS Activity,
                            CAST(m.RegistrationDate AS DATETIME)            AS ActivityDate
                        FROM  Membership m
                        INNER JOIN USERS u ON m.CustomerID = u.CustomerID

                    ) AS Combined
                    ORDER BY ActivityDate DESC";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptActivityLog.DataSource = dt;
                rptActivityLog.DataBind();
            }
        }

        // ══════════════════════════════════════════════════════════════════════
        // BUTTON — Refresh (wired to runat="server" button in .aspx)
        // ══════════════════════════════════════════════════════════════════════
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadSummaryCards();
            LoadRecentOrders();
            LoadLowStockAlerts();
            LoadSalesOverview();
            LoadActivityLogs();
        }

        // ══════════════════════════════════════════════════════════════════════
        // HELPER
        // ══════════════════════════════════════════════════════════════════════
        private object GetScalar(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar() ?? 0;
        }

        // ══════════════════════════════════════════════════════════════════════
        // HELPER — Called from .aspx Repeater to format relative timestamps
        // ══════════════════════════════════════════════════════════════════════
        protected string FormatTimeAgo(DateTime dt)
        {
            TimeSpan diff = DateTime.Now - dt;

            if (diff.TotalSeconds < 60)
                return "Just now";
            if (diff.TotalMinutes < 60)
                return (int)diff.TotalMinutes + " min ago";
            if (diff.TotalHours < 24)
                return (int)diff.TotalHours + " hr ago";
            if (diff.TotalDays < 7)
                return (int)diff.TotalDays + " day(s) ago";

            return dt.ToString("MMM dd, yyyy");
        }


    }
}
