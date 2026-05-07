<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AboutUs.aspx.cs" Inherits="PotatoCornerSys.AboutUs" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - About Us</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #e8e8e8;
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

        /* ACTIVE NAV LINK */

        .navbar-links .active {
            color: #f5c800 !important;
        }

        .navbar-links .active::after {
            width: 0 !important;
        }


        /* HERO BANNER */
        .hero-banner {
            background: #e8e8e8;
            padding: 30px 40px 50px 40px;
        }
        
        .hero-content {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        .history-header {
            background: linear-gradient(135deg, #e8401c 0%, #ff6b47 100%);
            padding: 25px 40px;
            border-radius: 16px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }
        
        .history-header h1 {
            font-size: 42px;
            font-weight: 900;
            color: white;
            text-transform: uppercase;
            letter-spacing: 4px;
            text-shadow: 0 3px 15px rgba(0,0,0,0.2);
        }
        
        /* ABOUT US CONTAINER */
        .about-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 80px 40px;
        }
        
        /* SECTION STYLES */
        .about-section {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 60px;
            align-items: center;
            margin-bottom: 100px;
        }
        
        .about-section:last-child {
            margin-bottom: 0;
        }
        
        .about-section.reverse {
            direction: rtl;
        }
        
        .about-section.reverse > * {
            direction: ltr;
        }
        
        .about-text {
            padding: 0;
            background: transparent;
            box-shadow: none;
            border: none;
        }
        
        .about-text:hover {
            transform: none;
            box-shadow: none;
        }
        
        .about-text h2 {
            font-size: 32px;
            font-weight: 900;
            color: #119247;
            margin-bottom: 20px;
            line-height: 1.3;
        }
        
        .about-text p {
            font-size: 16px;
            line-height: 1.9;
            color: #444;
            text-align: justify;
        }
        
        .about-image {
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            position: relative;
            transition: all 0.3s;
        }
        
        .about-image:hover {
            transform: scale(1.02);
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
        }
        
        .about-image::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(17,146,71,0.1) 0%, transparent 100%);
            z-index: 1;
            pointer-events: none;
        }
        
        .about-image img {
            width: 100%;
            height: 450px;
            object-fit: cover;
            display: block;
        }
        
        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 40px;
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
            .about-section {
                grid-template-columns: 1fr;
                gap: 40px;
            }
            
            .about-section.reverse {
                direction: ltr;
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
                <li><a href="AboutUs.aspx" class="active">About Us</a></li>
                <li><a href="Order.aspx" class="btn-order-nav">Order Now</a></li>
                <li><a href="Profile.aspx">Profile</a></li>
            </ul>
        </div>
        
        <!-- HERO BANNER -->
        <div class="hero-banner">
            <div class="hero-content">
                <div class="history-header">
                    <h1>HISTORY</h1>
                </div>
            </div>
        </div>
        
        <!-- ABOUT US CONTENT -->
        <div class="about-container">
            
            <!-- SECTION 1: Text - Image -->
            <div class="about-section">
                <div class="about-text">
                    <h2>The World's Best Flavored Fries - 32 Years Strong and Counting</h2>
                    <p>
                        Wherever you go in the Philippines, you're bound to spot a vibrant green kiosk with a smiling spud inviting you in. 
                        That iconic sight is Potato Corner—home of the world-famous flavored fries and the brand that ignited a global snacking phenomenon. 
                        For over 32 years, Potato Corner has been the go-to venture for budding entrepreneurs and a beloved favorite among kids and kids-at-heart.
                        From its humble beginning in 1992 to its extensive worldwide network today, Potato Corner continues to bring joy, opportunity, and flavor to every corner of the world.
                    </p>
                </div>
                <div class="about-image">
                    <img src="CREW-PHOTO-copy.jpg" alt="Potato Corner Store" />
                </div>
            </div>
            
            <!-- SECTION 2: Image - Text -->
            <div class="about-section reverse">
                <div class="about-text">
                    <h2>Global Presence, Local Flavor</h2>
                    <p>
                        Potato Corner has grown into a global brand with more than 2,000 stores in 15 countries as of late 2025. 
                        While it remains strongly rooted in the Philippines, it has also built a solid international presence with over 400 locations worldwide. 
                        The company's expansion accelerated after its acquisition by Shakey's Pizza, leading to the continuous opening of new kiosks, carts, 
                        and counters across different parts of the world.
                    </p>
                </div>
                <div class="about-image">
                    <img src="branches.jpg" alt="Potato Corner Branches" />
                </div>
            </div>
            
            <!-- SECTION 3: Text - Image -->
            <div class="about-section">
                <div class="about-text">
                    <h2>Award-Winning Excellence</h2>
                    <p>
                        Throughout the years, Potato Corner has garnered numerous awards, mostly recognizing its excellent business model and well-loved brand. 
                        It has received the Franchise Excellence Hall of Fame Award by the Philippine Franchise Association and Department of Trade and Industry in 2003, 
                        won Best Franchise of the Year on three consecutive years, and most recently, bagged the Global Franchise Award recognized by the same institution. 
                        Potato Corner is truly an iconic brand for kids and kids-at-heart and a distinguished business venture for entrepreneurs.
                    </p>
                </div>
                <div class="about-image">
                    <img src="award.jpg" alt="Potato Corner Awards" />
                </div>
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
