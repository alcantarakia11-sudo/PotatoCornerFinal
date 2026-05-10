<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Sale.aspx.cs" Inherits="PotatoCornerSys.Sales" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sales Dashboard - Potato Corner</title>
    <style type="text/css">
        :root {
            --primary-green: #119247;
            --primary-dark: #0d7336;
            --accent-yellow: #f5c800;
            --bg-light: #f8fffe;
            --bg-white: #ffffff;
            --text-dark: #2c3e50;
            --text-light: #6c757d;
            --border-light: #e9ecef;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.15);
            --shadow-lg: 0 8px 25px rgba(0,0,0,0.15);
        }

        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }

        body {
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
        }

        /* MODERN NAVBAR */
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

        /* MAIN CONTAINER */
        .sales-container {
            max-width: 1400px;
            margin: 50px auto;
            padding: 0 40px;
        }

        /* PAGE HEADER */
        .page-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .page-header h1 {
            font-size: 48px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        /* STATS CARDS */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 50px;
        }

        .stat-card {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 8px 30px rgba(245, 200, 0, 0.25);
            transition: all 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
        }

        .stat-card h3 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.9;
        }

        .stat-card .stat-value {
            font-size: 42px;
            font-weight: 900;
            margin-bottom: 5px;
        }

        .stat-card .stat-change {
            font-size: 12px;
            color: #e8401c;
            font-weight: 700;
        }

        /* ORDERS SECTION */
        .orders-section {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.1);
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 30px;
        }

        .section-header h2 {
            font-size: 32px;
            color: #e8401c;
            font-weight: 900;
            text-transform: uppercase;
            margin: 0;
        }

        .order-count {
            background: #e8401c;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
        }

        /* MODERN TABLE */
        .table-container {
            overflow-x: auto;
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
        }

        .orders-table th {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 0.5px;
        }

        .orders-table td {
            padding: 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 14px;
        }

        .orders-table tbody tr {
            transition: all 0.2s ease;
        }

        .orders-table tbody tr:hover {
            background: #f8f9fa;
        }

        /* ORDER ID STYLING */
        .order-id {
            font-weight: 700;
            color: var(--primary-green);
            font-size: 16px;
        }

        /* CUSTOMER NAME */
        .customer-name {
            font-weight: 600;
            color: var(--text-dark);
        }

        /* DELIVERY TYPE BADGES */
        .delivery-type {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .delivery-badge, .walkin-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .delivery-badge {
            background: #e3f2fd;
            color: #1565c0;
            border: 1px solid #90caf9;
        }

        .walkin-badge {
            background: #f3e5f5;
            color: #6a1b9a;
            border: 1px solid #ce93d8;
        }

        /* DATE STYLING */
        .order-date {
            color: var(--text-light);
            font-size: 14px;
        }

        /* AMOUNT STYLING */
        .order-amount {
            font-weight: 700;
            color: var(--primary-green);
            font-size: 16px;
        }

        /* STATUS BADGES - REDESIGNED */
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-badge::before {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .status-confirmed {
            background: #d4edda;
            color: #155724;
            border: 1px solid #a5d6a7;
        }

        .status-out-for-delivery {
            background: #e3f2fd;
            color: #1565c0;
            border: 1px solid #90caf9;
        }

        .status-delivered {
            background: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #81c784;
        }

        .status-picked-up {
            background: #f3e5f5;
            color: #6a1b9a;
            border: 1px solid #ce93d8;
        }

        .status-no-show {
            background: #fff3e0;
            color: #e65100;
            border: 1px solid #ffb74d;
        }

        .status-cancelled {
            background: #fce4ec;
            color: #b71c1c;
            border: 1px solid #ef9a9a;
        }

        /* ROW STATES */
        .orders-table tr.cancelled {
            background: #f8f9fa;
            opacity: 0.6;
        }

        .orders-table tr.cancelled td {
            color: #6c757d;
            text-decoration: line-through;
        }

        .orders-table tr.no-show {
            background: #fff8f0;
            opacity: 0.8;
        }

        .orders-table tr.no-show td {
            color: #e65100;
        }

        /* ACTION BUTTONS - REDESIGNED */
        .btn-action {
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 12px;
            transition: all 0.2s ease;
            margin-right: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-confirm {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            font-weight: 800;
        }

        .btn-confirm:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5a2a 100%);
            transform: translateY(-2px);
        }

        .btn-out-delivery {
            background: linear-gradient(135deg, #0077b6 0%, #005f99 100%);
            color: white;
        }

        .btn-out-delivery:hover {
            background: linear-gradient(135deg, #005f99 0%, #004d7a 100%);
            transform: translateY(-2px);
        }

        .btn-picked-up {
            background: linear-gradient(135deg, #6a1b9a 0%, #4a148c 100%);
            color: white;
        }

        .btn-picked-up:hover {
            background: linear-gradient(135deg, #4a148c 0%, #38006b 100%);
            transform: translateY(-2px);
        }

        /* PAGINATION STYLING */
        .pager-style {
            border-radius: 0 0 20px 20px;
            padding: 15px;
        }

        .pager-style table {
            margin: 0 auto;
        }

        .pager-style td {
            padding: 8px 12px;
        }

        .pager-style a {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 8px;
            background: rgba(255,255,255,0.2);
            transition: all 0.3s;
            font-weight: 600;
        }

        .pager-style a:hover {
            background: #f5c800;
            color: #119247;
            transform: translateY(-2px);
        }

        .pager-style span {
            color: #f5c800;
            padding: 8px 15px;
            border-radius: 8px;
            background: rgba(245,200,0,0.2);
            font-weight: 700;
        }

        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 60px 40px;
            font-size: 15px;
            border-top: 5px solid #f5c800;
            margin-top: 80px;
        }

        .footer a {
            color: #f5c800;
            text-decoration: none;
            margin: 0 15px;
            font-size: 15px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .footer a:hover {
            color: #fff;
            text-shadow: 0 2px 8px rgba(245,200,0,0.5);
        }

        .footer .footer-copy {
            margin-top: 20px;
            font-size: 14px;
            color: #ccc;
        }

        /* RESPONSIVE */
        @media (max-width: 768px) {
            .sales-container {
                padding: 16px;
            }
            
            .page-header {
                flex-direction: column;
                gap: 16px;
                align-items: flex-start;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .orders-table th,
            .orders-table td {
                padding: 12px 8px;
                font-size: 12px;
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
                <li><asp:LinkButton ID="lnkSales" runat="server" OnClick="lnkSales_Click" Text="Sales" CssClass="active"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate" runat="server" OnClick="lnkUpdate_Click" Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" OnClick="lnkProfile_Click" Text="Profile"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="sales-container">
            <!-- PAGE HEADER -->
            <div class="page-header">
                <h1>Sales Dashboard</h1>
            </div>

            <!-- STATS CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Total Users</h3>
                    <div class="stat-value"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-change">Active customers</div>
                </div>
                <div class="stat-card">
                    <h3>Total Revenue</h3>
                    <div class="stat-value">PHP <asp:Label ID="lblTotalRevenue" runat="server" Text="0.00"></asp:Label></div>
                    <div class="stat-change">All-time earnings</div>
                </div>
                <div class="stat-card">
                    <h3>Total Orders</h3>
                    <div class="stat-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-change">Orders processed</div>
                </div>
            </div>

            <!-- ORDERS SECTION -->
            <div class="orders-section">
                <div class="section-header">
                    <h2>Customer Orders</h2>
                    <div style="display: flex; align-items: center; gap: 20px;">
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <label style="font-weight: 600; color: #119247;">Filter:</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged"
                                style="padding: 10px 15px; border: 2px solid #119247; border-radius: 10px; font-weight: 600; cursor: pointer;">
                                <asp:ListItem Value="" Text="All Orders" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="Pending" Text="Pending"></asp:ListItem>
                                <asp:ListItem Value="Confirmed" Text="Confirmed"></asp:ListItem>
                                <asp:ListItem Value="Out for Delivery" Text="Out for Delivery"></asp:ListItem>
                                <asp:ListItem Value="Delivered" Text="Delivered"></asp:ListItem>
                                <asp:ListItem Value="Picked Up" Text="Picked Up"></asp:ListItem>
                                <asp:ListItem Value="No Show" Text="No Show"></asp:ListItem>
                                <asp:ListItem Value="Cancelled" Text="Cancelled"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="order-count">
                            <asp:Label ID="lblOrderCount" runat="server" Text="0"></asp:Label> orders
                        </div>
                    </div>
                </div>
                
                <div class="table-container">
                    <asp:GridView ID="gvOrders" runat="server" CssClass="orders-table" AutoGenerateColumns="False" 
                        OnRowCommand="gvOrders_RowCommand" OnRowDataBound="gvOrders_RowDataBound"
                        AllowPaging="True" PageSize="10" OnPageIndexChanging="gvOrders_PageIndexChanging">
                        <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" 
                            PageButtonCount="5" Position="Bottom" />
                        <PagerStyle BackColor="#119247" ForeColor="White" HorizontalAlign="Center" 
                            Font-Bold="True" Font-Size="14px" Height="50px" VerticalAlign="Middle" 
                            CssClass="pager-style" />
                        <Columns>
                            <asp:TemplateField HeaderText="Order ID">
                                <ItemTemplate>
                                    <div class="order-id">#PC-<%# Eval("OrderID") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Customer">
                                <ItemTemplate>
                                    <div class="customer-name"><%# Eval("CustomerName") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Type">
                                <ItemTemplate>
                                    <div class="delivery-type">
                                        <span class='<%# Eval("DeliveryType").ToString() == "Delivery" ? "delivery-badge" : "walkin-badge" %>'>
                                            <%# Eval("DeliveryType") %>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Date & Time">
                                <ItemTemplate>
                                    <div class="order-date"><%# Eval("OrderDate", "{0:MMM dd, yyyy}") %></div>
                                    <div class="order-date"><%# Eval("OrderDate", "{0:h:mm tt}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Amount">
                                <ItemTemplate>
                                    <div class="order-amount">PHP <%# Eval("TotalAmount", "{0:N2}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:Button ID="btnConfirm" runat="server" Text="Confirm" CssClass="btn-action btn-confirm" 
                                        CommandName="ConfirmOrder" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Pending" %>' />
                                    
                                    <asp:Button ID="btnOutForDelivery" runat="server" Text="Out for Delivery" CssClass="btn-action btn-out-delivery" 
                                        CommandName="OutForDelivery" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Confirmed" && Eval("DeliveryType").ToString() == "Delivery" %>' />
                                    
                                    <asp:Button ID="btnPickedUp" runat="server" Text="Picked Up" CssClass="btn-action btn-picked-up" 
                                        CommandName="MarkPickedUp" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Confirmed" && Eval("DeliveryType").ToString() == "Walk-in" %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms and Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">(c) 2026 Potato Corner. All rights reserved.</div>
        </div>

    </form>
</body>
</html>