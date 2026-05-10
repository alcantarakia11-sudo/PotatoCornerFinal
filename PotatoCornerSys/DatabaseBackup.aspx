<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DatabaseBackup.aspx.cs" Inherits="PotatoCornerSys.DatabaseBackup" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Database Backup & Recovery - Potato Corner</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: linear-gradient(135deg, #f0f4f8 0%, #e8eef3 100%);
            padding: 20px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .header {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            padding: 25px;
            border-radius: 12px 12px 0 0;
            text-align: center;
            border-bottom: 4px solid #f5c800;
        }

        .header h1 {
            font-size: 24px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .content {
            background: white;
            padding: 30px;
            border-radius: 0 0 12px 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }

        .section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border-left: 4px solid #119247;
        }

        .section-title {
            font-size: 18px;
            font-weight: 700;
            color: #119247;
            margin-bottom: 15px;
            text-transform: uppercase;
        }

        .section-desc {
            color: #666;
            font-size: 14px;
            margin-bottom: 15px;
            line-height: 1.6;
        }

        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-right: 10px;
        }

        .btn-backup {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(17,146,71,0.3);
        }

        .btn-backup:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(17,146,71,0.4);
        }

        .btn-export {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(33,150,243,0.3);
        }

        .btn-export:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(33,150,243,0.4);
        }

        .btn-restore {
            background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(255,152,0,0.3);
        }

        .btn-restore:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(255,152,0,0.4);
        }

        .message {
            padding: 12px 15px;
            border-radius: 8px;
            margin-top: 15px;
            font-size: 14px;
            font-weight: 600;
        }

        .success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        .info {
            background: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }

        .file-upload {
            margin-top: 10px;
        }

        .backup-history {
            margin-top: 20px;
        }

        .backup-item {
            background: white;
            padding: 12px 15px;
            margin-bottom: 10px;
            border-radius: 8px;
            border: 2px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .backup-info {
            flex: 1;
        }

        .backup-name {
            font-weight: 700;
            color: #119247;
            font-size: 14px;
        }

        .backup-date {
            color: #666;
            font-size: 12px;
        }

        .back-link {
            text-align: center;
            margin-top: 20px;
        }

        .btn-back {
            display: inline-block;
            padding: 12px 30px;
            background: #e0e0e0;
            color: #666;
            text-decoration: none;
            font-weight: 700;
            border-radius: 8px;
            transition: all 0.3s;
        }

        .btn-back:hover {
            background: #d0d0d0;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="header">
                <h1>Database Backup & Recovery</h1>
            </div>

            <div class="content">
                <!-- Backup Section -->
                <div class="section">
                    <div class="section-title">Create Database Backup</div>
                    <div class="section-desc">
                        Create a full backup of your database. This will save all your data including users, orders, products, and membership information.
                    </div>
                    <asp:Button ID="btnBackup" runat="server" Text="Create Backup" CssClass="btn btn-backup" OnClick="btnBackup_Click" />
                    <asp:Label ID="lblBackupMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
                </div>

                <!-- Export Section -->
                <div class="section">
                    <div class="section-title">Export Data to CSV</div>
                    <div class="section-desc">
                        Export your data to CSV format for easy viewing and analysis in Excel or other spreadsheet applications.
                    </div>
                    <asp:Button ID="btnExportOrders" runat="server" Text="Export Orders" CssClass="btn btn-export" OnClick="btnExportOrders_Click" />
                    <asp:Label ID="lblExportMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
                </div>

                <!-- Restore Section -->
                <div class="section">
                    <div class="section-title">Restore Database</div>
                    <div class="section-desc">
                        <strong>Warning:</strong> Restoring a backup will replace all current data. Make sure you have a recent backup before proceeding.
                    </div>
                    <div class="file-upload">
                        <asp:FileUpload ID="fileRestore" runat="server" />
                    </div>
                    <asp:Button ID="btnRestore" runat="server" Text="Restore from Backup" CssClass="btn btn-restore" OnClick="btnRestore_Click" />
                    <asp:Label ID="lblRestoreMessage" runat="server" CssClass="message" Visible="false"></asp:Label>
                </div>

                <!-- Backup History -->
                <div class="section">
                    <div class="section-title">Recent Backups</div>
                    <div class="backup-history">
                        <asp:Literal ID="litBackupHistory" runat="server"></asp:Literal>
                    </div>
                </div>

                <div class="back-link">
                    <a href="AccountAdmin.aspx" class="btn-back">Back to Profile</a>
                </div>
            </div>
        </div>
    </form>
</body>
</html>