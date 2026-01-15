using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Runtime.Versioning;
using System.Linq;
using eRent.Subscriber.Models;
using eRent.Subscriber.Interfaces;
using System.Net.Sockets;
using System.Net;

namespace eRent.Subscriber.Services
{
    public class BackgroundWorkerService : BackgroundService
    {
        private readonly ILogger<BackgroundWorkerService> _logger;
        private readonly IEmailSenderService _emailSender;
        private readonly string _host = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
        private readonly string _username = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
        private readonly string _password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
        private readonly string _virtualhost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";

        public BackgroundWorkerService(
            ILogger<BackgroundWorkerService> logger,
            IEmailSenderService emailSender)
        {
            _logger = logger;
            _emailSender = emailSender;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            // Check internet connectivity to smtp.gmail.com
            try
            {
                var addresses = await Dns.GetHostAddressesAsync("smtp.gmail.com");
                _logger.LogInformation($"smtp.gmail.com resolved to: {string.Join(", ", addresses.Select(a => a.ToString()))}");
                using (var client = new TcpClient())
                {
                    var connectTask = client.ConnectAsync("smtp.gmail.com", 587);
                    var timeoutTask = Task.Delay(5000, stoppingToken);
                    var completed = await Task.WhenAny(connectTask, timeoutTask);
                    if (completed == connectTask && client.Connected)
                    {
                        _logger.LogInformation("Successfully connected to smtp.gmail.com:587");
                    }
                    else
                    {
                        _logger.LogError("Failed to connect to smtp.gmail.com:587 (timeout or error)");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError($"Internet connectivity check failed: {ex.Message}");
            }

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using (var bus = RabbitHutch.CreateBus($"host={_host};virtualHost={_virtualhost};username={_username};password={_password}"))
                    {
                        // Subscribe to rent notifications
                        bus.PubSub.Subscribe<RentNotification>("Rent_Notifications", HandleRentMessage);

                        _logger.LogInformation("Waiting for rent notifications...");
                        await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                    }
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Error in RabbitMQ listener: {ex.Message}");
                    await Task.Delay(TimeSpan.FromSeconds(5), stoppingToken);
                }
            }
        }

        private async Task HandleRentMessage(RentNotification notification)
        {
            var rent = notification.Rent;

            if (string.IsNullOrWhiteSpace(rent.NotificationType))
            {
                _logger.LogWarning("No notification type provided in the rent notification");
                return;
            }

            try
            {
                // Generate HTML email based on notification type
                var htmlBody = EmailTemplateService.GenerateRentNotificationEmail(rent, rent.NotificationType);
                
                // Determine recipient email and subject based on notification type
                string recipientEmail;
                string subject;

                switch (rent.NotificationType)
                {
                    case "Pending":
                        recipientEmail = rent.LandlordEmail;
                        subject = $"New Rent Request - {rent.PropertyTitle}";
                        break;
                    case "Cancelled":
                        recipientEmail = rent.LandlordEmail;
                        subject = $"Rent Cancelled - {rent.PropertyTitle}";
                        break;
                    case "Accepted":
                        recipientEmail = rent.UserEmail;
                        subject = $"Rent Request Accepted - {rent.PropertyTitle}";
                        break;
                    case "Rejected":
                        recipientEmail = rent.UserEmail;
                        subject = $"Rent Request Rejected - {rent.PropertyTitle}";
                        break;
                    case "Paid":
                        recipientEmail = rent.LandlordEmail;
                        subject = $"Payment Received - {rent.PropertyTitle}";
                        break;
                    default:
                        recipientEmail = rent.UserEmail;
                        subject = $"Rent Status Update - {rent.PropertyTitle}";
                        break;
                }

                if (string.IsNullOrWhiteSpace(recipientEmail))
                {
                    _logger.LogWarning($"No recipient email found for notification type: {rent.NotificationType}");
                    return;
                }

                await _emailSender.SendHtmlEmailAsync(recipientEmail, subject, htmlBody);
                _logger.LogInformation($"Rent notification ({rent.NotificationType}) sent to: {recipientEmail}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send rent notification email: {ex.Message}");
            }
        }
    }
}