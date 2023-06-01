function Set-CompleteAfterDate
{
param($batchname, $userlistlocation, $amountofdays)
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
write-host 'Collecting information for '$batchname -forgroundcolor darkgray
$badrequests = Get-moverequest -resultsize unlimited -BatchName $batchname
}
foreach ($badrequest in $badrequests)
{
Write-Host 'Trying to update compoleteafter for '$badrequest.identity -ForegroundColor DarkGray
    try
    {
    Set-Moverequest $badrequest.identity -completeafter ((get-date).adddays($amountofdays)) -erroraction stop
    Write-Host 'Sucessful updated completeafter date for '$badrequest.identity' to '((get-date).adddays($amountofdays)) -ForegroundColor green
        try
        {
        write-host 'Resuming moverequest for '$badrequest.identity -forgroundcolor darkgray
        Resume-Moverequest $badrequest.identity -erroraction stop
         write-host 'Resuming was sucessfull moverequest for '$badrequest.identity -foregroundcolor Green

        }
        catch
        {
        write-host 'Resuming failed moverequest for '$badrequest.identity -foregroundcolor Magenta
        write-host $_.ErrorDetails.Message -BackgroundColor DarkMagenta 
        write-host $_.ErrorDetails

        }    
    }
    catch
    {
    Write-Host 'Unable to update '$badrequest.identity -ForegroundColor Magenta
    write-host $_.ErrorDetails.Message -BackgroundColor DarkMagenta 
    write-host $_.ErrorDetails

    }
}
}
