<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegisterForm.aspx.cs" Inherits="PotatoCornerSys.RegisterForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - Membership Registration</title>
    <style type="text/css">
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
        }

        .logo {
            text-align: center;
            margin-bottom: 15px;
        }

        .logo img {
            height: 70px;
            filter: drop-shadow(0 4px 10px rgba(0,0,0,0.3));
        }

        .form-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }

        .form-title {
            font-size: 24px;
            color: #119247;
            font-weight: 900;
            text-align: center;
            margin-bottom: 5px;
            text-transform: uppercase;
        }

        .form-subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 15px;
            font-size: 13px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 12px;
            margin-bottom: 15px;
        }

        .form-group { margin-bottom: 0; }
        .form-group.full-width { grid-column: 1 / -1; }
        .form-group.two-col { grid-column: span 2; }

        .form-label {
            display: block;
            font-weight: 700;
            color: #333;
            margin-bottom: 5px;
            font-size: 12px;
        }

        .form-input {
            width: 100%;
            padding: 8px 10px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 13px;
            transition: all 0.3s;
        }

        .form-input[readonly] {
            background: #f0f4f0;
            color: #444;
            cursor: not-allowed;
            border-color: #c8d8c8;
        }

        .prefilled-note {
            font-size: 11px;
            color: #888;
            margin-top: 4px;
            font-style: italic;
        }

        .upload-section {
            background: linear-gradient(135deg, #f8f9fa 0%, #e8f5ee 100%);
            border: 2px dashed #119247;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
        }

        .upload-icon {
            font-size: 16px;
            color: #119247;
            margin-bottom: 5px;
            font-weight: 900;
            letter-spacing: 2px;
        }

        .file-upload {
            display: inline-block;
            padding: 6px 14px;
            background: #119247;
            color: white;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 700;
            font-size: 12px;
            transition: all 0.3s;
        }

        .file-upload:hover { background: #0d7336; }

        #fileNameDisplay {
            margin-top: 6px;
            font-size: 11px;
            color: #119247;
            font-weight: 600;
            word-break: break-all;
        }

        .fee-section {
            background: linear-gradient(135deg, #fffbf0 0%, #fff3e0 100%);
            border: 2px solid #f5c800;
            border-radius: 10px;
            padding: 12px;
            margin-bottom: 12px;
            text-align: center;
        }

        .fee-label { font-size: 12px; color: #666; margin-bottom: 2px; }
        .fee-amount { font-size: 24px; color: #e8401c; font-weight: 900; }

        .payment-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
            margin-top: 6px;
        }

        .payment-btn {
            padding: 8px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            background: white;
            font-weight: 700;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .payment-btn:hover {
            border-color: #119247;
            background: #e8f5ee;
        }

        .payment-btn.selected {
            border-color: #119247;
            background: linear-gradient(135deg, #e8f5ee 0%, #d4edda 100%);
            color: #119247;
        }

        .btn-register {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 900;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(232,64,28,0.4);
            letter-spacing: 1px;
            margin-top: 12px;
        }

        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.5);
        }

        .back-link { text-align: center; margin-top: 20px; }

        .btn-back {
            display: inline-block;
            padding: 12px 30px;
            background: white;
            color: #119247;
            text-decoration: none;
            font-weight: 700;
            font-size: 14px;
            border-radius: 8px;
            border: 2px solid #119247;
            transition: all 0.3s;
        }

        .btn-back:hover {
            background: #119247;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(17,146,71,0.3);
        }

        .error-msg {
            background: #f8d7da;
            color: #721c24;
            padding: 8px;
            border-radius: 6px;
            margin-bottom: 12px;
            border-left: 3px solid #dc3545;
            font-size: 12px;
            display: block;
        }

        .success-msg {
            background: #d4edda;
            color: #155724;
            padding: 8px;
            border-radius: 6px;
            margin-bottom: 12px;
            border-left: 3px solid #28a745;
            font-size: 12px;
            display: block;
        }

        /* ── MODAL BASE ── */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.7);
            z-index: 9999;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(5px);
        }

        .modal-container { animation: modalSlideIn 0.4s ease-out; }

        @keyframes modalSlideIn {
            from { transform: translateY(-50px) scale(0.9); opacity: 0; }
            to   { transform: translateY(0) scale(1); opacity: 1; }
        }

        .modal-content {
            background: white;
            border-radius: 20px;
            padding: 40px 35px;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
            position: relative;
            border: 3px solid #f5c800;
        }

        .modal-icon { margin-bottom: 20px; }
        .modal-icon svg { filter: drop-shadow(0 4px 8px rgba(17,146,71,0.2)); }

        .modal-header h2 {
            color: #119247;
            font-size: 24px;
            font-weight: 900;
            margin: 0 0 15px 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modal-body { margin-bottom: 30px; }

        .modal-body p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin: 0 0 10px 0;
        }

        .modal-body p:first-child {
            font-weight: 700;
            color: #119247;
            font-size: 16px;
        }

        .modal-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
        }

        .btn-modal {
            padding: 12px 24px;
            border: none;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            min-width: 120px;
        }

        .btn-profile {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(17,146,71,0.4);
        }

        .btn-profile:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(17,146,71,0.5);
        }

        .btn-close-modal {
            background: #f0f0f0;
            color: #666;
            border: 2px solid #ddd;
        }

        .btn-close-modal:hover {
            background: #e0e0e0;
            border-color: #ccc;
            transform: translateY(-1px);
        }

        /* ── QR MODAL SPECIFIC ── */
        .qr-modal-content { border-color: #119247; }

        .qr-amount-badge {
            display: inline-block;
            background: linear-gradient(135deg, #e8401c 0%, #c73516 100%);
            color: white;
            font-size: 22px;
            font-weight: 900;
            padding: 8px 24px;
            border-radius: 50px;
            margin: 10px 0 18px 0;
            box-shadow: 0 4px 12px rgba(232,64,28,0.3);
        }

        .qr-box {
            background: #f8f9fa;
            border: 2px dashed #119247;
            border-radius: 12px;
            padding: 16px;
            margin: 0 auto 18px auto;
            max-width: 240px;
            min-height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .qr-box img {
            width: 100%;
            border-radius: 8px;
            display: block;
        }

        /* Loading spinner while QR loads */
        .qr-loading {
            position: absolute;
            font-size: 12px;
            color: #888;
            font-weight: 600;
        }

        .qr-ref-label {
            font-size: 12px;
            color: #888;
            margin-bottom: 6px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .qr-ref-input {
            width: 100%;
            padding: 10px 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 13px;
            text-align: center;
            letter-spacing: 1px;
            margin-bottom: 12px;
            transition: border-color 0.3s;
        }

        .qr-ref-input:focus {
            border-color: #119247;
            outline: none;
            box-shadow: 0 0 0 3px rgba(17,146,71,0.1);
        }

        .btn-confirm-payment {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 900;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(17,146,71,0.3);
            letter-spacing: 1px;
            margin-bottom: 10px;
        }

        .btn-confirm-payment:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(17,146,71,0.4);
        }

        .btn-cancel-qr {
            background: none;
            border: none;
            color: #aaa;
            font-size: 12px;
            cursor: pointer;
            text-decoration: underline;
            padding: 6px;
            transition: color 0.2s;
            width: 100%;
        }

        .btn-cancel-qr:hover { color: #666; }

        /* ── QR hint text ── */
        .qr-hint {
            font-size: 11px;
            color: #888;
            margin-bottom: 14px;
            line-height: 1.5;
            background: #f0faf4;
            border-radius: 6px;
            padding: 8px 10px;
            border-left: 3px solid #119247;
            text-align: left;
        }

        @media (max-width: 480px) {
            .modal-content { padding: 30px 25px; margin: 20px; }
            .modal-buttons { flex-direction: column; }
            .btn-modal { width: 100%; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="logo">
                <img src="potato.png" alt="Potato Corner" />
            </div>

            <div class="form-card">
                <h1 class="form-title">Membership Registration</h1>
                <p class="form-subtitle">Join our Royalty Program and enjoy exclusive benefits!</p>

                <asp:Label ID="lblMessage" runat="server" CssClass="error-msg" Visible="false"></asp:Label>

                <div class="form-grid">
                    <div class="form-group two-col">
                        <label class="form-label">Full Name <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input" 
                            placeholder="Enter your full name"
                            onkeypress="return /[a-zA-Z ]/.test(String.fromCharCode(event.charCode))"
                            oninput="this.value = this.value.replace(/[^a-zA-Z ]/g, '')">
                        </asp:TextBox>
                        <div class="prefilled-note">Auto-filled from your account. Cannot be changed here.</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Email Address <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" 
                            TextMode="Email" placeholder="email@example.com">
                        </asp:TextBox>
                        <div class="prefilled-note">Auto-filled from your account. Cannot be changed here.</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Contact Number <span style="color:red">*</span></label>
                        <asp:TextBox ID="txtContact" runat="server" CssClass="form-input" 
                            placeholder="09XX XXX XXXX"
                            onkeypress="return /[0-9]/.test(String.fromCharCode(event.charCode))"
                            oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                            MaxLength="11">
                        </asp:TextBox>
                        <div class="prefilled-note">Auto-filled from your account. Cannot be changed here.</div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Upload Photo <span style="color:red">*</span></label>
                        <div class="upload-section">
                            <div class="upload-icon">PHOTO</div>
                            <asp:FileUpload ID="fileUploadPicture" runat="server" 
                                CssClass="file-upload" accept=".png,.jpg,.jpeg"
                                onchange="showFileName(this)" />
                            <div id="fileNameDisplay"></div>
                        </div>
                    </div>
                </div>

                <div class="fee-section">
                    <div class="fee-label">Registration Fee</div>
                    <div class="fee-amount">PHP 100</div>
                </div>

                <div class="form-group" style="margin-bottom:12px;">
                    <label class="form-label">Payment Method <span style="color:red">*</span></label>
                    <div class="payment-grid">
                        <button type="button" class="payment-btn" onclick="selectPayment('GoTyme', this)">GoTyme</button>
                        <button type="button" class="payment-btn" onclick="selectPayment('Maya', this)">Maya</button>
                        <button type="button" class="payment-btn" onclick="selectPayment('GCash', this)">GCash</button>
                    </div>
                    <asp:HiddenField ID="hdnPaymentMethod"      runat="server" Value="" />
                    <asp:HiddenField ID="hdnGeneratedReference" runat="server" Value="" />
                </div>

                <div class="form-group" id="amountPaidGroup" style="margin-bottom:12px;">
                    <label class="form-label">Amount to Pay</label>
                    <asp:TextBox ID="txtAmountPaid" runat="server" CssClass="form-input"
                        Text="100" ReadOnly="true" TextMode="Number">
                    </asp:TextBox>
                    <div class="prefilled-note">Fixed registration fee. Cannot be changed.</div>
                </div>

                <asp:Button ID="btnRegister" runat="server" Text="Register Now" 
                    CssClass="btn-register" OnClick="btnRegister_Click" />

                <div class="back-link">
                    <a href="Membership.aspx" class="btn-back">Back to Membership</a>
                </div>
            </div>
        </div>

        <%-- ── ALREADY MEMBER MODAL ── --%>
        <div id="alreadyMemberModal" class="modal-overlay">
            <div class="modal-container">
                <div class="modal-content">
                    <div class="modal-icon">
                        <svg width="80" height="80" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <circle cx="12" cy="12" r="10" stroke="#119247" stroke-width="2" fill="#e8f5ee"/>
                            <path d="M9 12l2 2 4-4" stroke="#119247" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </div>
                    <div class="modal-header">
                        <h2>Already a Royalty Member</h2>
                    </div>
                    <div class="modal-body">
                        <p>You are already registered as a Royalty Member.</p>
                        <p>Visit your profile to view your membership details and enjoy exclusive benefits.</p>
                    </div>
                    <div class="modal-buttons">
                        <button type="button" class="btn-modal btn-profile" onclick="goToProfile()">View Profile</button>
                        <button type="button" class="btn-modal btn-close-modal" onclick="goToMembership()">Back to Membership</button>
                    </div>
                </div>
            </div>
        </div>

        <%-- ── QR CODE PAYMENT MODAL ── --%>
        <div id="qrPaymentModal" class="modal-overlay">
            <div class="modal-container">
                <div class="modal-content qr-modal-content">
                    <div class="modal-header">
                        <h2>💳 Scan to Pay</h2>
                    </div>
                    <div class="modal-body">
                        <p id="qrMethodLabel">Pay via GCash</p>
                        <div class="qr-amount-badge">PHP 100.00</div>

                        <%-- ✅ QR code image — generated by api.qrserver.com --%>
                        <div class="qr-box">
                            <span class="qr-loading" id="qrLoadingText">Generating QR...</span>
                            <img id="qrCodeImage" src="" alt="QR Code"
                                style="display:none;"
                                onload="this.style.display='block'; document.getElementById('qrLoadingText').style.display='none';"
                                onerror="document.getElementById('qrLoadingText').innerText='Failed to load QR. Check your connection.';" />
                        </div>

                        <div class="qr-hint">
                            📱 Scan with your phone camera or any QR reader app.
                            The QR contains your full payment details.
                            Then copy the <strong>Reference Number</strong> shown and paste it below.
                        </div>

                        <div class="qr-ref-label">Reference Number</div>
                        <asp:TextBox ID="txtPaymentReferenceModal" runat="server" 
                            CssClass="qr-ref-input" 
                            placeholder="REF-XXXXXXXXXXXXXXX">
                        </asp:TextBox>

                        <asp:Button ID="btnSubmitPaymentModal" runat="server" 
                            Text="Confirm Payment" 
                            CssClass="btn-confirm-payment"
                            OnClick="btnSubmitPaymentModal_Click" />

                        <button type="button" class="btn-cancel-qr" onclick="closeQRModal()">
                            Cancel — choose a different payment method
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <%-- ✅ Script is INSIDE <form> so ScriptManager injections can call these functions --%>
        <script type="text/javascript">

            function showFileName(input) {
                var display = document.getElementById('fileNameDisplay');
                if (input.files && input.files[0]) {
                    display.innerText = '✔ ' + input.files[0].name;
                } else {
                    display.innerText = '';
                }
            }

            function selectPayment(method, btn) {
                var btns = document.querySelectorAll('.payment-btn');
                btns.forEach(function (b) { b.classList.remove('selected'); });
                btn.classList.add('selected');
                document.getElementById('<%= hdnPaymentMethod.ClientID %>').value = method;
            document.getElementById('amountPaidGroup').style.display = 'block';
            }

            function showAlreadyMemberModal() {
                document.getElementById('alreadyMemberModal').style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }

            function goToProfile() { window.location.href = 'Profile.aspx'; }
            function goToMembership() { window.location.href = 'Membership.aspx'; }

            // ✅ Updated: generates QR via api.qrserver.com with structured payment data
            function showQRCodeModal(method, amount) {
                // Generate reference number
                var ref = 'REF-' + method.substring(0, 2).toUpperCase() + Date.now();
                document.getElementById('<%= hdnGeneratedReference.ClientID %>').value = ref;
                document.getElementById('qrMethodLabel').innerText = 'Pay via ' + method;

                // Format current date/time
                var now = new Date().toLocaleString('en-PH', {
                    year: 'numeric', month: 'long', day: 'numeric',
                    hour: '2-digit', minute: '2-digit'
                });

                // Structured data — shows clearly when scanned by any QR reader
                var qrData = [
                    '=== POTATO CORNER MEMBERSHIP ===',
                    'Merchant  : Potato Corner',
                    'Purpose   : Royalty Membership Fee',
                    'Amount    : PHP ' + amount,
                    'Method    : ' + method,
                    'Reference : ' + ref,
                    'Date      : ' + now,
                    '=================================',
                    'Enter the Reference No. above to confirm payment.'
                ].join('\n');

                // Show loading state
                var img = document.getElementById('qrCodeImage');
                var loadingText = document.getElementById('qrLoadingText');
                img.style.display = 'none';
                loadingText.style.display = 'block';
                loadingText.innerText = 'Generating QR...';

                // Build URL for api.qrserver.com
                img.src = 'https://api.qrserver.com/v1/create-qr-code/'
                    + '?size=200x200'
                    + '&margin=10'
                    + '&ecc=M'
                    + '&data=' + encodeURIComponent(qrData);

                // Clear previous reference input
                document.getElementById('<%= txtPaymentReferenceModal.ClientID %>').value = '';

                document.getElementById('qrPaymentModal').style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }

            function closeQRModal() {
                document.getElementById('qrPaymentModal').style.display = 'none';
                document.body.style.overflow = 'auto';
                document.getElementById('<%= txtPaymentReferenceModal.ClientID %>').value = '';
            }

            document.addEventListener('DOMContentLoaded', function () {
                document.getElementById('alreadyMemberModal').addEventListener('click', function (e) {
                    if (e.target === this) { this.style.display = 'none'; document.body.style.overflow = 'auto'; }
                });
                document.getElementById('qrPaymentModal').addEventListener('click', function (e) {
                    if (e.target === this) closeQRModal();
                });
            });

        </script>

    </form>
</body>
</html>
