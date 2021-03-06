# set-executionpolicy Unrestricted
#
# Скрипт для проверки корректности работы отправки почты на криптоботе
# При нормальной работе сервера из директории $folder все файлы отправляются по электронной почте.
# Если там скапливаются файлы, значит что-то пошло не так. Если дата файла более 2 часов, то скрипт отправляет уведомление по эл.почте.
# Отправка почты осуществляется через MS Exchange.
# Автор: Кульков К.А. (liroy3000@gmail.com)

# mail param.
[string]$MailReportEmailFromAddress = "kulkovka@kibank.ru"
[string]$MailReportEmailToAddress = "kulkovka@kibank.ru"
[string]$MailReportEmailSubject = "Криптобот не отправляет почту"
[string]$MailReportSMTPServer = "mail.of61.kib.ru"
[boolean]$MailReportSMTPServerEnableSSL = $False
[string]$MailReportSMTPServerUsername = ""
[string]$MailReportSMTPServerPassword = ""

# scan param.
$folder = "Z:\transmission.service\OOD"
$limit = (get-date).addhours(-2)

function MailReport {
    param (
        [ValidateSet("TXT","HTML")] 
        [String] $MessageContentType = "HTML"
    )
    $message = New-Object System.Net.Mail.MailMessage
    $mailer = New-Object System.Net.Mail.SmtpClient ($MailReportSMTPServer) #, $MailReportSMTPPort)
    $mailer.EnableSSL = $MailReportSMTPServerEnableSSL
    if ($MailReportSMTPServerUsername -ne "") {
        $mailer.Credentials = New-Object System.Net.NetworkCredential($MailReportSMTPServerUsername, $MailReportSMTPServerPassword)
    }
    $message.From = $MailReportEmailFromAddress
    $message.To.Add($MailReportEmailToAddress)
    $message.Subject = $MailReportEmailSubject
    $message.Body = "    Внимание, следующие файлы имеют дату изменения более 2 часов.
    Возможно, отправка почты не работает, проверь лог!
    "
    $message.Body += $a
    $message.IsBodyHtml = $False
    $mailer.send(($message))
}

$old_files = @()    # Сюда запишутся файлы старше 2 часов.
$files = Get-ChildItem -Recurse -File -Path $folder | select FullName, LastWriteTime
foreach ($file in $files) {
    if ($file.LastWriteTime -lt $limit) {
        $old_files += $file
    }
}
echo $old_files

$a = $old_files | Out-String
# Если массив old_files не пустой, то вызываем функцию отправки уведомления на почту.
if ($old_files.lenght) {
    MailReport
}

exit