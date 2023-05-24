function Export-MoveRequestStatistics
{
param($batchname)
$failure = @()
$moverequestconfig = @()
$filelocation = 'C:\temp\'
if($batchname)
{
$moverequests = Get-MoveRequest -BatchName $batchname
}
else
{
$moverequests = Get-MoveRequest
}
foreach ($moverequest in $moverequests)
{
$requeststats = Get-MoveRequestStatistics $moverequest.ExchangeGuid
Write-Host 'Checking user '$moverequest.DisplayName -ForegroundColor DarkGray
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType Noteproperty -Name DisplayName $requeststats.DisplayName
                $object | Add-Member -MemberType Noteproperty -Name Status $requeststats.Status
                $object | Add-Member -MemberType Noteproperty -Name StatusDetail $requeststats.StatusDetail
                $object | Add-Member -MemberType Noteproperty -Name SyncStage $requeststats.SyncStage
                $object | Add-Member -MemberType Noteproperty -Name WorkloadType $requeststats.WorkloadType
                $object | Add-Member -MemberType Noteproperty -Name RecipientTypeDetails $requeststats.RecipientTypeDetails
                $object | Add-Member -MemberType Noteproperty -Name QueuedTimestamp $requeststats.QueuedTimestamp
                $object | Add-Member -MemberType Noteproperty -Name StartTimestamp $requeststats.StartTimestamp
                $object | Add-Member -MemberType Noteproperty -Name LastUpdateTimestamp $requeststats.LastUpdateTimestamp
                $object | Add-Member -MemberType Noteproperty -Name LastSuccessfulSyncTimestamp $requeststats.LastSuccessfulSyncTimestamp
                $object | Add-Member -MemberType Noteproperty -Name InitialSeedingCompletedTimestamp $requeststats.InitialSeedingCompletedTimestamp
                $object | Add-Member -MemberType Noteproperty -Name SuspendedTimestamp $requeststats.SuspendedTimestamp
                $object | Add-Member -MemberType Noteproperty -Name OverallDuration  $requeststats.OverallDuration 
                $object | Add-Member -MemberType Noteproperty -Name TotalMailboxSize $requeststats.TotalMailboxSize
                $object | Add-Member -MemberType Noteproperty -Name TotalMailboxItemCount $requeststats.TotalMailboxItemCount
                $object | Add-Member -MemberType Noteproperty -Name BytesTransferred $requeststats.BytesTransferred
                $object | Add-Member -MemberType Noteproperty -Name ItemsTransferred  $requeststats.ItemsTransferred 
                $object | Add-Member -MemberType Noteproperty -Name PercentComplete  $requeststats.PercentComplete 
                $object | Add-Member -MemberType Noteproperty -Name Batchname  $requeststats.Batchname
                $object | Add-Member -MemberType Noteproperty -Name Alias  $requeststats.Alias
                try
                {   
                $object | Add-Member -MemberType Noteproperty -Name EmailAddress  (get-mailuser -identity $requeststats.alias -ErrorAction stop).PrimarySmtpAddress             
                }
                catch
                {
                $object | Add-Member -MemberType Noteproperty -Name EmailAddress  (get-mailbox -identity $requeststats.alias -ErrorAction stop).PrimarySmtpAddress             

                }
                $object | Add-Member -MemberType Noteproperty -Name CompleteAfter  $requeststats.CompleteAfter
                $object | Add-Member -MemberType Noteproperty -Name StartAfter  $requeststats.StartAfter
                $object | Add-Member -MemberType Noteproperty -Name MRSproxy  $requeststats.RemoteHostName
                $object | Add-Member -MemberType Noteproperty -Name TotalInProgressDuration  $requeststats.TotalInProgressDuration                 
                $moverequestconfig += $object
                if($requeststats.Status.Value -eq 'failed')
                {
                Write-Host 'Error detected '$requeststats.DisplayName -ForegroundColor Magenta
                $failure += (($requeststats.DisplayName)+';'+($requeststats).Message)
                }
                Write-Host 'Completeafter '$requeststats.CompleteAfter -BackgroundColor Green -ForegroundColor Black

}
$moverequestconfig | ConvertTo-Csv -Delimiter ';' | Out-File -FilePath ($filelocation+'moverequest-export.csv') -Encoding unicode
$failure | Out-File -FilePath ($filelocation+'failure-export.csv') -Encoding unicode
}
