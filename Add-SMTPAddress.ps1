function Add-SMTPAddress
{
param($userlistlocation, $smtpdomain)
$badrequests =@()
if($userlistlocation)
{
try
{
$userlist = Get-content -Path $userlistlocation -ErrorAction stop
foreach ($user in $userlist)
{
Write-Host 'Looking for mailbox '$user -ForegroundColor DarkGray
$badrequests += Get-Mailbox -Identity $user
}
}
catch
{
Write-Host $userlistlocation' can not be found' -ForegroundColor Magenta
}
$stats = $badrequests
        foreach($stat in $stats)
        { 
        try
        { 
        write-host 'Trying to Add '($stat.PrimarySmtpAddress.address.Split('@')[0]+'@'+$smtpdomain) -ForegroundColor DarkGray
                get-mailbox $stat.Identity | Set-Mailbox -EmailAddresses @{add=($stat.PrimarySmtpAddress.address.Split('@')[0]+'@'+$smtpdomain)} -ErrorAction stop
        }
        catch
        {
        write-host 'Not Able to Add '($stat.PrimarySmtpAddress.address.Split('@')[0]+'@'+$smtpdomain)' and setup as WindowsEmailAddress' -ForegroundColor Magenta
        }
        } 
}
else
{
Write-Host 'No File found' -BackgroundColor Magenta
}
}
