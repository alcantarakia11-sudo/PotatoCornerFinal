<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Order.aspx.cs" Inherits="PotatoCornerSys.Order" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, sans-serif; background: linear-gradient(135deg, #f0f4f8 0%, #e8eef3 100%); overflow: hidden; }
        
        .navbar { 
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%); 
            padding: 15px 50px; 
            display: flex; 
            align-items: center;
            justify-content: space-between; 
            border-bottom: 5px solid #f5c800;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        .navbar-logo img { height: 85px; filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2)); transition: transform 0.3s; }
        .navbar-logo img:hover { transform: scale(1.05); }
        .navbar-links { display: flex; align-items: center; gap: 40px; list-style: none; }
        .navbar-links a { color: white; text-decoration: none; font-size: 16px; font-weight: 700; letter-spacing: 0.5px; transition: all 0.3s; position: relative; }
        .navbar-links a:hover { color: #f5c800; transform: translateY(-2px); }
        .navbar-links a::after { content: ''; position: absolute; bottom: -5px; left: 0; width: 0; height: 3px; background: #f5c800; transition: width 0.3s; }
        .navbar-links a:hover::after { width: 100%; }

        .navbar-links .btn-order-nav {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 12px 28px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 15px;
            text-transform: uppercase;
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
            transition: all 0.3s;
        }

        .navbar-links .btn-order-nav::after {
            display: none;
        }

        .navbar-links .btn-order-nav:hover {
           background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
           color: white;
           transform: translateY(-3px);
           box-shadow: 0 6px 16px rgba(232,64,28,0.4);
        }
        
        .pos-container { display: grid; grid-template-columns: 300px 1fr 380px; gap: 20px; padding: 20px; height: calc(100vh - 110px); overflow: hidden; }
        
        .left-panel { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); overflow-y: auto; border: 1px solid rgba(17,146,71,0.1); }
        .panel-title { font-size: 17px; font-weight: 900; color: #119247; text-transform: uppercase; margin-bottom: 18px; border-bottom: 4px solid #f5c800; padding-bottom: 10px; letter-spacing: 0.5px; }
        .input-group { margin-bottom: 16px; }
        .input-group label { display: block; font-size: 13px; font-weight: 700; color: #555; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.3px; }
        .input-group input, .input-group select { width: 100%; padding: 12px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px; transition: all 0.3s; }
        .input-group input:focus, .input-group select:focus { border-color: #119247; outline: none; box-shadow: 0 0 0 3px rgba(17,146,71,0.1); }
        .input-group input.readonly-field { background: #f5f5f5; color: #666; cursor: not-allowed; }

        /* VALIDATION STYLES */
        .field-error { display: block; color: #dc3545; font-size: 11px; font-weight: 600; margin-top: 5px; min-height: 16px; transition: all 0.2s; }
        .input-group input.invalid { border-color: #dc3545 !important; box-shadow: 0 0 0 3px rgba(220,53,69,0.15) !important; }
        .input-group input.valid { border-color: #28a745 !important; box-shadow: 0 0 0 3px rgba(40,167,69,0.15) !important; }

        .royalty-row { display: flex; gap: 10px; align-items: flex-end; }
        .royalty-row input { flex: 1; }
        .btn-validate { background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; border: none; padding: 12px 18px; border-radius: 8px; font-weight: 700; cursor: pointer; font-size: 13px; transition: all 0.3s; box-shadow: 0 2px 8px rgba(17,146,71,0.3); }
        .btn-validate:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(17,146,71,0.4); }
        .btn-validate:active { transform: translateY(0); }
        .status-msg { font-size: 12px; margin-top: 8px; padding: 8px 12px; border-radius: 6px; font-weight: 600; }
        .status-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .status-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
        .status-info { background: #d1ecf1; color: #0c5460; border-left: 4px solid #17a2b8; }
        
        .center-panel { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); overflow-y: auto; border: 1px solid rgba(17,146,71,0.1); }
        .product-grid { display: grid; gap: 24px; }
        .product-card { background: linear-gradient(135deg, #fffbf0 0%, #ffffff 100%); border: 3px solid #f5c800; border-radius: 16px; padding: 24px; box-shadow: 0 6px 20px rgba(0,0,0,0.08); transition: all 0.3s; }
        .product-card:hover { transform: translateY(-4px); box-shadow: 0 10px 30px rgba(0,0,0,0.12); }
        .product-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 12px; border-bottom: 2px solid #f5c800; }
        .product-name { font-size: 22px; font-weight: 900; color: #119247; letter-spacing: 0.5px; text-transform: uppercase; }
        .product-body { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .sizes-section, .flavors-section { display: block; }
        .section-label { font-size: 13px; font-weight: 800; color: #119247; margin-bottom: 12px; text-transform: uppercase; letter-spacing: 0.5px; }
        .size-option, .flavor-option { display: flex; align-items: center; gap: 10px; padding: 10px 14px; background: white; border: 2px solid #e0e0e0; border-radius: 10px; margin-bottom: 10px; cursor: pointer; transition: all 0.3s; }
        .size-option:hover, .flavor-option:hover { border-color: #119247; background: #e8f5ee; transform: translateX(4px); }
        .size-option input, .flavor-option input { display: none; }
        .size-option input:checked ~ label, .flavor-option input:checked ~ label { color: #119247; font-weight: 800; }
        .size-option:has(input:checked), .flavor-option:has(input:checked) { border-color: #119247; background: #e8f5ee; box-shadow: 0 2px 8px rgba(17,146,71,0.2); }
        .size-option label, .flavor-option label { cursor: pointer; flex: 1; font-size: 14px; font-weight: 600; }
        .qty-section { margin-top: 20px; display: flex; align-items: center; gap: 14px; padding: 12px; background: #f8f9fa; border-radius: 10px; }
        .qty-label { font-size: 14px; font-weight: 800; color: #119247; text-transform: uppercase; }
        .qty-controls { display: flex; align-items: center; gap: 12px; }
        .qty-btn { background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; border: none; width: 36px; height: 36px; border-radius: 8px; font-size: 20px; font-weight: 700; cursor: pointer; transition: all 0.3s; box-shadow: 0 2px 6px rgba(17,146,71,0.3); }
        .qty-btn:hover { transform: scale(1.1); box-shadow: 0 4px 10px rgba(17,146,71,0.4); }
        .qty-btn:active { transform: scale(0.95); }
        .qty-display { font-size: 20px; font-weight: 900; min-width: 35px; text-align: center; color: #119247; }
        .btn-add { width: 100%; background: linear-gradient(135deg, #e8401c 0%, #c73516 100%); color: white; border: none; padding: 14px; border-radius: 10px; font-size: 15px; font-weight: 800; cursor: pointer; margin-top: 20px; text-transform: uppercase; transition: all 0.3s; box-shadow: 0 4px 12px rgba(232,64,28,0.3); letter-spacing: 0.5px; }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 6px 16px rgba(232,64,28,0.4); }
        .btn-add:active { transform: translateY(0); }
        
        .right-panel { background: white; border-radius: 16px; padding: 24px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); overflow-y: auto; display: flex; flex-direction: column; border: 1px solid rgba(17,146,71,0.1); }
        .cart-section { flex: 1; overflow-y: auto; margin-bottom: 18px; min-height: 180px; }
        .cart-empty { text-align: center; color: #aaa; padding: 60px 20px; font-size: 16px; font-weight: 600; }
        .cart-item { background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%); padding: 16px; border-radius: 12px; margin-bottom: 12px; font-size: 14px; border: 2px solid #e8f5ee; transition: all 0.3s; }
        .cart-item:hover { border-color: #119247; box-shadow: 0 2px 8px rgba(17,146,71,0.1); }
        .cart-item-header { display: flex; justify-content: space-between; align-items: center; font-weight: 800; color: #119247; margin-bottom: 8px; font-size: 15px; }
        .cart-item-details { color: #555; font-size: 13px; line-height: 1.8; }
        .btn-remove { background: linear-gradient(135deg, #e8401c 0%, #c73516 100%); color: white; border: none; padding: 7px 16px; border-radius: 6px; font-size: 12px; cursor: pointer; font-weight: 700; transition: all 0.3s; white-space: nowrap; }
        .btn-remove:hover { transform: scale(1.05); box-shadow: 0 2px 6px rgba(232,64,28,0.4); }
        .cart-totals { border-top: 3px solid #f5c800; padding: 16px; margin-top: 14px; background: #fffbf0; border-radius: 8px; }
        .total-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 15px; font-weight: 600; }
        .total-row.grand { font-size: 22px; font-weight: 900; color: #119247; margin-top: 12px; padding-top: 12px; border-top: 2px dashed #119247; }
        .delivery-section, .payment-section { margin-top: 18px; }
        .option-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 10px; }
        .option-btn { padding: 12px; border: 2px solid #e0e0e0; border-radius: 10px; text-align: center; font-size: 13px; font-weight: 700; cursor: pointer; background: white; transition: all 0.3s; }
        .option-btn:hover { border-color: #119247; background: #e8f5ee; transform: translateY(-2px); }
        .option-btn.selected { border-color: #119247; background: linear-gradient(135deg, #e8f5ee 0%, #d4edda 100%); color: #119247; box-shadow: 0 2px 8px rgba(17,146,71,0.2); }
        .btn-confirm { width: 100%; background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; border: none; padding: 18px; border-radius: 10px; font-size: 17px; font-weight: 900; cursor: pointer; text-transform: uppercase; margin-top: 18px; transition: all 0.3s; box-shadow: 0 4px 16px rgba(17,146,71,0.3); letter-spacing: 1px; }
        .btn-confirm:hover { transform: translateY(-3px); box-shadow: 0 6px 20px rgba(17,146,71,0.4); }
        .btn-confirm:active { transform: translateY(0); }
        
        /* FILE UPLOAD STYLING */
        .file-upload-input {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .file-upload-input:hover {
            border-color: #119247;
            background: #f8f9fa;
        }
        
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: #f1f1f1; border-radius: 10px; }
        ::-webkit-scrollbar-thumb { background: #119247; border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: #0d7336; }
        
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 9999; justify-content: center; align-items: center; backdrop-filter: blur(4px); }
        .modal-overlay.active { display: flex; }
        .modal-box { background: white; border-radius: 16px; padding: 32px; max-width: 450px; width: 90%; box-shadow: 0 10px 40px rgba(0,0,0,0.3); animation: modalSlideIn 0.3s ease-out; }
        @keyframes modalSlideIn { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        
        /* ALERT MODAL */
        .alert-modal-box { background: white; border-radius: 20px; padding: 36px 32px; max-width: 420px; width: 90%; box-shadow: 0 20px 60px rgba(0,0,0,0.25); animation: modalSlideIn 0.3s ease-out; }
        .alert-modal-icon { font-size: 56px; text-align: center; margin-bottom: 16px; }
        .alert-modal-head { font-family: 'Segoe UI', sans-serif; font-size: 24px; font-weight: 900; color: #1a1612; text-align: center; margin-bottom: 12px; letter-spacing: 0.5px; }
        .alert-modal-msg { font-size: 14px; color: #666; text-align: center; margin-bottom: 24px; line-height: 1.6; }
        .alert-modal-btn { width: 100%; padding: 12px; border: none; border-radius: 10px; background: #119247; color: white; font-family: 'Segoe UI', sans-serif; font-size: 14px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; cursor: pointer; transition: all 0.2s; }
        .alert-modal-btn:hover { background: #0d7336; }
        
        .modal-header { font-size: 22px; font-weight: 800; color: #119247; margin-bottom: 12px; text-align: center; }
        .modal-message { font-size: 14px; color: #666; margin-bottom: 24px; text-align: center; line-height: 1.6; }
        .time-slots { max-height: 300px; overflow-y: auto; margin-bottom: 24px; }
        .time-slot-list { list-style: none; }
        .time-slot-list label { display: block; padding: 14px 18px; margin-bottom: 10px; background: #f8f9fa; border: 2px solid #e0e0e0; border-radius: 10px; cursor: pointer; transition: all 0.3s; font-size: 14px; font-weight: 600; }
        .time-slot-list label:hover { border-color: #119247; background: #e8f5ee; }
        .time-slot-list input[type="radio"]:checked + label { border-color: #119247; background: linear-gradient(135deg, #e8f5ee 0%, #d4edda 100%); color: #119247; box-shadow: 0 2px 8px rgba(17,146,71,0.2); }
        .modal-buttons { display: flex; gap: 12px; }
        .modal-btn { flex: 1; padding: 12px 24px; border: none; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer; transition: all 0.3s; text-transform: uppercase; letter-spacing: 0.5px; }
        .modal-btn-cancel { background: #e8e8e8; color: #666; }
        .modal-btn-cancel:hover { background: #d0d0d0; }
        .modal-btn-confirm { background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; }
        .modal-btn-confirm:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(17,146,71,0.4); }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true"></asp:ScriptManager>
        <div class="navbar">
            <div class="navbar-logo">
                <img src="logopotcor.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><a href="Default.aspx">Home</a></li>
                <li><a href="Menu.aspx">Menu</a></li>
                <li><a href="Membership.aspx">Membership</a></li>
                <li><a href="AboutUs.aspx">About Us</a></li>
                <li><a href="Order.aspx" class="btn-order-nav">Order Now</a></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" ForeColor="White" Font-Bold="true" Text="Profile" OnClick="lnkProfile_Click"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="pos-container">
            <!-- LEFT PANEL -->
            <div class="left-panel">
                <div class="panel-title">Customer Info</div>

                <div class="input-group">
                    <label>Name</label>
                    <asp:TextBox ID="txtName" runat="server" placeholder="Your name" ReadOnly="true" CssClass="readonly-field"></asp:TextBox>
                    <span id="errName" class="field-error"></span>
                </div>
                <div class="input-group">
                    <label>Location</label>
                    <asp:DropDownList ID="ddlLocation" runat="server" CssClass="input-group input" onchange="checkLocationAvailability()">
                        <asp:ListItem Value="" Text="-- Select Location --"></asp:ListItem>
                        <asp:ListItem Value="Balisong|Delivery" Text="Balisong (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Talo-ot|Delivery" Text="Talo-ot (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Tulic|Delivery" Text="Tulic (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Talaga|Delivery" Text="Talaga (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Bogo|Delivery" Text="Bogo (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Binlod|Delivery" Text="Binlod (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Bulasa|Delivery" Text="Bulasa (Delivery)"></asp:ListItem>
                        <asp:ListItem Value="Poblacion|Both" Text="Poblacion"></asp:ListItem>
                        <asp:ListItem Value="Lamacan|Both" Text="Lamacan"></asp:ListItem>
                        <asp:ListItem Value="Langtad|Both" Text="Langtad"></asp:ListItem>
                        <asp:ListItem Value="Canbanua|Both" Text="Canbanua"></asp:ListItem>
                    </asp:DropDownList>
                    <span id="errLocation" class="field-error"></span>
                </div>
                <div class="input-group">
                    <label>Street Address</label>
                    <asp:TextBox ID="txtStreet" runat="server" placeholder="Enter street address"></asp:TextBox>
                    <span id="errStreet" class="field-error"></span>
                </div>
                <div class="input-group">
                    <label>Contact</label>
                    <asp:TextBox ID="txtContact" runat="server" placeholder="e.g. 09123456789" MaxLength="11"></asp:TextBox>
                    <span id="errContact" class="field-error"></span>
                </div>

                <div class="panel-title" style="margin-top:20px;">Royalty Member</div>
                <div class="royalty-row">
                    <asp:TextBox ID="txtRoyaltyNo" runat="server" placeholder="Card number"></asp:TextBox>
                    <asp:Button ID="btnValidate" runat="server" Text="Validate" CssClass="btn-validate" OnClick="btnValidate_Click" CausesValidation="false" />
                </div>
                <asp:Label ID="lblRoyaltyMsg" runat="server" CssClass="status-msg" Visible="false"></asp:Label>
                <div style="margin-top:8px; font-size:12px;">
                    <a href="RegisterForm.aspx" style="color:#119247; text-decoration:underline;">Not a member? Register here</a>
                </div>
                <asp:HiddenField ID="hdnIsRoyalty" runat="server" Value="false" />
            </div>

            <!-- CENTER PANEL -->
            <div class="center-panel">
                <div class="panel-title">Menu</div>
                <div class="product-grid">
                    <!-- French Fries -->
                    <div class="product-card">
                        <div class="product-header">
                            <div class="product-name">French Fries</div>
                        </div>
                        <div class="product-body">
                            <div class="sizes-section">
                                <div class="section-label">Size</div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesRegular" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesRegular.ClientID %>">Regular - PHP 39</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesLarge" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesLarge.ClientID %>">Large - PHP 58</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesJumbo" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesJumbo.ClientID %>">Jumbo - PHP 97</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesMega" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesMega.ClientID %>">Mega - PHP 135</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesGiga" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesGiga.ClientID %>">Giga - PHP 198</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbFriesTerra" runat="server" GroupName="FriesSize" /><label for="<%= rbFriesTerra.ClientID %>">Terra - PHP 228</label></div>
                            </div>
                            <div class="flavors-section">
                                <div class="section-label">Flavor <span id="friesFlavorNote" style="font-size:10px; color:#e8401c; font-weight:600;"></span></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbFriesSourCream" runat="server" /><label for="<%= cbFriesSourCream.ClientID %>">Sour Cream</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbFriesBBQ" runat="server" /><label for="<%= cbFriesBBQ.ClientID %>">BBQ</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbFriesCheese" runat="server" /><label for="<%= cbFriesCheese.ClientID %>">Cheese</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbFriesSalt" runat="server" /><label for="<%= cbFriesSalt.ClientID %>">Chili BBQ</label></div>
                            </div>
                        </div>
                        <div class="qty-section">
                            <span class="qty-label">Qty:</span>
                            <div class="qty-controls">
                                <asp:UpdatePanel ID="upFriesQty" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="btnFriesMinus" runat="server" Text="-" CssClass="qty-btn" OnClick="btnFriesMinus_Click" CausesValidation="false" />
                                        <asp:Label ID="lblFriesQty" runat="server" Text="1" CssClass="qty-display"></asp:Label>
                                        <asp:Button ID="btnFriesPlus" runat="server" Text="+" CssClass="qty-btn" OnClick="btnFriesPlus_Click" CausesValidation="false" />
                                        <asp:HiddenField ID="hdnFriesQty" runat="server" Value="1" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                        <asp:Button ID="btnAddFries" runat="server" Text="Add to Order" CssClass="btn-add" OnClick="btnAddFries_Click" CausesValidation="false" />
                    </div>

                    <!-- Chicken Pops -->
                    <div class="product-card">
                        <div class="product-header">
                            <div class="product-name">Chicken Pops</div>
                        </div>
                        <div class="product-body">
                            <div class="sizes-section">
                                <div class="section-label">Size</div>
                                <div class="size-option"><asp:RadioButton ID="rbChickenSolo" runat="server" GroupName="ChickenSize" /><label for="<%= rbChickenSolo.ClientID %>">Solo - PHP 75</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbChickenLarge" runat="server" GroupName="ChickenSize" /><label for="<%= rbChickenLarge.ClientID %>">Large Mix - PHP 95</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbChickenMega" runat="server" GroupName="ChickenSize" /><label for="<%= rbChickenMega.ClientID %>">Mega Mix - PHP 199</label></div>
                            </div>
                            <div class="flavors-section">
                                <div class="section-label">Flavor <span id="chickenFlavorNote" style="font-size:10px; color:#e8401c; font-weight:600;"></span></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbChickenSourCream" runat="server" /><label for="<%= cbChickenSourCream.ClientID %>">Sour Cream</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbChickenBBQ" runat="server" /><label for="<%= cbChickenBBQ.ClientID %>">BBQ</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbChickenCheese" runat="server" /><label for="<%= cbChickenCheese.ClientID %>">Cheese</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbChickenSalt" runat="server" /><label for="<%= cbChickenSalt.ClientID %>">Chili BBQ</label></div>
                            </div>
                        </div>
                        <div class="qty-section">
                            <span class="qty-label">Qty:</span>
                            <div class="qty-controls">
                                <asp:UpdatePanel ID="upChickenQty" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="btnChickenMinus" runat="server" Text="-" CssClass="qty-btn" OnClick="btnChickenMinus_Click" CausesValidation="false" />
                                        <asp:Label ID="lblChickenQty" runat="server" Text="1" CssClass="qty-display"></asp:Label>
                                        <asp:Button ID="btnChickenPlus" runat="server" Text="+" CssClass="qty-btn" OnClick="btnChickenPlus_Click" CausesValidation="false" />
                                        <asp:HiddenField ID="hdnChickenQty" runat="server" Value="1" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                        <asp:Button ID="btnAddChicken" runat="server" Text="Add to Order" CssClass="btn-add" OnClick="btnAddChicken_Click" CausesValidation="false" />
                    </div>

                    <!-- Loopys -->
                    <div class="product-card">
                        <div class="product-header">
                            <div class="product-name">Loopys</div>
                        </div>
                        <div class="product-body">
                            <div class="sizes-section">
                                <div class="section-label">Size</div>
                                <div class="size-option"><asp:RadioButton ID="rbLoopysLarge" runat="server" GroupName="LoopysSize" /><label for="<%= rbLoopysLarge.ClientID %>">Large - PHP 75</label></div>
                                <div class="size-option"><asp:RadioButton ID="rbLoopysMega" runat="server" GroupName="LoopysSize" /><label for="<%= rbLoopysMega.ClientID %>">Mega - PHP 135</label></div>
                            </div>
                            <div class="flavors-section">
                                <div class="section-label">Flavor <span id="loopysFlavorNote" style="font-size:10px; color:#e8401c; font-weight:600;"></span></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbLoopysSourCream" runat="server" /><label for="<%= cbLoopysSourCream.ClientID %>">Sour Cream</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbLoopysBBQ" runat="server" /><label for="<%= cbLoopysBBQ.ClientID %>">BBQ</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbLoopysCheese" runat="server" /><label for="<%= cbLoopysCheese.ClientID %>">Cheese</label></div>
                                <div class="flavor-option"><asp:CheckBox ID="cbLoopysSalt" runat="server" /><label for="<%= cbLoopysSalt.ClientID %>">Chili BBQ</label></div>
                            </div>
                        </div>
                        <div class="qty-section">
                            <span class="qty-label">Qty:</span>
                            <div class="qty-controls">
                                <asp:UpdatePanel ID="upLoopysQty" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Button ID="btnLoopysMinus" runat="server" Text="-" CssClass="qty-btn" OnClick="btnLoopysMinus_Click" CausesValidation="false" />
                                        <asp:Label ID="lblLoopysQty" runat="server" Text="1" CssClass="qty-display"></asp:Label>
                                        <asp:Button ID="btnLoopysPlus" runat="server" Text="+" CssClass="qty-btn" OnClick="btnLoopysPlus_Click" CausesValidation="false" />
                                        <asp:HiddenField ID="hdnLoopysQty" runat="server" Value="1" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                        </div>
                        <asp:Button ID="btnAddLoopys" runat="server" Text="Add to Order" CssClass="btn-add" OnClick="btnAddLoopys_Click" CausesValidation="false" />
                    </div>
                </div>
            </div>

            <!-- RIGHT PANEL -->
            <div class="right-panel">
                <div class="panel-title">Order Summary</div>
                <div class="cart-section">
                    <div id="cartDisplay" runat="server"></div>
                    <asp:Label ID="lblSubtotal" runat="server" Text="0.00" Style="display:none;"></asp:Label>
                    <asp:Label ID="lblDiscount" runat="server" Text="0.00" Style="display:none;"></asp:Label>
                    <asp:Label ID="lblDeliveryFee" runat="server" Text="0.00" Style="display:none;"></asp:Label>
                    <asp:Label ID="lblTotal" runat="server" Text="0.00" Style="display:none;"></asp:Label>
                </div>

                <div class="delivery-section">
                    <div class="section-label">Delivery Type</div>
                    <div class="option-grid">
                        <asp:Button ID="btnWalkIn" runat="server" Text="Walk-in" CssClass="option-btn selected" OnClientClick="showPickupTimeModal(); return false;" CausesValidation="false" />
                        <asp:Button ID="btnDelivery" runat="server" Text="Delivery +PHP 50" CssClass="option-btn" OnClick="btnDeliveryType_Click" CausesValidation="false" />
                    </div>
                    <asp:HiddenField ID="hdnDeliveryType" runat="server" Value="WalkIn" />
                    <asp:HiddenField ID="hdnPickupTime" runat="server" Value="" />
                    <asp:Label ID="lblPickupTime" runat="server" Visible="false"
                        Style="display:block; margin-top:10px; font-size:12px; color:#119247; font-weight:700; text-align:center;"></asp:Label>
                </div>

                <div class="payment-section">
                    <div class="section-label">Payment Method</div>
                    <div class="option-grid">
                        <asp:Button ID="btnGoTyme" runat="server" Text="GoTyme" CssClass="option-btn" OnClick="btnPayment_Click" CausesValidation="false" />
                        <asp:Button ID="btnMayaBank" runat="server" Text="Maya Bank" CssClass="option-btn" OnClick="btnPayment_Click" CausesValidation="false" />
                        <asp:Button ID="btnGCash" runat="server" Text="GCash" CssClass="option-btn" OnClick="btnPayment_Click" CausesValidation="false" />
                        <asp:Button ID="btnPoints" runat="server" Text="Points" CssClass="option-btn" OnClick="btnPayment_Click" CausesValidation="false" />
                    </div>
                    <asp:HiddenField ID="hdnPaymentMethod" runat="server" Value="" />
                    <asp:HiddenField ID="hdnGeneratedReference" runat="server" />
                </div>

                <asp:Label ID="lblErrorMsg" runat="server" CssClass="status-msg status-error" Visible="false" Style="margin-top:12px;"></asp:Label>
                <asp:Button ID="btnConfirm" runat="server" Text="Confirm Order" CssClass="btn-confirm" OnClientClick="return handleConfirmOrder();" OnClick="btnConfirm_Click" />
                <asp:HiddenField ID="hdnShowQRModal" runat="server" Value="false" />
            </div>
        </div>

        <!-- PICKUP TIME MODAL -->
        <div id="pickupTimeModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-header">Select Pickup Time</div>
                <div class="modal-message">Choose when you'd like to pick up your order</div>
                <div class="time-slots">
                    <asp:RadioButtonList ID="rblPickupTime" runat="server" CssClass="time-slot-list"></asp:RadioButtonList>
                </div>
                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-cancel" onclick="hidePickupTimeModal()">Cancel</button>
                    <asp:Button ID="btnConfirmPickupTime" runat="server"
                        Text="Confirm"
                        CssClass="modal-btn modal-btn-confirm"
                        OnClick="btnConfirmPickupTime_Click"
                        CausesValidation="false" />
                </div>
            </div>
        </div>

        <!-- ALERT MODAL (Reusable) -->
        <div id="alertModal" class="modal-overlay">
            <div class="alert-modal-box">
                <div class="alert-modal-icon" id="alertModalIcon">⚠️</div>
                <div class="alert-modal-head" id="alertModalTitle">Alert</div>
                <div class="alert-modal-msg" id="alertModalMessage">This is an alert message.</div>
                <button type="button" class="alert-modal-btn" onclick="closeAlertModal()">OK</button>
            </div>
        </div>

        <!-- LOCATION NOT AVAILABLE MODAL -->
        <div id="locationModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-header" style="color: #e8401c;">Location Not Available</div>
                <div class="modal-message">This location is only available for delivery orders. Please select "Delivery" as your delivery type or choose a different location that supports walk-in.</div>
                <div class="modal-buttons">
                    <button type="button" class="modal-btn modal-btn-confirm" onclick="hideLocationModal()" style="width: 100%;">OK</button>
                </div>
            </div>
        </div>

        <!-- PAYMENT QR CODE MODAL (Phase 2.5 - 2 Column Grid) -->
        <div id="qrCodeModal" class="modal-overlay">
            <div class="modal-box" style="max-width: 650px; padding: 24px;">
                <div class="modal-header" style="margin-bottom: 8px;">Scan QR Code to Pay</div>
                <div class="modal-message" style="margin-bottom: 20px; font-size: 13px;">
                    Scan the QR code to get your payment reference, then enter it below
                </div>
                
                <!-- 2x2 Grid Layout -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 18px;">
                    <!-- LEFT SIDE: QR CODE -->
                    <div style="background: white; padding: 16px; border-radius: 10px; text-align: center; border: 2px solid #e8f5ee;">
                        <div style="background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%); padding: 12px; border-radius: 8px; margin-bottom: 12px;">
                            <div style="font-size: 20px; font-weight: 900; color: #1a1a1a;">
                                PHP <asp:Label ID="lblQRTotal" runat="server" Text="0.00"></asp:Label>
                            </div>
                            <div style="font-size: 11px; color: #1a1a1a; opacity: 0.8;">Total Amount</div>
                        </div>
                        
                        <img id="qrCodeImage" src="" alt="Payment QR Code" style="width: 100%; max-width: 220px; height: auto; aspect-ratio: 1; border: 3px solid #119247; border-radius: 10px; padding: 8px; background: white;" />
                        
                        <div style="margin-top: 12px; padding: 10px; background: #e3f2fd; border-radius: 6px; border-left: 3px solid #119247;">
                            <div style="font-size: 11px; color: #0d47a1; font-weight: 600; line-height: 1.4;">
                                📱 Use your phone camera or QR scanner app
                            </div>
                        </div>
                    </div>
                    
                    <!-- RIGHT SIDE: REFERENCE INPUT -->
                    <div style="background: #f8f9fa; padding: 16px; border-radius: 10px; display: flex; flex-direction: column; justify-content: space-between; border: 2px solid #e0e0e0;">
                        <div>
                            <div style="font-size: 13px; font-weight: 800; color: #119247; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.3px;">
                                Enter Payment Reference
                            </div>
                            <div style="font-size: 11px; color: #666; margin-bottom: 12px; line-height: 1.5;">
                                After scanning the QR code, you will see a reference number. Enter it below to confirm your payment.
                            </div>
                            <asp:TextBox ID="txtPaymentReferenceModal" runat="server" 
                                placeholder="e.g., REF-2024-001234"
                                CssClass="file-upload-input"
                                MaxLength="50"
                                style="text-transform: uppercase; font-family: monospace; font-size: 14px; font-weight: 600; width: 100%; padding: 10px; border: 2px solid #e0e0e0; border-radius: 8px;"></asp:TextBox>
                            <div id="modalRefError" style="color: #dc3545; font-size: 11px; font-weight: 600; margin-top: 6px; min-height: 16px;"></div>
                        </div>
                        
                        <div style="text-align: center; margin-top: 12px;">
                            <asp:Button ID="btnSubmitPaymentModal" runat="server" 
                                Text="Done" 
                                CssClass="modal-btn modal-btn-confirm" 
                                OnClientClick="return validateAndSubmitReference();"
                                OnClick="btnSubmitPaymentModal_Click"
                                style="padding: 10px 32px; font-size: 13px; font-weight: 700; background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; border: none; border-radius: 8px; cursor: pointer; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.3s; display: inline-block;" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        // ── QR CODE MODAL ──
        function showQRCodeModal(paymentMethod, total) {
            document.getElementById('<%= lblQRTotal.ClientID %>').textContent = total;
            
            // Get the generated reference from hidden field
            var reference = document.getElementById('<%= hdnGeneratedReference.ClientID %>').value;
            
            // Create QR code data (this is what customer sees when they scan)
            var qrData = 'PAYMENT SUCCESSFUL!\n' +
                        'Merchant: Potato Corner\n' +
                        'Amount: PHP ' + total + '\n' +
                        'Reference: ' + reference + '\n' +
                        'Date: ' + new Date().toLocaleString();
            
            // Generate QR code image
            var qrImage = document.getElementById('qrCodeImage');
            qrImage.src = 'https://api.qrserver.com/v1/create-qr-code/?size=280x280&data=' + encodeURIComponent(qrData);
            
            // Clear previous input and error
            document.getElementById('<%= txtPaymentReferenceModal.ClientID %>').value = '';
            document.getElementById('modalRefError').textContent = '';
            
            document.getElementById('qrCodeModal').classList.add('active');
        }
        
        function hideQRCodeModal() {
            document.getElementById('qrCodeModal').classList.remove('active');
        }
        
        // Validate reference in modal before submitting
        function validateAndSubmitReference() {
            var enteredRef = document.getElementById('<%= txtPaymentReferenceModal.ClientID %>').value.trim().toUpperCase();
            var generatedRef = document.getElementById('<%= hdnGeneratedReference.ClientID %>').value;
            var errorDiv = document.getElementById('modalRefError');
            
            if (enteredRef === '') {
                errorDiv.textContent = 'Please enter the payment reference number from the QR code.';
                return false;
            }
            
            if (!enteredRef.startsWith('REF-') || enteredRef.length < 15) {
                errorDiv.textContent = 'Invalid reference format. Please scan the QR code and enter the correct reference.';
                return false;
            }
            
            if (enteredRef !== generatedRef) {
                errorDiv.textContent = 'Reference number does not match. Please check and try again.';
                return false;
            }
            
            // Valid reference - allow form submission
            return true;
        }
        
        // Generate reference when payment method is selected
        function generatePaymentReference() {
            var timestamp = new Date().getTime();
            var random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
            var reference = 'REF-' + new Date().getFullYear() + '-' + timestamp.toString().slice(-6) + random;
            
            // Store in hidden field
            document.getElementById('<%= hdnGeneratedReference.ClientID %>').value = reference;
            
            return reference;
        }
        
        // ── MODAL ──
        function showPickupTimeModal() {
            document.getElementById('pickupTimeModal').classList.add('active');
        }
        function hidePickupTimeModal() {
            document.getElementById('pickupTimeModal').classList.remove('active');
        }
        function showLocationModal() {
            document.getElementById('locationModal').classList.add('active');
        }
        function hideLocationModal() {
            document.getElementById('locationModal').classList.remove('active');
        }
        
        // Alert Modal Function
        function showAlertModal(icon, title, message) {
            document.getElementById('alertModalIcon').textContent = icon;
            document.getElementById('alertModalTitle').textContent = title;
            document.getElementById('alertModalMessage').textContent = message;
            document.getElementById('alertModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeAlertModal() {
            document.getElementById('alertModal').classList.remove('active');
            document.body.style.overflow = 'auto';
        }
        
        function removeCartItem(index) {
            if (confirm('Remove this item from cart?')) {
                __doPostBack('RemoveCartItem', index);
            }
        }
        
        // Check location availability
        function checkLocationAvailability() {
            var locationDropdown = document.getElementById('<%= ddlLocation.ClientID %>');
            var deliveryType = document.getElementById('<%= hdnDeliveryType.ClientID %>').value;
            var selectedValue = locationDropdown.value;
            
            if (selectedValue) {
                var parts = selectedValue.split('|');
                var locationType = parts[1];
                
                // If location is Delivery-only and user selected Walk-in
                if (locationType === 'Delivery' && deliveryType === 'WalkIn') {
                    showLocationModal();
                    locationDropdown.selectedIndex = 0; // Reset to "Select Location"
                }
            }
        }
        
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('pickupTimeModal');
            if (modal) {
                modal.addEventListener('click', function (e) {
                    if (e.target === this) hidePickupTimeModal();
                });
            }
            
            var locationModalEl = document.getElementById('locationModal');
            if (locationModalEl) {
                locationModalEl.addEventListener('click', function (e) {
                    if (e.target === this) hideLocationModal();
                });
            }
            
            var qrModalEl = document.getElementById('qrCodeModal');
            if (qrModalEl) {
                qrModalEl.addEventListener('click', function (e) {
                    if (e.target === this) hideQRCodeModal();
                });
            }
        });

        // ── DUAL FLAVOR SELECTION LOGIC ──
        // French Fries
        var friesSizeRadios = [
            document.getElementById('<%= rbFriesRegular.ClientID %>'),
            document.getElementById('<%= rbFriesLarge.ClientID %>'),
            document.getElementById('<%= rbFriesJumbo.ClientID %>'),
            document.getElementById('<%= rbFriesMega.ClientID %>'),
            document.getElementById('<%= rbFriesGiga.ClientID %>'),
            document.getElementById('<%= rbFriesTerra.ClientID %>')
        ];
        var friesFlavorCheckboxes = [
            document.getElementById('<%= cbFriesSourCream.ClientID %>'),
            document.getElementById('<%= cbFriesBBQ.ClientID %>'),
            document.getElementById('<%= cbFriesCheese.ClientID %>'),
            document.getElementById('<%= cbFriesSalt.ClientID %>')
        ];
        var friesFlavorNote = document.getElementById('friesFlavorNote');
        
        function updateFriesFlavorMode() {
            var isMegaOrAbove = friesSizeRadios[3].checked || friesSizeRadios[4].checked || friesSizeRadios[5].checked;
            if (isMegaOrAbove) {
                friesFlavorNote.textContent = '(Choose 1 or 2 flavors)';
            } else {
                friesFlavorNote.textContent = '';
                // Uncheck all but first checked
                var checkedCount = 0;
                friesFlavorCheckboxes.forEach(function(cb) {
                    if (cb.checked) {
                        checkedCount++;
                        if (checkedCount > 1) cb.checked = false;
                    }
                });
            }
        }
        
        friesSizeRadios.forEach(function(radio) {
            if (radio) radio.addEventListener('change', updateFriesFlavorMode);
        });
        
        friesFlavorCheckboxes.forEach(function(cb) {
            if (cb) {
                cb.addEventListener('change', function() {
                    var isMegaOrAbove = friesSizeRadios[3].checked || friesSizeRadios[4].checked || friesSizeRadios[5].checked;
                    var checkedCount = friesFlavorCheckboxes.filter(function(c) { return c.checked; }).length;
                    
                    if (!isMegaOrAbove && checkedCount > 1) {
                        // For non-Mega sizes, only allow 1 flavor
                        friesFlavorCheckboxes.forEach(function(c) {
                            if (c !== cb) c.checked = false;
                        });
                    } else if (checkedCount > 2) {
                        // Max 2 flavors for Mega+
                        cb.checked = false;
                    }
                });
            }
        });
        
        // Chicken Pops
        var chickenSizeRadios = [
            document.getElementById('<%= rbChickenSolo.ClientID %>'),
            document.getElementById('<%= rbChickenLarge.ClientID %>'),
            document.getElementById('<%= rbChickenMega.ClientID %>')
        ];
        var chickenFlavorCheckboxes = [
            document.getElementById('<%= cbChickenSourCream.ClientID %>'),
            document.getElementById('<%= cbChickenBBQ.ClientID %>'),
            document.getElementById('<%= cbChickenCheese.ClientID %>'),
            document.getElementById('<%= cbChickenSalt.ClientID %>')
        ];
        var chickenFlavorNote = document.getElementById('chickenFlavorNote');
        
        function updateChickenFlavorMode() {
            var isMega = chickenSizeRadios[2].checked;
            if (isMega) {
                chickenFlavorNote.textContent = '(Choose 1 or 2 flavors)';
            } else {
                chickenFlavorNote.textContent = '';
                var checkedCount = 0;
                chickenFlavorCheckboxes.forEach(function(cb) {
                    if (cb.checked) {
                        checkedCount++;
                        if (checkedCount > 1) cb.checked = false;
                    }
                });
            }
        }
        
        chickenSizeRadios.forEach(function(radio) {
            if (radio) radio.addEventListener('change', updateChickenFlavorMode);
        });
        
        chickenFlavorCheckboxes.forEach(function(cb) {
            if (cb) {
                cb.addEventListener('change', function() {
                    var isMega = chickenSizeRadios[2].checked;
                    var checkedCount = chickenFlavorCheckboxes.filter(function(c) { return c.checked; }).length;
                    
                    if (!isMega && checkedCount > 1) {
                        chickenFlavorCheckboxes.forEach(function(c) {
                            if (c !== cb) c.checked = false;
                        });
                    } else if (checkedCount > 2) {
                        cb.checked = false;
                    }
                });
            }
        });
        
        // Loopys
        var loopysSizeRadios = [
            document.getElementById('<%= rbLoopysLarge.ClientID %>'),
            document.getElementById('<%= rbLoopysMega.ClientID %>')
        ];
        var loopysFlavorCheckboxes = [
            document.getElementById('<%= cbLoopysSourCream.ClientID %>'),
            document.getElementById('<%= cbLoopysBBQ.ClientID %>'),
            document.getElementById('<%= cbLoopysCheese.ClientID %>'),
            document.getElementById('<%= cbLoopysSalt.ClientID %>')
        ];
        var loopysFlavorNote = document.getElementById('loopysFlavorNote');
        
        function updateLoopysFlavorMode() {
            var isMega = loopysSizeRadios[1].checked;
            if (isMega) {
                loopysFlavorNote.textContent = '(Choose 1 or 2 flavors)';
            } else {
                loopysFlavorNote.textContent = '';
                var checkedCount = 0;
                loopysFlavorCheckboxes.forEach(function(cb) {
                    if (cb.checked) {
                        checkedCount++;
                        if (checkedCount > 1) cb.checked = false;
                    }
                });
            }
        }
        
        loopysSizeRadios.forEach(function(radio) {
            if (radio) radio.addEventListener('change', updateLoopysFlavorMode);
        });
        
        loopysFlavorCheckboxes.forEach(function(cb) {
            if (cb) {
                cb.addEventListener('change', function() {
                    var isMega = loopysSizeRadios[1].checked;
                    var checkedCount = loopysFlavorCheckboxes.filter(function(c) { return c.checked; }).length;
                    
                    if (!isMega && checkedCount > 1) {
                        loopysFlavorCheckboxes.forEach(function(c) {
                            if (c !== cb) c.checked = false;
                        });
                    } else if (checkedCount > 2) {
                        cb.checked = false;
                    }
                });
            }
        });

        // ── REAL-TIME INPUT VALIDATION ──
        var nameInput    = document.getElementById('<%= txtName.ClientID %>');
        var streetInput  = document.getElementById('<%= txtStreet.ClientID %>');
        var contactInput = document.getElementById('<%= txtContact.ClientID %>');
        var locationDropdown = document.getElementById('<%= ddlLocation.ClientID %>');

        var errName    = document.getElementById('errName');
        var errStreet  = document.getElementById('errStreet');
        var errContact = document.getElementById('errContact');
        var errLocation = document.getElementById('errLocation');

        function setValid(input, errEl) {
            input.classList.remove('invalid');
            input.classList.add('valid');
            errEl.textContent = '';
        }
        function setInvalid(input, errEl, msg) {
            input.classList.remove('valid');
            input.classList.add('invalid');
            errEl.textContent = msg;
        }
        function clearState(input, errEl) {
            input.classList.remove('valid', 'invalid');
            errEl.textContent = '';
        }

        // NAME
        nameInput.addEventListener('input', function () {
            var val = this.value.trim();
            if (val === '') {
                clearState(this, errName);
            } else if (val.length < 2) {
                setInvalid(this, errName, 'Name must be at least 2 characters.');
            } else if (/\d/.test(val)) {
                setInvalid(this, errName, 'Name cannot contain numbers.');
            } else if (!/^[a-zA-Z\s\-\.]+$/.test(val)) {
                setInvalid(this, errName, 'Name can only contain letters, spaces, hyphens, or periods.');
            } else {
                setValid(this, errName);
            }
        });
        nameInput.addEventListener('blur', function () {
            if (this.value.trim() === '') setInvalid(this, errName, 'Full name is required.');
        });

        // STREET ADDRESS
        streetInput.addEventListener('input', function () {
            var val = this.value.trim();
            if (val === '') {
                clearState(this, errStreet);
            } else if (val.length < 5) {
                setInvalid(this, errStreet, 'Please enter a valid street address (min 5 characters).');
            } else if (!/^[a-zA-Z0-9\s,.\-#\/]+$/.test(val)) {
                setInvalid(this, errStreet, 'Street address contains invalid characters.');
            } else {
                setValid(this, errStreet);
            }
        });
        streetInput.addEventListener('blur', function () {
            if (this.value.trim() === '') setInvalid(this, errStreet, 'Street address is required.');
        });

        // CONTACT — digits only, must be exactly 11 digits starting with 09
        contactInput.addEventListener('input', function () {
            this.value = this.value.replace(/[^0-9]/g, '');
            var val = this.value.trim();
            if (val === '') {
                clearState(this, errContact);
            } else if (val.length < 11) {
                setInvalid(this, errContact, 'Contact number must be exactly 11 digits.');
            } else if (val.length === 11 && !/^09\d{9}$/.test(val)) {
                setInvalid(this, errContact, 'Contact must start with 09 (e.g. 09123456789).');
            } else if (val.length === 11) {
                setValid(this, errContact);
            }
        });
        contactInput.addEventListener('blur', function () {
            var val = this.value.trim();
            if (val === '') {
                setInvalid(this, errContact, 'Contact number is required.');
            } else if (val.length !== 11) {
                setInvalid(this, errContact, 'Contact number must be exactly 11 digits.');
            } else if (!/^09\d{9}$/.test(val)) {
                setInvalid(this, errContact, 'Contact must start with 09.');
            }
        });

        // LOCATION VALIDATION
        locationDropdown.addEventListener('change', function () {
            if (this.value === '') {
                setInvalid(this, errLocation, 'Please select a location.');
            } else {
                setValid(this, errLocation);
            }
        });

        // BLOCK CONFIRM if frontend validation fails
        var confirmBtn = document.getElementById('<%= btnConfirm.ClientID %>');
        
        function handleConfirmOrder() {
            var nameVal = nameInput.value.trim();
            var streetVal = streetInput.value.trim();
            var contactVal = contactInput.value.trim();
            var locationVal = locationDropdown.value;
            var paymentMethod = document.getElementById('<%= hdnPaymentMethod.ClientID %>').value;
            var hasError = false;

            if (nameVal === '') {
                setInvalid(nameInput, errName, 'Full name is required.');
                hasError = true;
            } else if (/\d/.test(nameVal) || !/^[a-zA-Z\s\-\.]+$/.test(nameVal)) {
                setInvalid(nameInput, errName, 'Please enter a valid full name.');
                hasError = true;
            }

            if (locationVal === '') {
                setInvalid(locationDropdown, errLocation, 'Please select a location.');
                hasError = true;
            }

            if (streetVal === '') {
                setInvalid(streetInput, errStreet, 'Street address is required.');
                hasError = true;
            } else if (streetVal.length < 5) {
                setInvalid(streetInput, errStreet, 'Please enter a complete street address.');
                hasError = true;
            }

            if (contactVal === '') {
                setInvalid(contactInput, errContact, 'Contact number is required.');
                hasError = true;
            } else if (contactVal.length !== 11) {
                setInvalid(contactInput, errContact, 'Contact number must be exactly 11 digits.');
                hasError = true;
            } else if (!/^09\d{9}$/.test(contactVal)) {
                setInvalid(contactInput, errContact, 'Enter a valid 11-digit number starting with 09.');
                hasError = true;
            }

            // CHECK IF CART IS EMPTY
            var cartCountElement = document.getElementById('<%= lblTotal.ClientID %>');
            if (!cartCountElement || cartCountElement.textContent === '0.00') {
                showAlertModal('🛒', 'Cart Empty', 'Your cart is empty! Please add items before checking out.');
                hasError = true;
            }
            
            // CHECK PAYMENT METHOD
            if (!paymentMethod) {
                showAlertModal('💳', 'Payment Method Required', 'Please select a payment method.');
                hasError = true;
            }

            if (hasError) {
                if (!cartCountElement || cartCountElement.textContent === '0.00') {
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                } else {
                    nameInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
                return false;
            }
            
            // If payment method is NOT Points, generate reference and show QR modal
            if (paymentMethod !== 'Points') {
                // Generate reference number
                generatePaymentReference();
                
                var total = document.getElementById('<%= lblTotal.ClientID %>').textContent;
                showQRCodeModal(paymentMethod, total);
                return false; // Prevent form submission, user will enter reference in modal
            }
            
            // For Points payment, allow form submission
            return true;
        }
        
        if (confirmBtn) {
            confirmBtn.addEventListener('click', function (e) {
                // Validation is now handled in handleConfirmOrder
            });
        }
    </script>
</body>
</html>