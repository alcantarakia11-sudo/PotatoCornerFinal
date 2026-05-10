using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static PotatoCornerSys.Order;

namespace PotatoCornerSys
{
    public partial class Receipt : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["OrderName"] == null)
                {
                    Response.Redirect("~/Order.aspx");
                    return;
                }

                // Customer details
                lblName.Text = Session["OrderName"].ToString();
                string address = Session["OrderAddress"]?.ToString();
                lblAddress.Text = address;
                pnlAddress.Visible = !string.IsNullOrEmpty(address);
                lblContact.Text = Session["OrderContact"].ToString();
                lblDelivery.Text = Session["OrderDelivery"].ToString();
                lblOrderDate.Text = DateTime.Now.ToString("MMMM dd, yyyy hh:mm tt");
                lblOrderNo.Text = Session["OrderID"]?.ToString() ?? new Random().Next(10000, 99999).ToString();

                // Royalty
                bool isRoyalty = Session["OrderIsRoyalty"]?.ToString() == "true";
                pnlRoyalty.Visible = isRoyalty;
                pnlNoRoyalty.Visible = !isRoyalty;

                if (isRoyalty && Session["RoyaltyNo"] != null)
                    lblRoyaltyNo.Text = Session["RoyaltyNo"].ToString();

                // Totals from session
                lblSubtotal.Text = Session["OrderSubtotal"]?.ToString() ?? "0.00";
                lblDiscount.Text = Session["OrderDiscount"]?.ToString() ?? "0.00";
                lblDeliveryFee.Text = Session["OrderDeliveryFee"]?.ToString() ?? "0.00";
                lblTotal.Text = Session["OrderTotal"]?.ToString() ?? "0.00";

                // ✅ Read from ReceiptCart (saved before cart was cleared in Order.aspx)
                var cart = Session["ReceiptCart"] as List<CartItem>;
                if (cart != null && cart.Count > 0)
                {
                    rptItems.DataSource = cart;
                    rptItems.DataBind();
                }

                // Payment & points
                lblPaymentMethod.Text = Session["PaymentMethod"]?.ToString() ?? "-";
                lblAmountPaid.Text = Session["AmountPaid"]?.ToString() ?? "-";
                lblChange.Text = Session["Change"]?.ToString() ?? "0.00";
                lblPointsEarned.Text = Session["PointsEarned"]?.ToString() ?? "0";

                // ✅ Clear both after displaying
                Session["ReceiptCart"] = null;
                Session["Cart"] = null;
            }
        }

        protected void btnHome_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Default.aspx");
        }
    }
}