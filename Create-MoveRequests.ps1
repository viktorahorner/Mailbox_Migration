#How to use
# Enter the name of your migration batch
# Enter the location of your list of users who should be migrated.... (Simply a list with e-mail addresses)
# If you need to delay completion date for some days, just add the amount of days from now.
#script sample Create-MoveRequests -batchname '2ndBatch' -userlistlocation 'C:\temp\userlist.txt' -completeafterdays '5' 

function Create-MoveRequests
{
param($batchname, $userlistlocation, $completeafterdays)
$badrequests =@()
$EndPoint = "hybrid.mccloud.cloud"
$TargetDomain = "mccloud.onmicrosoft.com"
if($userlistlocation)
{
try
{
$badrequests = Get-content -Path $userlistlocation -ErrorAction stop
if($completeafterdays)
{
$completeafter = (get-date).AddDays($completeafterdays)
}
else
{
$completeafter = (get-date)
}
foreach ($badrequest in $badrequests)
{
Write-Host 'Trying to create moverequest for '$badrequest' in Batch '$batchname -ForegroundColor DarkGray
    try
    {
    New-MoveRequest -Identity $badrequest -Remote -RemoteHostName $Endpoint -TargetDeliveryDomain $TargetDomain -RemoteCredential $global:OPCred -Completeafter $completeafter -BatchName $batchname -erroraction stop
    Write-Host 'Sucessful created moverequest for '$badrequest -ForegroundColor green
    }
    catch
    {
    Write-Host 'Unable to Create '$badrequest -ForegroundColor Magenta
Write-Output $_
    }
}
}
catch
{
Write-Host $userlistlocation' can not be found' -ForegroundColor Magenta
Write-Output $_

}
}
else
{
write-host 'Collecting information for '$batchname -forgroundcolor darkgray
$badrequests = Get-moverequest -resultsize unlimited -BatchName $batchname
}
}
