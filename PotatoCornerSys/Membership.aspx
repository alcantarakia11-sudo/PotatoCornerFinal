<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Membership.aspx.cs" Inherits="PotatoCornerSys.Membership" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>Potato Corner - Membership</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, sans-serif; 
            background: linear-gradient(135deg, #f0f4f8 0%, #e8eef3 100%);
            min-height: 100vh;
        }
        
        /* NAVBAR - CONSISTENT ACROSS ALL PAGES */
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

        
        /* HERO BANNER - ORANGE */
        .hero { 
            background: #e8e8e8;
            padding: 30px 40px 50px 40px;
        }
        
        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .hero-banner {
            background: linear-gradient(135deg, #e8401c 0%, #ff6b47 100%);
            padding: 15px 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }
        
        .hero-banner h1 { 
            font-size: 48px; 
            color: white; 
            font-weight: 900; 
            text-transform: uppercase; 
            letter-spacing: 4px; 
            text-shadow: 0 3px 15px rgba(0,0,0,0.2);
            margin-bottom: 0;
        }
        
        /* MAIN CONTAINER */
        .container { 
            max-width: 1400px; 
            margin: 50px auto; 
            padding: 0 40px;
        }
        
        /* TWO COLUMN LAYOUT */
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin-bottom: 50px;
        }
        
        /* BENEFITS CARD */
        .benefits-card { 
            background: white;
            border-radius: 24px; 
            padding: 40px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            border: 3px solid #119247;
            position: relative;
            overflow: hidden;
        }
        
        .benefits-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 6px;
            background: linear-gradient(90deg, #f5c800 0%, #ffd700 100%);
        }
        
        .card-title { 
            color: #119247; 
            font-size: 32px; 
            margin-bottom: 30px; 
            text-transform: uppercase;
            font-weight: 900;
            letter-spacing: 1px;
        }
        
        .benefits-list { 
            list-style: none; 
            padding: 0;
        }
        
        .benefit-item { 
            padding: 18px 20px; 
            margin-bottom: 15px; 
            background: linear-gradient(135deg, #e8f5ee 0%, #f8f9fa 100%);
            border-left: 5px solid #119247;
            border-radius: 10px;
            font-size: 17px; 
            color: #333;
            font-weight: 600;
            transition: all 0.3s;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .benefit-item:hover {
            transform: translateX(10px);
            box-shadow: 0 4px 15px rgba(17,146,71,0.2);
            background: linear-gradient(135deg, #d4edda 0%, #e8f5ee 100%);
        }
        
        .benefit-item:last-child {
            margin-bottom: 0;
        }
        
        /* HOW IT WORKS CARD */
        .how-it-works-card {
            background: linear-gradient(135deg, #fffbf0 0%, #ffffff 100%);
            border-radius: 24px; 
            padding: 40px; 
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            border: 3px solid #f5c800;
            position: relative;
            overflow: hidden;
        }
        
        .how-it-works-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 6px;
            background: linear-gradient(90deg, #119247 0%, #0d7336 100%);
        }
        
        .steps-list {
            list-style: none;
            padding: 0;
        }
        
        .step-item {
            padding: 20px;
            margin-bottom: 20px;
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 15px;
            position: relative;
            padding-left: 80px;
            transition: all 0.3s;
        }
        
        .step-item:hover {
            border-color: #f5c800;
            box-shadow: 0 6px 20px rgba(245,200,0,0.2);
            transform: translateY(-3px);
        }
        
        .step-number {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            font-weight: 900;
            color: #333;
            box-shadow: 0 3px 10px rgba(245,200,0,0.4);
        }
        
        .step-content h3 {
            font-size: 20px;
            color: #119247;
            margin-bottom: 8px;
            font-weight: 800;
        }
        
        .step-content p {
            font-size: 15px;
            color: #666;
            line-height: 1.6;
        }
        
        /* CTA SECTION */
        .cta-section { 
            text-align: center; 
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            padding: 50px 40px;
            border-radius: 24px;
            box-shadow: 0 10px 40px rgba(232,64,28,0.3);
        }
        
        .cta-section h2 {
            font-size: 36px;
            color: white;
            margin-bottom: 20px;
            font-weight: 900;
            text-transform: uppercase;
        }
        
        .cta-section p {
            font-size: 18px;
            color: white;
            margin-bottom: 30px;
        }
        
        .btn-register { 
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            color: #333; 
            padding: 20px 60px; 
            font-size: 20px; 
            font-weight: 900; 
            border: none; 
            border-radius: 50px; 
            cursor: pointer; 
            text-transform: uppercase; 
            box-shadow: 0 8px 25px rgba(245,200,0,0.5); 
            transition: all 0.3s; 
            letter-spacing: 2px;
        }
        
        .btn-register:hover { 
            transform: translateY(-5px) scale(1.05); 
            box-shadow: 0 12px 35px rgba(245,200,0,0.6);
        }
        
        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 40px;
            margin-top: 50px;
            border-top: 5px solid #f5c800;
        }
        
        .footer-links {
            margin-bottom: 20px;
        }
        
        .footer-links a {
            color: #f5c800;
            text-decoration: none;
            margin: 0 15px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .footer-links a:hover {
            color: white;
        }
        
        .footer-copy {
            font-size: 14px;
            color: #ccc;
            margin-top: 15px;
        }
        
        /* RESPONSIVE */
        @media (max-width: 1024px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .hero h1 { 
                font-size: 36px; 
            }
            
            .navbar {
                flex-direction: column;
                gap: 20px;
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
                <li><a href="Default.aspx">Home</a></li>
                <li><a href="Menu.aspx">Menu</a></li>
                <li><a href="Membership.aspx">Membership</a></li>
                <li><a href="AboutUs.aspx">About Us</a></li>
                <li><a href="Order.aspx" class="btn-order-nav">Order Now</a></li>
                <li><a href="Profile.aspx">Profile</a></li>
            </ul>
        </div>
        
        <!-- HERO BANNER - ORANGE -->
        <div class="hero">
            <div class="hero-content">
                <div class="hero-banner">
                    <h1>ROYALTY MEMBERSHIP</h1>
                </div>
            </div>
        </div>
        
        <!-- MAIN CONTENT -->
        <div class="container">
            <div class="content-grid">
                <!-- BENEFITS CARD -->
                <div class="benefits-card">
                    <h2 class="card-title">Member Benefits</h2>
                    <ul class="benefits-list">
                        <li class="benefit-item">Get 10% discount on all orders</li>
                        <li class="benefit-item">Earn 2 points for every PHP 500 spent</li>
                        <li class="benefit-item">Redeem points for free items</li>
                        <li class="benefit-item">Exclusive access to new flavors</li>
                        <li class="benefit-item">Birthday special treats</li>
                        <li class="benefit-item">Priority service during peak hours</li>
                        <li class="benefit-item">Member-only promotions</li>
                    </ul>
                </div>
                
                <!-- HOW IT WORKS CARD -->
                <div class="how-it-works-card">
                    <h2 class="card-title">How It Works</h2>
                    <ul class="steps-list">
                        <li class="step-item">
                            <div class="step-number">1</div>
                            <div class="step-content">
                                <h3>Register</h3>
                                <p>Sign up for free and get your Royalty Card number instantly</p>
                            </div>
                        </li>
                        <li class="step-item">
                            <div class="step-number">2</div>
                            <div class="step-content">
                                <h3>Shop & Earn</h3>
                                <p>Use your card on every purchase to earn points and get discounts</p>
                            </div>
                        </li>
                        <li class="step-item">
                            <div class="step-number">3</div>
                            <div class="step-content">
                                <h3>Redeem Rewards</h3>
                                <p>Exchange your points for free items and exclusive offers</p>
                            </div>
                        </li>
                        <li class="step-item">
                            <div class="step-number">4</div>
                            <div class="step-content">
                                <h3>Enjoy Perks</h3>
                                <p>Access special promotions and priority service year-round</p>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>
            
            <!-- CTA SECTION -->
            <div class="cta-section">
                <h2>Ready to Join?</h2>
                <p>Start enjoying exclusive benefits today - it's free and easy!</p>
                <asp:Button ID="btnRegister" runat="server" Text="Register Now" CssClass="btn-register" OnClick="btnRegister_Click" />
            </div>
        </div>
        
        <!-- FOOTER -->
        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms & Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">© 2026 Potato Corner. All rights reserved.</div>
        </div>
    </form>
</body>
</html>
