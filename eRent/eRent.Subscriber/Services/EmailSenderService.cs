using System.Net;
using System.Net.Mail;
using eRent.Subscriber.Interfaces;

namespace eRent.Subscriber.Services
{
    public class EmailSenderService : IEmailSenderService
    {
        private readonly string _gmailMail = "info.vedadnuhic@gmail.com";
        private readonly string _gmailPass = "ktrt mlro qujo nvks";

        public Task SendEmailAsync(string email, string subject, string message)
        {
            var client = new SmtpClient("smtp.gmail.com", 587)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(_gmailMail, _gmailPass)
            };

            return client.SendMailAsync(
                new MailMessage(from: _gmailMail,
                              to: email,
                              subject,
                              message
                              ));
        }

        public Task SendHtmlEmailAsync(string email, string subject, string htmlBody)
        {
            var client = new SmtpClient("smtp.gmail.com", 587)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(_gmailMail, _gmailPass)
            };

            var mailMessage = new MailMessage(from: _gmailMail, to: email, subject, htmlBody)
            {
                IsBodyHtml = true
            };

            return client.SendMailAsync(mailMessage);
        }
    }
}