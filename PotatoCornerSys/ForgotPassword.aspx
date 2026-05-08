<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="PotatoCornerSys.ForgotPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password - Potato Corner</title>
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
            background: linear-gradient(135deg, #f8fffe 0%, #e8f5e9 100%);
            color: var(--text-dark);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            align-items: center;
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
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }

        .navbar-logo img {
            height: 65px;
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
        .forgot-container {
            max-width: 600px;
            margin: 120px auto 50px;
            padding: 0 40px;
            width: 100%;
        }

        /* CARD STYLING */
        .forgot-card {
            background: white;
            border-radius: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            overflow: hidden;
            animation: fadeInUp 0.6s ease-out;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .card-header {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            padding: 40px 30px;
            text-align: center;
            border-bottom: 5px solid #f5c800;
        }

        .potato-icon {
            font-size: 60px;
            margin-bottom: 15px;
            display: inline-block;
            animation: bounce 2s ease-in-out infinite;
        }

        @keyframes bounce {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }

        .card-header h1 {
            color: white;
            font-size: 32px;
            font-weight: 900;
            margin-bottom: 8px;
            letter-spacing: 1px;
        }

        .card-header p {
            color: #f5c800;
            font-size: 14px;
            margin: 0;
            font-weight: 600;
        }

        .card-body {
            padding: 40px;
        }

        /* MESSAGE STYLES */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideIn 0.4s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .alert-info {
            background: #e3f2fd;
            color: #1565c0;
            border-left: 4px solid #1565c0;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .alert-danger {
            background: #fce4ec;
            color: #b71c1c;
            border-left: 4px solid #dc3545;
        }

        .alert i {
            font-size: 20px;
        }

        /* FORM GROUPS */
        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            margin-bottom: 12px;
            font-weight: 700;
            color: #119247;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .form-control {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 16px;
            transition: all 0.3s;
            font-family: inherit;
        }

        .form-control:focus {
            outline: none;
            border-color: #119247;
            box-shadow: 0 0 0 4px rgba(17, 146, 71, 0.1);
        }

        /* BUTTONS */
        .btn-potato {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            padding: 14px 30px;
            border: none;
            border-radius: 12px;
            font-weight: 800;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: all 0.3s;
        }

        .btn-potato:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(17, 146, 71, 0.3);
        }

        .btn-potato:active {
            transform: translateY(0);
        }

        /* BACK LINK */
        .back-link {
            text-align: center;
            margin-top: 25px;
        }

        .back-link a {
            color: #119247;
            text-decoration: none;
            font-weight: 700;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s;
        }

        .back-link a:hover {
            color: #f5c800;
            transform: translateX(-5px);
        }

        /* LOADING SPINNER */
        .loading {
            display: none;
            text-align: center;
            margin-top: 20px;
        }

        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #119247;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 0 auto;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 40px 40px;
            font-size: 14px;
            border-top: 5px solid #f5c800;
            margin-top: 80px;
        }

        .footer-links a {
            color: #f5c800;
            text-decoration: none;
            margin: 0 15px;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .footer-links a:hover {
            color: #fff;
            text-shadow: 0 2px 8px rgba(245,200,0,0.5);
        }

        .footer-copy {
            margin-top: 20px;
            font-size: 12px;
            color: #ccc;
        }

        /* RESPONSIVE */
        @media (max-width: 768px) {
            .navbar {
                padding: 12px 20px;
            }
            
            .navbar-links {
                gap: 20px;
            }
            
            .navbar-links a {
                font-size: 12px;
            }
            
            .forgot-container {
                padding: 0 20px;
                margin: 100px auto 30px;
            }
            
            .card-body {
                padding: 30px 20px;
            }
            
            .card-header h1 {
                font-size: 24px;
            }
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
                <li><a href="Login.aspx">Login</a></li>
                <li><a href="Register.aspx">Register</a></li>
            </ul>
        </div>

        <div class="forgot-container">
            <div class="forgot-card">
                <div class="card-header">
                    <div class="potato-icon">🥔</div>
                    <h1>Forgot Password?</h1>
                    <p>We'll help you reset it in no time</p>
                </div>
                
                <div class="card-body">
                    <!-- Message Display Control -->
                    <asp:Literal ID="litMessage" runat="server" />
                    
                    <!-- Info Message -->
                    <div class="alert alert-info">
                        <i>📧</i>
                        <span>Enter your email address and we'll send you a 6-digit verification code to reset your password.</span>
                    </div>
                    
                    <!-- Email Input -->
                    <div class="form-group">
                        <label for="txtEmail">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" 
                            CssClass="form-control" 
                            TextMode="Email" 
                            placeholder="you@example.com"
                            required="true" />
                    </div>
                    
                    <!-- Send Code Button -->
                    <asp:Button ID="btnSendCode" runat="server" 
                        Text="Send Verification Code" 
                        CssClass="btn-potato" 
                        OnClick="btnSendCode_Click" />
                    
                    <!-- Back to Login Link -->
                    <div class="back-link">
                        <a href="Login.aspx">← Back to Login</a>
                    </div>
                    
                    <!-- Loading Spinner -->
                    <div class="loading" id="loadingSpinner">
                        <div class="spinner"></div>
                        <p style="margin-top: 10px; color: #119247;">Sending code...</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms and Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">© 2026 Potato Corner. All rights reserved.</div>
        </div>

    </form>

    <!-- JavaScript for Loading Effect -->
    <script type="text/javascript">
        function showLoading() {
            document.getElementById('loadingSpinner').style.display = 'block';
            return true;
        }
        
        // Attach to button if needed
        var btn = document.getElementById('<%= btnSendCode.ClientID %>');
        if (btn) {
            btn.onclick = function() {
                document.getElementById('loadingSpinner').style.display = 'block';
                return true;
            };
        }
    </script>
</body>
</html>