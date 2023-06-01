function Export-ReceiveConnectors
{
$receiveconnectorconfig=@()
$outputlocation = 'C:\temp\' #change your output location here
$receiveconnectors = Get-ReceiveConnector
foreach ($receiveconnector in $receiveconnectors)
{
        foreach ($remoteiprange in $receiveconnector.RemoteIPRanges)
        {
            foreach ($authmethanism in $receiveconnector.AuthMechanism)
            {
                foreach ($permissiongroups in $receiveconnector.PermissionGroups)
                {
                $object = New-Object -TypeName PSObject
                $object | Add-Member -MemberType Noteproperty -Name Name $receiveconnector.name
                $object | Add-Member -MemberType Noteproperty -Name AuthMechanism $authmethanism
                $object | Add-Member -MemberType Noteproperty -Name Bindings $receiveconnector.Bindings
                $object | Add-Member -MemberType Noteproperty -Name AddressSpaces $recipientdomain
                $object | Add-Member -MemberType Noteproperty -Name DomainSecureEnabled $receiveconnector.DomainSecureEnabled
                $object | Add-Member -MemberType Noteproperty -Name Enabled $receiveconnector.Enabled
                $object | Add-Member -MemberType Noteproperty -Name PermissionGroups $permissiongroups
                $object | Add-Member -MemberType Noteproperty -Name Fqdn $receiveconnector.Fqdn
                $object | Add-Member -MemberType Noteproperty -Name Identity $receiveconnector.Identity
                $object | Add-Member -MemberType Noteproperty -Name RemoteIPRanges $remoteiprange
                $object | Add-Member -MemberType Noteproperty -Name RequireTLS $receiveconnector.RequireTLS
                $object | Add-Member -MemberType Noteproperty -Name RequireEHLODomain $receiveconnector.RequireEHLODomain
                $object | Add-Member -MemberType Noteproperty -Name TransportRole  $receiveconnector.TransportRole 
                $receiveconnectorconfig += $object
                }
            }
    }
}
write-host 'Trying to export Send-Connector configuration to '($outputlocation+'Receive-config-export.csv') -ForegroundColor DarkGray
try
{
$sendconnectorconfig | ConvertTo-Csv -Delimiter ';' | Out-File -FilePath ($outputlocation+'send-config-export.csv') -ErrorAction stop
write-host 'Export of Send-Connector configuration to '($outputlocation+'Receive-config-export.csv')' was successful' -ForegroundColor green
}
catch
{
write-host 'Export of Send-Connector configuration to '($outputlocation+'Receive-config-export.csv')' was not successful' -ForegroundColor magenta
}
}
