using eRent.Subscriber.Models;

namespace eRent.Subscriber.Services
{
    public static class EmailTemplateService
    {
        public static string GenerateRentNotificationEmail(RentNotificationDto rent, string notificationType)
        {
            var rentalType = rent.IsDailyRental ? "Daily" : "Monthly";
            var duration = rent.IsDailyRental 
                ? $"{(rent.EndDate - rent.StartDate).Days + 1} day(s)"
                : $"{(rent.EndDate - rent.StartDate).Days} day(s)";

            return notificationType switch
            {
                "Pending" => GeneratePendingEmail(rent, rentalType, duration),
                "Cancelled" => GenerateCancelledEmail(rent, rentalType, duration),
                "Accepted" => GenerateAcceptedEmail(rent, rentalType, duration),
                "Rejected" => GenerateRejectedEmail(rent, rentalType, duration),
                "Paid" => GeneratePaidEmail(rent, rentalType, duration),
                _ => GenerateDefaultEmail(rent, notificationType, rentalType, duration)
            };
        }

        private static string GeneratePendingEmail(RentNotificationDto rent, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #667eea; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
        .status-badge {{ display: inline-block; padding: 8px 16px; background: #ffc107; color: #333; border-radius: 20px; font-weight: bold; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🏠 New Rent Request</h1>
            <p>Your rent request has been submitted</p>
        </div>
        <div class='content'>
            <p>Hello <strong>{rent.LandlordFullName}</strong>,</p>
            <p>You have received a new rent request for your property. The request is currently <span class='status-badge'>Pending</span> your approval.</p>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #667eea;'>Rent Request Details</h3>
                <div class='info-row'>
                    <span class='label'>Tenant: </span>
                    <span class='value'><strong> {rent.UserFullName}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Location: </span>
                    <span class='value'> {rent.PropertyAddress}, {rent.CityName}, {rent.CountryName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Rental Type: </span>
                    <span class='value'> {rentalType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Duration: </span>
                    <span class='value'> {duration}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Start Date: </span>
                    <span class='value'> {rent.StartDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>End Date: </span>
                    <span class='value'> {rent.EndDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Price: </span>
                    <span class='value'><strong style='color: #667eea; font-size: 18px;'>€{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>

            <p>Please review this request and take appropriate action (Accept or Reject) as soon as possible.</p>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private static string GenerateCancelledEmail(RentNotificationDto rent, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #f5576c; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
        .status-badge {{ display: inline-block; padding: 8px 16px; background: #f5576c; color: white; border-radius: 20px; font-weight: bold; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>❌ Rent Cancelled</h1>
            <p>A rent request has been cancelled</p>
        </div>
        <div class='content'>
            <p>Hello <strong> {rent.LandlordFullName}</strong>,</p>
            <p>We wanted to inform you that a rent request for your property has been <span class='status-badge'>Cancelled</span> by the tenant.</p>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #f5576c;'>Cancelled Rent Details</h3>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Tenant: </span>
                    <span class='value'> {rent.UserFullName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Rental Type: </span>
                    <span class='value'> {rentalType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Duration: </span>
                    <span class='value'> {duration}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Dates: </span>
                    <span class='value'> {rent.StartDate:MMMM dd, yyyy} - {rent.EndDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Price: </span>
                    <span class='value'><strong>€{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>

            <p>The property is now available for other renters during this period.</p>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private static string GenerateAcceptedEmail(RentNotificationDto rent, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #4facfe; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
        .status-badge {{ display: inline-block; padding: 8px 16px; background: #28a745; color: white; border-radius: 20px; font-weight: bold; margin: 10px 0; }}
        .cta-button {{ display: inline-block; padding: 12px 30px; background: #4facfe; color: white; text-decoration: none; border-radius: 5px; margin: 20px 0; font-weight: bold; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>✅ Rent Request Accepted!</h1>
            <p>Great news - your request has been approved</p>
        </div>
        <div class='content'>
            <p>Hello <strong> {rent.UserFullName}</strong>,</p>
            <p>🎉 Excellent news! Your rent request has been <span class='status-badge'>Accepted</span> by the landlord.</p>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #4facfe;'>Rent Details</h3>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Location: </span>
                    <span class='value'> {rent.PropertyAddress}, {rent.CityName}, {rent.CountryName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Landlord: </span>
                    <span class='value'> {rent.LandlordFullName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Rental Type: </span>
                    <span class='value'> {rentalType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Duration: </span>
                    <span class='value'> {duration}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Start Date: </span>
                    <span class='value'> {rent.StartDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>End Date: </span>
                    <span class='value'> {rent.EndDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Price: </span>
                    <span class='value'><strong style='color: #4facfe; font-size: 18px;'>€{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>

            <p style='text-align: center;'>
                <strong>Next Step:</strong> Please proceed with payment to confirm your reservation.
            </p>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private static string GenerateRejectedEmail(RentNotificationDto rent, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #fa709a 0%, #fee140 100%); color: #333; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #fa709a; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
        .status-badge {{ display: inline-block; padding: 8px 16px; background: #dc3545; color: white; border-radius: 20px; font-weight: bold; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>⚠️ Rent Request Rejected</h1>
            <p>Your request could not be approved</p>
        </div>
        <div class='content'>
            <p>Hello <strong> {rent.UserFullName}</strong>,</p>
            <p>We regret to inform you that your rent request has been <span class='status-badge'>Rejected</span> by the landlord.</p>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #fa709a;'>Rent Details</h3>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Location: </span>
                    <span class='value'> {rent.PropertyAddress}, {rent.CityName}, {rent.CountryName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Rental Type: </span>
                    <span class='value'> {rentalType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Duration: </span>
                    <span class='value'> {duration}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Dates: </span>
                    <span class='value'> {rent.StartDate:MMMM dd, yyyy} - {rent.EndDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Price: </span>
                    <span class='value'><strong> €{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>

            <p>Don't worry! You can browse other available properties and submit new rent requests.</p>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private static string GeneratePaidEmail(RentNotificationDto rent, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #11998e; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
        .status-badge {{ display: inline-block; padding: 8px 16px; background: #11998e; color: white; border-radius: 20px; font-weight: bold; margin: 10px 0; }}
        .success-box {{ background: #d4edda; border: 1px solid #c3e6cb; padding: 15px; border-radius: 5px; margin: 20px 0; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>💰 Payment Received</h1>
            <p>Rent payment has been completed</p>
        </div>
        <div class='content'>
            <p>Hello <strong> {rent.LandlordFullName}</strong>,</p>
            <p>Great news! Payment for the rent has been received and the reservation is now <span class='status-badge'>Paid</span>.</p>
            
            <div class='success-box'>
                <strong>✅ Payment Confirmed:</strong> The tenant has successfully completed the payment for this rent.
            </div>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #11998e;'>Rent Details</h3>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Tenant: </span>
                    <span class='value'> {rent.UserFullName}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Rental Type: </span>
                    <span class='value'> {rentalType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Duration: </span>
                    <span class='value'> {duration}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Dates: </span>
                    <span class='value'> {rent.StartDate:MMMM dd, yyyy} - {rent.EndDate:MMMM dd, yyyy}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Amount Received: </span>
                    <span class='value'><strong style='color: #11998e; font-size: 18px;'>€{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>

            <p>The property is now confirmed for the tenant during the specified period.</p>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }

        private static string GenerateDefaultEmail(RentNotificationDto rent, string notificationType, string rentalType, string duration)
        {
            return $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='utf-8'>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }}
        .content {{ background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }}
        .info-box {{ background: white; padding: 20px; margin: 15px 0; border-radius: 8px; border-left: 4px solid #667eea; }}
        .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #eee; }}
        .info-row:last-child {{ border-bottom: none; }}
        .label {{ font-weight: bold; color: #555; }}
        .value {{ color: #333; }}
        .footer {{ text-align: center; margin-top: 30px; color: #777; font-size: 12px; }}
    </style>
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>Rent Status Update</h1>
            <p>Your rent status has changed</p>
        </div>
        <div class='content'>
            <p>Hello,</p>
            <p>Your rent status has been updated to: <strong> {notificationType}</strong></p>
            
            <div class='info-box'>
                <h3 style='margin-top: 0; color: #667eea;'>Rent Details</h3>
                <div class='info-row'>
                    <span class='label'>Property: </span>
                    <span class='value'><strong> {rent.PropertyTitle}</strong></span>
                </div>
                <div class='info-row'>
                    <span class='label'>Status: </span>
                    <span class='value'> {notificationType}</span>
                </div>
                <div class='info-row'>
                    <span class='label'>Total Price: </span>
                    <span class='value'><strong> €{rent.TotalPrice:F2}</strong></span>
                </div>
            </div>
            
            <div class='footer'>
                <p>Best regards,<br>The eRent Team</p>
            </div>
        </div>
    </div>
</body>
</html>";
        }
    }
}
