using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void lnkProfile_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Profile.aspx");
        }

        protected void btnOrderNav_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Order.aspx");
        }

        protected void btnOrder_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Order.aspx");
        }

        protected void lnkMenu_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Menu.aspx");
        }

        protected void lnkMembership_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/Membership.aspx");
        }

        protected void lnkAboutUs_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/AboutUs.aspx");
        }

        protected void lnkHome_Click(object sender, EventArgs e)
        {
            Response.Redirect("Default.aspx");
        }
    }
}