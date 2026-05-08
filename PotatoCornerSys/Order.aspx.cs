using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Order : System.Web.UI.Page
    {
        const decimal DELIVERY_FEE = 50m;
        const decimal ROYALTY_DISCOUNT_RATE = 0.10m;

        public class CartItem
        {
            public string Product { get; set; }
            public string Size { get; set; }
            public string Flavor { get; set; }
            public int Qty { get; set; }
            public decimal UnitPrice { get; set; }
            public decimal LineTotal => UnitPrice * Qty;
        }

        private List<CartItem> Cart
        {
            get
            {
                if (Session["Cart"] == null)
                    Session["Cart"] = new List<CartItem>();
                return (List<CartItem>)Session["Cart"];
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Auto-fill name from session
                if (Session["Name"] != null)
                {
                    txtName.Text = Session["Name"].ToString();
                }
                else if (Session["Fullname"] != null)
                {
                    txtName.Text = Session["Fullname"].ToString();
                }
                else if (Session["Username"] != null)
                {
                    txtName.Text = Session["Username"].ToString();
                }
            }
            
            if (Request.Form["__EVENTTARGET"] == "RemoveCartItem")
            {
                try
                {
                    int index = Convert.ToInt32(Request.Form["__EVENTARGUMENT"]);
                    if (index >= 0 && index < Cart.Count)
                    {
                        Cart.RemoveAt(index);
                        BindCart();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error removing cart item: " + ex.Message);
                }
                return;
            }

            if (!IsPostBack)
            {
                if (Session["Cart"] == null)
                    Session["Cart"] = new List<CartItem>();

                hdnFriesQty.Value = "1";
                hdnChickenQty.Value = "1";
                hdnLoopysQty.Value = "1";
                LoadPickupTimeSlots();

                if (Session["ReorderMessage"] != null)
                {
                    lblErrorMsg.Text = Session["ReorderMessage"].ToString();
                    lblErrorMsg.CssClass = "status-msg status-success";
                    lblErrorMsg.Visible = true;
                    Session["ReorderMessage"] = null;
                }
            }
            BindCart();
        }

        private void LoadPickupTimeSlots()
        {
            rblPickupTime.Items.Clear();
            DateTime now = DateTime.Now;

            for (int i = 1; i <= 12; i++)
            {
                DateTime slotTime = now.AddMinutes(15 * i);
                string timeText = slotTime.ToString("h:mm tt") + " (" + (15 * i) + " mins)";
                rblPickupTime.Items.Add(new ListItem(timeText, slotTime.ToString("yyyy-MM-dd HH:mm")));
            }
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Profile.aspx");
        }

        protected void btnValidate_Click(object sender, EventArgs e)
        {
            string royaltyNo = txtRoyaltyNo.Text.Trim();

            if (string.IsNullOrEmpty(royaltyNo))
            {
                lblRoyaltyMsg.Text = "Please enter a royalty number.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                return;
            }

            if (royaltyNo.Length != 7 ||
                !char.IsLetter(royaltyNo[0]) ||
                !char.IsLetter(royaltyNo[1]) ||
                !royaltyNo.Substring(2).All(char.IsDigit))
            {
                lblRoyaltyMsg.Text = "Invalid royalty number format. Should be 2 letters + 5 numbers (e.g., PC12345)";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            bool isLoggedIn = Session["CustomerID"] != null;
            bool hasRoyalty = Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"];
            string storedRoyaltyNo = Session["RoyaltyNumber"]?.ToString();

            if (isLoggedIn && hasRoyalty && !string.IsNullOrEmpty(storedRoyaltyNo))
            {
                if (!royaltyNo.Equals(storedRoyaltyNo, StringComparison.OrdinalIgnoreCase))
                {
                    lblRoyaltyMsg.Text = "Card number doesn't match to the user card number.";
                    lblRoyaltyMsg.CssClass = "status-msg status-error";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "false";
                    return;
                }

                // ✅ Flexible name matching
                string storedFullName = Session["Fullname"]?.ToString();

                if (!string.IsNullOrEmpty(storedFullName))
                {
                    Func<string, string> normalize = s =>
                        System.Text.RegularExpressions.Regex
                            .Replace(s.Trim().ToLower(), @"\s+", " ");

                    string enteredName = normalize(txtName.Text);
                    string accountName = normalize(storedFullName);

                    if (enteredName != accountName)
                    {
                        string[] enteredParts = enteredName.Split(' ');
                        string[] accountParts = accountName.Split(' ');

                        bool firstMatch = enteredParts[0] == accountParts[0];
                        bool lastMatch = enteredParts.Last() == accountParts.Last();

                        if (!firstMatch || !lastMatch)
                        {
                            lblRoyaltyMsg.Text = "Customer name doesn't match the royalty card holder.";
                            lblRoyaltyMsg.CssClass = "status-msg status-error";
                            lblRoyaltyMsg.Visible = true;
                            hdnIsRoyalty.Value = "false";
                            return;
                        }
                    }
                }
            }

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                SELECT u.CustomerID, u.Fullname, u.MembershipLevel
                FROM USERS u
                INNER JOIN Membership m ON u.CustomerID = m.CustomerID
                WHERE u.MembershipLevel = 'Royalty' AND m.MembershipNumber = @MembershipNumber";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@MembershipNumber", royaltyNo);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblRoyaltyMsg.Text = "Royalty number validated! 10% discount applied.";
                                lblRoyaltyMsg.CssClass = "status-msg status-success";
                                lblRoyaltyMsg.Visible = true;
                                hdnIsRoyalty.Value = "true";
                                UpdateCartTotals();
                                return;
                            }
                        }
                    }
                }

                lblRoyaltyMsg.Text = "Royalty number not found. Please check and try again.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
            }
            catch (Exception ex)
            {
                if (hasRoyalty && !string.IsNullOrEmpty(storedRoyaltyNo) &&
                    storedRoyaltyNo.Equals(royaltyNo, StringComparison.OrdinalIgnoreCase))
                {
                    lblRoyaltyMsg.Text = "Royalty number validated! 10% discount applied.";
                    lblRoyaltyMsg.CssClass = "status-msg status-success";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "true";
                    UpdateCartTotals();
                }
                else
                {
                    lblRoyaltyMsg.Text = "Card number doesn't match to the user card number.";
                    lblRoyaltyMsg.CssClass = "status-msg status-error";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "false";
                }
            }
        }

        protected void btnChickenMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnChickenQty.Value);
            if (qty > 1) qty--;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update();
        }

        protected void btnChickenPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnChickenQty.Value);
            qty++;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update();
        }

        protected void btnLoopysMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnLoopysQty.Value);
            if (qty > 1) qty--;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update();
        }

        protected void btnLoopysPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnLoopysQty.Value);
            qty++;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update();
        }

        protected void btnFriesMinus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnFriesQty.Value);
            if (qty > 1) qty--;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update();
        }

        protected void btnFriesPlus_Click(object sender, EventArgs e)
        {
            int qty = int.Parse(hdnFriesQty.Value);
            qty++;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update();
        }

        protected void btnAddFries_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbFriesRegular.Checked) { size = "Regular"; price = 39; }
            else if (rbFriesLarge.Checked) { size = "Large"; price = 58; }
            else if (rbFriesJumbo.Checked) { size = "Jumbo"; price = 97; }
            else if (rbFriesMega.Checked) { size = "Mega"; price = 135; }
            else if (rbFriesGiga.Checked) { size = "Giga"; price = 198; }
            else if (rbFriesTerra.Checked) { size = "Terra"; price = 228; }
            else
            {
                lblErrorMsg.Text = "Please select a size for French Fries.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbFriesSourCream.Checked) flavor = "Sour Cream";
            else if (rbFriesBBQ.Checked) flavor = "BBQ";
            else if (rbFriesCheese.Checked) flavor = "Cheese";
            else if (rbFriesSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for French Fries.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnFriesQty.Value);
            Cart.Add(new CartItem { Product = "French Fries", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            lblErrorMsg.Text = $"Added: {qty}x French Fries ({size}, {flavor}) - PHP {price}";
            lblErrorMsg.CssClass = "status-msg status-success";
            lblErrorMsg.Visible = true;

            rbFriesRegular.Checked = rbFriesLarge.Checked = rbFriesJumbo.Checked = false;
            rbFriesMega.Checked = rbFriesGiga.Checked = rbFriesTerra.Checked = false;
            rbFriesSourCream.Checked = rbFriesBBQ.Checked = rbFriesCheese.Checked = false;
            rbFriesSalt.Checked = false;
            hdnFriesQty.Value = "1";
            lblFriesQty.Text = "1";

            BindCart();
        }

        protected void btnAddChicken_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbChickenSolo.Checked) { size = "Solo"; price = 75; }
            else if (rbChickenLarge.Checked) { size = "Large Mix"; price = 95; }
            else if (rbChickenMega.Checked) { size = "Mega Mix"; price = 199; }
            else
            {
                lblErrorMsg.Text = "Please select a size for Chicken Pops.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbChickenSourCream.Checked) flavor = "Sour Cream";
            else if (rbChickenBBQ.Checked) flavor = "BBQ";
            else if (rbChickenCheese.Checked) flavor = "Cheese";
            else if (rbChickenSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for Chicken Pops.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnChickenQty.Value);
            Cart.Add(new CartItem { Product = "Chicken Pops", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            rbChickenSolo.Checked = rbChickenLarge.Checked = rbChickenMega.Checked = false;
            rbChickenSourCream.Checked = rbChickenBBQ.Checked = rbChickenCheese.Checked = false;
            rbChickenSalt.Checked = false;
            hdnChickenQty.Value = "1";
            lblChickenQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void btnAddLoopys_Click(object sender, EventArgs e)
        {
            string size = "";
            decimal price = 0;

            if (rbLoopysLarge.Checked) { size = "Large"; price = 75; }
            else if (rbLoopysMega.Checked) { size = "Mega"; price = 135; }
            else
            {
                lblErrorMsg.Text = "Please select a size for Loopys.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = "";
            if (rbLoopysSourCream.Checked) flavor = "Sour Cream";
            else if (rbLoopysBBQ.Checked) flavor = "BBQ";
            else if (rbLoopysCheese.Checked) flavor = "Cheese";
            else if (rbLoopysSalt.Checked) flavor = "Salt";
            else
            {
                lblErrorMsg.Text = "Please select a flavor for Loopys.";
                lblErrorMsg.Visible = true;
                return;
            }

            int qty = int.Parse(hdnLoopysQty.Value);
            Cart.Add(new CartItem { Product = "Loopys", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            rbLoopysLarge.Checked = rbLoopysMega.Checked = false;
            rbLoopysSourCream.Checked = rbLoopysBBQ.Checked = rbLoopysCheese.Checked = false;
            rbLoopysSalt.Checked = false;
            hdnLoopysQty.Value = "1";
            lblLoopysQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                try
                {
                    int index = Convert.ToInt32(e.CommandArgument);
                    if (index >= 0 && index < Cart.Count)
                    {
                        Cart.RemoveAt(index);
                        BindCart();
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error removing item: " + ex.Message);
                }
            }
        }

        protected void btnRemoveItem_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                int index = Convert.ToInt32(btn.CommandArgument);
                if (index >= 0 && index < Cart.Count)
                {
                    Cart.RemoveAt(index);
                    BindCart();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error removing item: " + ex.Message);
            }
        }

        protected void btnDeliveryType_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            btnWalkIn.CssClass = "option-btn";
            btnDelivery.CssClass = "option-btn";
            btn.CssClass = "option-btn selected";

            hdnDeliveryType.Value = btn.ID == "btnDelivery" ? "Delivery" : "WalkIn";

            if (hdnDeliveryType.Value == "Delivery")
            {
                hdnPickupTime.Value = "";
                lblPickupTime.Visible = false;
            }

            UpdateCartTotals();
        }

        // ✅ Payment method selection with Points balance check
        protected void btnPayment_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            btnGoTyme.CssClass = "option-btn";
            btnMayaBank.CssClass = "option-btn";
            btnGCash.CssClass = "option-btn";
            btnPoints.CssClass = "option-btn";

            if (btn.ID == "btnPoints")
            {
                decimal currentTotal = 0;
                decimal.TryParse(lblTotal.Text, out currentTotal);

                int userPoints = 0;
                if (Session["Points"] != null)
                    int.TryParse(Session["Points"].ToString(), out userPoints);

                decimal pointsValue = userPoints * 10m; // 1 point = PHP 10

                if (userPoints == 0 || pointsValue < currentTotal)
                {
                    lblErrorMsg.Text = $"Insufficient points balance. You have {userPoints} pts " +
                                       $"(PHP {pointsValue:0.00}) but the total is PHP {currentTotal:0.00}.";
                    lblErrorMsg.CssClass = "status-msg status-error";
                    lblErrorMsg.Visible = true;
                    hdnPaymentMethod.Value = "";
                    return;
                }
            }

            btn.CssClass = "option-btn selected";
            hdnPaymentMethod.Value = btn.Text;
            lblErrorMsg.Visible = false;
        }

        protected void btnConfirmPickupTime_Click(object sender, EventArgs e)
        {
            if (rblPickupTime.SelectedValue != "")
            {
                hdnPickupTime.Value = rblPickupTime.SelectedValue;
                hdnDeliveryType.Value = "WalkIn";
                btnWalkIn.CssClass = "option-btn selected";
                btnDelivery.CssClass = "option-btn";

                DateTime selectedTime = DateTime.Parse(rblPickupTime.SelectedValue);
                lblPickupTime.Text = "Pickup Time: " + selectedTime.ToString("MMM dd, yyyy h:mm tt");
                lblPickupTime.Visible = true;

                UpdateCartTotals();
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal", "hidePickupTimeModal();", true);
            }
        }

        // ✅ NEW: Handle modal submission with reference validation
        protected void btnSubmitPaymentModal_Click(object sender, EventArgs e)
        {
            string enteredReference = txtPaymentReferenceModal.Text.Trim().ToUpper();
            string generatedReference = hdnGeneratedReference.Value;
            
            // Validate reference format
            if (!enteredReference.StartsWith("REF-") || enteredReference.Length < 15)
            {
                lblErrorMsg.Text = "Invalid reference number format. Please scan the QR code and enter the correct reference.";
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal", 
                    $"showQRCodeModal('{hdnPaymentMethod.Value}', '{lblTotal.Text}');", true);
                return;
            }
            
            // Validate reference matches generated one
            if (enteredReference != generatedReference)
            {
                lblErrorMsg.Text = "Reference number does not match. Please scan the QR code and enter the correct reference.";
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal", 
                    $"showQRCodeModal('{hdnPaymentMethod.Value}', '{lblTotal.Text}');", true);
                return;
            }
            
            // Check for duplicate reference
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string checkQuery = "SELECT COUNT(*) FROM Orders WHERE PaymentReference = @Reference AND OrderStatus != 'Cancelled'";
                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Reference", enteredReference);
                        int count = (int)cmd.ExecuteScalar();
                        
                        if (count > 0)
                        {
                            lblErrorMsg.Text = "This reference number has already been used. Please generate a new QR code.";
                            lblErrorMsg.CssClass = "status-msg status-error";
                            lblErrorMsg.Visible = true;
                            ScriptManager.RegisterStartupScript(this, GetType(), "showModal", 
                                $"showQRCodeModal('{hdnPaymentMethod.Value}', '{lblTotal.Text}');", true);
                            return;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = "Error validating reference: " + ex.Message;
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                return;
            }
            
            // Reference is valid, process order
            ProcessOrder(enteredReference);
        }

        // ✅ Points payment or direct submission
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            // Only Points payment reaches here (GCash/Maya/GoTyme show modal instead)
            if (hdnPaymentMethod.Value == "Points")
            {
                ProcessOrder(null);
            }
        }
        
        private void ProcessOrder(string paymentReference)
        {
            if (string.IsNullOrEmpty(txtName.Text.Trim()) ||
                string.IsNullOrEmpty(ddlLocation.SelectedValue) ||
                string.IsNullOrEmpty(txtStreet.Text.Trim()) ||
                string.IsNullOrEmpty(txtContact.Text.Trim()))
            {
                lblErrorMsg.Text = "Please fill in all customer information.";
                lblErrorMsg.Visible = true;
                return;
            }

            string name = txtName.Text.Trim();
            if (name.Any(char.IsDigit))
            {
                lblErrorMsg.Text = "Full name cannot contain numbers.";
                lblErrorMsg.Visible = true;
                return;
            }

            string contact = txtContact.Text.Trim();
            if (!contact.All(char.IsDigit))
            {
                lblErrorMsg.Text = "Phone number can only contain numbers.";
                lblErrorMsg.Visible = true;
                return;
            }

            string street = txtStreet.Text.Trim();
            if (!street.All(c => char.IsLetterOrDigit(c) || c == ' ' || c == ',' || c == '.' || c == '-' || c == '#' || c == '/'))
            {
                lblErrorMsg.Text = "Street address contains invalid characters.";
                lblErrorMsg.Visible = true;
                return;
            }

            // Parse location
            string[] locationParts = ddlLocation.SelectedValue.Split('|');
            string barangay = locationParts[0];
            string locationType = locationParts[1];

            // Validate delivery type matches location
            if (locationType == "Delivery" && hdnDeliveryType.Value == "WalkIn")
            {
                lblErrorMsg.Text = "This location is only available for delivery orders.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (hdnDeliveryType.Value == "WalkIn" && string.IsNullOrEmpty(hdnPickupTime.Value))
            {
                lblErrorMsg.Text = "Please select a pickup time for walk-in orders.";
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                return;
            }

            if (Cart.Count == 0)
            {
                lblErrorMsg.Text = "Your cart is empty. Please add at least one item.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
            {
                lblErrorMsg.Text = "Please select a payment method.";
                lblErrorMsg.Visible = true;
                return;
            }

            decimal orderTotal = decimal.Parse(lblTotal.Text);
            decimal subtotal = decimal.Parse(lblSubtotal.Text);
            decimal discount = decimal.Parse(lblDiscount.Text);
            decimal deliveryFee = decimal.Parse(lblDeliveryFee.Text);
            
            // Points payment validation
            decimal amountPaid = orderTotal;
            decimal change = 0;

            if (hdnPaymentMethod.Value == "Points")
            {
                // ✅ Safety re-check — cart total may have changed after Points was selected
                int userPoints = 0;
                if (Session["Points"] != null)
                    int.TryParse(Session["Points"].ToString(), out userPoints);

                decimal pointsValue = userPoints * 10m;

                if (pointsValue < orderTotal)
                {
                    lblErrorMsg.Text = $"Insufficient points balance. You have {userPoints} pts " +
                                       $"(PHP {pointsValue:0.00}) but the total is PHP {orderTotal:0.00}. " +
                                       $"Please select another payment method.";
                    lblErrorMsg.CssClass = "status-msg status-error";
                    lblErrorMsg.Visible = true;
                    hdnPaymentMethod.Value = "";
                    btnPoints.CssClass = "option-btn";
                    return;
                }
            }

            try
            {
                int orderID = SaveOrderToDatabase(name, barangay, street, contact, orderTotal, subtotal, discount, deliveryFee, amountPaid, change, paymentReference);

                if (orderID > 0)
                {
                    // Deduct stock for each item
                    DeductStockForOrder();

                    // ✅ FIX: Deduct points if paid with Points, otherwise add earned points
                    int pointsEarned = (int)(orderTotal / 500) * 2;

                    if (hdnPaymentMethod.Value == "Points")
                    {
                        // Points used to pay = orderTotal / 10 (1 pt = PHP 10), rounded up
                        int pointsUsed = (int)Math.Ceiling(orderTotal / 10m);
                        // Net delta: subtract points spent, then add points earned
                        int pointsDelta = pointsEarned - pointsUsed;
                        UpdateCustomerPoints(pointsDelta);
                        Session["PointsEarned"] = "0"; // no bonus points shown on receipt when paying with points
                    }
                    else
                    {
                        UpdateCustomerPoints(pointsEarned);
                        Session["PointsEarned"] = pointsEarned.ToString();
                    }

                    Session["OrderID"] = orderID.ToString();
                    Session["OrderName"] = name;
                    Session["OrderAddress"] = barangay + ", " + street;
                    Session["OrderContact"] = contact;
                    Session["OrderDelivery"] = hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in";
                    Session["OrderPickupTime"] = hdnPickupTime.Value;
                    Session["OrderIsRoyalty"] = hdnIsRoyalty.Value;
                    Session["OrderTotal"] = orderTotal.ToString("0.00");
                    Session["OrderSubtotal"] = subtotal.ToString("0.00");
                    Session["OrderDiscount"] = discount.ToString("0.00");
                    Session["OrderDeliveryFee"] = deliveryFee.ToString("0.00");
                    Session["PaymentMethod"] = hdnPaymentMethod.Value;
                    Session["AmountPaid"] = amountPaid.ToString("0.00");
                    Session["Change"] = change.ToString("0.00");

                    if (!string.IsNullOrEmpty(txtRoyaltyNo.Text.Trim()))
                        Session["RoyaltyNo"] = txtRoyaltyNo.Text.Trim();

                    Session["ReceiptCart"] = Session["Cart"];
                    Session["Cart"] = new List<CartItem>();

                    Response.Redirect("~/Receipt.aspx");
                }
                else
                {
                    lblErrorMsg.Text = "Failed to save order. Please try again.";
                    lblErrorMsg.Visible = true;
                }
            }
            catch (Exception ex)
            {
                lblErrorMsg.Text = "Error processing order: " + ex.Message;
                if (ex.InnerException != null)
                    lblErrorMsg.Text += "<br/>Inner Error: " + ex.InnerException.Message;
                lblErrorMsg.Text += "<br/>Stack Trace: " + ex.StackTrace;
                lblErrorMsg.Visible = true;
            }
        }

        private int SaveOrderToDatabase(string customerName, string barangay, string street, string contact,
            decimal totalAmount, decimal subtotal, decimal discount, decimal deliveryFee,
            decimal amountPaid, decimal change, string paymentReference)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int customerID = GetOrCreateCustomerID(conn, customerName, barangay + ", " + street, contact);

                    // Phase 2.5: All orders start as "Pending", but PaymentVerified flag differs
                    string orderStatus = "Pending";
                    bool paymentVerified = hdnPaymentMethod.Value == "Points"; // Points = auto-verified

                    string orderQuery = @"
                        INSERT INTO Orders (CustomerID, OrderDate, DeliveryType, TotalAmount, Discount, 
                                          AmountPaid, ChangeAmount, PaymentMethod, OrderStatus, PickupTime, TotalQuantity, Barangay, Street, PaymentReference, PaymentVerified)
                        VALUES (@CustomerID, @OrderDate, @DeliveryType, @TotalAmount, @Discount, 
                                @AmountPaid, @ChangeAmount, @PaymentMethod, @OrderStatus, @PickupTime, @TotalQuantity, @Barangay, @Street, @PaymentReference, @PaymentVerified);
                        SELECT SCOPE_IDENTITY();";

                    int orderID = 0;
                    using (SqlCommand cmd = new SqlCommand(orderQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerID);
                        cmd.Parameters.AddWithValue("@OrderDate", DateTime.Now);
                        cmd.Parameters.AddWithValue("@DeliveryType", hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in");
                        cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                        cmd.Parameters.AddWithValue("@Discount", discount);
                        cmd.Parameters.AddWithValue("@AmountPaid", amountPaid);
                        cmd.Parameters.AddWithValue("@ChangeAmount", change);
                        cmd.Parameters.AddWithValue("@PaymentMethod", hdnPaymentMethod.Value);
                        cmd.Parameters.AddWithValue("@OrderStatus", orderStatus);
                        cmd.Parameters.AddWithValue("@PickupTime",
                            !string.IsNullOrEmpty(hdnPickupTime.Value) ? (object)DateTime.Parse(hdnPickupTime.Value) : DBNull.Value);
                        cmd.Parameters.AddWithValue("@TotalQuantity", Cart.Sum(item => item.Qty));
                        cmd.Parameters.AddWithValue("@Barangay", barangay);
                        cmd.Parameters.AddWithValue("@Street", street);
                        cmd.Parameters.AddWithValue("@PaymentReference", 
                            !string.IsNullOrEmpty(paymentReference) ? (object)paymentReference : DBNull.Value);
                        cmd.Parameters.AddWithValue("@PaymentVerified", paymentVerified);

                        orderID = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    foreach (var item in Cart)
                    {
                        int productID = GetProductID(conn, item.Product);
                        int? sizeID = GetSizeID(conn, productID, item.Size);
                        int? flavorID = GetFlavorID(conn, productID, item.Flavor);

                        string itemQuery = @"
                            INSERT INTO OrderItems (OrderID, ProductID, SizeID, FlavorID, Quantity, UnitPrice, TotalPrice)
                            VALUES (@OrderID, @ProductID, @SizeID, @FlavorID, @Quantity, @UnitPrice, @TotalPrice)";

                        using (SqlCommand cmd = new SqlCommand(itemQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", orderID);
                            cmd.Parameters.AddWithValue("@ProductID", productID);
                            cmd.Parameters.AddWithValue("@SizeID", sizeID.HasValue ? (object)sizeID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@FlavorID", flavorID.HasValue ? (object)flavorID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@Quantity", item.Qty);
                            cmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                            cmd.Parameters.AddWithValue("@TotalPrice", item.LineTotal);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    return orderID;
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Database error: " + ex.Message);
            }
        }

        private int GetOrCreateCustomerID(SqlConnection conn, string name, string address, string contact)
        {
            if (Session["CustomerID"] != null)
                return Convert.ToInt32(Session["CustomerID"]);

            string checkQuery = "SELECT CustomerID FROM USERS WHERE PhoneNumber = @Phone";
            using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
            {
                cmd.Parameters.AddWithValue("@Phone", contact);
                object result = cmd.ExecuteScalar();
                if (result != null) return Convert.ToInt32(result);
            }

            string insertQuery = @"
                INSERT INTO USERS (UserName, Fullname, [Address], Email, PhoneNumber, [Password], Points, MembershipLevel)
                VALUES (@UserName, @Fullname, @Address, @Email, @Phone, @Password, 0, 'Guest');
                SELECT SCOPE_IDENTITY();";

            using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
            {
                cmd.Parameters.AddWithValue("@UserName", "guest_" + contact);
                cmd.Parameters.AddWithValue("@Fullname", name);
                cmd.Parameters.AddWithValue("@Address", address);
                cmd.Parameters.AddWithValue("@Email", "guest@email.com");
                cmd.Parameters.AddWithValue("@Phone", contact);
                cmd.Parameters.AddWithValue("@Password", "guest123");
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private int GetProductID(SqlConnection conn, string productName)
        {
            string query = "SELECT ProductID FROM Products WHERE ProductName = @ProductName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductName", productName);
                object result = cmd.ExecuteScalar();
                if (result != null) return Convert.ToInt32(result);
                else throw new Exception($"Product '{productName}' not found in database.");
            }
        }

        private int? GetSizeID(SqlConnection conn, int productID, string sizeName)
        {
            string query = "SELECT SizeID FROM ProductSizes WHERE ProductID = @ProductID AND SizeName = @SizeName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductID", productID);
                cmd.Parameters.AddWithValue("@SizeName", sizeName);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : (int?)null;
            }
        }

        private int? GetFlavorID(SqlConnection conn, int productID, string flavorName)
        {
            string query = "SELECT FlavorID FROM ProductFlavors WHERE ProductID = @ProductID AND FlavorName = @FlavorName";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProductID", productID);
                cmd.Parameters.AddWithValue("@FlavorName", flavorName);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : (int?)null;
            }
        }

        // ✅ UPDATED — handles both earning (positive delta) and spending (negative delta) points
        private void UpdateCustomerPoints(int pointsDelta)
        {
            if (Session["CustomerID"] == null) return;
            if (pointsDelta == 0) return;

            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Prevent points from going below 0 in the database
                    string updateQuery = @"
                        UPDATE USERS 
                        SET Points = CASE 
                            WHEN Points + @Delta < 0 THEN 0 
                            ELSE Points + @Delta 
                        END
                        WHERE CustomerID = @CustomerID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Delta", pointsDelta);
                        cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(Session["CustomerID"]));
                        cmd.ExecuteNonQuery();
                    }

                    // Sync session to reflect updated balance
                    if (Session["Points"] != null)
                    {
                        int currentPoints = Convert.ToInt32(Session["Points"]);
                        int newPoints = currentPoints + pointsDelta;
                        Session["Points"] = Math.Max(0, newPoints).ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error updating points: " + ex.Message);
            }
        }

        private void DeductStockForOrder()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    foreach (var item in Cart)
                    {
                        int productID = GetProductID(conn, item.Product);
                        int? sizeID = GetSizeID(conn, productID, item.Size);
                        int? flavorID = GetFlavorID(conn, productID, item.Flavor);

                        // Deduct size stock (1:1 ratio - 1 order = 1 stock unit)
                        if (sizeID.HasValue)
                        {
                            string sizeStockQuery = @"
                                UPDATE ProductSizeStock 
                                SET StockQuantity = StockQuantity - @Quantity,
                                    LastUpdated = GETDATE()
                                WHERE ProductID = @ProductID AND SizeID = @SizeID";

                            using (SqlCommand cmd = new SqlCommand(sizeStockQuery, conn))
                            {
                                cmd.Parameters.AddWithValue("@ProductID", productID);
                                cmd.Parameters.AddWithValue("@SizeID", sizeID.Value);
                                cmd.Parameters.AddWithValue("@Quantity", item.Qty);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Deduct flavor stock (1:10 ratio - 1 flavor unit serves 10 orders)
                        if (flavorID.HasValue)
                        {
                            int flavorUnitsNeeded = (int)Math.Ceiling(item.Qty / 10.0);

                            string flavorStockQuery = @"
                                UPDATE FlavorStock 
                                SET StockQuantity = StockQuantity - @FlavorUnits,
                                    LastUpdated = GETDATE()
                                WHERE FlavorID = @FlavorID";

                            using (SqlCommand cmd = new SqlCommand(flavorStockQuery, conn))
                            {
                                cmd.Parameters.AddWithValue("@FlavorID", flavorID.Value);
                                cmd.Parameters.AddWithValue("@FlavorUnits", flavorUnitsNeeded);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error deducting stock: " + ex.Message);
            }
        }

        private void BindCart()
        {
            var cart = Cart;

            if (cart.Count == 0)
            {
                cartDisplay.InnerHtml = @"
            <div class='cart-empty' style='text-align:center;color:#aaa;padding:60px 20px;font-size:16px;font-weight:600;'>
                Your cart is empty<br/>
                <small style='font-size:13px;color:#ccc;'>Add items from the menu to get started</small>
            </div>";
            }
            else
            {
                var html = new StringBuilder();

                for (int i = 0; i < cart.Count; i++)
                {
                    var item = cart[i];
                    html.AppendFormat(@"
                <div class='cart-item'>
                    <div class='cart-item-header'>
                        <span>{0} ({1})</span>
                        <button type='button' class='btn-remove' onclick='removeCartItem({2})'>Remove</button>
                    </div>
                    <div class='cart-item-details'>
                        <strong>Flavor:</strong> {3}<br/>
                        <strong>Qty:</strong> {4} &times; PHP {5:0.00} = <strong>PHP {6:0.00}</strong>
                    </div>
                </div>",
                        item.Product, item.Size, i, item.Flavor, item.Qty, item.UnitPrice, item.LineTotal);
                }

                decimal subtotal = cart.Sum(item => item.LineTotal);
                bool isRoyalty = hdnIsRoyalty.Value == "true";
                bool isDelivery = hdnDeliveryType.Value == "Delivery";
                decimal discount = isRoyalty ? subtotal * ROYALTY_DISCOUNT_RATE : 0;
                decimal delivery = isDelivery ? DELIVERY_FEE : 0;
                decimal total = subtotal - discount + delivery;

                html.AppendFormat(@"
            <div class='cart-totals'>
                <div class='total-row'><span>Subtotal:</span><span>PHP {0:0.00}</span></div>
                <div class='total-row'><span>Discount:</span><span>PHP {1:0.00}</span></div>
                <div class='total-row'><span>Delivery Fee:</span><span>PHP {2:0.00}</span></div>
                <div class='total-row grand'><span>Total:</span><span>PHP {3:0.00}</span></div>
            </div>", subtotal, discount, delivery, total);

                cartDisplay.InnerHtml = html.ToString();
                lblSubtotal.Text = subtotal.ToString("0.00");
                lblDiscount.Text = discount.ToString("0.00");
                lblDeliveryFee.Text = delivery.ToString("0.00");
                lblTotal.Text = total.ToString("0.00");
            }

            ViewState["CartCount"] = cart.Count;
        }

        private void UpdateCartTotals()
        {
            BindCart();
        }
    }
}