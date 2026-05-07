<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs" Inherits="PotatoCornerSys.AdminLogin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin Login - Potato Corner</title>
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f5f5f5;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .navbar {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            padding: 15px 50px;
            display: flex;
            align-items: center;
            border-bottom: 5px solid #f5c800;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }

        .navbar-logo img {
            height: 85px;
            filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
        }

        .page-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 50px 20px;
        }

        .login-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 12px 40px rgba(0,0,0,0.12);
            overflow: hidden;
            width: 100%;
            max-width: 440px;
        }

        .login-card-header {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            padding: 35px 40px;
            text-align: center;
            border-bottom: 4px solid #f5c800;
        }

        .shield-icon {
            width: 70px;
            height: 70px;
            background: rgba(255,255,255,0.15);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            border: 2px solid rgba(255,255,255,0.3);
            font-size: 32px;
        }

        .login-card-header h2 {
            color: white;
            font-size: 26px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 6px;
        }

        .login-card-header p {
            color: rgba(255,255,255,0.8);
            font-size: 13px;
        }

        .login-card-body {
            padding: 40px;
        }

        .admin-badge {
            display: inline-block;
            background: #fff3cd;
            color: #856404;
            font-size: 12px;
            font-weight: 700;
            padding: 4px 14px;
            border-radius: 20px;
            border: 1px solid #ffc107;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 24px;
        }

        .badge-wrapper {
            text-align: center;
        }

        .form-group {
            margin-bottom: 22px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 700;
            color: #555;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }

        .form-group input {
            width: 100%;
            padding: 13px 16px;
            border: 1.5px solid #e0e0e0;
            border-radius: 10px;
            font-size: 15px;
            font-family: inherit;
            color: #333;
            background: #fafafa;
            transition: border-color 0.2s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #119247;
            background: white;
        }

        .error-message {
            color: #e8401c;
            font-size: 13px;
            margin-top: 5px;
        }

        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            font-size: 16px;
            font-weight: 800;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 1px;
            border-bottom: 4px solid #f5c800;
            transition: all 0.3s;
            margin-top: 8px;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5c2a 100%);
            transform: translateY(-2px);
        }

        .security-note {
            background: #f0faf5;
            border: 1px solid #c3e6d0;
            border-radius: 8px;
            padding: 12px 16px;
            margin-top: 20px;
            font-size: 12px;
            color: #2d7a4f;
            line-height: 1.5;
        }

        .back-link {
            text-align: center;
            margin-top: 20px;
            font-size: 13px;
            color: #888;
        }

        .back-link a {
            color: #e8401c;
            font-weight: 600;
            text-decoration: none;
        }

        .back-link a:hover {
            text-decoration: underline;
        }

        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: #ccc;
            text-align: center;
            padding: 24px 40px;
            font-size: 13px;
            border-top: 5px solid #f5c800;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="navbar">
            <div class="navbar-logo">
                <img src="logopotcor.png" alt="Potato Corner" />
            </div>
        </div>

        <div class="page-wrapper">
            <div class="login-card">
                <div class="login-card-header">
                    <div class="shield-icon">🛡️</div>
                    <h2>Admin Login</h2>
                    <p>Restricted access — authorized personnel only</p>
                </div>
                <div class="login-card-body">
                    <div class="badge-wrapper">
                        <span class="admin-badge">🔒 Admin Portal</span>
                    </div>

                    <div class="form-group">
                        <label for="txtUsername">Admin Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="" placeholder="Enter admin username" />
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                            ControlToValidate="txtUsername"
                            ErrorMessage="Username is required."
                            CssClass="error-message"
                            Display="Dynamic" />
                    </div>

                    <div class="form-group">
                        <label for="txtPassword">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter your password" />
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                            ControlToValidate="txtPassword"
                            ErrorMessage="Password is required."
                            CssClass="error-message"
                            Display="Dynamic" />
                    </div>

                    <asp:Label ID="lblError" runat="server" CssClass="error-message" Visible="false" />

                    <asp:Button ID="btnLogin" runat="server" Text="Sign In as Admin"
                        CssClass="btn-login" OnClick="btnLogin_Click" />

                    <div class="security-note">
                        🔐 This is a secured admin area. All login attempts are logged and monitored.
                    </div>

                    <div class="back-link">
                        Not an admin? <a href="Login.aspx">Go to User Login</a>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            &copy; 2026 Potato Corner. All rights reserved.
        </div>

    </form>
</body>
</html>