function Change-Credentials
{
$global:OPCred= Get-Credential
}

function Resume-FailedRequests
{
param($batchname, $userlistlocation)
$badrequests =@()
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
$badrequests = Get-moverequest -Status failed -resultsize unlimited -BatchName $batchname
}

if($global:OPCred)
{
Write-Host 'Using '$global:OPCred.UserName' credentials' -ForegroundColor DarkGreen
$badrequests = Get-moverequest -Status failed -resultsize unlimited -BatchName $batchname
foreach ($badrequest in $badrequests)
{
Write-Host 'Getting MoveRequestStatistics for '$badrequest.Identity -ForegroundColor DarkGray
$badrequestinfo = Get-MoveRequestStatistics $badrequest.ExchangeGuid
#--- Start troubleshooting of Transient failure error---#
if( $badrequestinfo.message-like '*too many transient failures*')
{
Write-Host 'Transient failure detected on Mailbox '$badrequestinfo.displayname -ForegroundColor DarkYellow
try
{
Write-Host 'trying to setup baditemslimit and largeitemlimit to 50 on Mailbox '$badrequestinfo.displayname -ForegroundColor DarkYellow
Set-MoveRequest $badrequest.ExchangeGuid -LargeItemLimit 50 -BadItemLimit 50  –ApproveSkippedItems –ApproveSkippedItems -RemoteCredential $global:OPCred -ErrorAction stop
Write-Host 'Update of baditemslimit and largeitemlimit to 50 on Mailbox '$badrequestinfo.displayname' was successfull' -ForegroundColor green
}
catch
{
Write-Host 'You dont have the right permissions to modify '$badrequest.identity -ForegroundColor DarkYellow
}
try
{
Write-Host 'Trying to resume '$badrequest.identity -ForegroundColor DarkGray
Resume-Moverequest $badrequest.identity -comfirm:$false  -ErrorAction stop
Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

}
catch
{
Write-Host 'You dont have the right permissions to resume '$badrequest.identity -ForegroundColor Magenta
}
}
#--- End troubleshooting of Transient failure error---#

#--- Start troubleshooting of authentication error---#

if( $badrequestinfo.message -like '*(401) Unauthorized*')
{
Write-Host 'Bad credentials detected for moverequest '$badrequestinfo.displayname 'current credentials are going to be updated' -ForegroundColor DarkYellow
try
{
Set-MoveRequest $badrequest.ExchangeGuid -RemoteCredential $global:OPCred -ErrorAction stop
Write-Host 'Credentials for moverequest '$badrequestinfo.displayname 'have been updated' -ForegroundColor green
}
catch
{
Write-Host 'You dont have the right permissions to modify '$badrequest.identity -ForegroundColor Magenta
}
    try
    {
    Write-Host 'Trying to resume '$badrequest.identity -ForegroundColor DarkGray
    Resume-Moverequest $badrequest.identity -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to resume '$badrequest.identity -ForegroundColor Magenta
    }
}
#--- End troubleshooting of authentication error---#

#--- Start troubleshooting of MRS proxy limit issue error---#

if( $badrequestinfo.message -like '*Unexpected end of file. Following elements are not closed*')
{
Write-Host 'MRS proxy resourcelimit seems to be reached' -ForegroundColor Yellow
Write-Host (Get-moverequest -Status autosuspended).count' with the status AutoSuspended are waiting for completion' -ForegroundColor Yellow
Write-Host 'Please complete oder cancel Autosuspended moverequests to resume another' -BackgroundColor Yellow -ForegroundColor Black
try
{
Set-MoveRequest $badrequest.identity -RemoteCredential $global:OPCred
}
catch
{
Write-Host 'You dont have the right permissions to modify '$badrequest.identity -ForegroundColor Magenta
}
    try
    {
    Write-Host 'Trying to resume '$badrequest.identity -ForegroundColor DarkGray
    Resume-Moverequest $badrequest.identity  -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to resume '$badrequest.identity -ForegroundColor Magenta
    }
}

#--- End troubleshooting of MRS proxy limit issue error---#

#--- Start troubleshooting of Mailbox is locked / latency  issue error---#

if( $badrequestinfo.message -like '*The mailbox is locked.*')
{
Write-Host 'Mailbox seems to be locked or is beeing moved by another administrator' -ForegroundColor Yellow
try
{
Set-MoveRequest $badrequest.identity -RemoteCredential $global:OPCred
}
catch
{
Write-Host 'You dont have the right permissions to modify '$badrequest.identity -ForegroundColor Magenta
}
    try
    {
    Write-Host 'Trying to resume '$badrequest.identity -ForegroundColor DarkGray
    Resume-Moverequest $badrequest.identity  -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to resume '$badrequest.identity -ForegroundColor Magenta
    }
}
#--- Stop troubleshooting of Mailbox is locked / latency  issue error---#

#--- Start troubleshooting an already pending request  issue error---#

if( $badrequestinfo.message -like '*already has a pending request*')
{
Write-Host 'A moverequest for this mailbox seems to persist already' -ForegroundColor Yellow
    try
    {
    Write-Host 'Trying to remove '$badrequest.identity -ForegroundColor DarkGray
    Remove-Moverequest $badrequest.identity -confirm:$false  -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to remove '$badrequest.identity -ForegroundColor Magenta
    }

}
#--- Stop troubleshooting ofalready pending request  issue error---#

#--- Start troubleshooting is listed in this CSV  issue error---#

if( $badrequestinfo.message -like '*is listed in this CSV*')
{
Write-Host 'A moverequest for this mailbox seems to persist in another CSV' -ForegroundColor Yellow
    try
    {
    Write-Host 'Trying to remove '$badrequest.identity -ForegroundColor DarkGray
    Remove-Moverequest $badrequest.identity -confirm:$false  -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to remove '$badrequest.identity -ForegroundColor Magenta
    }

}
#--- Stop troubleshooting of is listed in this CSV  issue error---#

#--- Start troubleshooting is A recipient wasnt found  issue error---#

if( $badrequestinfo.message -like '*A recipient wasn*')
{
Write-Host 'Recipient can not be found in ExchangeOnline check if your user / Mailuser / Mailcontact is synchronized' -ForegroundColor Yellow
    try
    {
    Write-Host 'Trying to remove '$badrequest.identity -ForegroundColor DarkGray
    Remove-Moverequest $badrequest.identity -confirm:$false  -ErrorAction stop
    Write-Host 'Resume '$badrequest.identity' was successful' -ForegroundColor green

    }
    catch
    {
    Write-Host 'You dont have the right permissions to remove '$badrequest.identity -ForegroundColor Magenta
    }

}
#--- Stop troubleshooting of A recipient wasn  issue error---#
}
}
else
{
write-host 'No credentials detected, please enter your credentials for Exchange-Online Recipient-Manager-Role and run the function again' -ForegroundColor Cyan
$global:OPCred = Get-Credential
}
}
