# function Send-FileLogEmail {
#     param (
#         # The message body of the email
#         [Parameter(Mandatory=$true,
#         HelpMessage="Message body is mandatory.")]
#         [string]
#         $MessageBody
#     )
#     $To = "filelogger@local.server"
#     $From = "filelogger@local.client"
#     $Server = "localhost"
#     $Port = 25
#     $Subject = "File changes $(Get-Date)"

#     Send-MailMessage -To $To -From $From -Body "$MessageBody" -SmtpServer $Server -Port $Port -Subject $Subject
# }

function Send-FileLogEmail {
    param (
        # MessageBody
        [Parameter(Mandatory=$true)]
        [string]
        $MessageBody
    )
    $smtp = New-Object System.Net.Mail.SmtpClient
    $to = New-Object System.Net.Mail.MailAddress("filelogger@local.server")
    $from = New-Object System.Net.Mail.MailAddress("filelogger@local.client")
    $msg = New-Object System.Net.Mail.MailMessage($from, $to)
    $msg.Subject = "File changes $(Get-Date)"
    $msg.Body = "$MessageBody"
    $smtp.Host = "localhost"
    $smtp.Port = 25
    $smtp.Send($msg)
    $smtp.Dispose();
}