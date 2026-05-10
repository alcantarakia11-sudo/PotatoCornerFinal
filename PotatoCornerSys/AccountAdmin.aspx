<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccountAdmin.aspx.cs" Inherits="PotatoCornerSys.AccountAdmin" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin Profile - Potato Corner</title>
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
        }

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
            font-family: 'Segoe UI', Tahoma, sans-serif;
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

        .profile-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 30px 20px;
        }

        /* HERO SECTION */
        .profile-hero {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            border-radius: 20px;
            padding: 50px 40px;
            text-align: center;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(232, 64, 28, 0.3);
        }

        .profile-hero::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(245, 200, 0, 0.15) 0%, transparent 70%);
            animation: float 6s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-20px) rotate(180deg); }
        }

        .admin-avatar {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #f5c800 0%, #fac775 100%);
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 42px;
            font-weight: 900;
            color: #1a1a1a;
            border: 5px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
            position: relative;
            z-index: 2;
        }

        .admin-title {
            color: white;
            font-size: 32px;
            font-weight: 900;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 2px;
            position: relative;
            z-index: 2;
        }

        .admin-subtitle {
            color: #f5c800;
            font-size: 18px;
            font-weight: 600;
            position: relative;
            z-index: 2;
        }

        .admin-badge-hero {
            display: inline-block;
            background: rgba(245, 200, 0, 0.2);
            color: #f5c800;
            padding: 8px 20px;
            border-radius: 25px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            margin-top: 15px;
            border: 2px solid rgba(245, 200, 0, 0.3);
            position: relative;
            z-index: 2;
        }

        /* CONTENT GRID */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-bottom: 30px;
        }

        /* PROFILE INFO CARD */
        .info-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            border-left: 5px solid #f5c800;
            transition: all 0.3s;
        }

        .info-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.12);
        }

        .card-title {
            font-size: 22px;
            font-weight: 900;
            color: #e8401c;
            margin-bottom: 25px;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-icon {
            width: 30px;
            height: 30px;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 14px;
        }

        .info-group {
            margin-bottom: 25px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f0f0f0;
        }

        .info-group:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }

        .info-label {
            font-size: 12px;
            font-weight: 700;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }

        .info-value {
            font-size: 16px;
            color: #333;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .role-badge {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 6px 15px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* QUICK STATS CARD */
        .stats-card {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            border-radius: 20px;
            padding: 40px;
            color: white;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(17, 146, 71, 0.3);
        }

        .stats-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(245, 200, 0, 0.1) 0%, transparent 70%);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            position: relative;
            z-index: 2;
        }

        .stat-item {
            text-align: center;
            padding: 20px;
            background: rgba(245, 200, 0, 0.15);
            border-radius: 12px;
            border: 2px solid rgba(245, 200, 0, 0.3);
        }

        .stat-number {
            font-size: 32px;
            font-weight: 900;
            color: white;
            margin-bottom: 5px;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        .stat-label {
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: rgba(255, 255, 255, 0.95);
        }

        /* ACTION BUTTONS */
        .action-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-top: 30px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            padding: 16px 28px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 800;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 4px 15px rgba(245, 200, 0, 0.3);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #ffd700 0%, #f5c800 100%);
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(245, 200, 0, 0.4);
        }

        .btn-logout {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 16px 28px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 800;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 4px 15px rgba(232, 64, 28, 0.3);
        }

        .btn-logout:hover {
            background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(232, 64, 28, 0.4);
        }

        /* LOGOUT MODAL */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.55);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-box {
            background: white;
            border-radius: 20px;
            padding: 40px 36px 32px;
            max-width: 420px;
            width: 90%;
            box-shadow: 0 16px 50px rgba(0,0,0,0.25);
            text-align: center;
            animation: modalIn 0.25s ease-out;
        }

        @keyframes modalIn {
            from { transform: translateY(-30px); opacity: 0; }
            to   { transform: translateY(0);     opacity: 1; }
        }

        .modal-icon {
            width: 70px; height: 70px;
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            box-shadow: 0 6px 20px rgba(232,64,28,0.35);
        }

        .modal-title {
            font-size: 22px;
            font-weight: 900;
            color: #1a1a1a;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }

        .modal-message {
            font-size: 15px;
            color: #6c757d;
            margin-bottom: 30px;
            line-height: 1.6;
        }

        .modal-buttons {
            display: flex;
            gap: 14px;
            justify-content: center;
        }

        .modal-btn-cancel {
            padding: 12px 28px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            background: white;
            color: #555;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.2s;
        }

        .modal-btn-cancel:hover {
            background: #f5f5f5;
            border-color: #ccc;
        }

        .modal-btn-confirm {
            padding: 12px 28px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.2s;
            box-shadow: 0 4px 15px rgba(232,64,28,0.3);
        }

        .modal-btn-confirm:hover {
            background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.4);
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

        .footer .footer-links {
            margin-bottom: 24px;
        }

        .footer .footer-copy {
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

            .content-grid {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .profile-hero {
                padding: 40px 20px;
            }
            
            .admin-title {
                font-size: 28px;
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
                <li><asp:LinkButton ID="lnkHome" runat="server" OnClick="lnkHome_Click" Text="Home"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkSales" runat="server" OnClick="lnkSales_Click" Text="Sales"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate" runat="server" OnClick="lnkUpdate_Click" Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkActivityLog" runat="server" OnClick="lnkActivityLog_Click" Text="Activity Log"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" OnClick="lnkProfile_Click" Text="Profile" CssClass="active"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="profile-container">
            <!-- HERO SECTION -->
            <div class="profile-hero">
                <div class="admin-avatar">SF</div>
                <h1 class="admin-title"><asp:Label ID="lblFullname" runat="server"></asp:Label></h1>
                <p class="admin-subtitle">System Administrator</p>
                <div class="admin-badge-hero">ADMIN ACCESS</div>
            </div>

            <!-- CONTENT GRID -->
            <div class="content-grid">
                <!-- PROFILE INFO CARD -->
                <div class="info-card">
                    <h2 class="card-title">
                        <div class="card-icon">i</div>
                        Profile Information
                    </h2>

                    <div class="info-group">
                        <div class="info-label">Username</div>
                        <div class="info-value"><asp:Label ID="lblUsername" runat="server"></asp:Label></div>
                    </div>

                    <div class="info-group">
                        <div class="info-label">Email Address</div>
                        <div class="info-value"><asp:Label ID="lblEmail" runat="server"></asp:Label></div>
                    </div>

                    <div class="info-group">
                        <div class="info-label">Phone Number</div>
                        <div class="info-value"><asp:Label ID="lblPhone" runat="server"></asp:Label></div>
                    </div>

                    <div class="info-group">
                        <div class="info-label">Address</div>
                        <div class="info-value"><asp:Label ID="lblAddress" runat="server"></asp:Label></div>
                    </div>

                    <div class="info-group">
                        <div class="info-label">Access Level</div>
                        <div class="info-value">
                            <asp:Label ID="lblRole" runat="server"></asp:Label>
                            <span class="role-badge">ADMINISTRATOR</span>
                        </div>
                    </div>
                </div>

                <!-- QUICK STATS CARD -->
                <div class="stats-card">
                    <h2 class="card-title">
                        <div class="card-icon">#</div>
                        System Overview
                    </h2>

                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-number"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                            <div class="stat-label">Total Users</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
                            <div class="stat-label">Total Orders</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number"><asp:Label ID="lblPendingOrders" runat="server" Text="0"></asp:Label></div>
                            <div class="stat-label">Pending Orders</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">PHP <asp:Label ID="lblTotalRevenue" runat="server" Text="0.00"></asp:Label></div>
                            <div class="stat-label">Total Revenue</div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ACTION BUTTONS -->
            <div class="action-buttons">
                <asp:Button ID="btnBackToDashboard" runat="server" Text="Back to Dashboard" CssClass="btn-primary" OnClick="btnBackToDashboard_Click" />
                <asp:Button ID="btnDatabaseBackup" runat="server" Text="Database Backup" CssClass="btn-primary" OnClick="btnDatabaseBackup_Click" />
                <button type="button" class="btn-logout" onclick="showLogoutModal()">Logout</button>
            </div>
        </div>

        <!-- LOGOUT CONFIRMATION MODAL -->
        <div id="logoutModal" class="modal-overlay">
            <div class="modal-box">
                <div class="modal-icon">🚪</div>
                <div class="modal-title">Log Out</div>
                <p class="modal-message">Are you sure you want to log out of your admin account?</p>
                <div class="modal-buttons">
                    <button type="button" class="modal-btn-cancel" onclick="hideLogoutModal()">Cancel</button>
                    <asp:Button ID="btnLogout" runat="server" Text="Yes, Log Out" CssClass="modal-btn-confirm" OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function showLogoutModal() {
                document.getElementById('logoutModal').classList.add('active');
            }
            function hideLogoutModal() {
                document.getElementById('logoutModal').classList.remove('active');
            }
            // Close modal when clicking outside the box
            document.getElementById('logoutModal').addEventListener('click', function (e) {
                if (e.target === this) hideLogoutModal();
            });
        </script>

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