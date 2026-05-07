using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Update : System.Web.UI.Page
    {
        string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
        private const int LOW_STOCK_THRESHOLD = 20;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserName"] == null || Session["MembershipLevel"]?.ToString() != "Admin")
                {
                    Response.Redirect("~/Login.aspx");
                }
                LoadStockData();
                CheckLowStock();
            }
        }

        private void LoadStockData()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                // Get product sizes stock - use DISTINCT to avoid duplicates
                string query = @"SELECT DISTINCT
                                    pss.StockID AS ProductID,
                                    p.ProductName + ' - ' + ps.SizeName AS ProductName,
                                    'Size' AS Category,
                                    pss.StockQuantity AS CurrentStock
                                FROM ProductSizeStock pss
                                INNER JOIN Products p ON pss.ProductID = p.ProductID
                                INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
                                UNION
                                SELECT DISTINCT
                                    fs.StockID AS ProductID,
                                    pf.FlavorName AS ProductName,
                                    'Flavor' AS Category,
                                    fs.StockQuantity AS CurrentStock
                                FROM FlavorStock fs
                                INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
                                ORDER BY Category, ProductName";

                SqlDataAdapter da = new SqlDataAdapter(query, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvStock.DataSource = dt;
                gvStock.DataBind();
            }
        }

        private void CheckLowStock()
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                string query = @"SELECT ProductName, CurrentStock FROM (
                                    SELECT 
                                        p.ProductName + ' - ' + ps.SizeName AS ProductName,
                                        pss.StockQuantity AS CurrentStock
                                    FROM ProductSizeStock pss
                                    INNER JOIN Products p ON pss.ProductID = p.ProductID
                                    INNER JOIN ProductSizes ps ON pss.SizeID = ps.SizeID
                                    WHERE pss.StockQuantity < @Threshold
                                    UNION ALL
                                    SELECT 
                                        pf.FlavorName AS ProductName,
                                        fs.StockQuantity AS CurrentStock
                                    FROM FlavorStock fs
                                    INNER JOIN ProductFlavors pf ON fs.FlavorID = pf.FlavorID
                                    WHERE fs.StockQuantity < @Threshold
                                ) AS LowStockItems
                                ORDER BY CurrentStock";

                SqlCommand cmd = new SqlCommand(query, conn);
                cmd.Parameters.AddWithValue("@Threshold", LOW_STOCK_THRESHOLD);

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                StringBuilder lowStockItems = new StringBuilder();
                bool hasLowStock = false;

                while (reader.Read())
                {
                    hasLowStock = true;
                    string productName = reader["ProductName"].ToString();
                    int stock = Convert.ToInt32(reader["CurrentStock"]);
                    lowStockItems.Append($"{productName} (Stock: {stock}), ");
                }

                if (hasLowStock)
                {
                    pnlLowStockAlert.Visible = true;
                    lblLowStockItems.Text = "The following items are running low: " + 
                        lowStockItems.ToString().TrimEnd(',', ' ');
                }
                else
                {
                    pnlLowStockAlert.Visible = false;
                }
            }
        }

        protected void gvStock_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                int currentStock = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "CurrentStock"));
                Label lblStatus = (Label)e.Row.FindControl("lblStockStatus");

                if (currentStock < LOW_STOCK_THRESHOLD)
                {
                    lblStatus.Text = "LOW STOCK";
                    lblStatus.CssClass = "stock-badge stock-low";
                    e.Row.CssClass = "low-stock";
                }
                else
                {
                    lblStatus.Text = "OK";
                    lblStatus.CssClass = "stock-badge stock-ok";
                }
            }
        }

        protected void gvStock_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "UpdateStock")
            {
                int productID = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = (GridViewRow)((Button)e.CommandSource).NamingContainer;
                TextBox txtAddStock = (TextBox)row.FindControl("txtAddStock");
                
                int addStock = 0;
                if (int.TryParse(txtAddStock.Text, out addStock) && addStock > 0)
                {
                    UpdateProductStock(productID, addStock);
                    LoadStockData();
                    CheckLowStock();
                }
            }
        }

        private void UpdateProductStock(int stockID, int addStock)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                // Try updating ProductSizeStock first
                string querySizeStock = @"UPDATE ProductSizeStock 
                                SET StockQuantity = StockQuantity + @AddStock,
                                    LastUpdated = GETDATE()
                                WHERE StockID = @StockID";

                SqlCommand cmd = new SqlCommand(querySizeStock, conn);
                cmd.Parameters.AddWithValue("@StockID", stockID);
                cmd.Parameters.AddWithValue("@AddStock", addStock);

                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();

                // If no rows affected, try FlavorStock
                if (rowsAffected == 0)
                {
                    string queryFlavorStock = @"UPDATE FlavorStock 
                                    SET StockQuantity = StockQuantity + @AddStock,
                                        LastUpdated = GETDATE()
                                    WHERE StockID = @StockID";

                    SqlCommand cmdFlavor = new SqlCommand(queryFlavorStock, conn);
                    cmdFlavor.Parameters.AddWithValue("@StockID", stockID);
                    cmdFlavor.Parameters.AddWithValue("@AddStock", addStock);
                    cmdFlavor.ExecuteNonQuery();
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
            Response.Redirect("~/ProfileAdmin.aspx");
        }
    }
}
