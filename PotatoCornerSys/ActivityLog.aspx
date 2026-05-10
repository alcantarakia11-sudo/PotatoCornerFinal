<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActivityLog.aspx.cs" Inherits="PotatoCornerSys.ActivityLog" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Activity Log - Potato Corner Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;700;800&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css" />
    <style type="text/css">
        :root {
            --primary-green: #119247;
            --primary-dark:  #0d7336;
            --accent-yellow: #f5c800;
            --accent-red:    #e8401c;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f4f6f4;
            color: #2c3e50;
            line-height: 1.5;
        }

        /* ── NAVBAR ── */
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

        .navbar-links a,
        .navbar-links .nav-link {
            color: white;
            text-decoration: none;
            font-size: 16px;
            font-weight: 700;
            letter-spacing: 0.5px;
            transition: all 0.3s;
            position: relative;
            background: none;
            border: none;
            cursor: pointer;
            padding: 0;
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
        }

        .navbar-links a:hover,
        .navbar-links .nav-link:hover {
            color: #f5c800;
            transform: translateY(-2px);
        }

        .navbar-links a::after,
        .navbar-links .nav-link::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 0;
            width: 0;
            height: 3px;
            background: #f5c800;
            transition: width 0.3s;
        }

        .navbar-links a:hover::after,
        .navbar-links .nav-link:hover::after {
            width: 100%;
        }

        .navbar-links .active {
            color: #f5c800 !important;
        }

        .navbar-links .active::after {
            width: 100%;
        }

        /* ── PAGE BODY ── */
        .page-body {
            max-width: 1300px;
            margin: 0 auto;
            padding: 24px 28px;
        }

        .page-title {
            text-align: center;
            margin-bottom: 20px;
        }

        .page-title h1 {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            font-size: 48px; font-weight: 900;
            color: #119247;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        .page-title p {
            font-size: 12px;
            color: #6c757d;
        }

        /* ── FILTER BAR ── */
        .filter-bar {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 12px;
            padding: 12px 16px;
            margin-bottom: 16px;
            display: flex;
            gap: 10px;
            align-items: flex-end;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .filter-group label {
            font-size: 10px;
            font-weight: 700;
            color: #119247;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .filter-group select,
        .filter-group input[type="text"],
        .filter-group input[type="date"] {
            font-family: 'DM Sans', sans-serif;
            font-size: 12px; font-weight: 500;
            padding: 6px 10px;
            border: 1px solid #d0d0d0;
            border-radius: 8px;
            background: #f8f9fa;
            color: #2c3e50;
            transition: border-color 0.2s;
        }

        .filter-group select:focus,
        .filter-group input:focus {
            border-color: #119247;
            outline: none;
            box-shadow: 0 0 0 2px rgba(17,146,71,0.1);
        }

        .search-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }

        .search-wrap i {
            position: absolute;
            left: 8px;
            font-size: 13px;
            color: #888;
            pointer-events: none;
        }

        .search-input {
            padding-left: 26px !important;
            width: 160px;
        }

        .btn-filter {
            font-family: ''Segoe UI', Tahoma, sans-serif;
            font-size: 11px; font-weight: 700;
            padding: 7px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: opacity 0.2s, transform 0.15s;
            align-self: flex-end;
        }

        .btn-filter:hover { opacity: 0.88; transform: translateY(-1px); }

        .btn-apply { background: #119247; color: white; }
        .btn-clear { background: #e8e8e8; color: #555; border: 1px solid #d0d0d0; }

        /* ── LOG CARD ── */
        .log-card {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 12px;
            overflow: hidden;
        }

        .log-card-header {
            padding: 12px 18px;
            border-bottom: 3px solid #f5c800;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .log-card-header h2 {
            font-family: ''Segoe UI', Tahoma, sans-serif;
            font-size: 14px; font-weight: 800;
            color: #e8401c;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .log-count-badge {
            background: #e8401c;
            color: white;
            font-size: 11px; font-weight: 700;
            padding: 3px 12px;
            border-radius: 20px;
        }

        /* ── TABLE ── */
        .activity-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .activity-table th {
            background: #e8401c;
            color: white;
            font-size: 10px; font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 10px 12px;
            text-align: left;
        }

        .activity-table th:nth-child(1) { width: 8%;  }
        .activity-table th:nth-child(2) { width: 12%; }
        .activity-table th:nth-child(3) { width: 9%;  }
        .activity-table th:nth-child(4) { width: 17%; }
        .activity-table th:nth-child(5) { width: 36%; }
        .activity-table th:nth-child(6) { width: 18%; }

        .activity-table td {
            padding: 10px 12px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 12px;
            vertical-align: middle;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .activity-table tbody tr:hover { background: #f8f9fa; }
        .activity-table tbody tr:last-child td { border-bottom: none; }

        /* Time */
        .col-time {
            font-size: 12px;
            font-weight: 600;
            color: #2c3e50;
            white-space: nowrap;
        }

        /* User ID */
        .col-userid {
            font-size: 11px;
            font-weight: 600;
            font-family: 'Courier New', monospace;
            color: #2c3e50;
        }

        /* Role badges */
        .role-badge {
            font-size: 10px; font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
            display: inline-block;
            white-space: nowrap;
        }

        .role-admin    { background: #e1f5ee; color: #0d7336; border: 1px solid #9FE1CB; }
        .role-customer { background: #e6f1fb; color: #185FA5; border: 1px solid #B5D4F4; }
        .role-staff    { background: #fff3cd; color: #856404; border: 1px solid #ffc107; }

        /* Action cell */
        .col-action {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
            font-weight: 500;
            color: #2c3e50;
            white-space: nowrap;
            overflow: hidden;
        }

        .col-action i {
            font-size: 14px;
            flex-shrink: 0;
        }

        .act-login    { color: #119247; }
        .act-logout   { color: #856404; }
        .act-create   { color: #185FA5; }
        .act-edit     { color: #854F0B; }
        .act-delete   { color: #721c24; }
        .act-message  { color: #553098; }
        .act-upload   { color: #0c5460; }
        .act-settings { color: #3B6D11; }
        .act-cart     { color: #185FA5; }
        .act-order    { color: #119247; }
        .act-view     { color: #5F5E5A; }

        /* Details */
        .col-details {
            font-size: 12px;
            color: #2c3e50;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        /* Device / IP */
        .col-device {
            font-size: 11px;
            color: #6c757d;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .col-device strong {
            color: #2c3e50;
            font-weight: 600;
        }

        /* Pager */
        .pager-style { border-radius: 0 0 12px 12px; padding: 12px; background: #f8f9fa; }
        .pager-style table { margin: 0 auto; }
        .pager-style td { padding: 4px 6px; }

        .pager-style a {
            color: #119247;
            text-decoration: none;
            padding: 5px 12px;
            border-radius: 6px;
            background: white;
            border: 1px solid #d0d0d0;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.2s;
        }

        .pager-style a:hover {
            background: #119247;
            color: white;
            border-color: #119247;
        }

        .pager-style span {
            background: #119247;
            color: white;
            padding: 5px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
        }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 32px;
            color: #6c757d;
            font-size: 13px;
        }

        /* ── FOOTER ── */
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

        .footer-copy {
            margin-top: 20px;
            font-size: 14px;
            color: #ccc;
        }
        /* RESPONSIVE */
        @media (max-width: 768px) {
            .navbar {
                padding: 14px 18px;
                flex-wrap: wrap;
                gap: 12px;
            }

            .navbar-logo img {
                height: 60px;
            }

            .navbar-links {
                gap: 18px;
                width: 100%;
                justify-content: center;
            }

            .page-body {
                padding: 16px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- NAVBAR -->
        <div class="navbar">
            <div class="navbar-logo">
                <img src="potato.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><asp:LinkButton ID="lnkHome"        runat="server" OnClick="lnkHome_Click"        Text="Home"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkSales"       runat="server" OnClick="lnkSales_Click"       Text="Sales"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate"      runat="server" OnClick="lnkUpdate_Click"      Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkActivityLog" runat="server" OnClick="lnkActivityLog_Click" Text="Activity Log" CssClass="active"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile"     runat="server" OnClick="lnkProfile_Click"     Text="Profile"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="page-body">

            <!-- PAGE TITLE -->
            <div class="page-title">
                <h1>Activity Log</h1>
                <p>Monitor all system activities and admin actions</p>
            </div>

            <!-- FILTER BAR -->
            <div class="filter-bar">

                <div class="filter-group">
                    <label>Search</label>
                    <div class="search-wrap">
                        <i class="ti ti-search"></i>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input"
                            placeholder="User ID, action…" AutoPostBack="false"></asp:TextBox>
                    </div>
                </div>

                <div class="filter-group">
                    <label>Action</label>
                    <asp:DropDownList ID="ddlActionType" runat="server">
                        <asp:ListItem Value=""         Text="All Actions"       Selected="True"></asp:ListItem>
                        <asp:ListItem Value="login"    Text="Logged In"></asp:ListItem>
                        <asp:ListItem Value="logout"   Text="Logged Out"></asp:ListItem>
                        <asp:ListItem Value="create"   Text="Data Created"></asp:ListItem>
                        <asp:ListItem Value="edit"     Text="Data Edited"></asp:ListItem>
                        <asp:ListItem Value="delete"   Text="Data Deleted"></asp:ListItem>
                        <asp:ListItem Value="message"  Text="Message Sent"></asp:ListItem>
                        <asp:ListItem Value="upload"   Text="File Uploaded"></asp:ListItem>
                        <asp:ListItem Value="settings" Text="Settings Changed"></asp:ListItem>
                        <asp:ListItem Value="cart"     Text="Cart Updated"></asp:ListItem>
                        <asp:ListItem Value="order"    Text="Order Placed"></asp:ListItem>
                        <asp:ListItem Value="view"     Text="Menu Viewed"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="filter-group">
                    <label>Role</label>
                    <asp:DropDownList ID="ddlRole" runat="server">
                        <asp:ListItem Value=""         Text="All Roles"  Selected="True"></asp:ListItem>
                        <asp:ListItem Value="Admin"    Text="Admin"></asp:ListItem>
                        <asp:ListItem Value="Staff"    Text="Staff"></asp:ListItem>
                        <asp:ListItem Value="Customer" Text="Customer"></asp:ListItem>
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

                <asp:Button ID="btnFilter" runat="server" Text="Apply Filter"
                    CssClass="btn-filter btn-apply" OnClick="btnFilter_Click" />
                <asp:Button ID="btnClear"  runat="server" Text="Clear"
                    CssClass="btn-filter btn-clear"  OnClick="btnClear_Click" />

            </div>

            <!-- LOG CARD -->
            <div class="log-card">
                <div class="log-card-header">
                    <h2>Activity Logs</h2>
                    <span class="log-count-badge">
                        <asp:Label ID="lblLogCount" runat="server" Text="0"></asp:Label> logs
                    </span>
                </div>

                <asp:GridView ID="gvActivityLog" runat="server"
                    CssClass="activity-table"
                    AutoGenerateColumns="False"
                    AllowPaging="True"
                    PageSize="20"
                    EmptyDataText=""
                    OnPageIndexChanging="gvActivityLog_PageIndexChanging"
                    OnRowDataBound="gvActivityLog_RowDataBound">

                    <EmptyDataTemplate>
                        <div class="empty-state">No activities match the selected filters.</div>
                    </EmptyDataTemplate>

                    <PagerSettings Mode="NumericFirstLast"
                        FirstPageText="First" LastPageText="Last"
                        PageButtonCount="5" Position="Bottom" />
                    <PagerStyle CssClass="pager-style"
                        HorizontalAlign="Center"
                        Font-Bold="True" Font-Size="12px"
                        Height="44px" VerticalAlign="Middle" />

                    <Columns>

                        <asp:TemplateField HeaderText="Time">
                            <ItemTemplate>
                                <span class="col-time">
                                    <%# Eval("Timestamp", "{0:hh:mm tt}") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        
                        <asp:TemplateField HeaderText="User ID">
                            <ItemTemplate>
                                <span class="col-userid"><%# Eval("UserID") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                       
                        <asp:TemplateField HeaderText="Role">
                            <ItemTemplate>
                                <asp:Label ID="lblRole" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Label ID="lblAction" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                        
                        <asp:TemplateField HeaderText="Details">
                            <ItemTemplate>
                                <span class="col-details" title="<%# Eval("ActivityDescription") %>">
                                    <%# Eval("ActivityDescription") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                    
                        <asp:TemplateField HeaderText="Device / IP">
                            <ItemTemplate>
                                <asp:Label ID="lblDevice" runat="server"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </div>

        </div>


        <div class="footer">
            <div>
                <a href="#">Terms and Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">&copy; 2026 Potato Corner. All rights reserved.</div>
        </div>

    </form>
</body>
</html>
