<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="PotatoCorner.AdminDashboard" %>
<%@ Import Namespace="System.Data" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Potato Corner Argao — Admin Dashboard</title>
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Fredoka+One&display=swap" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
  <style>
    :root {
      --green-dark:   #1a5c2a;
      --green-main:   #2d7a3a;
      --green-mid:    #3a9448;
      --green-light:  #e8f5ea;
      --yellow-main:  #f5c800;
      --yellow-deep:  #e0a800;
      --orange-main:  #e84c1e;
      --orange-light: #fff0eb;
      --white:        #ffffff;
      --gray-bg:      #f3f4f2;
      --gray-border:  #d9e4d9;
      --gray-text:    #5a6a5a;
      --red-alert:    #d32f2f;
      --red-light:    #fdecea;
      --sidebar-w:    240px;
      --radius:       14px;
      --shadow:       0 4px 20px rgba(0,0,0,0.08);
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      background: var(--gray-bg);
      color: #1e2e1e;
      min-height: 100vh;
      display: flex;
      width: 100%;
      overflow-x: hidden;
    }

    /* ── SIDEBAR ── */
    .sidebar {
      width: var(--sidebar-w);
      background: var(--green-dark);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      position: fixed;
      top: 0; left: 0;
      z-index: 100;
      box-shadow: 4px 0 24px rgba(0,0,0,0.15);
    }
    .sidebar-brand {
      padding: 16px 20px;
      border-bottom: 2px solid rgba(245,200,0,0.25);
      text-align: center;
    }
    .sidebar-brand .brand-title {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      color: var(--yellow-main);
      font-size: 1.45rem;
      line-height: 1.1;
    }
    .sidebar-brand .brand-sub {
      font-size: 0.7rem;
      color: rgba(255,255,255,0.55);
      letter-spacing: 1.5px;
      text-transform: uppercase;
      margin-top: 2px;
    }
    .sidebar-brand .admin-badge {
      display: inline-block;
      margin-top: 8px;
      background: var(--orange-main);
      color: #fff;
      font-size: 0.62rem;
      font-weight: 800;
      letter-spacing: 1px;
      text-transform: uppercase;
      padding: 3px 10px;
      border-radius: 20px;
    }
    .sidebar-nav { padding: 20px 0; flex: 1; }
    .nav-section-label {
      font-size: 0.6rem;
      font-weight: 800;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: rgba(245,200,0,0.5);
      padding: 10px 22px 6px;
    }
    .nav-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 11px 22px;
      color: rgba(255,255,255,0.72);
      font-size: 0.88rem;
      font-weight: 600;
      cursor: pointer;
      text-decoration: none;
      border-left: 3px solid transparent;
      transition: all 0.2s;
    }
    .nav-item:hover { background: rgba(245,200,0,0.08); color: var(--yellow-main); border-left-color: var(--yellow-main); }
    .nav-item.active { background: rgba(245,200,0,0.13); color: var(--yellow-main); border-left-color: var(--yellow-main); }
    .nav-item i { width: 18px; text-align: center; font-size: 0.95rem; }
    .sidebar-footer { padding: 16px 20px; border-top: 1px solid rgba(255,255,255,0.1); }
    .admin-user { display: flex; align-items: center; gap: 10px; }
    .admin-avatar {
      width: 36px; height: 36px;
      background: var(--yellow-main);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-family: 'Segoe UI', Tahoma, sans-serif;
      color: var(--green-dark);
      font-size: 1rem;
    }
    .admin-info .admin-name { color: #fff; font-size: 0.82rem; font-weight: 700; }
    .admin-info .admin-role { color: rgba(255,255,255,0.45); font-size: 0.68rem; text-transform: uppercase; letter-spacing: 1px; }

    /* ── MAIN ── */
    .main-wrap {
      margin-left: var(--sidebar-w);
      flex: 1;
      display: flex;
      flex-direction: column;
      min-width: 0;
      overflow-x: hidden;
    }

    /* ── TOPBAR ── */
    .topbar {
      background: #e84c1e;
      border-bottom: 3px solid var(--yellow-main);
      padding: 50px 32px;
      height: 66px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky; top: 0; z-index: 50;
      box-shadow: 0 2px 12px rgba(0,0,0,0.07);
      width: 100%;
    }
    .topbar-left h1 {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      font-size: 1.3rem;
      color: white;
    }
    .topbar-left .topbar-date { font-size: 0.72rem; color: #f5c800; font-weight: 600; }
    .topbar-right { display: flex; align-items: center; gap: 16px; }
    .topbar-btn {
      width: 38px; height: 38px;
      border: none;
      background: var(--green-light);
      color: var(--green-main);
      border-radius: 10px;
      cursor: pointer;
      font-size: 1rem;
      display: flex; align-items: center; justify-content: center;
      transition: all 0.2s;
      position: relative;
    }
    .topbar-btn:hover { background: var(--green-main); color: #fff; }
    .notif-dot {
      position: absolute; top: 6px; right: 6px;
      width: 8px; height: 8px;
      background: var(--orange-main);
      border-radius: 50%;
      border: 2px solid #fff;
    }
    .refresh-btn {
      display: flex; align-items: center; gap: 8px;
      background: var(--green-main);
      color: #fff; border: none;
      border-radius: 10px;
      padding: 8px 16px;
      font-family: 'Segoe UI', Tahoma, sans-serif;
      font-size: 0.8rem; font-weight: 700;
      cursor: pointer; transition: all 0.2s;
    }
    .refresh-btn:hover { background: var(--green-dark); }

    /* ── CONTENT ── */
    .content { padding: 28px 32px; display: flex; flex-direction: column; gap: 28px; width: 100%; }

    /* ── SUMMARY CARDS ── */
    .cards-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; width: 100%; }
    .summary-card {
      background: var(--white);
      border-radius: var(--radius);
      padding: 22px 22px 18px;
      box-shadow: var(--shadow);
      border-top: 5px solid var(--green-main);
      position: relative; overflow: hidden;
      transition: transform 0.2s, box-shadow 0.2s;
    }
    .summary-card:hover { transform: translateY(-3px); box-shadow: 0 8px 30px rgba(0,0,0,0.12); }
    .summary-card::after {
      content: ''; position: absolute;
      bottom: -18px; right: -18px;
      width: 72px; height: 72px;
      border-radius: 50%; opacity: 0.07;
    }
    .card-orders  { border-top-color: var(--green-main); }
    .card-orders::after  { background: var(--green-main); }
    .card-sales   { border-top-color: var(--yellow-deep); }
    .card-sales::after   { background: var(--yellow-deep); }
    .card-pending { border-top-color: var(--orange-main); }
    .card-pending::after { background: var(--orange-main); }
    .card-pickup  { border-top-color:  #1a5c2a; }
    .card-pickup::after  { background: #1976d2; }
    .card-icon {
      width: 44px; height: 44px; border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.2rem; margin-bottom: 14px;
    }
    .card-orders .card-icon  { background: var(--green-light); color: var(--green-main); }
    .card-sales .card-icon   { background: #fffbea; color: var(--yellow-deep); }
    .card-pending .card-icon { background: var(--orange-light); color: var(--orange-main); }
    .card-pickup .card-icon  { background: #e3f0fb; color: #1976d2; }
    .card-label {
      font-size: 0.72rem; font-weight: 800;
      letter-spacing: 1.2px; text-transform: uppercase;
      color: var(--gray-text); margin-bottom: 4px;
    }
    .card-value {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      font-size: 2rem; line-height: 1;
      color: var(--green-dark);
    }
    .card-sales .card-value   { color: var(--yellow-deep); }
    .card-pending .card-value { color: var(--orange-main); }
    .card-pickup .card-value  { color:  #1a5c2a; }
    .card-trend {
      margin-top: 8px; font-size: 0.72rem; font-weight: 700;
      display: flex; align-items: center; gap: 4px;
    }
    .trend-up   { color: var(--green-mid); }
    .trend-warn { color: var(--orange-main); }

    /* ── PANEL ── */
    .panel { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden; display: flex; flex-direction: column; width: 100%; }
    .panel-header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 16px 22px;
      border-bottom: 2px solid var(--gray-border);
      background: linear-gradient(135deg, var(--green-dark) 0%, var(--green-main) 100%);
      flex-shrink: 0;
    }
    .panel-title {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      font-size: 1rem; color: var(--white);
      display: flex; align-items: center; gap: 10px;
    }
    .panel-title i { color: var(--yellow-main); }
    .panel-badge {
      font-size: 0.65rem; font-weight: 800;
      background: var(--yellow-main); color: var(--green-dark);
      padding: 3px 10px; border-radius: 20px;
      letter-spacing: 0.5px; text-transform: uppercase;
    }
    .panel-body { padding: 0; flex: 1; display: flex; flex-direction: column; }

    /* ── ORDERS TABLE ── */
    .orders-table { width: 100%; border-collapse: collapse; }
    .orders-table thead th {
      background: var(--green-light); color: var(--green-dark);
      font-size: 0.7rem; font-weight: 800;
      letter-spacing: 1.2px; text-transform: uppercase;
      padding: 11px 18px; text-align: left;
      border-bottom: 2px solid var(--gray-border);
    }
    .orders-table tbody tr { border-bottom: 1px solid var(--gray-border); transition: background 0.15s; }
    .orders-table tbody tr:hover { background: var(--green-light); }
    .orders-table tbody td { padding: 10px 18px; font-size: 0.83rem; font-weight: 600; color: #2a3a2a; }
    .order-id { font-family: 'Segoe UI', Tahoma, sans-serif; color: var(--green-main); font-size: 0.92rem; }
    .customer-cell { display: flex; align-items: center; gap: 9px; }
    .cust-dot {
      width: 28px; height: 28px; border-radius: 50%;
      background: var(--green-main); color: #fff;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.7rem; font-weight: 800; flex-shrink: 0;
    }
    .status-badge {
      display: inline-block; padding: 4px 12px;
      border-radius: 20px; font-size: 0.68rem;
      font-weight: 800; letter-spacing: 0.5px;
    }
    .status-Preparing   { background: #fff8e1; color: #f57f17; }
    .status-Ready       { background: var(--green-light); color: var(--green-dark); }
    .status-Pending     { background: var(--orange-light); color: var(--orange-main); }
    .status-Done,
    .status-Completed   { background: #e8f5e9; color: #2e7d32; }
    .status-Delivered   { background: #e8f5e9; color: #2e7d32; }
    .status-Cancelled   { background: #fdecea; color: var(--red-alert); }
    .status-Confirmed   { background: #e3f0fb; color: #1565c0; }
    .status-WalkIn      { background: #f3e5f5; color: #6a1b9a; }

    #form1 {
      display: flex;
      width: 100%;
      min-height: 100vh;
    }

    .view-all-link {
      display: block; text-align: center; padding: 13px;
      font-size: 0.78rem; font-weight: 800;
      color: var(--green-main); text-decoration: none;
      border-top: 1px solid var(--gray-border);
      background: var(--green-light);
      letter-spacing: 0.5px; text-transform: uppercase;
      transition: background 0.2s;
      margin-top: auto;
    }
    .view-all-link:hover { background: var(--green-main); color: #fff; }

    /* ── LOW STOCK ── */
    .stock-list { padding: 8px 0; flex: 1; min-height: 80px; }
    .stock-item {
      display: flex; align-items: center;
      justify-content: space-between;
      padding: 13px 20px;
      border-bottom: 1px solid var(--gray-border);
      transition: background 0.15s;
    }
    .stock-item:hover { background: var(--gray-bg); }
    .stock-item:last-child { border-bottom: none; }
    .stock-left { display: flex; align-items: center; gap: 10px; }
    .stock-icon {
      width: 34px; height: 34px; border-radius: 10px;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.85rem;
    }
    .stock-icon.critical { background: #fdecea; color: var(--red-alert); }
    .stock-icon.low      { background: #fff3e0; color: #e65100; }
    .stock-name { font-size: 0.83rem; font-weight: 700; color: #1e2e1e; }
    .stock-qty  { font-size: 0.7rem; color: var(--gray-text); font-weight: 600; }
    .stock-level {
      display: inline-block; padding: 4px 12px;
      border-radius: 20px; font-size: 0.65rem;
      font-weight: 800; letter-spacing: 0.5px;
      text-transform: uppercase; white-space: nowrap;
    }
    .level-critical { background: var(--red-light); color: var(--red-alert); }
    .level-low      { background: #fff3e0; color: #e65100; }
    .no-alerts {
      padding: 32px 20px; text-align: center;
      color: var(--green-main); font-size: 0.85rem; font-weight: 700;
    }

    /* ── CHART ── */
    .chart-tabs { display: flex; padding: 14px 20px 0; }
    .chart-tab {
      padding: 7px 18px; font-size: 0.75rem; font-weight: 800;
      border: 2px solid var(--gray-border);
      background: transparent; color: var(--gray-text);
      cursor: pointer; letter-spacing: 0.5px;
      text-transform: uppercase; transition: all 0.2s;
    }
    .chart-tab:first-child { border-radius: 8px 0 0 8px; }
    .chart-tab:last-child  { border-radius: 0 8px 8px 0; border-left: none; }
    .chart-tab.active { background: var(--green-main); border-color: var(--green-main); color: #fff; }
    .chart-wrap { padding: 16px 20px 20px; flex: 1; }

    /* ── ACTIVITY LOG ── */
    .activity-list { padding: 6px 0; flex: 1; overflow-y: auto; max-height: 420px; }
    .activity-item {
      display: flex; align-items: flex-start; gap: 12px;
      padding: 13px 20px;
      border-bottom: 1px solid var(--gray-border);
      transition: background 0.15s;
    }
    .activity-item:hover { background: var(--gray-bg); }
    .activity-item:last-child { border-bottom: none; }
    .activity-dot {
      width: 32px; height: 32px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      font-size: 0.75rem; flex-shrink: 0; margin-top: 1px;
    }
    .dot-green  { background: var(--green-light); color: var(--green-main); }
    .dot-yellow { background: #fffbea; color: var(--yellow-deep); }
    .dot-orange { background: var(--orange-light); color: var(--orange-main); }
    .dot-blue   { background: #e3f0fb; color: #1976d2; }
    .activity-text { font-size: 0.82rem; font-weight: 600; color: #2a3a2a; line-height: 1.4; }
    .activity-time { font-size: 0.67rem; color: var(--gray-text); font-weight: 700; margin-top: 3px; }

    /* ── FOOTER ── */
    .dashboard-footer {
      padding: 16px 32px; text-align: center;
      font-size: 0.7rem; color: var(--gray-text);
      font-weight: 700; border-top: 2px solid var(--gray-border);
      background: var(--white); letter-spacing: 0.5px;
      width: 100%;
    }
    .dashboard-footer span { color: var(--green-main); }


    /* ── ANIMATIONS ── */
    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(16px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .summary-card { animation: fadeUp 0.4s ease both; }
    .summary-card:nth-child(1) { animation-delay: 0.05s; }
    .summary-card:nth-child(2) { animation-delay: 0.10s; }
    .summary-card:nth-child(3) { animation-delay: 0.15s; }
    .summary-card:nth-child(4) { animation-delay: 0.20s; }
    .panel { animation: fadeUp 0.5s ease 0.2s both; }
  </style>
</head>
<body>
<form id="form1" runat="server">

  <%-- Hidden fields carry JSON chart data from code-behind to JS --%>
  <asp:HiddenField ID="hfDailyData"  runat="server" />
  <asp:HiddenField ID="hfWeeklyData" runat="server" />

  <!-- ════════ SIDEBAR ════════ -->
  <aside class="sidebar">
    <div class="sidebar-brand">
        <img src="potato.png" alt="Potato Corner" style="width: 100%; max-width: 180px; display: block; margin: 0 auto 8px;" />
        <span class="admin-badge">Admin Panel</span>
    </div>
    <nav class="sidebar-nav">
      <div class="nav-section-label">Main</div>
      <a class="nav-item active" href="AdminDashboard.aspx">
        <i class="fa-solid fa-gauge-high"></i> Dashboard
      </a>
      <div class="nav-section-label" style="margin-top:12px;">Management</div>
      <a class="nav-item" href="Orders.aspx">
        <i class="fa-solid fa-bag-shopping"></i> Orders
      </a>
      <a class="nav-item" href="Sale.aspx">
        <i class="fa-solid fa-chart-line"></i> Sales
      </a>
      <a class="nav-item" href="Stock.aspx">
        <i class="fa-solid fa-boxes-stacked"></i> Stock
      </a>
      <a class="nav-item" href="ActivityLog.aspx">
        <i class="fa-solid fa-scroll"></i> Activity Logs
      </a>
      <div class="nav-section-label" style="margin-top:12px;">Account</div>
      <a class="nav-item" href="Profile.aspx">
        <i class="fa-solid fa-circle-user"></i> Profile
      </a>
      <a class="nav-item" href="Logout.aspx">
        <i class="fa-solid fa-right-from-bracket"></i> Logout
      </a>
    </nav>
    <div class="sidebar-footer">
      <div class="admin-user">
        <div class="admin-avatar">
          <%= Session["AdminName"] != null
                ? Server.HtmlEncode(Session["AdminName"].ToString().Substring(0,1).ToUpper())
                : "A" %>
        </div>
        <div class="admin-info">
          <div class="admin-name">
            <%= Session["AdminName"] != null
                  ? Server.HtmlEncode(Session["AdminName"].ToString())
                  : "Admin" %>
          </div>
          <div class="admin-role">
            <%= Session["AdminRole"] != null
                  ? Server.HtmlEncode(Session["AdminRole"].ToString())
                  : "Admin" %>
          </div>
        </div>
      </div>
    </div>
  </aside>

  <!-- ════════ MAIN ════════ -->
  <div class="main-wrap">

    <!-- TOPBAR -->
    <div class="topbar">
      <div class="topbar-left">
        <h1>📊 Dashboard Overview</h1>
        <div class="topbar-date" id="live-date">Loading...</div>
      </div>
      <div class="topbar-right">
        <button type="button" class="topbar-btn" title="Notifications">
          <i class="fa-solid fa-bell"></i>
          <span class="notif-dot"></span>
        </button>
        <asp:Button ID="btnRefresh" runat="server"
                    CssClass="refresh-btn"
                    OnClick="btnRefresh_Click"
                    Text="↻ Refresh" />
      </div>
    </div>

    <!-- CONTENT -->
    <div class="content">

      <!-- ═══ 1. SUMMARY CARDS ═══ -->
      <div class="cards-grid">

        <div class="summary-card card-orders">
          <div class="card-icon"><i class="fa-solid fa-receipt"></i></div>
          <div class="card-label">Orders Today</div>
          <div class="card-value">
            <asp:Label ID="lblOrdersToday" runat="server" Text="0" />
          </div>
          <div class="card-trend trend-up">
            <i class="fa-solid fa-arrow-trend-up"></i>
            <asp:Label ID="lblOrdersTrend" runat="server" Text="Loading..." />
          </div>
        </div>

        <div class="summary-card card-sales">
          <div class="card-icon"><i class="fa-solid fa-peso-sign"></i></div>
          <div class="card-label">Sales Today</div>
          <div class="card-value">
            <asp:Label ID="lblSalesToday" runat="server" Text="₱0" />
          </div>
          <div class="card-trend trend-up">
            <i class="fa-solid fa-arrow-trend-up"></i> From completed orders
          </div>
        </div>

        <div class="summary-card card-pending">
          <div class="card-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
          <div class="card-label">Pending Orders</div>
          <div class="card-value">
            <asp:Label ID="lblPendingOrders" runat="server" Text="0" />
          </div>
          <div class="card-trend trend-warn">
            <i class="fa-solid fa-triangle-exclamation"></i> Needs attention
          </div>
        </div>

        <div class="summary-card card-pickup">
          <div class="card-icon"><i class="fa-solid fa-hand-holding-box"></i></div>
          <div class="card-label">Ready for Pick-up</div>
          <div class="card-value">
            <asp:Label ID="lblReadyPickup" runat="server" Text="0" />
          </div>
          <div class="card-trend trend-up">
            <i class="fa-solid fa-check"></i> Awaiting customers
          </div>
        </div>

      </div>

      <!-- ═══ 2. RECENT ORDERS ═══ -->
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">
            <i class="fa-solid fa-clipboard-list"></i> Recent Orders
          </div>
          <span class="panel-badge">Live</span>
        </div>
        <div class="panel-body">
          <asp:GridView ID="gvRecentOrders" runat="server"
                        AutoGenerateColumns="false"
                        CssClass="orders-table"
                        GridLines="None"
                        ShowHeaderWhenEmpty="true"
                        EmptyDataText="No orders found.">
            <Columns>

              <asp:TemplateField HeaderText="Order ID">
                <ItemTemplate>
                  <span class="order-id">#<%# Eval("OrderID") %></span>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Customer">
                <ItemTemplate>
                  <div class="customer-cell">
                    <div class="cust-dot">
                      <%# !string.IsNullOrEmpty(Eval("Customer").ToString())
                            ? Server.HtmlEncode(Eval("Customer").ToString().Substring(0,1).ToUpper())
                            : "?" %>
                    </div>
                    <%# Server.HtmlEncode(Eval("Customer").ToString()) %>
                  </div>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Qty">
                <ItemTemplate>
                  <%# Eval("TotalQuantity") %> item(s)
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Total">
                <ItemTemplate>
                  ₱<%# Convert.ToDecimal(Eval("TotalAmount")).ToString("N0") %>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Type">
                <ItemTemplate>
                  <%# Server.HtmlEncode(Eval("DeliveryType").ToString()) %>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Status">
                <ItemTemplate>
                  <span class='status-badge status-<%# Server.HtmlEncode(Eval("OrderStatus").ToString().Replace(" ","")) %>'>
                    <%# Server.HtmlEncode(Eval("OrderStatus").ToString()) %>
                  </span>
                </ItemTemplate>
              </asp:TemplateField>

              <asp:TemplateField HeaderText="Date">
                <ItemTemplate>
                  <%# Convert.ToDateTime(Eval("OrderDate")).ToString("MM/dd hh:mm tt") %>
                </ItemTemplate>
              </asp:TemplateField>

            </Columns>
          </asp:GridView>
          <a class="view-all-link" href="ActivityLog.aspx">View All Activity →</a>
        </div>
      </div>

      <!-- ═══ 3. LOW STOCK ALERT ═══ -->
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">
            <i class="fa-solid fa-triangle-exclamation"></i> Low Stock Alert
          </div>
          <span class="panel-badge" style="background:var(--orange-main);color:#fff;">Alert</span>
        </div>
        <div class="panel-body">
          <div class="stock-list">

            <asp:Label ID="lblNoAlerts" runat="server" Visible="false">
              <div class="no-alerts">
                <i class="fa-solid fa-circle-check" style="font-size:1.5rem;display:block;margin-bottom:6px;"></i>
                All stock levels are OK!
              </div>
            </asp:Label>

            <asp:Repeater ID="rptLowStock" runat="server">
              <ItemTemplate>
                <div class="stock-item">
                  <div class="stock-left">
                    <div class="stock-icon <%# Eval("StockStatus").ToString() == "Critical" ? "critical" : "low" %>">
                      <i class="fa-solid <%# Eval("StockType").ToString() == "Flavor" ? "fa-pepper-hot" : "fa-box" %>"></i>
                    </div>
                    <div>
                      <div class="stock-name"><%# Server.HtmlEncode(Eval("ItemName").ToString()) %></div>
                      <div class="stock-qty">Qty: <%# Eval("Quantity") %> left</div>
                    </div>
                  </div>
                  <span class="stock-level <%# Eval("StockStatus").ToString() == "Critical" ? "level-critical" : "level-low" %>">
                    <%# Server.HtmlEncode(Eval("StockStatus").ToString()) %>
                  </span>
                </div>
              </ItemTemplate>
            </asp:Repeater>

          </div>
          <a class="view-all-link" href="Inventory.aspx">Manage Inventory →</a>
        </div>
      </div>

      <!-- ═══ 4. SALES OVERVIEW CHART ═══ -->
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">
            <i class="fa-solid fa-chart-bar"></i> Sales Overview
          </div>
        </div>
        <div class="panel-body">
          <div class="chart-tabs">
            <button type="button" class="chart-tab active" onclick="showChart('daily', this)">Daily</button>
            <button type="button" class="chart-tab" onclick="showChart('weekly', this)">Weekly</button>
          </div>
          <div class="chart-wrap">
            <canvas id="salesChart" height="200"></canvas>
          </div>
        </div>
      </div>

      <!-- ═══ 5. RECENT ACTIVITY LOGS ═══ -->
      <div class="panel">
        <div class="panel-header">
          <div class="panel-title">
            <i class="fa-solid fa-scroll"></i> Recent Activity Logs
          </div>
          <span class="panel-badge">Today</span>
        </div>
        <div class="panel-body">
          <div class="activity-list">

            <asp:Repeater ID="rptActivityLog" runat="server">
              <ItemTemplate>
                <div class="activity-item">
                  <div class="activity-dot
                    <%# Container.ItemIndex % 4 == 0 ? "dot-green"
                      : Container.ItemIndex % 4 == 1 ? "dot-yellow"
                      : Container.ItemIndex % 4 == 2 ? "dot-orange"
                      : "dot-blue" %>">
                    <i class="fa-solid
                      <%# Container.ItemIndex % 4 == 0 ? "fa-receipt"
                        : Container.ItemIndex % 4 == 1 ? "fa-star"
                        : Container.ItemIndex % 4 == 2 ? "fa-pen"
                        : "fa-boxes-stacked" %>"></i>
                  </div>
                  <div>
                    <div class="activity-text">
                      <%# Server.HtmlEncode(Eval("Activity").ToString()) %>
                    </div>
                    <div class="activity-time">
                      <%# FormatTimeAgo(Convert.ToDateTime(Eval("ActivityDate"))) %>
                    </div>
                  </div>
                </div>
              </ItemTemplate>
            </asp:Repeater>

          </div>
          <a class="view-all-link" href="Orders.aspx">View All Activity →</a>
        </div>
      </div>

    </div><!-- /content -->

    <div class="dashboard-footer">
      &copy; 2025 <span>Potato Corner Argao Branch</span> — Admin System &nbsp;|&nbsp; All Rights Reserved
    </div>

  </div><!-- /main-wrap -->

</form>

<script>
  // ── Live date/time ──────────────────────────────────────────────────────
  const d = new Date();
  document.getElementById('live-date').textContent =
    d.toLocaleDateString('en-PH', { weekday:'long', year:'numeric', month:'long', day:'numeric' }) +
    ' — ' + d.toLocaleTimeString('en-PH', { hour:'2-digit', minute:'2-digit' });

  // ── Chart colours ───────────────────────────────────────────────────────
  const GREEN  = '#2d7a3a';
  const ORANGE = '#e84c1e';

  // ── Read JSON from server HiddenFields ──────────────────────────────────
  function parseHF(id) {
    try {
      const raw = document.getElementById(id).value;
      if (!raw || raw === '') return null;
      return JSON.parse(raw);
    } catch(e) { return null; }
  }

  // ── Fallback static data ────────────────────────────────────────────────
  const fallbackDaily = {
    labels: ['8am','9am','10am','11am','12pm','1pm','2pm','3pm','4pm','5pm','6pm'],
    sales:  [0,0,0,0,0,0,0,0,0,0,0],
    orders: [0,0,0,0,0,0,0,0,0,0,0]
  };
  const fallbackWeekly = {
    labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
    sales:  [0,0,0,0,0,0,0],
    orders: [0,0,0,0,0,0,0]
  };

  const dailyData  = parseHF('<%= hfDailyData.ClientID %>')  || fallbackDaily;
  const weeklyData = parseHF('<%= hfWeeklyData.ClientID %>') || fallbackWeekly;

    // ── Chart builder ───────────────────────────────────────────────────────
    let chartInstance = null;

    function buildChart(data) {
        const ctx = document.getElementById('salesChart').getContext('2d');
        if (chartInstance) chartInstance.destroy();
        chartInstance = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.labels,
                datasets: [
                    {
                        label: 'Sales (₱)',
                        data: data.sales,
                        backgroundColor: 'rgba(45,122,58,0.18)',
                        borderColor: GREEN,
                        borderWidth: 2,
                        borderRadius: 6,
                        type: 'bar',
                        yAxisID: 'y'
                    },
                    {
                        label: 'Orders',
                        data: data.orders,
                        borderColor: ORANGE,
                        backgroundColor: 'transparent',
                        borderWidth: 2.5,
                        pointBackgroundColor: ORANGE,
                        pointRadius: 4,
                        tension: 0.4,
                        type: 'line',
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                responsive: true,
                interaction: { mode: 'index', intersect: false },
                plugins: {
                    legend: {
                        labels: { font: { family: 'Nunito', weight: '700', size: 11 }, color: '#2a3a2a' }
                    }
                },
                scales: {
                    y: {
                        position: 'left',
                        ticks: {
                            callback: v => '₱' + v.toLocaleString(),
                            font: { family: 'Nunito', size: 10 }, color: '#5a6a5a'
                        },
                        grid: { color: 'rgba(0,0,0,0.05)' }
                    },
                    y1: {
                        position: 'right',
                        ticks: { font: { family: 'Nunito', size: 10 }, color: ORANGE },
                        grid: { drawOnChartArea: false }
                    },
                    x: {
                        ticks: { font: { family: 'Nunito', size: 10 }, color: '#5a6a5a' },
                        grid: { color: 'rgba(0,0,0,0.04)' }
                    }
                }
            }
        });
    }

    function showChart(type, btn) {
        document.querySelectorAll('.chart-tab').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        buildChart(type === 'daily' ? dailyData : weeklyData);
    }

    buildChart(dailyData);
</script>

</body>
</html>
