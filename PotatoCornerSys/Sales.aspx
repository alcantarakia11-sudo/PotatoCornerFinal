<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Sales.aspx.cs" Inherits="PotatoCornerSys.Sales" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Sales Dashboard - Potato Corner</title>
    <style type="text/css">
        :root {
            --primary-green: #119247;
            --primary-dark: #0d7336;
            --accent-yellow: #f5c800;
            --bg-light: #f8fffe;
            --bg-white: #ffffff;
            --text-dark: #2c3e50;
            --text-light: #6c757d;
            --border-light: #e9ecef;
            --shadow-sm: 0 2px 4px rgba(0,0,0,0.1);
            --shadow-md: 0 4px 12px rgba(0,0,0,0.15);
            --shadow-lg: 0 8px 25px rgba(0,0,0,0.15);
        }

        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
        }

        body {
            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
            background: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
            min-height: 100vh;
        }

        /* MODERN NAVBAR */
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

        .navbar-links .active {
            color: #f5c800;
        }

        .navbar-links .active::after {
            width: 100%;
        }

        /* MAIN CONTAINER */
        .sales-container {
            max-width: 1400px;
            margin: 50px auto;
            padding: 0 40px;
        }

        /* PAGE HEADER */
        .page-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .page-header h1 {
            font-size: 48px;
            color: #119247;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
        }

        /* STATS CARDS */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-bottom: 50px;
        }

        .stat-card {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 8px 30px rgba(245, 200, 0, 0.25);
            transition: all 0.3s;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 40px rgba(0,0,0,0.2);
        }

        .stat-card h3 {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 1px;
            opacity: 0.9;
        }

        .stat-card .stat-value {
            font-size: 42px;
            font-weight: 900;
            margin-bottom: 5px;
        }

        .stat-card .stat-change {
            font-size: 12px;
            color: #e8401c;
            font-weight: 700;
        }

        /* ORDERS SECTION */
        .orders-section {
            background: var(--bg-white);
            border-radius: 20px;
            padding: 28px 28px 20px;
            border: 1px solid var(--border-light);
            box-shadow: var(--shadow-md);
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 18px;
            padding-bottom: 16px;
            border-bottom: 2px solid #f1f4f6;
        }

        .section-header h2 {
            font-size: 26px;
            color: var(--primary-green);
            font-weight: 800;
            text-transform: none;
            margin: 0;
            letter-spacing: 0.3px;
        }

        .orders-toolbar {
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .filter-label {
            font-weight: 700;
            color: #119247;
        }

        .status-filter {
            padding: 10px 14px;
            border: 1px solid #b8cdc0;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            min-width: 170px;
            background: var(--bg-white);
            color: var(--text-dark);
        }

        .order-count {
            background: #f3f7f4;
            color: var(--primary-green);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 700;
            border: 1px solid #d7e7dd;
        }

        /* MODERN TABLE */
        .table-container {
            overflow-x: auto;
            border: 1px solid var(--border-light);
            border-radius: 12px;
        }

        .orders-table {
            width: 100%;
            border-collapse: collapse;
            background: var(--bg-white);
        }

        .orders-table th {
            background: #f4faf7;
            color: var(--primary-green);
            padding: 14px 15px;
            text-align: left;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.8px;
            position: sticky;
            top: 0;
            z-index: 2;
            border-bottom: 1px solid var(--border-light);
        }

        .orders-table td {
            padding: 15px;
            border-bottom: 1px solid #edf1f3;
            font-size: 14px;
            vertical-align: middle;
        }

        .orders-table tbody tr {
            transition: all 0.2s ease;
        }

        .orders-table tbody tr:hover {
            background: #f7fbf9;
        }

        .orders-table tbody tr:nth-child(even) {
            background: #fbfdfc;
        }

        /* ORDER ID STYLING */
        .order-id {
            font-weight: 700;
            color: var(--primary-green);
            font-size: 16px;
        }

        /* CUSTOMER NAME */
        .customer-name {
            font-weight: 600;
            color: var(--text-dark);
        }

        /* DELIVERY TYPE BADGES */
        .delivery-type {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .delivery-badge, .walkin-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .delivery-badge {
            background: #eef7f1;
            color: #0d7336;
            border: 1px solid #cfe4d7;
        }

        .walkin-badge {
            background: #fff8e0;
            color: #9a6a00;
            border: 1px solid #f0dda1;
        }

        /* DATE STYLING */
        .order-date {
            color: var(--text-light);
            font-size: 14px;
        }

        /* AMOUNT STYLING */
        .order-amount {
            font-weight: 700;
            color: var(--primary-green);
            font-size: 16px;
        }

        .payment-ref {
            font-family: Consolas, Monaco, monospace;
            font-size: 12px;
            font-weight: 700;
            color: #119247;
            word-break: break-word;
        }

        /* STATUS BADGES - REDESIGNED */
        .status-badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-badge::before {
            content: '';
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .status-pending-verification {
            background: #ffe0b2;
            color: #e65100;
            border: 1px solid #ffb74d;
            position: relative;
        }

        .status-pending-verification::after {
            content: 'NEW';
            position: absolute;
            top: -8px;
            right: -8px;
            background: #e8401c;
            color: white;
            font-size: 9px;
            padding: 3px 6px;
            border-radius: 4px;
            font-weight: 900;
            letter-spacing: 0.5px;
        }

        .status-confirmed {
            background: #e8f5ee;
            color: #0d7336;
            border: 1px solid #cde4d7;
        }

        .status-out-for-delivery {
            background: #fff8e6;
            color: #9a6a00;
            border: 1px solid #efdca2;
        }

        .status-delivered {
            background: #e8f5ee;
            color: #0d7336;
            border: 1px solid #cde4d7;
        }

        .status-picked-up {
            background: #fff8e6;
            color: #9a6a00;
            border: 1px solid #efdca2;
        }

        .status-no-show {
            background: #fff3e0;
            color: #e65100;
            border: 1px solid #ffb74d;
        }

        .status-cancelled {
            background: #fce4ec;
            color: #b71c1c;
            border: 1px solid #ef9a9a;
        }

        /* ROW STATES */
        .orders-table tr.cancelled {
            background: #f8f9fa;
            opacity: 0.6;
        }

        .orders-table tr.cancelled td {
            color: #6c757d;
            text-decoration: line-through;
        }

        .orders-table tr.no-show {
            background: #fff8f0;
            opacity: 0.8;
        }

        .orders-table tr.no-show td {
            color: #e65100;
        }

        /* ACTION BUTTONS - REDESIGNED */
        .btn-action {
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 12px;
            transition: all 0.2s ease;
            margin-right: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .actions-wrap {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .btn-confirm {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            font-weight: 800;
        }

        .btn-confirm:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5a2a 100%);
            transform: translateY(-2px);
        }

        .btn-out-delivery {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: #fff;
        }

        .btn-out-delivery:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5a2a 100%);
            transform: translateY(-2px);
        }

        .btn-picked-up {
            background: linear-gradient(135deg, #e8b000 0%, #d4a000 100%);
            color: #1a1a1a;
        }

        .btn-picked-up:hover {
            background: linear-gradient(135deg, #d4a000 0%, #c09000 100%);
            transform: translateY(-2px);
        }

        .btn-see-details {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
        }

        .btn-see-details:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5a2a 100%);
            transform: translateY(-2px);
        }

        .btn-confirm-payment {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            color: #1a1a1a;
            font-weight: 800;
        }

        .btn-confirm-payment:hover {
            background: linear-gradient(135deg, #e8b000 0%, #d4a000 100%);
            transform: translateY(-2px);
        }

        /* PAYMENT DETAILS MODAL */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.6);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-box {
            background: white;
            border-radius: 16px;
            padding: 32px;
            max-width: 600px;
            width: 90%;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: modalSlideIn 0.3s ease-out;
            max-height: 90vh;
            overflow-y: auto;
        }

        @keyframes modalSlideIn {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }

        .modal-header {
            font-size: 24px;
            font-weight: 800;
            color: #119247;
            margin-bottom: 20px;
            text-align: center;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .payment-info-grid {
            display: grid;
            gap: 16px;
            margin-bottom: 24px;
        }

        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 12px;
            background: #f8f9fa;
            border-radius: 8px;
            border-left: 4px solid #119247;
        }

        .info-label {
            font-weight: 700;
            color: #119247;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            font-weight: 600;
            color: #2c3e50;
            font-size: 14px;
        }

        .qr-container {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
            border-radius: 12px;
            border: 2px solid #e8f5ee;
            margin-bottom: 20px;
        }

        .qr-container img {
            max-width: 250px;
            width: 100%;
            height: auto;
            border: 3px solid #119247;
            border-radius: 10px;
            padding: 10px;
            background: white;
        }

        .reference-display {
            background: linear-gradient(135deg, #f5c800 0%, #e8b000 100%);
            padding: 16px;
            border-radius: 10px;
            text-align: center;
            margin: 20px 0;
        }

        .reference-display .label {
            font-size: 12px;
            color: #1a1a1a;
            font-weight: 600;
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .reference-display .value {
            font-size: 20px;
            font-weight: 900;
            color: #1a1a1a;
            font-family: monospace;
            letter-spacing: 1px;
        }

        .payment-status-indicator {
            background: #d4edda;
            border: 2px solid #28a745;
            border-radius: 10px;
            padding: 16px;
            text-align: center;
            margin-bottom: 20px;
        }

        .payment-status-indicator .icon {
            font-size: 32px;
            margin-bottom: 8px;
        }

        .payment-status-indicator .text {
            font-size: 14px;
            font-weight: 700;
            color: #155724;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modal-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
        }

        .modal-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .modal-btn-close {
            background: #e8e8e8;
            color: #666;
        }

        .modal-btn-close:hover {
            background: #d0d0d0;
        }

        .modal-btn-confirm {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
        }

        .modal-btn-confirm:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(17,146,71,0.4);
        }

        /* ORDER ITEMS SUMMARY */
        .order-items-summary {
            font-size: 12px;
            color: var(--text-dark);
            line-height: 1.7;
        }

        .order-items-summary .item-line {
            display: flex;
            align-items: baseline;
            gap: 5px;
            white-space: nowrap;
        }

        .item-qty {
            font-weight: 800;
            color: #119247;
            font-size: 13px;
        }

        .btn-view-items {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 7px 14px;
            font-size: 11px;
            font-weight: 700;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 6px;
            transition: all 0.2s;
        }

        .btn-view-items:hover {
            background: linear-gradient(135deg, #0d7336 0%, #0a5a2a 100%);
            transform: translateY(-1px);
        }

        /* ORDER ITEMS MODAL */
        .items-modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.6);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .items-modal-overlay.active {
            display: flex;
        }

        .items-modal-box {
            background: white;
            border-radius: 16px;
            padding: 0;
            max-width: 560px;
            width: 92%;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: modalSlideIn 0.25s ease-out;
            max-height: 85vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }

        .items-modal-header {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            border-bottom: 4px solid #f5c800;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .items-modal-header h3 {
            color: white;
            font-size: 18px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin: 0;
        }

        .items-modal-close {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            font-size: 20px;
            font-weight: 900;
            cursor: pointer;
            border-radius: 6px;
            width: 32px; height: 32px;
            display: flex; align-items: center; justify-content: center;
            transition: background 0.2s;
        }

        .items-modal-close:hover { background: rgba(255,255,255,0.35); }

        .items-modal-body {
            padding: 20px 24px;
            overflow-y: auto;
        }

        .items-modal-table {
            width: 100%;
            border-collapse: collapse;
        }

        .items-modal-table th {
            background: #f4faf7;
            color: #119247;
            padding: 10px 12px;
            text-align: left;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            border-bottom: 2px solid #e9ecef;
        }

        .items-modal-table td {
            padding: 12px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 13px;
            vertical-align: middle;
        }

        .items-modal-table tbody tr:last-child td { border-bottom: none; }
        .items-modal-table tbody tr:hover { background: #f7fbf9; }

        .items-modal-footer {
            padding: 14px 24px;
            border-top: 2px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #f8fffe;
        }

        .items-modal-total {
            font-size: 16px;
            font-weight: 800;
            color: #119247;
        }

        .items-modal-btn-close {
            padding: 10px 24px;
            border: none;
            border-radius: 8px;
            background: #e8e8e8;
            color: #555;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            text-transform: uppercase;
            transition: background 0.2s;
        }

        .items-modal-btn-close:hover { background: #d0d0d0; }

        /* PAGINATION STYLING */
        .pager-style {
            border-radius: 0 0 20px 20px;
            padding: 15px;
        }

        .pager-style table {
            margin: 0 auto;
        }

        .pager-style td {
            padding: 8px 12px;
        }

        .pager-style a {
            color: white;
            text-decoration: none;
            padding: 8px 15px;
            border-radius: 8px;
            background: rgba(255,255,255,0.2);
            transition: all 0.3s;
            font-weight: 600;
        }

        .pager-style a:hover {
            background: #f5c800;
            color: #119247;
            transform: translateY(-2px);
        }

        .pager-style span {
            color: #f5c800;
            padding: 8px 15px;
            border-radius: 8px;
            background: rgba(245,200,0,0.2);
            font-weight: 700;
        }

        .empty-state {
            text-align: center;
            padding: 30px 20px;
            color: var(--text-light);
            font-weight: 600;
        }

        .membership-section {
            margin-top: 28px;
        }

        .membership-name {
            font-weight: 700;
            color: #119247;
        }

        .membership-action-btn {
            background: linear-gradient(135deg, #119247 0%, #0d7336 100%);
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 9px 14px;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 12px;
            cursor: pointer;
        }

        /* FOOTER */
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

        .footer .footer-copy {
            margin-top: 20px;
            font-size: 14px;
            color: #ccc;
        }

        /* RESPONSIVE */
        @media (max-width: 768px) {
            .navbar {
                padding: 14px 18px;
                flex-wrap: wrap;
                gap: 12px;
            }

            .navbar-logo img {
                height: 60px;
            }

            .navbar-links {
                gap: 18px;
                width: 100%;
                justify-content: center;
            }

            .sales-container {
                padding: 16px;
                margin: 26px auto;
            }
            
            .page-header h1 {
                font-size: 34px;
                letter-spacing: 1px;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .section-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 14px;
            }

            .section-header h2 {
                font-size: 26px;
            }
            
            .orders-table th,
            .orders-table td {
                padding: 12px 8px;
                font-size: 12px;
            }

            .status-filter {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager>
        
        <div class="navbar">
            <div class="navbar-logo">
                <img src="potato.png" alt="Potato Corner" />
            </div>
            <ul class="navbar-links">
                <li><asp:LinkButton ID="lnkHome" runat="server" OnClick="lnkHome_Click" Text="Home"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkSales" runat="server" OnClick="lnkSales_Click" Text="Sales" CssClass="active"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkUpdate" runat="server" OnClick="lnkUpdate_Click" Text="Update"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkActivityLog" runat="server" OnClick="lnkActivityLog_Click" Text="Activity Log"></asp:LinkButton></li>
                <li><asp:LinkButton ID="lnkProfile" runat="server" OnClick="lnkProfile_Click" Text="Profile"></asp:LinkButton></li>
            </ul>
        </div>

        <div class="sales-container">
            <!-- PAGE HEADER -->
            <div class="page-header">
                <h1>Sales Dashboard</h1>
            </div>

            <!-- STATS CARDS -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Total Users</h3>
                    <div class="stat-value"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-change">Active customers</div>
                </div>
                <div class="stat-card">
                    <h3>Total Revenue</h3>
                    <div class="stat-value">PHP <asp:Label ID="lblTotalRevenue" runat="server" Text="0.00"></asp:Label></div>
                    <div class="stat-change">All-time earnings</div>
                </div>
                <div class="stat-card">
                    <h3>Total Orders</h3>
                    <div class="stat-value"><asp:Label ID="lblTotalOrders" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-change">Orders processed</div>
                </div>
            </div>

            <!-- ORDERS SECTION -->
            <div class="orders-section">
                <div class="section-header">
                    <h2>Customer Orders</h2>
                    <div class="orders-toolbar">
                        <div class="filter-group">
                            <label class="filter-label">Filter:</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged"
                                CssClass="status-filter">
                                <asp:ListItem Value="" Text="All Orders" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="Pending" Text="Pending"></asp:ListItem>
                                <asp:ListItem Value="Confirmed" Text="Confirmed"></asp:ListItem>
                                <asp:ListItem Value="Out for Delivery" Text="Out for Delivery"></asp:ListItem>
                                <asp:ListItem Value="Delivered" Text="Delivered"></asp:ListItem>
                                <asp:ListItem Value="Picked Up" Text="Picked Up"></asp:ListItem>
                                <asp:ListItem Value="No Show" Text="No Show"></asp:ListItem>
                                <asp:ListItem Value="Cancelled" Text="Cancelled"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="order-count">
                            <asp:Label ID="lblOrderCount" runat="server" Text="0"></asp:Label> orders
                        </div>
                    </div>
                </div>
                
                <div class="table-container">
                    <asp:GridView ID="gvOrders" runat="server" CssClass="orders-table" AutoGenerateColumns="False" 
                        OnRowCommand="gvOrders_RowCommand" OnRowDataBound="gvOrders_RowDataBound"
                        AllowPaging="True" PageSize="10" OnPageIndexChanging="gvOrders_PageIndexChanging"
                        EmptyDataText="No orders match your current filter.">
                        <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" 
                            PageButtonCount="5" Position="Bottom" />
                        <PagerStyle BackColor="#119247" ForeColor="White" HorizontalAlign="Center" 
                            Font-Bold="True" Font-Size="14px" Height="50px" VerticalAlign="Middle" 
                            CssClass="pager-style" />
                        <Columns>
                            <asp:TemplateField HeaderText="Order ID">
                                <ItemTemplate>
                                    <div class="order-id">#PC-<%# Eval("OrderID") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Customer">
                                <ItemTemplate>
                                    <div class="customer-name"><%# Eval("CustomerName") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Type">
                                <ItemTemplate>
                                    <div class="delivery-type">
                                        <span class='<%# Eval("DeliveryType").ToString() == "Delivery" ? "delivery-badge" : "walkin-badge" %>'>
                                            <%# Eval("DeliveryType") %>
                                        </span>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Date & Time">
                                <ItemTemplate>
                                    <div class="order-date"><%# Eval("OrderDate", "{0:MMM dd, yyyy}") %></div>
                                    <div class="order-date"><%# Eval("OrderDate", "{0:h:mm tt}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Amount">
                                <ItemTemplate>
                                    <div class="order-amount">PHP <%# Eval("TotalAmount", "{0:N2}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            
                            
                            <asp:TemplateField HeaderText="Items Ordered">
                                <ItemTemplate>
                                    <div class="order-items-summary">
                                        <asp:Label ID="lblOrderItems" runat="server"></asp:Label>
                                    </div>
                                    <button type="button" class="btn-view-items"
                                        onclick="showItemsModal(<%# Eval("OrderID") %>, 'PHP <%# Eval("TotalAmount", "{0:N2}") %>')">
                                        View Details
                                    </button>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <div class="actions-wrap">
                                    <asp:Button ID="btnConfirm" runat="server" Text="Confirm" CssClass="btn-action btn-confirm" 
                                        CommandName="ConfirmOrder" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Pending" %>' 
                                        CausesValidation="false" />
                                    
                                    <asp:Button ID="btnOutForDelivery" runat="server" Text="Out for Delivery" CssClass="btn-action btn-out-delivery" 
                                        CommandName="OutForDelivery" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Confirmed" && Eval("DeliveryType").ToString() == "Delivery" %>' 
                                        CausesValidation="false" />
                                    
                                    <asp:Button ID="btnPickedUp" runat="server" Text="Picked Up" CssClass="btn-action btn-picked-up" 
                                        CommandName="MarkPickedUp" CommandArgument='<%# Eval("OrderID") %>' 
                                        Visible='<%# Eval("OrderStatus").ToString() == "Confirmed" && Eval("DeliveryType").ToString() == "Walk-in" %>' 
                                        CausesValidation="false" />
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="orders-section membership-section">
                <div class="section-header">
                    <h2>Membership Registration Confirmation</h2>
                    <div class="order-count">
                        <asp:Label ID="lblMembershipPendingCount" runat="server" Text="0"></asp:Label> pending
                    </div>
                </div>
                <div class="table-container">
                    <asp:GridView ID="gvMembershipRequests" runat="server" CssClass="orders-table" AutoGenerateColumns="False"
                        EmptyDataText="No pending membership registrations."
                        OnRowCommand="gvMembershipRequests_RowCommand">
                        <Columns>
                            <asp:TemplateField HeaderText="Request ID">
                                <ItemTemplate>
                                    <div class="order-id">#MR-<%# Eval("RequestID") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Applicant">
                                <ItemTemplate>
                                    <div class="membership-name"><%# Eval("FullName") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField HeaderText="Email" DataField="Email" />
                            <asp:BoundField HeaderText="Contact" DataField="ContactNumber" />
                            <asp:BoundField HeaderText="Payment Method" DataField="PaymentMethod" />
                            <asp:TemplateField HeaderText="Amount">
                                <ItemTemplate>
                                    <div class="order-amount">PHP <%# Eval("AmountPaid", "{0:N2}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Reference">
                                <ItemTemplate>
                                    <div class="payment-ref"><%# Eval("PaymentReference") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Requested On">
                                <ItemTemplate>
                                    <div class="order-date"><%# Eval("RequestedDate", "{0:MMM dd, yyyy}") %></div>
                                    <div class="order-date"><%# Eval("RequestedDate", "{0:h:mm tt}") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Actions">
                                <ItemTemplate>
                                    <asp:Button ID="btnApproveMembership" runat="server" Text="Confirm Registration"
                                        CssClass="membership-action-btn"
                                        CommandName="ApproveMembership"
                                        CommandArgument='<%# Eval("RequestID") %>'
                                        CausesValidation="false" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
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

        <!-- ORDER ITEMS MODAL -->
        <div id="itemsModal" class="items-modal-overlay">
            <div class="items-modal-box">
                <div class="items-modal-header">
                    <h3 id="itemsModalTitle">Order Items</h3>
                    <button type="button" class="items-modal-close" onclick="closeItemsModal()">X</button>
                </div>
                <div class="items-modal-body">
                    <table class="items-modal-table">
                        <thead>
                            <tr>
                                <th>Product</th>
                                <th>Size</th>
                                <th>Flavor</th>
                                <th>Qty</th>
                                <th>Unit Price</th>
                                <th>Subtotal</th>
                            </tr>
                        </thead>
                        <tbody id="itemsModalBody">
                        </tbody>
                    </table>
                </div>
                <div class="items-modal-footer">
                    <div class="items-modal-total" id="itemsModalTotal"></div>
                    <button type="button" class="items-modal-btn-close" onclick="closeItemsModal()">Close</button>
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function showItemsModal(orderID, total) {
                document.getElementById('itemsModalTitle').innerText = 'Order #PC-' + orderID + ' - Items';
                document.getElementById('itemsModalTotal').innerText = 'Total: ' + total;
                document.getElementById('itemsModalBody').innerHTML = '<tr><td colspan="6" style="text-align:center;padding:20px;color:#888;">Loading...</td></tr>';
                document.getElementById('itemsModal').classList.add('active');

                // Fetch order items via PageMethod
                PageMethods.GetOrderItems(orderID, function (result) {
                    var rows = '';
                    if (!result || result.length === 0) {
                        rows = '<tr><td colspan="6" style="text-align:center;padding:20px;color:#888;">No items found.</td></tr>';
                    } else {
                        result.forEach(function (item) {
                            var subtotal = (item.UnitPrice * item.Quantity).toFixed(2);
                            rows += '<tr>' +
                                '<td><strong>' + item.ProductName + '</strong></td>' +
                                '<td>' + (item.SizeName || '—') + '</td>' +
                                '<td>' + (item.FlavorName || '—') + '</td>' +
                                '<td style="font-weight:800;color:#119247;">' + item.Quantity + '</td>' +
                                '<td>PHP ' + item.UnitPrice.toFixed(2) + '</td>' +
                                '<td style="font-weight:700;">PHP ' + subtotal + '</td>' +
                                '</tr>';
                        });
                    }
                    document.getElementById('itemsModalBody').innerHTML = rows;
                }, function (err) {
                    document.getElementById('itemsModalBody').innerHTML =
                        '<tr><td colspan="6" style="text-align:center;padding:20px;color:#e8401c;">Error loading items.</td></tr>';
                });
            }

            function closeItemsModal() {
                document.getElementById('itemsModal').classList.remove('active');
            }

            // Close on backdrop click
            document.getElementById('itemsModal').addEventListener('click', function (e) {
                if (e.target === this) closeItemsModal();
            });
        </script>

    </form>
</body>
</html>