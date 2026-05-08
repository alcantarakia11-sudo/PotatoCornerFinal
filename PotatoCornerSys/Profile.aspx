<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="PotatoCornerSys.Profile" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Potato Corner - My Profile</title>
    <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Barlow:wght@400;600;700;800;900&family=Barlow+Condensed:wght@700;900&display=swap" rel="stylesheet" />
    <style>
        :root {
            --green:       #119247;
            --green-dark:  #0d7336;
            --green-deep:  #095c2a;
            --yellow:      #f5c800;
            --yellow-warm: #fac775;
            --red:         #e8401c;
            --red-dark:    #c73516;
            --white:       #ffffff;
            --off-white:   #f7f5f0;
            --grey-light:  #eeebe4;
            --grey-mid:    #b0a99a;
            --grey-dark:   #3a3530;
            --ink:         #1a1612;
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--off-white);
            color: var(--ink);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── NAVBAR ─────────────────────────────────────────── */
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

        /* ── PAGE HERO ──────────────────────────────────────── */
        .page-hero {
            background: var(--off-white);
            padding: 48px 48px 0;
            position: relative;
            overflow: hidden;
        }
        .page-hero::before {
            content: 'PROFILE';
            position: absolute;
            font-family: 'Bebas Neue', sans-serif;
            font-size: 220px;
            color: rgba(17, 146, 71, 0.03);
            top: -20px;
            right: -20px;
            line-height: 1;
            pointer-events: none;
            letter-spacing: -4px;
        }
        .hero-inner {
            max-width: 1360px;
            margin: 0 auto;
            display: flex;
            align-items: flex-end;
            gap: 32px;
            padding-bottom: 0;
        }
        .hero-tag {
            background: var(--yellow);
            color: var(--ink);
            font-family: 'Segoe UI', sans-serif;
            font-size: 11px;
            font-weight: 900;
            letter-spacing: 3px;
            text-transform: uppercase;
            padding: 4px 12px;
            border-radius: 2px;
            display: inline-block;
            margin-bottom: 12px;
        }
        .hero-title {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 96px;
            line-height: 0.9;
            letter-spacing: 2px;
        }
        .hero-title .my-text {
            color: #e8401c;
            font-weight: 900;
        }
        .hero-title .profile-text {
            color: var(--yellow);
        }
        .hero-subtitle {
            font-size: 14px;
            color: var(--grey-mid);
            font-weight: 600;
            margin-top: 10px;
            letter-spacing: 0.5px;
        }
        .hero-tab-bar {
            background: var(--grey-light);
            border-radius: 10px 10px 0 0;
            display: flex;
            gap: 2px;
            padding: 8px 8px 0;
            margin-left: auto;
            align-self: flex-end;
        }
        .hero-tab {
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--grey-mid);
            padding: 10px 20px;
            border-radius: 6px 6px 0 0;
            cursor: pointer;
        }
        .hero-tab.active {
            background: var(--off-white);
            color: var(--green);
        }

        /* ── LAYOUT ─────────────────────────────────────────── */
        .page-body {
            max-width: 1360px;
            margin: 0 auto;
            padding: 32px 48px 64px;
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 24px;
            align-items: start;
        }

        /* ── LEFT SIDEBAR ───────────────────────────────────── */
        .sidebar {
            display: flex;
            flex-direction: column;
            gap: 16px;
            position: sticky;
            top: 115px;
        }

        .profile-card {
            background: var(--white);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.08);
        }
        
        /* ROYALTY MEMBER STYLING - KEEP CARD WHITE */
        .profile-card.royalty-gold {
            background: var(--white);
            box-shadow: 0 2px 16px rgba(0,0,0,0.08);
            border: none;
            position: relative;
            overflow: hidden;
        }
        
        .profile-card.royalty-gold::before {
            display: none;
        }
        
        .profile-card.royalty-gold .profile-card-top {
            background: linear-gradient(160deg, var(--green) 0%, var(--green-deep) 100%);
        }
        
        .profile-card.royalty-gold .profile-card-top::after {
            background: var(--yellow);
        }
        
        .profile-card.royalty-gold .profile-card-body {
            background: var(--white);
        }
        
        .profile-card.royalty-gold .info-row {
            border-bottom-color: var(--grey-light);
        }
        
        .profile-card.royalty-gold .info-row-label {
            color: var(--grey-mid);
        }
        
        .profile-card.royalty-gold .info-row-value {
            color: var(--grey-dark);
        }
        
        .profile-card.royalty-gold .royalty-number-value {
            color: var(--green);
        }
        
        .profile-card-top {
            background: linear-gradient(160deg, var(--green) 0%, var(--green-deep) 100%);
            padding: 28px 24px 20px;
            text-align: center;
            position: relative;
        }
        .profile-card-top::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 4px;
            background: var(--yellow);
        }
        .avatar-wrap {
            width: 88px;
            height: 88px;
            border-radius: 50%;
            border: 4px solid var(--yellow);
            margin: 0 auto 14px;
            overflow: hidden;
            background: var(--green-dark);
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Bebas Neue', sans-serif;
            font-size: 36px;
            color: var(--yellow);
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        
        .profile-card.royalty-gold .avatar-wrap {
            border: 4px solid var(--yellow);
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
            background: var(--green-dark);
            color: var(--yellow);
        }
        .profile-fullname {
            font-family: 'Segoe UI', sans-serif;
            font-size: 22px;
            font-weight: 900;
            color: var(--white);
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }
        .membership-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            background: rgba(255,255,255,0.15);
            color: rgba(255,255,255,0.9);
            border: 1px solid rgba(255,255,255,0.2);
        }
        .membership-pill.royalty {
            background: linear-gradient(135deg, #ffd700 0%, #ffed4e 50%, #ffc107 100%);
            color: #1a1612;
            border: none;
            box-shadow: 
                0 0 20px rgba(255, 215, 0, 0.6),
                0 4px 12px rgba(0, 0, 0, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
            font-size: 12px;
            padding: 10px 20px;
            position: relative;
            overflow: hidden;
            font-weight: 900;
            letter-spacing: 2.5px;
            border-radius: 25px;
        }
        .membership-pill.royalty::before {
            content: '★';
            font-size: 14px;
            margin-right: 6px;
            color: #1a1612;
        }
        .membership-pill.royalty::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: linear-gradient(45deg, transparent, rgba(255,255,255,0.4), transparent);
            animation: shine 3s infinite;
        }
        
        @keyframes shine {
            0% { transform: translateX(-100%) translateY(-100%) rotate(45deg); }
            100% { transform: translateX(100%) translateY(100%) rotate(45deg); }
        }
        
        .membership-pill::before {
            content: '●';
            font-size: 7px;
        }

        .profile-card-body {
            padding: 20px 24px;
        }
        .info-row {
            display: flex;
            flex-direction: column;
            gap: 2px;
            padding: 12px 0;
            border-bottom: 1px solid var(--grey-light);
        }
        .info-row:last-child { border-bottom: none; }
        .info-row-label {
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--grey-mid);
        }
        .info-row-value {
            font-size: 13px;
            font-weight: 700;
            color: var(--grey-dark);
            word-break: break-all;
        }
        .royalty-number-value {
            color: var(--green);
            font-family: 'Segoe UI', sans-serif;
            font-size: 18px;
            font-weight: 900;
            letter-spacing: 2px;
        }

        .sidebar-actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        .btn-settings {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #e8401c, #c73516);
            color: var(--white);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        .btn-settings::before { content: '🗑️'; font-size: 15px; }
        .btn-settings:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.35);
            background: linear-gradient(135deg, #c73516, #a82a12);
        }
        .btn-logout-new {
            width: 100%;
            padding: 13px;
            border: 2px solid var(--red);
            border-radius: 10px;
            background: transparent;
            color: var(--red);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-logout-new:hover {
            background: var(--red);
            color: var(--white);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.3);
        }

        /* ── POINTS PANEL ───────────────────────────────────── */
        .points-panel {
            background: linear-gradient(135deg, var(--green) 0%, var(--green-deep) 100%);
            border-radius: 16px;
            padding: 24px;
            color: var(--white);
            position: relative;
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.12);
        }
        .points-panel::before {
            content: '';
            position: absolute;
            width: 180px; height: 180px;
            border-radius: 50%;
            background: rgba(255,255,255,0.04);
            top: -60px; right: -40px;
        }
        .points-panel::after {
            content: '';
            position: absolute;
            width: 120px; height: 120px;
            border-radius: 50%;
            background: rgba(255,255,255,0.03);
            bottom: -30px; left: -20px;
        }
        .points-label-small {
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: rgba(255,255,255,0.6);
            margin-bottom: 4px;
        }
        .points-number {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 72px;
            color: var(--yellow-warm);
            line-height: 1;
        }
        .points-unit {
            font-size: 14px;
            font-weight: 700;
            color: rgba(255,255,255,0.6);
            margin-bottom: 16px;
        }
        .discount-strip {
            background: var(--yellow);
            color: var(--ink);
            border-radius: 10px;
            padding: 14px 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            position: relative;
            z-index: 1;
        }
        .discount-strip-label {
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: rgba(0,0,0,0.5);
        }
        .discount-strip-value {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 28px;
            color: var(--ink);
            line-height: 1;
        }
        .btn-use-points-new {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 10px;
            background: var(--red);
            color: var(--white);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
            z-index: 1;
        }
        .btn-use-points-new:hover {
            background: var(--red-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(232,64,28,0.4);
        }
        .points-msg {
            margin-top: 10px;
            font-size: 12px;
            font-weight: 700;
            color: var(--yellow-warm);
            text-align: center;
            position: relative;
            z-index: 1;
        }

        /* ── MAIN CONTENT ───────────────────────────────────── */
        .main-content {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* ── STATS ROW ──────────────────────────────────────── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 12px;
        }
        .stat-tile {
            background: var(--white);
            border-radius: 14px;
            padding: 20px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            border-top: 4px solid transparent;
        }
        .stat-tile.t-green  { border-top-color: var(--green); }
        .stat-tile.t-red    { border-top-color: var(--red); }
        .stat-tile.t-yellow { border-top-color: var(--yellow); }
        .stat-tile.t-green-alt   { border-top-color: #0d7336; }
        .stat-tile::after {
            content: attr(data-icon);
            position: absolute;
            font-size: 52px;
            right: -6px; bottom: -10px;
            opacity: 0.06;
            line-height: 1;
        }
        .stat-tile-label {
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--grey-mid);
            margin-bottom: 8px;
        }
        .stat-tile-value {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 38px;
            line-height: 1;
        }
        .stat-tile.t-green  .stat-tile-value { color: var(--green); }
        .stat-tile.t-red    .stat-tile-value { color: var(--red); }
        .stat-tile.t-yellow .stat-tile-value { color: #c8970a; }
        .stat-tile.t-green-alt   .stat-tile-value { color: #0d7336; }

        /* ── ORDER HISTORY SECTION ──────────────────────────── */
        .section-card {
            background: var(--white);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 2px 16px rgba(0,0,0,0.06);
        }
        .section-top-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 20px 28px;
            border-bottom: 2px solid var(--grey-light);
            flex-wrap: wrap;
            gap: 12px;
        }
        .section-title-label {
            font-family: 'Segoe UI', sans-serif;
            font-size: 20px;
            font-weight: 900;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--ink);
        }
        .section-title-label span {
            color: var(--green);
        }
        .controls-group {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .ctrl-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--grey-mid);
        }
        .ctrl-select {
            border: 2px solid var(--grey-light);
            border-radius: 8px;
            padding: 7px 12px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 12px;
            font-weight: 700;
            color: var(--grey-dark);
            background: var(--white);
            cursor: pointer;
            outline: none;
            transition: border 0.2s;
        }
        .ctrl-select:focus { border-color: var(--green); }
        .btn-summary {
            background: var(--yellow);
            color: var(--ink);
            border: none;
            border-radius: 8px;
            padding: 8px 18px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-summary:hover {
            background: #e0b600;
            transform: translateY(-1px);
        }

        /* search bar */
        .search-bar {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 16px 28px;
            background: var(--off-white);
            border-bottom: 2px solid var(--grey-light);
            flex-wrap: wrap;
        }
        .search-input {
            flex: 1;
            min-width: 180px;
            padding: 9px 14px;
            border: 2px solid var(--grey-light);
            border-radius: 8px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 600;
            color: var(--ink);
            background: var(--white);
            outline: none;
            transition: border 0.2s;
        }
        .search-input:focus { border-color: var(--green); }
        .btn-search-new {
            background: var(--green);
            color: var(--white);
            border: none;
            border-radius: 8px;
            padding: 9px 18px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-search-new:hover { background: var(--green-dark); }
        .btn-clear-new {
            background: transparent;
            color: var(--grey-mid);
            border: 2px solid var(--grey-light);
            border-radius: 8px;
            padding: 7px 16px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-clear-new:hover {
            border-color: var(--grey-mid);
            color: var(--grey-dark);
        }

        /* search result banner */
        .search-banner {
            background: #edf7f1;
            border-left: 4px solid var(--green);
            padding: 10px 28px;
            font-size: 13px;
            font-weight: 700;
            color: var(--green-dark);
        }

        /* empty state */
        .empty-state {
            text-align: center;
            padding: 60px 40px;
        }
        .empty-icon { font-size: 52px; margin-bottom: 14px; }
        .empty-text {
            font-size: 14px;
            font-weight: 700;
            color: var(--grey-mid);
        }

        /* order table */
        .order-tbl { width: 100%; border-collapse: collapse; }
        .order-tbl thead tr {
            background: var(--off-white);
        }
        .order-tbl th {
            padding: 12px 20px;
            text-align: left;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            color: var(--grey-mid);
        }
        .order-tbl td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--grey-light);
            vertical-align: middle;
        }
        .order-tbl tbody tr:last-child td { border-bottom: none; }
        .order-tbl tbody tr:hover { background: #fafaf8; }

        .order-num {
            font-family: 'Segoe UI', sans-serif;
            font-size: 16px;
            font-weight: 900;
            color: var(--ink);
            letter-spacing: 0.5px;
        }
        .order-num span { color: var(--green); }
        .order-dt {
            font-size: 12px;
            font-weight: 600;
            color: var(--grey-mid);
        }
        .order-items-text {
            font-size: 12px;
            font-weight: 600;
            color: var(--grey-dark);
            max-width: 220px;
        }
        .order-amount {
            font-family: 'Segoe UI', sans-serif;
            font-size: 18px;
            font-weight: 900;
            color: var(--green);
        }

        /* status badges */
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
        .badge-pending    { background: #fff8e1; color: #856404; border: 1px solid #ffe082; }
        .badge-confirmed  { background: #e8f5e9; color: #2e7d32; border: 1px solid #a5d6a7; }
        .badge-out-delivery { background: #e3f2fd; color: #1565c0; border: 1px solid #90caf9; }
        .badge-delivered  { background: #d4edda; color: #155724; border: 1px solid #81c784; }
        .badge-picked-up  { background: #f3e5f5; color: #6a1b9a; border: 1px solid #ce93d8; }
        .badge-no-show    { background: #fff3e0; color: #e65100; border: 1px solid #ffb74d; }
        .badge-cancelled  { background: #fce4ec; color: #b71c1c; border: 1px solid #ef9a9a; }

        /* action buttons */
        .action-grp { display: flex; gap: 6px; align-items: center; flex-wrap: nowrap; }
        .btn-reorder-new {
            background: var(--green);
            color: var(--white);
            border: none;
            border-radius: 6px;
            padding: 7px 14px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-reorder-new:hover {
            background: var(--green-dark);
            transform: translateY(-1px);
        }
        .btn-cancel-new {
            background: transparent;
            color: var(--red);
            border: 2px solid var(--red);
            border-radius: 6px;
            padding: 5px 12px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-cancel-new:hover {
            background: var(--red);
            color: var(--white);
        }
        .btn-delivered-new {
            background: transparent;
            color: var(--green);
            border: 2px solid var(--green);
            border-radius: 6px;
            padding: 5px 12px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
            white-space: nowrap;
        }
        .btn-delivered-new:hover {
            background: var(--green);
            color: var(--white);
        }

        .view-all-link {
            display: block;
            text-align: center;
            padding: 16px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 13px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--green);
            text-decoration: none;
            border-top: 2px solid var(--grey-light);
            transition: background 0.2s;
        }
        .view-all-link:hover { background: var(--off-white); }

        /* ── FOOTER ─────────────────────────────────────────── */
        .footer {
            background: var(--green-deep);
            border-top: 5px solid var(--yellow);
            text-align: center;
            padding: 36px 40px;
            margin-top: 48px;
        }
        .footer a {
            color: var(--yellow);
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            margin: 0 12px;
        }
        .footer p {
            font-size: 12px;
            color: rgba(255,255,255,0.4);
            margin-top: 12px;
        }

        /* ── MODALS ─────────────────────────────────────────── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.65);
            z-index: 9999;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(4px);
        }
        .modal-overlay.active { display: flex; }
        
        /* ALERT MODAL */
        .alert-modal-box {
            background: var(--white);
            border-radius: 20px;
            padding: 36px 32px;
            max-width: 420px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            animation: modalIn 0.25s ease-out;
        }
        .alert-modal-icon {
            font-size: 56px;
            text-align: center;
            margin-bottom: 16px;
        }
        .alert-modal-head {
            font-family: 'Segoe UI', sans-serif;
            font-size: 24px;
            font-weight: 900;
            color: var(--ink);
            text-align: center;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }
        .alert-modal-msg {
            font-size: 14px;
            color: var(--grey-mid);
            text-align: center;
            margin-bottom: 24px;
            line-height: 1.6;
        }
        .alert-modal-btn {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: var(--green);
            color: var(--white);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .alert-modal-btn:hover {
            background: var(--green-dark);
        }
        .modal-box {
            background: var(--white);
            border-radius: 20px;
            padding: 36px 32px;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            animation: modalIn 0.25s ease-out;
        }
        @keyframes modalIn {
            from { transform: translateY(-24px) scale(0.97); opacity: 0; }
            to   { transform: translateY(0) scale(1); opacity: 1; }
        }
        .modal-head {
            font-family: 'Segoe UI', sans-serif;
            font-size: 28px;
            font-weight: 900;
            color: var(--ink);
            text-align: center;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }
        .modal-msg {
            font-size: 14px;
            color: var(--grey-mid);
            text-align: center;
            margin-bottom: 24px;
            line-height: 1.6;
        }
        .modal-btns {
            display: flex;
            gap: 10px;
        }
        .modal-btn-cancel-style {
            flex: 1;
            padding: 12px;
            border: 2px solid var(--grey-light);
            border-radius: 10px;
            background: transparent;
            color: var(--grey-dark);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .modal-btn-cancel-style:hover {
            background: var(--grey-light);
        }
        .modal-btn-confirm-style {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: var(--red);
            color: var(--white);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .modal-btn-confirm-style:hover {
            background: var(--red-dark);
        }

        /* cancel order modal */
        .cancel-modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.65);
            z-index: 10000;
            justify-content: center;
            align-items: center;
            backdrop-filter: blur(4px);
        }
        .cancel-modal-box {
            background: var(--white);
            border-radius: 20px;
            padding: 36px 32px;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            animation: modalIn 0.25s ease-out;
        }
        .cancel-modal-icon {
            font-size: 50px;
            text-align: center;
            margin-bottom: 16px;
        }
        .cancel-modal-head {
            font-family: 'Segoe UI', sans-serif;
            font-size: 28px;
            font-weight: 900;
            color: var(--red);
            text-align: center;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }
        .cancel-modal-body {
            font-size: 14px;
            color: var(--grey-mid);
            text-align: center;
            line-height: 1.6;
            margin-bottom: 16px;
        }
        .cancel-warning-box {
            background: #fff8f0;
            border: 2px solid #ff9800;
            border-radius: 10px;
            padding: 12px 16px;
            margin-bottom: 24px;
            font-size: 13px;
            font-weight: 700;
            color: #e65100;
            text-align: center;
        }
        .cancel-modal-btns {
            display: flex;
            gap: 10px;
        }
        .cancel-confirm-btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: var(--red);
            color: var(--white);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .cancel-confirm-btn:hover {
            background: var(--red-dark);
        }
        .cancel-keep-btn {
            flex: 1;
            padding: 12px;
            border: 2px solid var(--grey-light);
            border-radius: 10px;
            background: transparent;
            color: var(--grey-dark);
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 1px;
            text-transform: uppercase;
            cursor: pointer;
            transition: all 0.2s;
        }
        .cancel-keep-btn:hover {
            background: var(--grey-light);
        }

        /* ── DELETE ACCOUNT MODAL ─────────────────────────── */
        .delete-modal-box {
            background: var(--white);
            border-radius: 20px;
            padding: 36px 32px;
            max-width: 450px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.25);
            animation: modalIn 0.25s ease-out;
        }
        
        .delete-modal-icon {
            font-size: 50px;
            text-align: center;
            margin-bottom: 16px;
        }
        
        .delete-modal-title {
            font-family: 'Segoe UI', sans-serif;
            font-size: 28px;
            font-weight: 900;
            color: var(--red);
            text-align: center;
            margin-bottom: 12px;
            letter-spacing: 0.5px;
        }
        
        .delete-modal-warning {
            font-size: 14px;
            color: var(--grey-dark);
            text-align: center;
            margin-bottom: 24px;
            line-height: 1.6;
            font-weight: 600;
        }
        
        .delete-input-group {
            margin-bottom: 24px;
        }
        
        .delete-input-label {
            font-size: 12px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: var(--grey-mid);
            margin-bottom: 8px;
            display: block;
        }
        
        .delete-input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid var(--grey-light);
            border-radius: 10px;
            font-family: 'Segoe UI', sans-serif;
            font-size: 14px;
            font-weight: 600;
            color: var(--ink);
            outline: none;
            transition: border 0.2s;
        }
        
        .delete-input:focus {
            border-color: var(--red);
        }
        
        .delete-error-msg {
            color: var(--red);
            font-size: 12px;
            font-weight: 700;
            margin-top: 8px;
            display: none;
        }
        
        .delete-error-msg.show {
            display: block;
        }

        /* ── ORDER STATUS BADGES ────────────────────────────── */
        .order-status {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
        }

        .status-pending {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeaa7;
        }

        .status-confirmed {
            background: #d4edda;
            color: #155724;
            border: 1px solid #a5d6a7;
        }

        .status-out-delivery {
            background: #e3f2fd;
            color: #1565c0;
            border: 1px solid #90caf9;
        }

        .status-delivered {
            background: #e3f2fd;
            color: #1565c0;
            border: 1px solid #64b5f6;
        }

        .status-picked-up {
            background: #f3e5f5;
            color: #6a1b9a;
            border: 1px solid #ce93d8;
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

        /* ── RESPONSIVE ─────────────────────────────────────── */
        @media (max-width: 1100px) {
            .page-body { grid-template-columns: 1fr; }
            .sidebar { position: static; }
        }
        @media (max-width: 768px) {
            .page-body { padding: 20px 20px 48px; }
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .navbar { padding: 15px 20px; flex-direction: column; gap: 20px; }
            .hero-title { font-size: 64px; }
            .page-hero { padding: 32px 20px 0; }
        }
        @media (max-width: 480px) {
            .stats-row { grid-template-columns: 1fr; }
            .hero-title { font-size: 52px; }
        }
    </style>

    <script type="text/javascript">
        var currentOrderID = null;
        function cancelOrder(orderID) { currentOrderID = orderID; showCancelModal(); }
        function showCancelModal() {
            document.getElementById('cancelOrderModal').style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        function closeCancelModal() {
            document.getElementById('cancelOrderModal').style.display = 'none';
            document.body.style.overflow = 'auto';
            currentOrderID = null;
        }
        function confirmCancelOrder() {
            if (currentOrderID) {
                document.getElementById('<%= hdnCancelOrderID.ClientID %>').value = currentOrderID;
                document.getElementById('<%= btnCancelOrderHidden.ClientID %>').click();
            }
        }
        function markAsDelivered(orderID) {
            if (confirm('Mark this order as delivered?')) {
                document.getElementById('<%= hdnMarkDeliveredOrderID.ClientID %>').value = orderID;
                document.getElementById('<%= btnMarkDeliveredHidden.ClientID %>').click();
            }
        }
        function reorderItems(orderID) {
            document.getElementById('<%= hdnReorderOrderID.ClientID %>').value = orderID;
            document.getElementById('<%= btnReorderHidden.ClientID %>').click();
        }
        
        // Delete Account Modal
        function showDeleteAccountModal() {
            document.getElementById('deleteAccountModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeDeleteAccountModal() {
            document.getElementById('deleteAccountModal').classList.remove('active');
            document.body.style.overflow = 'auto';
            document.getElementById('<%= txtDeletePassword.ClientID %>').value = '';
            document.getElementById('deleteErrorMsg').classList.remove('show');
        }
        function confirmDelete() {
            var password = document.getElementById('<%= txtDeletePassword.ClientID %>').value;
            if (!password) {
                showAlertModal('⚠️', 'Password Required', 'Please enter your password to delete your account.');
                return false;
            }
            return true;
        }
        
        // Alert Modal Function
        function showAlertModal(icon, title, message) {
            document.getElementById('alertModalIcon').textContent = icon;
            document.getElementById('alertModalTitle').textContent = title;
            document.getElementById('alertModalMessage').textContent = message;
            document.getElementById('alertModal').classList.add('active');
            document.body.style.overflow = 'hidden';
        }
        function closeAlertModal() {
            document.getElementById('alertModal').classList.remove('active');
            document.body.style.overflow = 'auto';
        }
        
        // Security: Protect password fields
        document.addEventListener('DOMContentLoaded', function() {
            var passwordFields = document.querySelectorAll('input[type="password"]');
            passwordFields.forEach(function(field) {
                // Disable right-click
                field.addEventListener('contextmenu', function(e) {
                    e.preventDefault();
                    return false;
                });
                // Prevent copy/cut
                field.addEventListener('copy', function(e) { e.preventDefault(); });
                field.addEventListener('cut', function(e) { e.preventDefault(); });
                field.setAttribute('autocomplete', 'new-password');
            });
        });
        
        // Detect DevTools and clear password
        var devtoolsOpen = false;
        setInterval(function() {
            if (window.outerWidth - window.innerWidth > 160 || 
                window.outerHeight - window.innerHeight > 160) {
                if (!devtoolsOpen) {
                    devtoolsOpen = true;
                    var passwordFields = document.querySelectorAll('input[type="password"]');
                    passwordFields.forEach(function(field) { field.value = ''; });
                }
            } else {
                devtoolsOpen = false;
            }
        }, 500);
        
        // Disable inspect shortcuts
        document.addEventListener('keydown', function(e) {
            if (e.keyCode == 123 || 
                (e.ctrlKey && e.shiftKey && e.keyCode == 73) || 
                (e.ctrlKey && e.shiftKey && e.keyCode == 74) || 
                (e.ctrlKey && e.keyCode == 85)) {
                e.preventDefault();
                return false;
            }
        });
        
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('cancelOrderModal');
            if (modal) modal.addEventListener('click', function (e) { if (e.target === this) closeCancelModal(); });
            
            var deleteModal = document.getElementById('deleteAccountModal');
            if (deleteModal) deleteModal.addEventListener('click', function (e) { if (e.target === this) closeDeleteAccountModal(); });
        });
    </script>
</head>
<body>
<form id="form1" runat="server">
    <asp:HiddenField ID="hdnCancelOrderID" runat="server" />
    <asp:Button ID="btnCancelOrderHidden" runat="server" style="display:none;" OnClick="btnCancelOrder_Click" />
    <asp:HiddenField ID="hdnMarkDeliveredOrderID" runat="server" />
    <asp:Button ID="btnMarkDeliveredHidden" runat="server" style="display:none;" OnClick="btnMarkDelivered_Click" />
    <asp:HiddenField ID="hdnReorderOrderID" runat="server" />
    <asp:Button ID="btnReorderHidden" runat="server" style="display:none;" OnClick="btnReorder_Click" />

    <!-- NAVBAR -->
    <nav class="navbar">
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
    </nav>

    <!-- HERO -->
    <div class="page-hero">
        <div class="hero-inner">
            <div>
                <div class="hero-title"><span class="my-text">MY</span> <span class="profile-text">PROFILE</span></div>
            </div>
            <div class="hero-tab-bar">
                <div class="hero-tab active">Overview</div>
            </div>
        </div>
    </div>

    <!-- PAGE BODY -->
    <div class="page-body">

        <!-- LEFT SIDEBAR -->
        <aside class="sidebar">

            <!-- Profile Card -->
            <div class="profile-card" id="profileCardContainer" runat="server">
                <div class="profile-card-top">
                    <div class="avatar-wrap">
                        <asp:Image ID="imgProfilePic" runat="server" Visible="false"
                            style="width:100%;height:100%;object-fit:cover;" />
                        <asp:Label ID="lblInitials" runat="server" Text="JD" />
                    </div>
                    <div class="profile-fullname">
                        <asp:Label ID="lblFullName" runat="server" Text="Juan Dela Cruz" />
                    </div>
                    <asp:Label ID="lblMembershipBadge" runat="server"
                        CssClass="membership-pill" Text="REGULAR MEMBER" />
                </div>
                <div class="profile-card-body">
                    <div class="info-row">
                        <div class="info-row-label">Email</div>
                        <div class="info-row-value"><asp:Label ID="lblEmailAvatar" runat="server" /></div>
                    </div>
                    <div class="info-row">
                        <div class="info-row-label">Phone</div>
                        <div class="info-row-value"><asp:Label ID="lblInfoPhone" runat="server" /></div>
                    </div>
                    <div class="info-row">
                        <div class="info-row-label">Address</div>
                        <div class="info-row-value"><asp:Label ID="lblInfoAddress" runat="server" /></div>
                    </div>
                    <div class="info-row">
                        <div class="info-row-label">Member Since</div>
                        <div class="info-row-value"><asp:Label ID="lblMemberSince" runat="server" /></div>
                    </div>
                    <div class="info-row" id="royaltyNumberSection" runat="server" visible="false">
                        <div class="info-row-label">Royalty Card</div>
                        <div class="info-row-value royalty-number-value">
                            <asp:Label ID="lblRoyaltyNumber" runat="server" Text="N/A" />
                        </div>
                    </div>
                    <div class="info-row" id="membershipRequestStatusRow" runat="server" visible="false">
                        <div class="info-row-label">Membership Request</div>
                        <div class="info-row-value">
                            <asp:Label ID="lblMembershipRequestStatus" runat="server" Text="Pending Confirmation" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Points Panel -->
            <div class="points-panel">
                <div class="points-label-small">Available Points</div>
                <div class="points-number">
                    <asp:Label ID="lblPoints" runat="server" Text="0" />
                </div>
                <div class="points-unit">pts</div>
                <div class="discount-strip">
                    <div>
                        <div class="discount-strip-label">Discount Power</div>
                        <div class="discount-strip-value">
                            PHP <asp:Label ID="lblDiscountPower" runat="server" Text="0.00" />
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnUsePoints" runat="server"
                    Text="USE POINTS ON NEXT ORDER"
                    CssClass="btn-use-points-new"
                    OnClick="btnUsePoints_Click" />
                <asp:Label ID="lblPointsMsg" runat="server" Visible="false"
                    CssClass="points-msg" />
            </div>

            <!-- Sidebar Actions -->
            <div class="sidebar-actions">
                <asp:Button ID="btnAccountSettings" runat="server"
                    Text="DELETE ACCOUNT"
                    CssClass="btn-settings"
                    OnClientClick="showDeleteAccountModal(); return false;" />
                <asp:Button ID="btnLogout" runat="server"
                    Text="LOG OUT"
                    CssClass="btn-logout-new"
                    OnClientClick="showLogoutModal(); return false;" />
            </div>

        </aside>

        <!-- MAIN CONTENT -->
        <div class="main-content">

            <!-- Stats Row -->
            <div class="stats-row">
                <div class="stat-tile t-green" data-icon="📦">
                    <div class="stat-tile-label">Total Orders</div>
                    <div class="stat-tile-value">
                        <asp:Label ID="lblTotalOrders" runat="server" Text="0" />
                    </div>
                </div>
                <div class="stat-tile t-red" data-icon="💳">
                    <div class="stat-tile-label">Total Spent</div>
                    <div class="stat-tile-value">
                        <asp:Label ID="lblTotalSpent" runat="server" Text="₱0.00" />
                    </div>
                </div>
                <div class="stat-tile t-yellow" data-icon="📊">
                    <div class="stat-tile-label">Avg. Order</div>
                    <div class="stat-tile-value">
                        <asp:Label ID="lblAvgOrder" runat="server" Text="₱0.00" />
                    </div>
                </div>
                <div class="stat-tile t-green-alt" data-icon="🏆">
                    <div class="stat-tile-label">Biggest Order</div>
                    <div class="stat-tile-value">
                        <asp:Label ID="lblBiggestOrder" runat="server" Text="₱0.00" />
                    </div>
                </div>
            </div>

            <!-- Order History -->
            <div class="section-card">
                <div class="section-top-bar">
                    <div class="section-title-label">Order <span>History</span></div>
                    <div class="controls-group">
                        <asp:Button ID="btnOrderSummary" runat="server"
                            Text="Order Summary"
                            CssClass="btn-summary"
                            OnClick="btnOrderSummary_Click" />
                        <span class="ctrl-label">Sort</span>
                        <asp:DropDownList ID="ddlSortOrder" runat="server"
                            CssClass="ctrl-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlSortOrder_SelectedIndexChanged">
                            <asp:ListItem Value="DESC" Text="Most Recent" Selected="True" />
                            <asp:ListItem Value="ASC"  Text="Oldest First" />
                        </asp:DropDownList>
                        <span class="ctrl-label">Filter</span>
                        <asp:DropDownList ID="ddlFilterStatus" runat="server"
                            CssClass="ctrl-select"
                            AutoPostBack="true"
                            OnSelectedIndexChanged="ddlFilterStatus_SelectedIndexChanged">
                            <asp:ListItem Value="All"       Text="All Orders" Selected="True" />
                            <asp:ListItem Value="Pending"   Text="Pending" />
                            <asp:ListItem Value="Confirmed" Text="Confirmed" />
                            <asp:ListItem Value="Delivered" Text="Delivered" />
                            <asp:ListItem Value="Cancelled" Text="Cancelled" />
                        </asp:DropDownList>
                    </div>
                </div>

                <!-- Search -->
                <div class="search-bar">
                    <asp:TextBox ID="txtSearchOrderID" runat="server"
                        CssClass="search-input"
                        placeholder="Search by Order ID (e.g. 123)" />
                    <asp:Button ID="btnSearch" runat="server"
                        Text="Search"
                        CssClass="btn-search-new"
                        OnClick="btnSearch_Click" />
                    <asp:Button ID="btnClearSearch" runat="server"
                        Text="Clear"
                        CssClass="btn-clear-new"
                        OnClick="btnClearSearch_Click" />
                </div>

                <asp:Panel ID="pnlSearchResult" runat="server" Visible="false">
                    <div class="search-banner">
                        🔍 <asp:Label ID="lblSearchResultMsg" runat="server" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlNoOrders" runat="server" Visible="false">
                    <div class="empty-state">
                        <div class="empty-icon">📋</div>
                        <div class="empty-text">
                            <asp:Label ID="lblNoOrdersMsg" runat="server"
                                Text="No orders yet. Start ordering to see your history here!" />
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlOrdersTable" runat="server" Visible="true">
                    <table class="order-tbl">
                        <thead>
                            <tr>
                                <th>Order #</th>
                                <th>Date</th>
                                <th>Items</th>
                                <th>Total</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptOrderHistory" runat="server"
                                OnItemCommand="rptOrderHistory_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td class="order-num">
                                            <span>#PC-</span><%# Eval("OrderID") %>
                                        </td>
                                        <td class="order-dt">
                                            <%# Eval("OrderDate", "{0:MMM dd, yyyy}") %><br />
                                            <span style="color:#b0a99a;"><%# Eval("OrderDate", "{0:h:mm tt}") %></span>
                                        </td>
                                        <td class="order-items-text"><%# Eval("ItemsSummary") %></td>
                                        <td class="order-amount">
                                            PHP <%# Eval("TotalAmount", "{0:0.00}") %>
                                        </td>
                                        <td>
                                            <%# GetOrderStatus((DateTime)Eval("OrderDate"), Eval("OrderStatus").ToString()) %>
                                        </td>
                                        <td>
                                            <div class="action-grp">
                                                <%# GetReorderButton(Eval("OrderStatus").ToString(), Eval("OrderID").ToString()) %>
                                                <%# GetMarkDeliveredButton(Eval("DeliveryType").ToString(), Eval("OrderID").ToString(), Eval("OrderStatus").ToString()) %>
                                                <%# GetCancelButton((DateTime)Eval("OrderDate"), Eval("OrderID").ToString(), Eval("OrderStatus").ToString()) %>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </asp:Panel>

                <a href="#" class="view-all-link">View All Orders →</a>
            </div>

        </div>
    </div>

    <!-- FOOTER -->
    <div class="footer">
        <div>
            <a href="#">Terms &amp; Conditions</a>
            <a href="#">Privacy Policy</a>
        </div>
        <p>© 2026 Potato Corner. All rights reserved.</p>
    </div>

    <!-- LOGOUT MODAL -->
    <div id="logoutModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-head">Logging Out</div>
            <div class="modal-msg">Are you sure you want to log out of your account?</div>
            <div class="modal-btns">
                <button type="button" class="modal-btn-cancel-style" onclick="hideLogoutModal()">Cancel</button>
                <asp:Button ID="btnConfirmLogout" runat="server"
                    Text="Log Out"
                    CssClass="modal-btn-confirm-style"
                    OnClick="btnLogout_Click" />
            </div>
        </div>
    </div>

    <!-- ALERT MODAL (Reusable) -->
    <div id="alertModal" class="modal-overlay">
        <div class="alert-modal-box">
            <div class="alert-modal-icon" id="alertModalIcon">⚠️</div>
            <div class="alert-modal-head" id="alertModalTitle">Alert</div>
            <div class="alert-modal-msg" id="alertModalMessage">This is an alert message.</div>
            <button type="button" class="alert-modal-btn" onclick="closeAlertModal()">OK</button>
        </div>
    </div>

    <script>
        function showLogoutModal() { document.getElementById('logoutModal').classList.add('active'); }
        function hideLogoutModal() { document.getElementById('logoutModal').classList.remove('active'); }
        document.addEventListener('DOMContentLoaded', function () {
            document.getElementById('logoutModal').addEventListener('click', function (e) {
                if (e.target === this) hideLogoutModal();
            });
        });
    </script>

    <!-- CANCEL ORDER MODAL -->
    <div id="cancelOrderModal" class="cancel-modal-overlay">
        <div class="cancel-modal-box">
            <div class="cancel-modal-head">Cancel Order</div>
            <div class="cancel-modal-body">
                Are you sure you want to cancel this order?
                This action cannot be undone.
            </div>
            <div class="cancel-warning-box">
                Orders can only be cancelled within 10 minutes of placing.
            </div>
            <div class="cancel-modal-btns">
                <button type="button" class="cancel-confirm-btn" onclick="confirmCancelOrder()">Yes, Cancel</button>
                <button type="button" class="cancel-keep-btn" onclick="closeCancelModal()">Keep Order</button>
            </div>
        </div>
    </div>

    <!-- DELETE ACCOUNT MODAL -->
    <div id="deleteAccountModal" class="modal-overlay">
        <div class="delete-modal-box">
            <div class="delete-modal-title">Delete Account</div>
            <div class="delete-modal-warning">
                This action cannot be undone. All your data, orders, and points will be permanently deleted.
                <br /><br />
                <strong>Please enter your password to confirm:</strong>
            </div>
            <div class="delete-input-group">
                <label class="delete-input-label">Password</label>
                <asp:TextBox ID="txtDeletePassword" runat="server" TextMode="Password" 
                    CssClass="delete-input" placeholder="Enter your password" autocomplete="new-password" />
                <div id="deleteErrorMsg" class="delete-error-msg">Incorrect password. Please try again.</div>
            </div>
            <div class="modal-btns">
                <button class="modal-btn-cancel-style" onclick="closeDeleteAccountModal()">Cancel</button>
                <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete Account" 
                    CssClass="modal-btn-confirm-style" OnClick="btnConfirmDelete_Click" 
                    OnClientClick="return confirmDelete();" />
            </div>
        </div>
    </div>

    <!-- AUTO-REFRESH -->
    <script>
        var _snap = null, _paused = false;
        function checkChanges() {
            if (_paused) return;
            fetch(window.location.href, { credentials: 'same-origin' })
                .then(r => r.text()).then(html => {
                    var doc = new DOMParser().parseFromString(html, 'text/html');
                    var statuses = [...doc.querySelectorAll('.badge')].map(el => el.innerText.trim());
                    var total = doc.querySelector('.stat-tile.t-green .stat-tile-value');
                    if (total) statuses.push('t:' + total.innerText.trim());
                    var snap = statuses.join('|');
                    if (_snap === null) { _snap = snap; }
                    else if (snap !== _snap) { location.reload(); }
                }).catch(() => { });
        }
        document.addEventListener('DOMContentLoaded', function () {
            var c = document.getElementById('cancelOrderModal');
            var l = document.getElementById('logoutModal');
            new MutationObserver(() => {
                _paused = (c && c.style.display === 'flex') || (l && l.classList.contains('active'));
            }).observe(document.body, { attributes: true, subtree: true, attributeFilter: ['style', 'class'] });
        });
        checkChanges();
        setInterval(checkChanges, 5000);
    </script>

</form>
</body>
</html>
