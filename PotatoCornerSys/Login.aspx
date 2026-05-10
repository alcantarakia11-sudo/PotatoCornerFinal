<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="PotatoCornerSys.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Login</title>
    <style type="text/css">
        body {
            background-color: #119247;
            text-align: center;
            padding-top: 50px;
            margin: 0;
        }

        .logo {
            width: 280px;
            height: auto;
            margin-bottom: 40px;
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .login-container {
            background-color: rgba(255, 255, 255, 0.12);
            width: 420px;
            margin: 0 auto;
            padding: 50px 50px 40px 50px;
            border-radius: 10px;
        }

        .field-group {
            margin-bottom: 28px;
        }

        .textbox {
            display: block;
            margin: 0 auto;
            padding: 14px 16px;
            width: 100%;
            font-size: 17px;
            border-radius: 5px;
            border: none;
            box-sizing: border-box;
        }

        .login-btn {
            background-color: #0F5229;
            color: white;
            padding: 15px 0;
            width: 100%;
            border: none;
            font-size: 17px;
            cursor: pointer;
            margin-top: 20px;
            display: block;
            border-radius: 5px;
            box-sizing: border-box;
        }

        .login-btn:hover {
            background-color: #0a3d1e;
        }

        .error-msg {
            color: #ffcccc;
            margin-top: 16px;
            font-size: 14px;
        }

        .lockout-note {
            color: #e8f7ee;
            margin-top: 12px;
            font-size: 12px;
            line-height: 1.5;
            text-align: left;
            background-color: rgba(15, 82, 41, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 5px;
            padding: 10px 12px;
        }

        .register-link {
            color: white;
            margin-top: 24px;
            font-size: 15px;
        }

        /* Forgot Password Link Styling */
        .forgot-password-link {
            text-align: right;
            margin-top: 8px;
            margin-bottom: 0;
        }

        .forgot-password-link a {
            color: #f5c800;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .forgot-password-link a:hover {
            color: #fff;
            text-decoration: underline;
        }

        /* Divider line */
        .divider {
            margin: 20px 0 15px 0;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
    <script type="text/javascript">
        // Security: Prevent password field inspection
        document.addEventListener('DOMContentLoaded', function () {
            // Disable right-click on password fields
            var passwordFields = document.querySelectorAll('input[type="password"]');
            passwordFields.forEach(function (field) {
                field.addEventListener('contextmenu', function (e) {
                    e.preventDefault();
                    return false;
                });

                // Prevent copying password
                field.addEventListener('copy', function (e) {
                    e.preventDefault();
                    return false;
                });

                // Prevent cutting password
                field.addEventListener('cut', function (e) {
                    e.preventDefault();
                    return false;
                });

                // Add autocomplete off
                field.setAttribute('autocomplete', 'new-password');
            });
        });

        // Detect DevTools opening
        var devtoolsOpen = false;
        var threshold = 160;

        setInterval(function () {
            if (window.outerWidth - window.innerWidth > threshold ||
                window.outerHeight - window.innerHeight > threshold) {
                if (!devtoolsOpen) {
                    devtoolsOpen = true;
                    // Clear password fields when DevTools detected
                    var passwordFields = document.querySelectorAll('input[type="password"]');
                    passwordFields.forEach(function (field) {
                        field.value = '';
                    });
                }
            } else {
                devtoolsOpen = false;
            }
        }, 500);

        // Disable F12, Ctrl+Shift+I, Ctrl+Shift+J, Ctrl+U
        document.addEventListener('keydown', function (e) {
            if (e.keyCode == 123 || // F12
                (e.ctrlKey && e.shiftKey && e.keyCode == 73) || // Ctrl+Shift+I
                (e.ctrlKey && e.shiftKey && e.keyCode == 74) || // Ctrl+Shift+J
                (e.ctrlKey && e.keyCode == 85)) { // Ctrl+U
                e.preventDefault();
                return false;
            }
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/potato.png" CssClass="logo" />

        <div class="login-container">
            <div class="field-group">
                <asp:TextBox ID="txtUsername" runat="server" placeholder="Email" CssClass="textbox"></asp:TextBox>
            </div>
            <div class="field-group">
                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Password" CssClass="textbox" autocomplete="new-password"></asp:TextBox>
            </div>
            
            <!-- Forgot Password Link -->
            <div class="forgot-password-link">
                <asp:HyperLink ID="lnkForgotPassword" runat="server" NavigateUrl="~/ForgotPassword.aspx" Text="Forgot Password?"></asp:HyperLink>
            </div>
            
            <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="login-btn" OnClick="btnLogin_Click" />
            <asp:Label ID="lblError" runat="server" CssClass="error-msg" Visible="false"></asp:Label>
            
            <div class="divider"></div>
            
            <div class="lockout-note">
                Security notice: 5 failed login attempts will temporarily suspend your account for 1 minute.
            </div>
            <div class="register-link">
                Don't have an account? <asp:LinkButton ID="lnkRegister" runat="server" Text="Register here" OnClick="lnkRegister_Click" ForeColor="#f5c800"></asp:LinkButton>
            </div>
        </div>
    </form>
</body>
</html>