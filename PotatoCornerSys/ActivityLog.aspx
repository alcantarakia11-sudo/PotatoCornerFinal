<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActivityLog.aspx.cs" Inherits="PotatoCornerSys.ActivityLog" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Activity Log - Potato Corner Admin</title>
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

        /* MAIN CONTAINER */
        .activity-container {
            max-width: 1400px;
            margin: 50px auto;
            padding: 0 40px;
        }

        /* PAGE HEADER */
        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .page-header h1 {
            font-size: 48px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        .page-header p {
            font-size: 16px;
            color: #6c757d;
        }

        /* FILTER SECTION */
        .filter-section {
            background: white;
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            display: flex;
            gap: 20px;
            align-items: center;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .filter-group label {
            font-size: 13px;
            font-weight: 700;
            color: #119247;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .filter-group select,
        .filter-group input {
            padding: 10px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .filter-group select:focus,
        .filter-group input:focus {
            border-color: #119247;
            outline: none;
            box-shadow: 0 0 0 3px rgba(17,146,71,0.1);
        }

        .btn-filter {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 20px;
        }

        .btn-filter:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(17,146,71,0.4);
        }

        .btn-clear {
            background: #e8e8e8;
            color: #666;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 20px;
        }

        .btn-clear:hover {
            background: #d0d0d0;
        }

        /* ACTIVITY LOG SECTION */
        .log-section {
            background: white;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 3px solid #f5c800;
        }

        .section-header h2 {
            font-size: 28px;
            color: #e8401c;
            font-weight: 900;
            text-transform: uppercase;
        }

        .log-count {
            background: #e8401c;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
        }

        /* ACTIVITY TABLE */
        .activity-table {
            width: 100%;
            border-collapse: collapse;
        }

        .activity-table th {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 13px;
            letter-spacing: 0.5px;
        }

        .activity-table td {
            padding: 16px 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 14px;
        }

        .activity-table tbody tr {
            transition: all 0.2s ease;
        }

        .activity-table tbody tr:hover {
            background: #f8f9fa;
        }

        /* SEVERITY BADGES */
        .severity-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .severity-badge::before {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
        }

        .severity-info {
            background: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }

        .severity-warning {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .severity-critical {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        /* ACTIVITY TYPE BADGES */
        .activity-type {
            font-weight: 700;
            color: #119247;
            font-size: 13px;
        }

        /* TIMESTAMP */
        .timestamp {
            color: #6c757d;
            font-size: 13px;
            font-family: monospace;
        }

        /* PAGINATION */
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="navbar">
            <div class="navbar-logo">
                <img src="logopotcor.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><asp:LinkButton ID="lnkSales" runat="server" OnClick="lnkSales_Click" Text="Sales"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate" runat="server" OnClick="lnkUpdate_Click" Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkActivityLog" runat="server" OnClick="lnkActivityLog_Click" Text="Activity Log" CssClass="active"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" OnClick="lnkProfile_Click" Text="Profile"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="activity-container">
            <!-- PAGE HEADER -->
            <div class="page-header">
                <h1>Activity Log</h1>
                <p>Monitor all system activities and admin actions</p>
            </div>

            <!-- FILTER SECTION -->
            <div class="filter-section">
                <div class="filter-group">
                    <label>Activity Type</label>
                    <asp:DropDownList ID="ddlActivityType" runat="server">
                        <asp:ListItem Value="" Text="All Activities" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="Order Status Change" Text="Order Status Change"></asp:ListItem>
                        <asp:ListItem Value="User Registration" Text="User Registration"></asp:ListItem>
                        <asp:ListItem Value="Admin Action" Text="Admin Action"></asp:ListItem>
                        <asp:ListItem Value="Payment Verification" Text="Payment Verification"></asp:ListItem>
                        <asp:ListItem Value="Stock Update" Text="Stock Update"></asp:ListItem>
                        <asp:ListItem Value="System" Text="System"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Severity</label>
                    <asp:DropDownList ID="ddlSeverity" runat="server">
                        <asp:ListItem Value="" Text="All Levels" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="Info" Text="Info"></asp:ListItem>
                        <asp:ListItem Value="Warning" Text="Warning"></asp:ListItem>
                        <asp:ListItem Value="Critical" Text="Critical"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Date From</label>
                    <asp:TextBox ID="txtDateFrom" runat="server" TextMode="Date"></asp:TextBox>
                </div>

                <div class="filter-group">
                    <label>Date To</label>
                    <asp:TextBox ID="txtDateTo" runat="server" TextMode="Date"></asp:TextBox>
                </div>

                <div class="filter-group">
                    <asp:Button ID="btnFilter" runat="server" Text="Apply Filter" CssClass="btn-filter" OnClick="btnFilter_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn-clear" OnClick="btnClear_Click" />
                </div>
            </div>

            <!-- ACTIVITY LOG SECTION -->
            <div class="log-section">
                <div class="section-header">
                    <h2>Activity Logs</h2>
                    <div class="log-count">
                        <asp:Label ID="lblLogCount" runat="server" Text="0"></asp:Label> logs
                    </div>
                </div>

                <asp:GridView ID="gvActivityLog" runat="server" CssClass="activity-table" AutoGenerateColumns="False"
                    AllowPaging="True" PageSize="20" OnPageIndexChanging="gvActivityLog_PageIndexChanging"
                    OnRowDataBound="gvActivityLog_RowDataBound">
                    <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" 
                        PageButtonCount="5" Position="Bottom" />
                    <PagerStyle BackColor="#119247" ForeColor="White" HorizontalAlign="Center" 
                        Font-Bold="True" Font-Size="14px" Height="50px" VerticalAlign="Middle" 
                        CssClass="pager-style" />
                    <Columns>
                        <asp:TemplateField HeaderText="Timestamp">
                            <ItemTemplate>
                                <div class="timestamp"><%# Eval("Timestamp", "{0:MMM dd, yyyy HH:mm:ss}") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Activity Type">
                            <ItemTemplate>
                                <div class="activity-type"><%# Eval("ActivityType") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Description">
                            <ItemTemplate>
                                <%# Eval("ActivityDescription") %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Performed By">
                            <ItemTemplate>
                                <strong><%# Eval("PerformedBy") %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Target">
                            <ItemTemplate>
                                <%# Eval("TargetEntity") %>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Severity">
                            <ItemTemplate>
                                <asp:Label ID="lblSeverity" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
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
