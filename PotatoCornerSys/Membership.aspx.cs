using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PotatoCornerSys
{
    public partial class Membership : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"]) // not logged in
            {
                ClientScript.RegisterStartupScript(this.GetType(),
                    "showModal", "showLoginModal();", true);
            }
            else
            {
                Response.Redirect("~/RegisterForm.aspx");
            }
        }
    }
}