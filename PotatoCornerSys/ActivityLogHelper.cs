using System;
using System.Configuration;
using System.Data.SqlClient;

namespace PotatoCornerSys
{
    /// <summary>
    /// Static helper for inserting activity log entries.
    /// Renamed from ActivityLog to ActivityLogHelper to avoid conflict
    /// with the ActivityLog.aspx.cs code-behind partial class.
    /// 
    /// USAGE (from any other page):
    ///     ActivityLogHelper.LogActivity("Admin Action", "Did something", User.Identity.Name);
    /// </summary>
    public static class ActivityLogHelper
    {
        public static void LogActivity(
            string activityType,
            string description,
            string performedBy,
            string targetEntity = null,
            string severity = "Info")
        {
            try
            {
                string connectionString = ConfigurationManager
                    .ConnectionStrings["PotatoCornerDB"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Ensure the ActivityLog table exists (singular — matches the GridView query)
                    string createTable = @"
                        IF NOT EXISTS (
                            SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                            WHERE TABLE_NAME = 'ActivityLog'
                        )
                        CREATE TABLE ActivityLog (
                            LogID               INT IDENTITY(1,1) PRIMARY KEY,
                            ActivityType        NVARCHAR(100) NOT NULL,
                            ActivityDescription NVARCHAR(500) NOT NULL,
                            PerformedBy         NVARCHAR(150) NOT NULL,
                            TargetEntity        NVARCHAR(200) NULL,
                            IPAddress           NVARCHAR(50)  NULL,
                            Severity            NVARCHAR(50)  NOT NULL DEFAULT 'Info',
                            Timestamp           DATETIME      NOT NULL DEFAULT GETDATE()
                        )";

                    using (SqlCommand cmd = new SqlCommand(createTable, conn))
                        cmd.ExecuteNonQuery();

                    string insert = @"
                        INSERT INTO ActivityLog
                            (ActivityType, ActivityDescription, PerformedBy, TargetEntity, Severity, Timestamp)
                        VALUES
                            (@ActivityType, @Description, @PerformedBy, @TargetEntity, @Severity, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insert, conn))
                    {
                        cmd.Parameters.AddWithValue("@ActivityType", activityType ?? "");
                        cmd.Parameters.AddWithValue("@Description", description ?? "");
                        cmd.Parameters.AddWithValue("@PerformedBy", performedBy ?? "System");
                        cmd.Parameters.AddWithValue("@TargetEntity", (object)targetEntity ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Severity", severity ?? "Info");
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ActivityLogHelper error: " + ex.Message);
            }
        }
    }
}