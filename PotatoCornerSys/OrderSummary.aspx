<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderSummary.aspx.cs" Inherits="PotatoCornerSys.OrderSummary" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>Potato Corner - Order Summary</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #e8e8e8;
            min-height: 100vh;
        }
        
        /* NAVBAR */
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
        
        .navbar-logo img { 
            height: 85px;
            filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
            transition: transform 0.3s;
        }
        
        .navbar-logo img:hover {
            transform: scale(1.05);
        }
        
        .navbar-links { 
            display: flex; 
            align-items: center;
            gap: 40px;
            list-style: none;
        }
        
        .navbar-links a { 
            color: white; 
            text-decoration: none; 
            font-size: 16px;
            font-weight: 700; 
            letter-spacing: 0.5px;
            transition: all 0.3s;
            position: relative;
        }
        
        .navbar-links a:hover { 
            color: #f5c800;
            transform: translateY(-2px);
        }
        
        .navbar-links a::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 3px;
            background: #f5c800;
            transition: width 0.3s;
        }
        
        .navbar-links a:hover::after {
            width: 100%;
        }
        
        /* HERO BANNER */
        .hero-banner {
            background: #e8e8e8;
            padding: 30px 40px 50px 40px;
        }
        
        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .summary-header {
            background: linear-gradient(135deg, #e8401c 0%, #ff6b47 100%);
            padding: 25px 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }
        
        .summary-header h1 {
            font-size: 42px;
            font-weight: 900;
            color: white;
            text-transform: uppercase;
            letter-spacing: 4px;
            text-shadow: 0 3px 15px rgba(0,0,0,0.2);
            margin-bottom: 0;
        }
        
        /* MAIN CONTAINER */
        .summary-container { 
            max-width: 1400px; 
            margin: 0px auto; 
            padding: 0 40px;
        }
        
        /* BACK BUTTON */
        .back-section {
            margin-bottom: 30px;
        }
        
        .btn-back {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn-back:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(17,146,71,0.3);
        }
        
        /* FILTER SECTION */
        .filter-section {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .filter-header {
            font-size: 18px;
            font-weight: 800;
            color: #333;
            margin-bottom: 20px;
        }
        
        .filter-dropdown {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .filter-dropdown-select {
            background: white;
            color: #333;
            border: 2px solid #e0e0e0;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            min-width: 200px;
            outline: none;
        }
        
        .filter-dropdown-select:hover {
            border-color: #119247;
        }
        
        .filter-dropdown-select:focus {
            border-color: #119247;
            box-shadow: 0 0 0 3px rgba(17,146,71,0.1);
        }
        
        /* STATISTICS GRID */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 24px;
            color: white;
        }
        
        .stat-value {
            font-size: 36px;
            font-weight: 900;
            color: #333;
            margin-bottom: 8px;
        }
        
        .stat-label {
            font-size: 14px;
            color: #666;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        /* RESPONSIVE */
        @media (max-width: 768px) {
            .filter-dropdown {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .filter-dropdown-select {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="navbar">
            <div class="navbar-logo">
                <img src="potato.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><a href="Default.aspx">Home</a></li>
                <li><a href="Menu.aspx">Menu</a></li>
                <li><a href="Membership.aspx">Membership</a></li>
                <li><a href="AboutUs.aspx">About Us</a></li>
                <li><a href="Order.aspx">Order Now</a></li>
                <li><a href="Profile.aspx">Profile</a></li>
            </ul>
        </div>
        
        <!-- HERO BANNER -->
        <div class="hero-banner">
            <div class="hero-content">
                <div class="summary-header">
                    <h1>ORDER SUMMARY</h1>
                </div>
            </div>
        </div>
        
        <!-- MAIN SUMMARY CONTAINER -->
        <div class="summary-container">
            
            <!-- BACK BUTTON -->
            <div class="back-section">
                <a href="Profile.aspx" class="btn-back">← Back to Profile</a>
            </div>
            
            <!-- FILTER SECTION -->
            <div class="filter-section">
                <div class="filter-header">Filter by Delivery Type</div>
                <div class="filter-dropdown">
                    <asp:DropDownList ID="ddlDeliveryFilter" runat="server" 
                        CssClass="filter-dropdown-select" 
                        AutoPostBack="true" 
                        OnSelectedIndexChanged="ddlDeliveryFilter_SelectedIndexChanged">
                        <asp:ListItem Value="All" Text="All Orders" Selected="True" />
                        <asp:ListItem Value="Walk-in" Text="Walk-in Only" />
                        <asp:ListItem Value="Delivery" Text="Delivery Only" />
                    </asp:DropDownList>
                </div>
            </div>
            
            <!-- OVERALL STATISTICS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-value">
                        <asp:Label ID="lblTotalOrders" runat="server" Text="0" />
                    </div>
                    <div class="stat-label">Total Orders</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">💰</div>
                    <div class="stat-value">₱<asp:Label ID="lblTotalSpent" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Total Spent</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">📈</div>
                    <div class="stat-value">₱<asp:Label ID="lblAverageOrder" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Average Order</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">🏆</div>
                    <div class="stat-value">₱<asp:Label ID="lblLargestOrder" runat="server" Text="0.00" /></div>
                    <div class="stat-label">Largest Order</div>
                </div>
            </div>
            
        </div><!-- end summary-container -->
        
        <!-- FOOTER -->
        <div style="background: linear-gradient(135deg, #119247 0%, #0d7336 100%); color: white; text-align: center; padding: 40px; margin-top: 50px; border-top: 5px solid #f5c800;">
            <div style="margin-bottom: 20px;">
                <a href="#" style="color: #f5c800; text-decoration: none; margin: 0 15px; font-weight: 600;">Terms & Conditions</a> |
                <a href="#" style="color: #f5c800; text-decoration: none; margin: 0 15px; font-weight: 600;">Privacy Policy</a>
            </div>
            <div style="font-size: 14px; color: #ccc; margin-top: 15px;">© 2026 Potato Corner. All rights reserved.</div>
        </div>
        
    </form>
</body>
</html>
