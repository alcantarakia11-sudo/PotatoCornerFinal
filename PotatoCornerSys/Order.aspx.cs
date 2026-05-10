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

            public List<string> GetFlavors()
            {
                return Flavor.Split(new[] { " + " }, StringSplitOptions.None).ToList();
            }
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
            // No redirect — let the page load so the login modal can show client-side

            if (!IsPostBack)
            {
                if (Session["CustomerID"] != null)
                {
                    if (Session["Name"] != null)
                        txtName.Text = Session["Name"].ToString();
                    else if (Session["Fullname"] != null)
                        txtName.Text = Session["Fullname"].ToString();
                    else if (Session["Username"] != null)
                        txtName.Text = Session["Username"].ToString();
                }
            }

            if (Request.Form["__EVENTTARGET"] == "RemoveCartItem")
            {
                if (Session["CustomerID"] == null) return;
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

                // Default to Walk-in
                hdnDeliveryType.Value = "WalkIn";
                btnWalkIn.CssClass = "option-btn selected";
                btnDelivery.CssClass = "option-btn";

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

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Profile.aspx");
        }

        protected void btnValidate_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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
                lblRoyaltyMsg.Text = "Invalid royalty number format. Should be 2 letters + 5 numbers (e.g., PC12345).";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            bool isLoggedIn = Session["CustomerID"] != null;
            bool hasRoyalty = Session["HasRoyaltyMembership"] != null && (bool)Session["HasRoyaltyMembership"];
            string storedRoyaltyNo = Session["RoyaltyNumber"]?.ToString();

            if (!isLoggedIn)
            {
                lblRoyaltyMsg.Text = "You need to be a Royalty member to validate a card. Please log in or sign up.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            if (!hasRoyalty)
            {
                lblRoyaltyMsg.Text = "You are not a Royalty member yet. Upgrade your membership to enjoy exclusive discounts!";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            if (!string.IsNullOrEmpty(storedRoyaltyNo) &&
                !royaltyNo.Equals(storedRoyaltyNo, StringComparison.OrdinalIgnoreCase))
            {
                lblRoyaltyMsg.Text = "Card number doesn't match your registered Royalty card. Please use your own card.";
                lblRoyaltyMsg.CssClass = "status-msg status-error";
                lblRoyaltyMsg.Visible = true;
                hdnIsRoyalty.Value = "false";
                return;
            }

            string storedFullName = Session["Fullname"]?.ToString();
            if (!string.IsNullOrEmpty(storedFullName))
            {
                Func<string, string> normalize = s =>
                    System.Text.RegularExpressions.Regex.Replace(s.Trim().ToLower(), @"\s+", " ");

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
                        lblRoyaltyMsg.Text = "Customer name doesn't match the Royalty card holder.";
                        lblRoyaltyMsg.CssClass = "status-msg status-error";
                        lblRoyaltyMsg.Visible = true;
                        hdnIsRoyalty.Value = "false";
                        return;
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
                        SELECT u.CustomerID
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
                                lblRoyaltyMsg.Text = "Royalty card validated! 10% discount applied.";
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
                    lblRoyaltyMsg.Text = "Royalty card validated! 10% discount applied.";
                    lblRoyaltyMsg.CssClass = "status-msg status-success";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "true";
                    UpdateCartTotals();
                }
                else
                {
                    lblRoyaltyMsg.Text = "Validation error. Please try again.";
                    lblRoyaltyMsg.CssClass = "status-msg status-error";
                    lblRoyaltyMsg.Visible = true;
                    hdnIsRoyalty.Value = "false";
                }
            }
        }

        protected void btnChickenMinus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnChickenQty.Value);
            if (qty > 1) qty--;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update();
        }

        protected void btnChickenPlus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnChickenQty.Value);
            qty++;
            hdnChickenQty.Value = qty.ToString();
            lblChickenQty.Text = qty.ToString();
            upChickenQty.Update();
        }

        protected void btnLoopysMinus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnLoopysQty.Value);
            if (qty > 1) qty--;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update();
        }

        protected void btnLoopysPlus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnLoopysQty.Value);
            qty++;
            hdnLoopysQty.Value = qty.ToString();
            lblLoopysQty.Text = qty.ToString();
            upLoopysQty.Update();
        }

        protected void btnFriesMinus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnFriesQty.Value);
            if (qty > 1) qty--;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update();
        }

        protected void btnFriesPlus_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;
            int qty = int.Parse(hdnFriesQty.Value);
            qty++;
            hdnFriesQty.Value = qty.ToString();
            lblFriesQty.Text = qty.ToString();
            upFriesQty.Update();
        }

        protected void btnAddFries_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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

            List<string> selectedFlavors = new List<string>();
            if (cbFriesSourCream.Checked) selectedFlavors.Add("Sour Cream");
            if (cbFriesBBQ.Checked) selectedFlavors.Add("BBQ");
            if (cbFriesCheese.Checked) selectedFlavors.Add("Cheese");
            if (cbFriesSalt.Checked) selectedFlavors.Add("Salt");

            if (selectedFlavors.Count == 0)
            {
                lblErrorMsg.Text = "Please select at least one flavor for French Fries.";
                lblErrorMsg.Visible = true;
                return;
            }

            bool isMegaOrAbove = rbFriesMega.Checked || rbFriesGiga.Checked || rbFriesTerra.Checked;
            if (!isMegaOrAbove && selectedFlavors.Count > 1)
            {
                lblErrorMsg.Text = "Only Mega size and above can have 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (selectedFlavors.Count > 2)
            {
                lblErrorMsg.Text = "You can select a maximum of 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = string.Join(" + ", selectedFlavors);
            int qty = int.Parse(hdnFriesQty.Value);
            Cart.Add(new CartItem { Product = "French Fries", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            lblErrorMsg.Text = $"Added: {qty}x French Fries ({size}, {flavor}) - PHP {price}";
            lblErrorMsg.CssClass = "status-msg status-success";
            lblErrorMsg.Visible = true;

            rbFriesRegular.Checked = rbFriesLarge.Checked = rbFriesJumbo.Checked = false;
            rbFriesMega.Checked = rbFriesGiga.Checked = rbFriesTerra.Checked = false;
            cbFriesSourCream.Checked = cbFriesBBQ.Checked = cbFriesCheese.Checked = false;
            cbFriesSalt.Checked = false;
            hdnFriesQty.Value = "1";
            lblFriesQty.Text = "1";

            BindCart();
        }

        protected void btnAddChicken_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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

            List<string> selectedFlavors = new List<string>();
            if (cbChickenSourCream.Checked) selectedFlavors.Add("Sour Cream");
            if (cbChickenBBQ.Checked) selectedFlavors.Add("BBQ");
            if (cbChickenCheese.Checked) selectedFlavors.Add("Cheese");
            if (cbChickenSalt.Checked) selectedFlavors.Add("Salt");

            if (selectedFlavors.Count == 0)
            {
                lblErrorMsg.Text = "Please select at least one flavor for Chicken Pops.";
                lblErrorMsg.Visible = true;
                return;
            }

            bool isMega = rbChickenMega.Checked;
            if (!isMega && selectedFlavors.Count > 1)
            {
                lblErrorMsg.Text = "Only Mega Mix size can have 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (selectedFlavors.Count > 2)
            {
                lblErrorMsg.Text = "You can select a maximum of 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = string.Join(" + ", selectedFlavors);
            int qty = int.Parse(hdnChickenQty.Value);
            Cart.Add(new CartItem { Product = "Chicken Pops", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            rbChickenSolo.Checked = rbChickenLarge.Checked = rbChickenMega.Checked = false;
            cbChickenSourCream.Checked = cbChickenBBQ.Checked = cbChickenCheese.Checked = false;
            cbChickenSalt.Checked = false;
            hdnChickenQty.Value = "1";
            lblChickenQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void btnAddLoopys_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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

            List<string> selectedFlavors = new List<string>();
            if (cbLoopysSourCream.Checked) selectedFlavors.Add("Sour Cream");
            if (cbLoopysBBQ.Checked) selectedFlavors.Add("BBQ");
            if (cbLoopysCheese.Checked) selectedFlavors.Add("Cheese");
            if (cbLoopysSalt.Checked) selectedFlavors.Add("Salt");

            if (selectedFlavors.Count == 0)
            {
                lblErrorMsg.Text = "Please select at least one flavor for Loopys.";
                lblErrorMsg.Visible = true;
                return;
            }

            bool isMega = rbLoopysMega.Checked;
            if (!isMega && selectedFlavors.Count > 1)
            {
                lblErrorMsg.Text = "Only Mega size can have 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            if (selectedFlavors.Count > 2)
            {
                lblErrorMsg.Text = "You can select a maximum of 2 flavors.";
                lblErrorMsg.Visible = true;
                return;
            }

            string flavor = string.Join(" + ", selectedFlavors);
            int qty = int.Parse(hdnLoopysQty.Value);
            Cart.Add(new CartItem { Product = "Loopys", Size = size, Flavor = flavor, Qty = qty, UnitPrice = price });

            rbLoopysLarge.Checked = rbLoopysMega.Checked = false;
            cbLoopysSourCream.Checked = cbLoopysBBQ.Checked = cbLoopysCheese.Checked = false;
            cbLoopysSalt.Checked = false;
            hdnLoopysQty.Value = "1";
            lblLoopysQty.Text = "1";
            lblErrorMsg.Visible = false;

            BindCart();
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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
            if (Session["CustomerID"] == null) return;

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
            if (Session["CustomerID"] == null) return;

            hdnDeliveryType.Value = "Delivery";
            btnWalkIn.CssClass = "option-btn";
            btnDelivery.CssClass = "option-btn selected";

            hdnPickupTime.Value = "";
            lblPickupTime.Visible = false;

            UpdateCartTotals();

            ScriptManager.RegisterStartupScript(this, GetType(), "showDeliveryFields",
                "setDeliveryFields('Delivery');", true);
        }

        protected void btnPayment_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

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

                decimal pointsValue = userPoints * 10m;

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
            if (Session["CustomerID"] == null) return;

            string selectedSlot = hdnSelectedPickupSlot.Value;

            if (!string.IsNullOrEmpty(selectedSlot))
            {
                hdnPickupTime.Value = selectedSlot;
                hdnDeliveryType.Value = "WalkIn";
                btnWalkIn.CssClass = "option-btn selected";
                btnDelivery.CssClass = "option-btn";

                DateTime selectedTime = DateTime.Parse(selectedSlot);
                lblPickupTime.Text = "Pickup Time: " + selectedTime.ToString("MMM dd, yyyy h:mm tt");
                lblPickupTime.Visible = true;

                UpdateCartTotals();
                ScriptManager.RegisterStartupScript(this, GetType(), "hideModal",
                    "hidePickupTimeModal(); setDeliveryFields('WalkIn');", true);
            }
        }

        protected void btnSubmitPaymentModal_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

            string enteredReference = txtPaymentReferenceModal.Text.Trim().ToUpper();

            if (string.IsNullOrEmpty(enteredReference) ||
                !enteredReference.StartsWith("REF-") ||
                enteredReference.Length < 15)
            {
                lblErrorMsg.Text = "Invalid reference number format.";
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "showModal",
                    $"showQRCodeModal('{hdnPaymentMethod.Value}', '{lblTotal.Text}');", true);
                return;
            }

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
                            lblErrorMsg.Text = "This reference number has already been used. Please check your payment app for the correct reference.";
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
                System.Diagnostics.Debug.WriteLine("Duplicate check error: " + ex.Message);
            }

            ProcessOrder(enteredReference);

            if (lblErrorMsg.Visible)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "scrollToError",
                    "document.getElementById('" + lblErrorMsg.ClientID + "').scrollIntoView({behavior:'smooth', block:'center'});", true);
            }
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null) return;

            if (hdnPaymentMethod.Value == "Points")
                ProcessOrder(null);
        }

        private void ProcessOrder(string paymentReference)
        {
            string name = txtName.Text.Trim();
            string contact = txtContact.Text.Trim();
            bool isDelivery = hdnDeliveryType.Value == "Delivery";

            Action<string> fail = (msg) => {
                lblErrorMsg.Text = msg;
                lblErrorMsg.CssClass = "status-msg status-error";
                lblErrorMsg.Visible = true;
                ScriptManager.RegisterStartupScript(this, GetType(), "processOrderErr",
                    $"showAlertModal('❌', 'Order Error', {System.Web.HttpUtility.JavaScriptStringEncode(msg, true)});", true);
            };

            if (string.IsNullOrEmpty(name) || string.IsNullOrEmpty(contact))
            { fail("Please fill in all customer information."); return; }

            if (name.Any(char.IsDigit))
            { fail("Full name cannot contain numbers."); return; }

            if (!contact.All(char.IsDigit))
            { fail("Phone number can only contain numbers."); return; }

            string barangay = "Walk-in";
            string street = "Walk-in";
            string locationType = "Both";

            if (isDelivery)
            {
                if (string.IsNullOrEmpty(ddlLocation.SelectedValue) ||
                    string.IsNullOrEmpty(txtStreet.Text.Trim()))
                { fail("Please fill in location and street address for delivery orders."); return; }

                string[] locationParts = ddlLocation.SelectedValue.Split('|');
                barangay = locationParts[0];
                locationType = locationParts[1];
                street = txtStreet.Text.Trim();

                if (!street.All(c => char.IsLetterOrDigit(c) || c == ' ' || c == ',' || c == '.' || c == '-' || c == '#' || c == '/'))
                { fail("Street address contains invalid characters."); return; }

                if (locationType == "Delivery" && !isDelivery)
                { fail("This location is only available for delivery orders."); return; }
            }

            if (!isDelivery && string.IsNullOrEmpty(hdnPickupTime.Value))
            { fail("Please select a pickup time. Click Walk-in again to choose a time."); return; }

            if (Cart.Count == 0)
            { fail("Your cart is empty. Please add at least one item."); return; }

            if (string.IsNullOrEmpty(hdnPaymentMethod.Value))
            { fail("Please select a payment method."); return; }

            decimal orderTotal = decimal.Parse(lblTotal.Text);
            decimal subtotal = decimal.Parse(lblSubtotal.Text);
            decimal discount = decimal.Parse(lblDiscount.Text);
            decimal deliveryFee = decimal.Parse(lblDeliveryFee.Text);
            decimal amountPaid = orderTotal;
            decimal change = 0;

            if (hdnPaymentMethod.Value == "Points")
            {
                int userPoints = 0;
                if (Session["Points"] != null)
                    int.TryParse(Session["Points"].ToString(), out userPoints);

                decimal pointsValue = userPoints * 10m;

                if (pointsValue < orderTotal)
                {
                    fail($"Insufficient points. You have {userPoints} pts (PHP {pointsValue:0.00}) but total is PHP {orderTotal:0.00}.");
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
                    DeductStockForOrder();

                    int pointsEarned = (int)(orderTotal / 500) * 2;

                    if (hdnPaymentMethod.Value == "Points")
                    {
                        int pointsUsed = (int)Math.Ceiling(orderTotal / 10m);
                        int pointsDelta = pointsEarned - pointsUsed;
                        UpdateCustomerPoints(pointsDelta);
                        Session["PointsEarned"] = "0";
                    }
                    else
                    {
                        UpdateCustomerPoints(pointsEarned);
                        Session["PointsEarned"] = pointsEarned.ToString();
                    }

                    Session["OrderID"] = orderID.ToString();
                    Session["OrderName"] = name;
                    Session["OrderAddress"] = isDelivery ? barangay + ", " + street : "";
                    Session["OrderContact"] = contact;
                    Session["OrderDelivery"] = isDelivery ? "Delivery" : "Walk-in";
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
                    fail("Failed to save order. Please try again.");
                }
            }
            catch (Exception ex)
            {
                string errMsg = "Error processing order: " + ex.Message;
                if (ex.InnerException != null)
                    errMsg += " | Inner: " + ex.InnerException.Message;
                fail(errMsg);
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

                    bool paymentVerified = hdnPaymentMethod.Value == "Points";

                    string orderQuery = @"
                INSERT INTO Orders (CustomerID, OrderDate, DeliveryType, TotalAmount, Discount,
                                   AmountPaid, ChangeAmount, PaymentMethod, OrderStatus, PickupTime,
                                   TotalQuantity, Barangay, Street, PaymentReference, PaymentVerified)
                VALUES (@CustomerID, @OrderDate, @DeliveryType, @TotalAmount, @Discount,
                        @AmountPaid, @ChangeAmount, @PaymentMethod, @OrderStatus, @PickupTime,
                        @TotalQuantity, @Barangay, @Street, @PaymentReference, @PaymentVerified);
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
                        cmd.Parameters.AddWithValue("@OrderStatus", "Pending");
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
                        List<string> flavors = item.GetFlavors();

                        string itemQuery = @"
                    INSERT INTO OrderItems (OrderID, ProductID, SizeID, FlavorID, Quantity, UnitPrice, TotalPrice)
                    VALUES (@OrderID, @ProductID, @SizeID, @FlavorID, @Quantity, @UnitPrice, @TotalPrice)";

                        using (SqlCommand cmd = new SqlCommand(itemQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@OrderID", orderID);
                            cmd.Parameters.AddWithValue("@ProductID", productID);
                            cmd.Parameters.AddWithValue("@SizeID", sizeID.HasValue ? (object)sizeID.Value : DBNull.Value);

                            int? flavorID = GetFlavorID(conn, productID, flavors[0]);
                            cmd.Parameters.AddWithValue("@FlavorID", flavorID.HasValue ? (object)flavorID.Value : DBNull.Value);
                            cmd.Parameters.AddWithValue("@Quantity", item.Qty);
                            cmd.Parameters.AddWithValue("@UnitPrice", item.UnitPrice);
                            cmd.Parameters.AddWithValue("@TotalPrice", item.LineTotal);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    string customerNameForLog = Session["Username"]?.ToString() ?? customerName;
                    string orderSummary = $"Order #{orderID} placed by {customerNameForLog} - " +
                                         $"{Cart.Count} item(s), Total: PHP {totalAmount:0.00}, " +
                                         $"Payment: {hdnPaymentMethod.Value}, Delivery: {(hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in")}";

                    ActivityLogHelper.LogActivity(
                        activityType: "Order Placed",
                        description: orderSummary,
                        performedBy: customerNameForLog,
                        targetEntity: $"Order #{orderID}",
                        severity: "Info"
                    );

                    ActivityLogHelper.LogActivity(
                        "Order Placed",
                        "Order #" + orderID + " placed via " + (hdnDeliveryType.Value == "Delivery" ? "Delivery" : "Walk-in"),
                        Session["UserName"]?.ToString() ?? "Walk-in",
                        "Order #" + orderID,
                        "Info"
                    );

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
                    string updateQuery = @"
                        UPDATE USERS 
                        SET Points = CASE WHEN Points + @Delta < 0 THEN 0 ELSE Points + @Delta END
                        WHERE CustomerID = @CustomerID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Delta", pointsDelta);
                        cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(Session["CustomerID"]));
                        cmd.ExecuteNonQuery();
                    }

                    if (Session["Points"] != null)
                    {
                        int currentPoints = Convert.ToInt32(Session["Points"]);
                        Session["Points"] = Math.Max(0, currentPoints + pointsDelta).ToString();
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
                        List<string> flavors = item.GetFlavors();

                        if (sizeID.HasValue)
                        {
                            string sizeStockQuery = @"
                                UPDATE ProductSizeStock 
                                SET StockQuantity = StockQuantity - @Quantity, LastUpdated = GETDATE()
                                WHERE ProductID = @ProductID AND SizeID = @SizeID";

                            using (SqlCommand cmd = new SqlCommand(sizeStockQuery, conn))
                            {
                                cmd.Parameters.AddWithValue("@ProductID", productID);
                                cmd.Parameters.AddWithValue("@SizeID", sizeID.Value);
                                cmd.Parameters.AddWithValue("@Quantity", item.Qty);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        foreach (string flavorName in flavors)
                        {
                            int? flavorID = GetFlavorID(conn, productID, flavorName);
                            if (flavorID.HasValue)
                            {
                                int flavorUnitsNeeded = (int)Math.Ceiling(item.Qty / 10.0);
                                string flavorStockQuery = @"
                                    UPDATE FlavorStock 
                                    SET StockQuantity = StockQuantity - @FlavorUnits, LastUpdated = GETDATE()
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