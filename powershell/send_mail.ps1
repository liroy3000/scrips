# Скрипт для отправки электронной почты в PowerShell
#
# Сам скрипт ничего не делает, но может являться шпаргалкой в случае, если к вашему скрипту нужно "прикрутить" оповещение по почте.

function sendMail {

# В скрипте указаны настройки для отправки через Яндекс почту.
# Измените нужные переменные, если используете другой почтовый сервер.
# В реальном сценарии, возможно, некоторые переменные, например, $subject, или $mes.Body, можно вынести в параметры функции.

$serverSmtp = "smtp.yandex.ru" 
$port = 587
$From = "myaddress@yandex.ru" 
$To = "destination-address@yandex.ru, destination-address@gmail.com"
$subject = "ТЕМА ПИСЬМА"
$user = "myaddress@yandex.ru"
$pass = "mail-password"
#$att = New-object Net.Mail.Attachment($file)
$mes = New-Object System.Net.Mail.MailMessage
$mes.From = $from
$mes.To.Add($to)
$mes.Subject = $subject 
$mes.IsBodyHTML = $true 
$mes.Body = "<h1>Тело письма</h1>"
#$mes.Attachments.Add($att) 
$smtp = New-Object Net.Mail.SmtpClient($serverSmtp, $port)
$smtp.EnableSSL = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass);
$smtp.Send($mes) 
#$att.Dispose()

}

