<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs" Inherits="PotatoCornerSys.ResetPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Reset Password - Potato Corner</title>
    <style type="text/css">
        :root {
            --primary-green: #119247;
            --primary-dark: #0d7336;
            --accent-yellow: #f5c800;
            --bg-light: #f8fffe;
            --text-dark: #2c3e50;
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
        .reset-container {
            max-width: 550px;
            margin: 50px auto 50px;
            padding: 0 40px;
            width: 100%;
        }

        /* CARD STYLING */
        .reset-card {
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

        /* Message Styles */
        .alert {
            padding: 15px 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
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

        /* Form Groups */
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

        /* Password Requirements */
        .password-requirements {
            background: #f8f9fa;
            padding: 12px 15px;
            border-radius: 10px;
            margin-top: 10px;
        }

        .password-requirements p {
            font-size: 12px;
            margin: 5px 0;
            color: #666;
        }

        .password-requirements .valid {
            color: #119247;
        }

        .password-requirements .invalid {
            color: #dc3545;
        }

        /* Button */
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

        /* Button Group */
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 10px;
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
            padding: 14px 30px;
            border: none;
            border-radius: 12px;
            font-weight: 700;
            font-size: 16px;
            cursor: pointer;
            flex: 1;
            transition: all 0.3s;
        }

        .btn-cancel:hover {
            background: #5a6268;
        }

        .btn-reset {
            flex: 2;
        }

        /* Footer */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 60px 40px;
            font-size: 15px;
            border-top: 5px solid #f5c800;
            margin-top: 80px;
        }

        .footer-links a {
            color: #f5c800;
            text-decoration: none;
            margin: 0 15px;
            font-size: 15px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .footer-links a:hover {
            color: #fff;
            text-shadow: 0 2px 8px rgba(245,200,0,0.5);
        }

        .footer-copy {
            margin-top: 20px;
            font-size: 14px;
            color: #ccc;
        }

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
            .reset-container {
                padding: 0 20px;
                margin: 30px auto;
            }
            .card-body {
                padding: 30px 20px;
            }
            .button-group {
                flex-direction: column;
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
                <li><a href="Login.aspx">Login</a></li>
                <li><a href="Register.aspx">Register</a></li>
            </ul>
        </div>

        <div class="reset-container">
            <div class="reset-card">
                <div class="card-header">
                    <div class="potato-icon">🔑</div>
                    <h1>Create New Password</h1>
                    <p>Enter your new password below</p>
                </div>
                
                <div class="card-body">
                    <!-- Message Display -->
                    <asp:Literal ID="litMessage" runat="server" />
                    
                    <!-- Email Display -->
                    <div class="alert alert-info">
                        📧 Resetting password for: <strong><asp:Literal ID="litEmail" runat="server" /></strong>
                    </div>
                    
                    <!-- New Password Field -->
                    <div class="form-group">
                        <label for="txtNewPassword">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" 
                            CssClass="form-control" 
                            TextMode="Password" 
                            placeholder="Enter new password"
                            required="true" />
                    </div>
                    
                    <!-- Confirm Password Field -->
                    <div class="form-group">
                        <label for="txtConfirmPassword">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" 
                            CssClass="form-control" 
                            TextMode="Password" 
                            placeholder="Confirm your new password"
                            required="true" />
                    </div>
                    
                    <!-- Password Requirements -->
                    <div class="password-requirements">
                        <p>Password must contain:</p>
                        <p id="lengthReq">✓ At least 6 characters</p>
                        <p id="matchReq">✓ Passwords match</p>
                    </div>
                    
                    <!-- Buttons -->
                    <div class="button-group">
                        <asp:Button ID="btnCancel" runat="server" 
                            Text="Cancel" 
                            CssClass="btn-cancel" 
                            OnClick="btnCancel_Click" />
                        <asp:Button ID="btnResetPassword" runat="server" 
                            Text="Reset Password" 
                            CssClass="btn-potato btn-reset" 
                            OnClick="btnResetPassword_Click" />
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

    <!-- Password Validation Script -->
    <script type="text/javascript">
        function validatePassword() {
            var password = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var confirm = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            
            var lengthReq = document.getElementById('lengthReq');
            var matchReq = document.getElementById('matchReq');
            
            var isValid = true;
            
            // Check length
            if (password.length >= 6) {
                lengthReq.style.color = '#119247';
                lengthReq.innerHTML = '✓ At least 6 characters';
            } else {
                lengthReq.style.color = '#dc3545';
                lengthReq.innerHTML = '✗ At least 6 characters';
                isValid = false;
            }
            
            // Check match
            if (password === confirm && password !== '') {
                matchReq.style.color = '#119247';
                matchReq.innerHTML = '✓ Passwords match';
            } else {
                matchReq.style.color = '#dc3545';
                matchReq.innerHTML = '✗ Passwords match';
                isValid = false;
            }
            
            return isValid;
        }
        
        // Attach validation events
        document.getElementById('<%= txtNewPassword.ClientID %>').onkeyup = validatePassword;
        document.getElementById('<%= txtConfirmPassword.ClientID %>').onkeyup = validatePassword;
    </script>
</body>
</html>