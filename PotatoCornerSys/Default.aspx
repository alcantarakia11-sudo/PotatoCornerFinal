<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PotatoCornerSys.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Potato Corner - Home</title>
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: white;
            overflow-x: hidden;
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

        .navbar-links .btn-order-nav {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 12px 28px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 15px;
            text-transform: uppercase;
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
            transition: all 0.3s;
            border: none;
            cursor: pointer;
        }

        .navbar-links .btn-order-nav::after {
            display: none;
        }

        .navbar-links .btn-order-nav:hover {
            background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(232,64,28,0.4);
        }

        /* ACTIVE NAV LINK */
        .navbar-links .active {
            color: #f5c800 !important;
        }

        .navbar-links .active::after {
            width: 0 !important;
        }

        /* HERO BANNER WITH VIDEO */
        .hero {
            padding: 0;
            background-color: #000;
            position: relative;
            overflow: hidden;
            height: 85vh;
            min-height: 650px;
        }

        .hero video {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(to bottom, rgba(0,0,0,0.3) 0%, rgba(0,0,0,0.5) 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            color: white;
            text-align: center;
            padding: 20px;
        }

        .hero-overlay h1 {
            font-size: 56px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 20px;
            text-shadow: 0 4px 12px rgba(0,0,0,0.5);
            animation: fadeInUp 1s ease-out;
        }

        .hero-overlay p {
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 30px;
            text-shadow: 0 2px 8px rgba(0,0,0,0.5);
            animation: fadeInUp 1.2s ease-out;
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* PROMO BANNER */
        .promo-banner {
            padding: 40px 70px;
            background: white;
        }

        .promo-inner {
            background: linear-gradient(135deg, #ffd700 0%, #f5c800 50%, #e6b800 100%);
            border-radius: 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 80px 100px;
            overflow: hidden;
            min-height: 400px;
            box-shadow: 0 15px 50px rgba(0,0,0,0.2);
            transition: all 0.4s;
            position: relative;
            border: 3px solid rgba(255,255,255,0.3);
        }

        .promo-inner::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
            animation: rotate 25s linear infinite;
        }

        .promo-inner::after {
            content: '';
            position: absolute;
            bottom: -100px;
            left: -100px;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(232,64,28,0.1) 0%, transparent 70%);
            border-radius: 50%;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to   { transform: rotate(360deg); }
        }

        .promo-inner:hover {
            transform: translateY(-8px) scale(1.01);
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
        }

        .promo-text {
            max-width: 550px;
            position: relative;
            z-index: 1;
        }

        .promo-text h2 {
            font-size: 48px;
            color: #e8401c;
            font-weight: 900;
            text-transform: uppercase;
            line-height: 1.1;
            margin-bottom: 24px;
            text-shadow: 3px 3px 6px rgba(0,0,0,0.15);
            letter-spacing: 1px;
        }

        .promo-text p {
            font-size: 18px;
            color: #2c2c2c;
            margin-bottom: 36px;
            line-height: 1.8;
            font-weight: 500;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.5);
        }

        .promo-img {
            position: relative;
            z-index: 1;
        }

        .promo-img img {
            height: 360px;
            object-fit: contain;
            filter: drop-shadow(0 12px 30px rgba(0,0,0,0.3));
            transition: all 0.4s;
        }

        .promo-img img:hover {
            transform: scale(1.08) rotate(3deg);
            filter: drop-shadow(0 15px 40px rgba(0,0,0,0.4));
        }

        .btn-order {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 18px 50px;
            font-size: 18px;
            font-weight: 900;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-transform: uppercase;
            box-shadow: 0 8px 25px rgba(232,64,28,0.5);
            transition: all 0.3s;
            letter-spacing: 1.5px;
            position: relative;
            overflow: hidden;
        }

        .btn-order::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .btn-order:hover::before {
            width: 300px;
            height: 300px;
        }

        .btn-order:hover {
            background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
            transform: translateY(-4px);
            box-shadow: 0 12px 35px rgba(232,64,28,0.6);
        }

        .btn-order:active {
            transform: translateY(-1px);
        }

        /* FLAVOR THE MOMENT */
        .flavor-section {
            text-align: center;
            padding: 100px 40px;
        }

        .flavor-section h2 {
            font-size: 56px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 3px;
        }

        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 60px 40px;
            font-size: 15px;
            border-top: 5px solid #f5c800;
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

        .footer .footer-links { margin-bottom: 24px; }
        .footer .footer-copy  { margin-top: 20px; font-size: 14px; color: #ccc; }

        /* LOGIN REQUIRED MODAL */
        .login-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.6);
            z-index: 9999;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(5px);
        }

        .login-modal-overlay.active {
            display: flex;
        }

        @keyframes modalPop {
            from { transform: translateY(-30px) scale(0.95); opacity: 0; }
            to   { transform: translateY(0) scale(1); opacity: 1; }
        }

        .login-modal-box {
            background: #ffffff;
            border-radius: 24px;
            padding: 48px 40px 40px;
            max-width: 440px;
            width: 90%;
            text-align: center;
            box-shadow: 0 24px 64px rgba(0, 0, 0, 0.25);
            animation: modalPop 0.3s ease-out;
        }

        .login-modal-icon {
            font-size: 60px;
            margin-bottom: 18px;
        }

        .login-modal-title {
            font-size: 28px;
            font-weight: 900;
            color: #119247;
            margin-bottom: 14px;
            letter-spacing: 0.5px;
        }

        .login-modal-msg {
            font-size: 15px;
            color: #888;
            line-height: 1.7;
            margin-bottom: 32px;
        }

        .login-modal-msg strong {
            color: #1a1612;
        }

        .login-modal-btns {
            display: flex;
            gap: 14px;
            justify-content: center;
            margin-bottom: 20px;
        }

        .login-modal-btns a {
            flex: 1;
            padding: 14px 10px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            text-decoration: none;
            transition: all 0.25s;
        }

        .btn-modal-login {
            background: linear-gradient(135deg, #119247, #0d7336);
            color: #ffffff !important;
            box-shadow: 0 6px 18px rgba(17,146,71,0.35);
        }

        .btn-modal-login:hover {
            background: linear-gradient(135deg, #0d7336, #095c2a);
            transform: translateY(-2px);
            box-shadow: 0 8px 22px rgba(17,146,71,0.45);
        }

        .btn-modal-register {
            background: linear-gradient(135deg, #e8401c, #c73516);
            color: #ffffff !important;
            box-shadow: 0 6px 18px rgba(232,64,28,0.35);
        }

        .btn-modal-register:hover {
            background: linear-gradient(135deg, #c73516, #a82a12);
            transform: translateY(-2px);
            box-shadow: 0 8px 22px rgba(232,64,28,0.45);
        }

        .login-modal-skip {
            display: block;
            font-size: 13px;
            color: #aaa;
            text-decoration: none;
            transition: color 0.2s;
            cursor: pointer;
            background: none;
            border: none;
            font-family: inherit;
        }

        .login-modal-skip:hover {
            color: #666;
            text-decoration: underline;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .promo-inner {
                flex-direction: column;
                text-align: center;
                padding: 40px;
            }
            .promo-img { margin-top: 30px; }
            .hero-overlay h1 { font-size: 36px; }
            .login-modal-btns { flex-direction: column; }
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
                <li><asp:LinkButton ID="lnkHome" runat="server" CssClass="active" OnClick="lnkHome_Click" Text="Home"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkMenu" runat="server" OnClick="lnkMenu_Click" Text="Menu"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkMembership" runat="server" OnClick="lnkMembership_Click" Text="Membership"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkAboutUs" runat="server" OnClick="lnkAboutUs_Click" Text="About Us"></asp:LinkButton></li>
                <li>
                    <asp:LinkButton ID="btnOrderNav" runat="server"
                        CssClass="btn-order-nav"
                        OnClick="btnOrderNav_Click"
                        OnClientClick="return handleOrderClick();"
                        Text="Order Now">
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton ID="lnkProfile" runat="server" ForeColor="White" Font-Bold="true" Text="Profile" OnClick="lnkProfile_Click"></asp:LinkButton>
                </li>
            </ul>
        </div>

        <!-- HERO BANNER WITH VIDEO -->
        <div class="hero">
            <video autoplay muted loop playsinline>
                <source src="potato.mp4" type="video/mp4" />
                Your browser does not support the video tag.
            </video>
            <div class="hero-overlay">
                <h1>Make It A Potato Party</h1>
                <p>The World's Best Flavored Fries &amp; Snacks</p>
            </div>
        </div>

        <!-- PROMO BANNER -->
        <div class="promo-banner">
            <div class="promo-inner">
                <div class="promo-text">
                    <h2>Craving Something<br />Delicious?</h2>
                    <p>Indulge in the crispiest, most flavorful fries you'll ever taste. Choose from a wide range of seasonings and sizes - there's a perfect fry for every mood.</p>
                    <asp:Button ID="btnOrder1" runat="server"
                        Text="Order Now"
                        CssClass="btn-order"
                        OnClick="btnOrder_Click"
                        OnClientClick="return handleOrderClick();" />
                </div>
                <div class="promo-img">
                    <img src="ba.jpg" alt="Potato Corner Fries" />
                </div>
            </div>
        </div>

        <!-- FLAVOR BANNER -->
        <div class="promo-banner">
            <div class="promo-inner">
                <div class="promo-text">
                    <h2>Big Flavors,<br />Bigger Sizes!</h2>
                    <p>From our signature cheese to bold BBQ and sweet chocolate - every bite is packed with flavor. Available in Solo, Large, Giga, and Tera sizes, because one serving is never enough.</p>
                </div>
                <div class="promo-img">
                    <img src="finalhomepage.jpg" alt="Potato Corner Flavors" />
                </div>
            </div>
        </div>

        <!-- FLAVOR THE MOMENT -->
        <div class="flavor-section">
            <h2>#FlavorTheMoment</h2>
        </div>

        <!-- FOOTER -->
        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms &amp; Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">© 2026 Potato Corner. All rights reserved.</div>
        </div>

        <!-- LOGIN REQUIRED MODAL -->
        <div id="loginRequiredModal" class="login-modal-overlay">
            <div class="login-modal-box">
                <div class="login-modal-icon">🛒</div>
                <div class="login-modal-title">Login Required</div>
                <div class="login-modal-msg">
                    You need to be logged in to place an order. Create an account
                    to start ordering your favorite <strong>Potato Corner</strong> flavors!
                </div>
                <div class="login-modal-btns">
                    <a href="Login.aspx" class="btn-modal-login">Login</a>
                    <a href="Register.aspx" class="btn-modal-register">Register</a>
                </div>
                <button type="button" class="login-modal-skip" onclick="closeLoginModal()">
                    Already browsing? Continue as guest
                </button>
            </div>
        </div>

    </form>

    <script type="text/javascript">
        // Rendered from server — true if user session exists, false if guest
        var isLoggedIn = <%= Session["CustomerID"] != null ? "true" : "false" %>;

        function handleOrderClick() {
            if (!isLoggedIn) {
                openLoginModal();
                return false; // Prevent postback / navigation
            }
            return true; // Allow normal postback for logged-in users
        }

        function openLoginModal() {
            document.getElementById('loginRequiredModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeLoginModal() {
            document.getElementById('loginRequiredModal').classList.remove('active');
            document.body.style.overflow = 'auto';
        }

        // Close when clicking the dark backdrop
        document.getElementById('loginRequiredModal').addEventListener('click', function (e) {
            if (e.target === this) closeLoginModal();
        });
    </script>
</body>
</html>