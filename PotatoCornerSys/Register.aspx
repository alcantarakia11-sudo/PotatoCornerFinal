<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="PotatoCornerSys.Register" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Register</title>
    <style type="text/css">
    * { margin: 0; padding: 0; box-sizing: border-box; }

    html, body {
        height: 100%;
        overflow: hidden;
        background-color: #119247;
    }

    body {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 10px;
    }

    .logo {
        width: 160px;
        height: auto;
        margin-bottom: 15px;
        display: block;
        margin-left: auto;
        margin-right: auto;
    }

    .register-container {
        background-color: rgba(255, 255, 255, 0.12);
        width: 420px;
        margin: 0 auto;
        padding: 20px 40px 20px 40px;
        border-radius: 10px;
    }

    .field-group {
        margin-bottom: 8px;
        text-align: left;
    }

    .textbox {
        display: block;
        margin: 0 auto;
        padding: 8px 12px;
        width: 100%;
        font-size: 15px;
        border-radius: 5px;
        border: 2px solid transparent;
        box-sizing: border-box;
        transition: border-color 0.2s;
    }

    .textbox:focus {
        outline: none;
        border-color: #f5c800;
    }

    .textbox.input-error {
        border-color: #ff6b6b;
    }

    .field-hint {
        display: block;
        font-size: 10px;
        color: rgba(255,255,255,0.6);
        margin-top: 2px;
        padding-left: 2px;
    }

    .field-error {
        display: block;
        font-size: 11px;
        color: #ffcccc;
        margin-top: 2px;
        padding-left: 4px;
        font-weight: 600;
    }

    .register-btn {
        background-color: #0F5229;
        color: white;
        padding: 11px 0;
        width: 100%;
        border: none;
        font-size: 15px;
        cursor: pointer;
        margin-top: 12px;
        display: block;
        border-radius: 5px;
        box-sizing: border-box;
        transition: background-color 0.3s;
    }

    .register-btn:hover { background-color: #0a3d1e; }

    .login-link {
        color: white;
        margin-top: 12px;
        font-size: 13px;
        text-align: center;
        display: block;
    }

    .success-msg {
        display: block;
        background-color: rgba(25, 135, 84, 0.3);
        border: 1px solid rgba(25, 135, 84, 0.5);
        color: #ccffcc;
        margin-top: 8px;
        font-size: 12px;
        padding: 8px 12px;
        border-radius: 6px;
        text-align: left;
    }

    .error-msg {
        display: block;
        background-color: rgba(220, 53, 69, 0.2);
        border: 1px solid rgba(220, 53, 69, 0.5);
        color: #ffcccc;
        margin-top: 8px;
        font-size: 12px;
        padding: 8px 12px;
        border-radius: 6px;
        text-align: left;
    }
</style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Image ID="imgLogo" runat="server" ImageUrl="~/potato.png" CssClass="logo" />
        <div class="register-container">

            <div class="field-group">
                <asp:TextBox ID="txtName" runat="server" CssClass="textbox" placeholder="Full Name" />
                <asp:Label ID="lblNameError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">Letters and spaces only</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtEmail" runat="server" CssClass="textbox" placeholder="Email" />
                <asp:Label ID="lblEmailError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">e.g. user@email.com</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtUsername" runat="server" CssClass="textbox" placeholder="Username" />
                <asp:Label ID="lblUsernameError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">Min. 3 characters, letters/numbers/underscore only</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtPhone" runat="server" CssClass="textbox" placeholder="Phone Number" />
                <asp:Label ID="lblPhoneError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">11 digits starting with 09</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtAddress" runat="server" CssClass="textbox" placeholder="Address" />
                <asp:Label ID="lblAddressError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">e.g. 123 Rizal St, Brgy. Lahug, Cebu City (min. 10 characters)</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtPassword" runat="server" CssClass="textbox" TextMode="Password" placeholder="Password" />
                <asp:Label ID="lblPasswordError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">Min. 8 characters with at least 1 letter and 1 number</span>
            </div>

            <div class="field-group">
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="textbox" TextMode="Password" placeholder="Confirm Password" />
                <asp:Label ID="lblConfirmPasswordError" runat="server" CssClass="field-error" Visible="false" />
                <span class="field-hint">Must match your password</span>
            </div>

            <%-- General message for success or DB errors --%>
            <asp:Label ID="lblMessage" runat="server" Visible="false" />

            <asp:Button ID="btnRegister" runat="server" Text="Register" CssClass="register-btn" OnClick="btnRegister_Click" />

            <div class="login-link">
                Already have an account?
                <asp:LinkButton ID="LinkButton1" runat="server" Text="Login" OnClick="lnkLogin_Click" ForeColor="White" />
            </div>

        </div>
    </form>
</body>
</html>