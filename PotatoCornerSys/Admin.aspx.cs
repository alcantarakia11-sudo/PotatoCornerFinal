using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Admin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserName"] != null)
                {
                    lblAdminName.Text = Session["Fullname"] != null ? Session["Fullname"].ToString() : Session["UserName"].ToString();
                }
                else
                {
                    Response.Redirect("~/Login.aspx");
                }
            }
        }

        protected void lnkSales_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sales.aspx");
        }

        protected void lnkUpdate_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Update.aspx");
        }

        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ProfileAdmin.aspx");
        }

        protected void lnkActivityLog_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ActivityLog.aspx");
        }

        protected void btnSalesTab_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Sales.aspx");
        }

        protected void btnUpdateTab_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Update.aspx");
        }

        protected void btnProfileTab_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/ProfileAdmin.aspx");
        }
    }
}
