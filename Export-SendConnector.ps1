function Export-SendConnector
{
$outputlocation = 'C:\temp\' #change your output location here
$sendconnectorconfig=@()

$sendconnectors = Get-SendConnector
foreach ($sendconnector in $sendconnectors)
{
    foreach ($smarthost in $sendconnector.SmartHosts)
    {
        foreach ($sourceserver in $sendconnector.SourceTransportServers)
        {
            foreach ($recipientdomain in $sendconnector.AddressSpaces)
            {
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType Noteproperty -Name Name $sendconnector.name
            $object | Add-Member -MemberType Noteproperty -Name CloudServicesMailEnabled $sendconnector.CloudServicesMailEnabled
            $object | Add-Member -MemberType Noteproperty -Name ConnectedDomains $sendconnector.ConnectedDomains
            $object | Add-Member -MemberType Noteproperty -Name AddressSpaces $recipientdomain
            $object | Add-Member -MemberType Noteproperty -Name SmartHosts $smarthost
            $object | Add-Member -MemberType Noteproperty -Name ConnectorType $sendconnector.ConnectorType
            $object | Add-Member -MemberType Noteproperty -Name DNSRoutingEnabled $sendconnector.DNSRoutingEnabled
            $object | Add-Member -MemberType Noteproperty -Name DomainSecureEnabled $sendconnector.DomainSecureEnabled
            $object | Add-Member -MemberType Noteproperty -Name Fqdn $sendconnector.Fqdn
            $object | Add-Member -MemberType Noteproperty -Name Identity $sendconnector.Identity
            $object | Add-Member -MemberType Noteproperty -Name TlsAuthLevel $sendconnector.TlsAuthLevel
            $object | Add-Member -MemberType Noteproperty -Name TlsCertificateName $sendconnector.TlsCertificateName
            $object | Add-Member -MemberType Noteproperty -Name TlsDomain $sendconnector.TlsDomain
            $object | Add-Member -MemberType Noteproperty -Name RequireTLS  $sendconnector.RequireTLS 
            $sendconnectorconfig += $object
            }
        }
    }
}
write-host 'Trying to export Send-Connector configuration to '($outputlocation+'send-config-export.csv') -ForegroundColor DarkGray
try
{
$sendconnectorconfig | ConvertTo-Csv -Delimiter ';' | Out-File -FilePath ($outputlocation+'send-config-export.csv') -ErrorAction stop
write-host 'Export of Send-Connector configuration to '($outputlocation+'send-config-export.csv')' was successful' -ForegroundColor green
}
catch
{
write-host 'Export of Send-Connector configuration to '($outputlocation+'send-config-export.csv')' was not successful' -ForegroundColor magenta
}
}
