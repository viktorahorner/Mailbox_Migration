function Set-BatchName
{
param($batchname, $newbatchname)
$badrequests =@()
write-host 'Collecting information for '$batchname -forgroundcolor darkgray
$badrequests = Get-moverequest -resultsize unlimited -BatchName $batchname
foreach ($badrequest in $badrequests)
{
Write-Host 'Trying to update batchname for '$badrequest.identity -ForegroundColor DarkGray
    try
    {
    Set-Moverequest $badrequest.identity -batchname $newbatchname -erroraction stop
    Write-Host 'Sucessful updated batchname  for '$badrequest.identity' to '$newbatchname -ForegroundColor green
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
