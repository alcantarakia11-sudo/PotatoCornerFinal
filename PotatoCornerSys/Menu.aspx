<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PotatoCornerSys.Menu" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Menu</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: #e8e8e8;
            min-height: 100vh;
        }
        
        /* MAIN CONTAINER */
        .menu-container { 
            max-width: 1600px; 
            margin: 0 auto; 
            padding: 40px 40px;
        }
        
        /* PAGE TITLE WITH ORANGE CONTAINER */
        .page-title {
            font-size: 48px;
            font-weight: 900;
            color: white;
            margin-bottom: 50px;
            text-align: center;
            background: #e8401c;
            padding: 15px 40px;
            border-radius: 16px;
            text-transform: uppercase;
            letter-spacing: 4px;
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
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
        
        /* ORDER NOW BUTTON */
        .navbar-links .btn-order-nav {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white !important;
            padding: 12px 28px;
            border-radius: 8px;
            font-weight: 800;
            font-size: 15px;
            text-transform: uppercase;
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
            transition: all 0.3s;
        }

        .navbar-links .btn-order-nav:hover {
            background: linear-gradient(135deg, #c73516 0%, #a82a12 100%);
            color: white !important;
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(232,64,28,0.4);
        }
        
        /* SECTION */
        .menu-section {
            margin-bottom: 80px;
        }
        
        .section-header {
            font-size: 28px;
            font-weight: 900;
            color: #119247;
            margin-bottom: 40px;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 3px;
            position: relative;
            padding-bottom: 15px;
        }
        
        .section-header::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 120px;
            height: 4px;
            background: linear-gradient(90deg, #f5c800 0%, #ffd700 100%);
            border-radius: 2px;
        }
        
        /* ITEMS GRID - HORIZONTAL LAYOUT */
        .items-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 60px;
            justify-items: center;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .items-grid.flavors {
            grid-template-columns: repeat(4, 1fr);
            gap: 80px;
            max-width: 1400px;
        }
        
        /* Center items when there are only 2 items (Loopys) */
        .items-grid:has(.item-card:nth-child(2):last-child) {
            grid-template-columns: repeat(2, 1fr);
            max-width: 800px;
        }
        
        /* ITEM CARD */
        .item-card {
            text-align: center;
            transition: transform 0.3s;
        }
        
        .item-card:hover {
            transform: translateY(-8px);
        }
        
        /* CIRCULAR FLAVOR IMAGES */
        .flavor-image {
            width: 180px;
            height: 180px;
            border-radius: 50%;
            overflow: hidden;
            margin: 0 auto 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            transition: all 0.3s;
        }
        
        .item-card:hover .flavor-image {
            box-shadow: 0 12px 35px rgba(0,0,0,0.25);
            transform: scale(1.05);
        }
        
        .flavor-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        /* PRODUCT SIZE IMAGES */
        .size-image {
            width: 200px;
            height: 200px;
            margin: 0 auto 15px;
            transition: all 0.3s;
        }
        
        .item-card:hover .size-image {
            transform: scale(1.08);
        }
        
        .size-image img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            filter: drop-shadow(0 8px 20px rgba(0,0,0,0.15));
        }
        
        /* ITEM LABEL */
        .item-label {
            font-size: 16px;
            font-weight: 700;
            color: #119247;
            text-transform: capitalize;
        }
        
        /* RESPONSIVE */
        @media (max-width: 1200px) {
            .items-grid {
                gap: 40px;
            }
            
            .items-grid.flavors {
                gap: 60px;
            }
            
            .flavor-image {
                width: 150px;
                height: 150px;
            }
            
            .size-image {
                width: 170px;
                height: 170px;
            }
        }
        
        @media (max-width: 768px) {
            .navbar { 
                flex-direction: column; 
                gap: 20px; 
                padding: 20px;
            }
            
            .navbar-links {
                gap: 20px;
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .menu-container {
                padding: 40px 20px;
            }
            
            .page-title {
                font-size: 36px;
            }
            
            .items-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 30px;
            }
            
            .items-grid.flavors {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .flavor-image {
                width: 140px;
                height: 140px;
            }
            
            .size-image {
                width: 160px;
                height: 160px;
            }
        }
        
        @media (max-width: 480px) {
            .items-grid {
                grid-template-columns: 1fr;
            }
            
            .items-grid.flavors {
                grid-template-columns: 1fr;
            }
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

        .footer .footer-links {
            margin-bottom: 24px;
        }

        .footer .footer-copy {
            margin-top: 20px;
            font-size: 14px;
            color: #ccc;
        }

        /* ACTIVE NAV LINK */
        .navbar-links .active {
            color: #f5c800 !important;
        }

        .navbar-links .active::after{
            width: 0 !important;
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
                <li><a href="Default.aspx">Home</a></li>
                <li><a class="active" href="Menu.aspx">Menu</a></li>
                <li><a href="Membership.aspx">Membership</a></li>
                <li><a href="AboutUs.aspx">About Us</a></li>
                <li><a href="Order.aspx" class="btn-order-nav">Order Now</a></li>
                <li><a href="Profile.aspx">Profile</a></li>
            </ul>
        </div>
        
        <div class="menu-container">
            <h1 class="page-title">Menu</h1>
            
            <!-- FLAVORS SECTION -->
            <div class="menu-section">
                <h2 class="section-header">Flavors</h2>
                <div class="items-grid flavors">
                    <div class="item-card">
                        <div class="flavor-image">
                            <img src="cheese.png" alt="Cheese" />
                        </div>
                        <div class="item-label">Cheese</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="flavor-image">
                            <img src="bbqq.png" alt="BBQ" />
                        </div>
                        <div class="item-label">BBQ</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="flavor-image">
                            <img src="chilibbq.png" alt="Chili BBQ" />
                        </div>
                        <div class="item-label">ChiliBBQ</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="flavor-image">
                            <img src="sourcream.png" alt="Sour Cream" />
                        </div>
                        <div class="item-label">Sour Cream</div>
                    </div>
                </div>
            </div>
            
            <!-- FRIES SECTION -->
            <div class="menu-section">
                <h2 class="section-header">Fries</h2>
                <div class="items-grid">
                    <div class="item-card">
                        <div class="size-image">
                            <img src="regularfries.png" alt="Regular" />
                        </div>
                        <div class="item-label">Regular</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="large.png" alt="Large" />
                        </div>
                        <div class="item-label">Large</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="jumbofries.png" alt="Jumbo" />
                        </div>
                        <div class="item-label">Jumbo</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="megafries.png" alt="Mega" />
                        </div>
                        <div class="item-label">Mega</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="gigafries.png" alt="Giga" />
                        </div>
                        <div class="item-label">Giga</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="terrafries.png" alt="Terra" />
                        </div>
                        <div class="item-label">Terra</div>
                    </div>
                </div>
            </div>
            
            <!-- CHICKEN POPS SECTION -->
            <div class="menu-section">
                <h2 class="section-header">Chicken Pops</h2>
                <div class="items-grid">
                    <div class="item-card">
                        <div class="size-image">
                            <img src="solopops.png" alt="Solo" />
                        </div>
                        <div class="item-label">Solo</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="largepops.png" alt="Large" />
                        </div>
                        <div class="item-label">Large</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="megapops.png" alt="Mega" />
                        </div>
                        <div class="item-label">Mega</div>
                    </div>
                </div>
            </div>
            
            <!-- LOOPYS SECTION -->
            <div class="menu-section">
                <h2 class="section-header">Loopys</h2>
                <div class="items-grid">
                    <div class="item-card">
                        <div class="size-image">
                            <img src="largeloopys.png" alt="Large" />
                        </div>
                        <div class="item-label">Large</div>
                    </div>
                    
                    <div class="item-card">
                        <div class="size-image">
                            <img src="megaloopys.png" alt="Mega" />
                        </div>
                        <div class="item-label">Mega</div>
                    </div>
                </div>
            </div>
            
        </div>
        
        <!-- FOOTER -->
        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms &amp; Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">© 2026 Potato Corner. All rights reserved.</div>
        </div>
    </form>
</body>
</html>
