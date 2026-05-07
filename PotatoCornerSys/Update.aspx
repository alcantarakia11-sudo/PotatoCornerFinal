<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Update.aspx.cs" Inherits="PotatoCornerSys.Update" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Update Stock - Potato Corner</title>
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

        .update-container {
            max-width: 1400px;
            margin: 50px auto;
            padding: 0 40px;
        }

        .update-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .update-header h1 {
            font-size: 48px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        .alert-section {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 20px 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(232,64,28,0.3);
        }

        .alert-section h3 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 10px;
            text-transform: uppercase;
        }

        .alert-section p {
            font-size: 14px;
            line-height: 1.6;
        }

        .stock-section {
            background: white;
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.1);
        }

        .stock-section h2 {
            font-size: 32px;
            color: #119247;
            font-weight: 900;
            margin-bottom: 30px;
            text-transform: uppercase;
        }

        .stock-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .stock-table th {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 0.5px;
        }

        .stock-table td {
            padding: 15px;
            border-bottom: 1px solid #e0e0e0;
            font-size: 14px;
        }

        .stock-table tr:hover {
            background: #f5f5f5;
        }

        .stock-table tr.low-stock {
            background: #fff3cd;
        }

        .stock-input {
            padding: 8px 12px;
            border: 2px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            width: 100px;
            transition: all 0.3s;
        }

        .stock-input:focus {
            border-color: #f5c800;
            outline: none;
        }

        .btn-update {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            padding: 8px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 800;
            font-size: 13px;
            transition: all 0.3s;
        }

        .btn-update:hover {
            background: linear-gradient(135deg, #ffd700 0%, #f5c800 100%);
            transform: translateY(-2px);
        }

        .stock-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            display: inline-block;
        }

        .stock-low {
            background: #f8d7da;
            color: #721c24;
        }

        .stock-ok {
            background: #d4edda;
            color: #155724;
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

        <div class="update-container">
            <div class="update-header">
                <h1>Stock Management</h1>
            </div>

            <asp:Panel ID="pnlLowStockAlert" runat="server" CssClass="alert-section" Visible="false">
                <h3>Low Stock Alert</h3>
                <p><asp:Label ID="lblLowStockItems" runat="server"></asp:Label></p>
            </asp:Panel>

            <div class="stock-section">
                <h2>Products and Flavors</h2>
                <asp:GridView ID="gvStock" runat="server" CssClass="stock-table" AutoGenerateColumns="False" 
                    OnRowCommand="gvStock_RowCommand" OnRowDataBound="gvStock_RowDataBound">
                    <Columns>
                        <asp:BoundField DataField="ProductID" HeaderText="ID" />
                        <asp:BoundField DataField="ProductName" HeaderText="Product/Flavor" />
                        <asp:BoundField DataField="Category" HeaderText="Category" />
                        <asp:BoundField DataField="CurrentStock" HeaderText="Current Stock" />
                        <asp:TemplateField HeaderText="Add Stock">
                            <ItemTemplate>
                                <asp:TextBox ID="txtAddStock" runat="server" CssClass="stock-input" 
                                    Text="0" TextMode="Number"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <asp:Label ID="lblStockStatus" runat="server" CssClass="stock-badge"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:Button ID="btnUpdateStock" runat="server" Text="Update" CssClass="btn-update" 
                                    CommandName="UpdateStock" CommandArgument='<%# Eval("ProductID") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
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