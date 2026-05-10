<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs" Inherits="PotatoCornerSys.AdminLogin" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin Login - Potato Corner</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }

        html { height: 100%; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: #f0f2f0;
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow: hidden;
        }

        /* ── NAVBAR ── */
        .navbar {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            padding: 15px 50px;
            display: flex;
            align-items: center;
            border-bottom: 5px solid #f5c800;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
            flex-shrink: 0;
        }

        .navbar-logo img {
            height: 65px;
            filter: drop-shadow(0 2px 6px rgba(0,0,0,0.2));
        }

        /* ── PAGE WRAPPER ── */
        .page-wrapper {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            overflow: hidden;
        }

        /* ── LOGIN CARD ── */
        .login-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 16px 48px rgba(0,0,0,0.14);
            overflow: hidden;
            width: 100%;
            max-width: 420px;
        }

        /* ── CARD HEADER ── */
        .login-card-header {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            padding: 28px 40px 22px;
            text-align: center;
            border-bottom: 4px solid #f5c800;
        }

        .shield-icon {
            width: 58px;
            height: 58px;
            background: rgba(255,255,255,0.15);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 12px;
            border: 2px solid rgba(255,255,255,0.35);
            font-size: 26px;
            color: white;
        }

        .login-card-header h2 {
            color: white;
            font-size: 22px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 5px;
        }

        .login-card-header p {
            color: rgba(255,255,255,0.8);
            font-size: 12px;
        }

        /* ── CARD BODY ── */
        .login-card-body {
            padding: 24px 36px 22px;
        }

        .badge-wrapper {
            text-align: center;
            margin-bottom: 18px;
        }

        .admin-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff3cd;
            color: #856404;
            font-size: 11px;
            font-weight: 700;
            padding: 5px 14px;
            border-radius: 20px;
            border: 1px solid #ffc107;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* ── FORM ── */
        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 700;
            color: #555;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 7px;
        }

        .form-group label i {
            color: #119247;
            font-size: 12px;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #bbb;
            font-size: 14px;
            pointer-events: none;
        }

        .txt-input {
            width: 100%;
            padding: 11px 16px 11px 40px !important;
            border: 1.5px solid #e0e0e0 !important;
            border-radius: 10px !important;
            font-size: 14px !important;
            font-family: 'Segoe UI', Tahoma, sans-serif !important;
            color: #333 !important;
            background: #fafafa !important;
            transition: border-color 0.2s, box-shadow 0.2s !important;
            display: block;
        }

        .txt-input:focus {
            outline: none !important;
            border-color: #119247 !important;
            background: white !important;
            box-shadow: 0 0 0 3px rgba(17,146,71,0.08) !important;
        }

        .error-message {
            color: #e8401c;
            font-size: 11px;
            margin-top: 4px;
            display: block;
        }

        /* ── LOGIN BUTTON ── */
        .btn-login {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            font-size: 14px;
            font-weight: 800;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            transition: all 0.3s;
            margin-top: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5c2a 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(13,115,54,0.35);
        }

        /* ── SECURITY NOTE ── */
        .security-note {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            background: #f0faf5;
            border: 1px solid #c3e6d0;
            border-radius: 8px;
            padding: 10px 14px;
            margin-top: 14px;
            font-size: 11px;
            color: #2d7a4f;
            line-height: 1.5;
        }

        .security-note i {
            margin-top: 1px;
            flex-shrink: 0;
            font-size: 13px;
        }

        /* ── BACK LINK ── */
        .back-link {
            text-align: center;
            margin-top: 14px;
            font-size: 12px;
            color: #888;
        }

        .back-link a {
            color: #e8401c;
            font-weight: 700;
            text-decoration: none;
        }

        .back-link a:hover {
            text-decoration: underline;
        }

        /* ── FOOTER ── */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: rgba(255,255,255,0.7);
            text-align: center;
            padding: 14px 40px;
            font-size: 12px;
            flex-shrink: 0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" style="display:flex; flex-direction:column; height:100vh;">

        <div class="navbar">
            <div class="navbar-logo">
                <img src="potato.png" alt="Potato Corner" />
            </div>
        </div>

        <div class="page-wrapper">
            <div class="login-card">

                <div class="login-card-header">
                    <div class="shield-icon">
                        <i class="fa-solid fa-shield-halved"></i>
                    </div>
                    <h2>Admin Login</h2>
                    <p>Restricted access — authorized personnel only</p>
                </div>

                <div class="login-card-body">

                    <div class="badge-wrapper">
                        <span class="admin-badge">
                            <i class="fa-solid fa-lock"></i> Admin Portal
                        </span>
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fa-solid fa-user"></i> Admin Username
                        </label>
                        <div class="input-wrap">
                            <i class="fa-solid fa-user"></i>
                            <asp:TextBox ID="txtUsername" runat="server"
                                CssClass="txt-input"
                                placeholder="Enter admin username" />
                        </div>
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                            ControlToValidate="txtUsername"
                            ErrorMessage="Username is required."
                            CssClass="error-message"
                            Display="Dynamic" />
                    </div>

                    <div class="form-group">
                        <label>
                            <i class="fa-solid fa-key"></i> Password
                        </label>
                        <div class="input-wrap">
                            <i class="fa-solid fa-lock"></i>
                            <asp:TextBox ID="txtPassword" runat="server"
                                TextMode="Password"
                                CssClass="txt-input"
                                placeholder="Enter your password" />
                        </div>
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
                        <i class="fa-solid fa-circle-info"></i>
                        <span>This is a secured admin area. All login attempts are logged and monitored.</span>
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
