<%@ Page Title="Verify Reset Code" Language="C#" AutoEventWireup="true" CodeBehind="VerifyResetCode.aspx.cs" Inherits="PotatoCornerSys.VerifyResetCode" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Verify Reset Code - Potato Corner</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f5f5f5;
            font-family: system-ui, sans-serif;
            padding: 20px;
        }
        .card {
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .btn-potato {
            background-color: #8B4513;
            color: #FFD700;
        }
        .btn-potato:hover {
            background-color: #6b3410;
            color: #FFD700;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-6">
                    <div class="card mt-5">
                        <div class="card-header" style="background-color: #8B4513; color: #FFD700;">
                            <h3 class="text-center mb-0">🔐 Verify Reset Code</h3>
                        </div>
                        <div class="card-body">
                            <!-- Message display control -->
                            <asp:Literal ID="litMessage" runat="server" />
                            
                            <div class="alert alert-info">
                                <strong>📧 Check your email!</strong> 
                                We've sent a 6-digit verification code to your email address.
                                Please enter it below to reset your password.
                            </div>
                            
                            <div class="mb-3">
                                <label for="txtResetCode" class="form-label">Enter 6-Digit Verification Code</label>
                                <asp:TextBox ID="txtResetCode" runat="server" 
                                    CssClass="form-control form-control-lg text-center" 
                                    MaxLength="6" 
                                    placeholder="Enter code (e.g., 123456)"
                                    Font-Size="24px"
                                    Font-Bold="true"
                                    TextMode="Number" />
                                <small class="form-text text-muted">The code expires in 10 minutes.</small>
                            </div>
                            
                            <div class="d-grid gap-2 mt-4">
                                <asp:Button ID="btnVerifyCode" runat="server" 
                                    Text="Verify Code & Reset Password" 
                                    CssClass="btn btn-potato btn-lg"
                                    OnClick="btnVerifyCode_Click" />
                            </div>
                            
                            <div class="text-center mt-3">
                                <asp:LinkButton ID="lnkResendCode" runat="server" 
                                    Text="Didn't receive code? Resend" 
                                    OnClick="lnkResendCode_Click"
                                    ForeColor="#8B4513" />
                                <br />
                                <asp:LinkButton ID="lnkBackToLogin" runat="server" 
                                    Text="← Back to Login" 
                                    OnClick="lnkBackToLogin_Click"
                                    ForeColor="#666" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>