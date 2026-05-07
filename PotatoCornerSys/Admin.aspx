<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="PotatoCornerSys.Admin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin Dashboard - Potato Corner</title>
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: white;
            overflow-x: hidden;
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

        .admin-container {
            max-width: 1400px;
            margin: 50px auto;
            padding: 0 40px;
        }

        .admin-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .admin-header h1 {
            font-size: 42px;
            color: #e8401c;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 8px;
        }

        .admin-header p {
            font-size: 18px;
            color: #666;
        }

        .admin-tabs {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-bottom: 40px;
            flex-wrap: wrap;
        }

        .tab-button {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            padding: 14px 35px;
            font-size: 15px;
            font-weight: 800;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-transform: uppercase;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(245, 200, 0, 0.3);
        }

        .tab-button:hover {
            background: linear-gradient(135deg, #ffd700 0%, #f5c800 100%);
            transform: translateY(-3px);
            box-shadow: 0 6px 16px rgba(245, 200, 0, 0.4);
        }

        .tab-button.active {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
        }

        .content-section {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.1);
            min-height: 400px;
        }
        
        /* ABOUT US SECTION */
        .about-section {
            margin-bottom: 60px;
        }
        
        .about-hero {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            padding: 40px;
            border-radius: 20px;
            text-align: center;
            color: white;
            margin-bottom: 40px;
            box-shadow: 0 8px 30px rgba(232, 64, 28, 0.3);
        }
        
        .about-hero h2 {
            font-size: 38px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 12px;
        }
        
        .about-hero p {
            font-size: 18px;
            line-height: 1.8;
            max-width: 800px;
            margin: 0 auto;
            opacity: 0.95;
        }
        
        .about-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            margin-bottom: 50px;
        }
        
        .about-card {
            background: #f8f8f8;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            transition: all 0.3s;
        }
        
        .about-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }
        
        .about-card img {
            width: 100%;
            height: 300px;
            object-fit: cover;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        
        .about-card h3 {
            font-size: 28px;
            font-weight: 900;
            color: #e8401c;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .about-card p {
            font-size: 15px;
            line-height: 1.8;
            color: #555;
            margin-bottom: 12px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 25px;
            margin-top: 50px;
        }
        
        .stat-box {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            padding: 30px 20px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(245,200,0,0.3);
            transition: all 0.3s;
        }
        
        .stat-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(245,200,0,0.4);
        }
        
        .stat-box .stat-number {
            font-size: 36px;
            font-weight: 900;
            color: #1a1a1a;
            margin-bottom: 8px;
        }
        
        .stat-box .stat-label {
            font-size: 14px;
            font-weight: 700;
            color: #333;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        @media (max-width: 768px) {
            .about-content {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        .footer {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            text-align: center;
            padding: 60px 40px;
            font-size: 15px;
            border-top: 5px solid #f5c800;
            margin-top: 80px;
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <div class="navbar">
            <div class="navbar-logo">
                <img src="logopotcor.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><asp:LinkButton ID="lnkSales" runat="server" OnClick="lnkSales_Click" Text="Sales"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate" runat="server" OnClick="lnkUpdate_Click" Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" OnClick="lnkProfile_Click" Text="Profile"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="admin-container">
            <div class="admin-header">
                <h1>Admin Dashboard</h1>
                <p>Welcome, <asp:Label ID="lblAdminName" runat="server" Text="Administrator"></asp:Label></p>
            </div>

            <div class="admin-tabs">
                <asp:Button ID="btnSalesTab" runat="server" Text="Sales" CssClass="tab-button active" OnClick="btnSalesTab_Click" />
                <asp:Button ID="btnUpdateTab" runat="server" Text="Update Stock" CssClass="tab-button" OnClick="btnUpdateTab_Click" />
                <asp:Button ID="btnProfileTab" runat="server" Text="Profile" CssClass="tab-button" OnClick="btnProfileTab_Click" />
            </div>

            <div class="content-section">
                <!-- ABOUT US SECTION -->
                <div class="about-section">
                    <div class="about-hero">
                        <h2>About Potato Corner</h2>
                        <p>The world's leading flavored french fries brand, serving happiness one fry at a time since 1992. With over 500 stores worldwide, we continue to bring smiles and satisfaction to millions of customers.</p>
                    </div>
                    
                    <div class="about-content">
                        <div class="about-card">
                            <img src="CREW-PHOTO-copy.jpg" alt="Our Amazing Team" />
                            <h3>Our Amazing Team</h3>
                            <p>Behind every delicious serving of Potato Corner fries is a dedicated team of passionate individuals who work tirelessly to bring joy to our customers.</p>
                            <p>Our crew members are trained to deliver exceptional service with a smile, ensuring that every customer experience is memorable. From preparation to serving, they embody our commitment to quality and customer satisfaction.</p>
                            <p>We believe in fostering a positive work environment where teamwork, creativity, and excellence thrive. Our employees are the heart of Potato Corner, and their dedication drives our success.</p>
                        </div>
                        
                        <div class="about-card">
                            <img src="branches.jpg" alt="Potato Corner Store" />
                            <h3>Our Legacy</h3>
                            <p>Potato Corner started with a simple vision: to create the most flavorful and exciting french fries experience. Today, we're proud to be a global brand recognized for innovation and quality.</p>
                            <p>Our signature flavors - from BBQ to Sour Cream, Cheese to Chili BBQ - have become favorites across generations. Each flavor is carefully crafted to deliver the perfect balance of taste and satisfaction.</p>
                            <p>With locations spanning multiple countries, we continue to expand while maintaining the same commitment to quality that made us famous. Every store upholds our standards of freshness, flavor, and friendly service.</p>
                        </div>
                    </div>
                    
                    <div class="stats-grid">
                        <div class="stat-box">
                            <div class="stat-number">500+</div>
                            <div class="stat-label">Stores Worldwide</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-number">30+</div>
                            <div class="stat-label">Years of Excellence</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-number">10M+</div>
                            <div class="stat-label">Happy Customers</div>
                        </div>
                        <div class="stat-box">
                            <div class="stat-number">8</div>
                            <div class="stat-label">Signature Flavors</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="footer">
            <div class="footer-links">
                <a href="#">Terms and Conditions</a> |
                <a href="#">Privacy Policy</a>
            </div>
            <div class="footer-copy">(c) 2026 Potato Corner. All rights reserved.</div>
        </div>

    </form>
</body>
</html>