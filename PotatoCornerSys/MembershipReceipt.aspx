<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MembershipReceipt.aspx.cs" Inherits="PotatoCornerSys.MembershipReceipt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
        <title>Membership Receipt - Potato Corner</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: linear-gradient(135deg, #f0f4f8 0%, #e8eef3 100%);
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        .receipt-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            border: 2px solid #119247;
        }

        .header {
            text-align: center;
            border-bottom: 2px solid #f5c800;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }

        .header img {
            height: 50px;
            margin-bottom: 8px;
        }

        .header h1 {
            font-size: 22px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            margin-bottom: 3px;
        }

        .header p {
            color: #666;
            font-size: 12px;
        }

        .success-badge {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            padding: 6px 15px;
            border-radius: 50px;
            display: inline-block;
            font-weight: 700;
            font-size: 12px;
            margin-bottom: 10px;
            box-shadow: 0 3px 10px rgba(40,167,69,0.3);
        }

        .member-info {
            display: grid;
            grid-template-columns: 120px 1fr;
            gap: 15px;
            margin-bottom: 15px;
        }

        .member-photo img {
            width: 110px;
            height: 110px;
            border-radius: 10px;
            object-fit: cover;
            border: 2px solid #119247;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
        }

        .member-details {
            display: grid;
            gap: 5px;
        }

        .detail-row {
            display: grid;
            grid-template-columns: 110px 1fr;
            padding: 5px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .detail-label {
            font-weight: 700;
            color: #119247;
            font-size: 11px;
        }

        .detail-value {
            color: #333;
            font-size: 11px;
        }

        .royalty-number {
            background: linear-gradient(135deg, #f5c800 0%, #ffd700 100%);
            padding: 8px;
            border-radius: 10px;
            text-align: center;
            margin-bottom: 10px;
            box-shadow: 0 3px 10px rgba(245,200,0,0.3);
        }

        .royalty-number-label {
            font-size: 10px;
            color: #333;
            font-weight: 600;
            margin-bottom: 2px;
        }

        .royalty-number-value {
            font-size: 18px;
            color: #119247;
            font-weight: 900;
            letter-spacing: 1px;
        }

        .fee-section {
            background: linear-gradient(135deg, #fffbf0 0%, #fff3e0 100%);
            border: 2px solid #f5c800;
            border-radius: 8px;
            padding: 8px;
            margin-bottom: 10px;
            text-align: center;
        }

        .fee-label {
            font-size: 10px;
            color: #666;
            margin-bottom: 2px;
        }

        .fee-amount {
            font-size: 20px;
            color: #e8401c;
            font-weight: 900;
        }

        .buttons {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin-top: 15px;
        }

        .btn {
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
        }

        .btn-print {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            box-shadow: 0 3px 10px rgba(17,146,71,0.3);
        }

        .btn-home {
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            box-shadow: 0 3px 10px rgba(232,64,28,0.3);
        }

        @media print {
            body {
                background: white;
                padding: 0;
            }
            .buttons {
                display: none;
            }
            .receipt-card {
                box-shadow: none;
                border: 1px solid #119247;
                padding: 15px;
            }
            .header img {
                height: 40px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="receipt-card">
                <div class="header">
                    <img src="potato.png" alt="Potato Corner" />
                    <h1>Membership Receipt</h1>
                    <p>Thank you for joining our Royalty Program!</p>
                </div>

                <div style="text-align: center;">
                    <div class="success-badge">Registration Successful</div>
                </div>

                <div class="royalty-number">
                    <div class="royalty-number-label">Your Royalty Number</div>
                    <div class="royalty-number-value"><asp:Label ID="lblRoyaltyNumber" runat="server"></asp:Label></div>
                </div>

                <div class="member-info">
                    <div class="member-photo">
                        <asp:Image ID="imgMemberPhoto" runat="server" />
                    </div>
                    <div class="member-details">
                        <div class="detail-row">
                            <div class="detail-label">Member ID:</div>
                            <div class="detail-value"><asp:Label ID="lblMemberID" runat="server"></asp:Label></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">Full Name:</div>
                            <div class="detail-value"><asp:Label ID="lblFullName" runat="server"></asp:Label></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">Email:</div>
                            <div class="detail-value"><asp:Label ID="lblEmail" runat="server"></asp:Label></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">Contact Number:</div>
                            <div class="detail-value"><asp:Label ID="lblContact" runat="server"></asp:Label></div>
                        </div>
                        <div class="detail-row">
                            <div class="detail-label">Date Joined:</div>
                            <div class="detail-value"><asp:Label ID="lblDateJoined" runat="server"></asp:Label></div>
                        </div>
                    </div>
                </div>

                <div class="fee-section">
                    <div class="fee-label">Registration Fee Paid</div>
                    <div class="fee-amount">PHP <asp:Label ID="lblFee" runat="server"></asp:Label></div>
                </div>

                <div class="member-details" style="grid-column: 1 / -1; margin-top: 20px;">
                    <div class="detail-row">
                        <div class="detail-label">Payment Method:</div>
                        <div class="detail-value"><asp:Label ID="lblPaymentMethod" runat="server"></asp:Label></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Amount Paid:</div>
                        <div class="detail-value">PHP <asp:Label ID="lblAmountPaid" runat="server"></asp:Label></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Change:</div>
                        <div class="detail-value">PHP <asp:Label ID="lblChange" runat="server"></asp:Label></div>
                    </div>
                </div>

                <div class="buttons">
                    <asp:Button ID="btnPrint" runat="server" Text="Print Receipt" CssClass="btn btn-print" OnClientClick="window.print(); return false;" />
                    <asp:Button ID="btnHome" runat="server" Text="Go to Home" CssClass="btn btn-home" OnClick="btnHome_Click" />
                </div>
            </div>
        </div>
    </form>
</body>
</html>
