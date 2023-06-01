function Cancel-FailedMoverequests
{
param($batchname, $userlistlocation)
load-Config
$badrequests =@()
$failedlist = @()
$global:searchrequestlocation = 'C:\temp\'
if($userlistlocation)
{
try
{
$userlist = Get-content -Path $userlistlocation -ErrorAction stop
foreach ($user in $userlist)
{
Write-Host 'Looking for moverequest '$user -ForegroundColor DarkGray
$badrequests += Get-moverequest -Identity $user
}
}
catch
{
Write-Host $userlistlocation' can not be found' -ForegroundColor Magenta
}
}
else
{
write-host 'Collecting information for '$batchname -forgroundcolor darkgray
$badrequests = Get-moverequest -resultsize unlimited -BatchName $batchname -Status Failed
}
foreach ($badrequest in $badrequests)
{
Write-Host 'Trying to remove '$badrequest.identity -ForegroundColor DarkGray
    try
    {
    Remove-Moverequest $badrequest.identity -confirm:$false -erroraction stop
    Write-Host 'Sucessful removed '$badrequest.identity -ForegroundColor green
    }
    catch
    {
    Write-Host 'Unable to remove '$badrequest.identity -ForegroundColor Magenta
    }
    $failedlist += (Get-Mailuser -Identity $badrequest.identity).primarysmtpaddress
}
Write-Host 'Exporting log file '($global:searchrequestlocation+$batchname+'_canceled_Failed_moverequests.txt') -ForegroundColor DarkGray
$failedlist | Out-File -FilePath ($global:searchrequestlocation+$batchname+'_canceled_Failed_moverequests.txt')
}
