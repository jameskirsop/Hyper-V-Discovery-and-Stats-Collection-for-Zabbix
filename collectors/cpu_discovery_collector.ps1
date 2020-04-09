 param (
    [Parameter(Mandatory=$true)][string[]]$ClusterNames
    )

$return = New-Object -TypeName PSObject
foreach ($ClusterName in $ClusterNames){
    foreach ($row in (Get-VM -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name | Where-Object { $_.State -eq 'Running' } | Get-VMProcessor | Select-Object -Property Count, VMName)){
        $array = [System.Collections.ArrayList]@()
        $return | Add-Member -Name $row.VMName -MemberType NoteProperty -Value $array
        for ($i = 0; $i -lt $row.Count; $i++) {
            $obj = New-Object -TypeName psobject
            $obj | Add-Member -MemberType NoteProperty -Name "{#CPU.NUMBER}" -Value $($i)
            $obj | Add-Member -MemberType NoteProperty -Name "{#CPU.STATUS}" -Value "unknown"
            $return.$($row.VMName) += $obj
        }
    }
}

ConvertTo-JSON $return -Compress | Out-File -FilePath C:\zabbixWorkingFolder\clusterCpuDiscovery.json 