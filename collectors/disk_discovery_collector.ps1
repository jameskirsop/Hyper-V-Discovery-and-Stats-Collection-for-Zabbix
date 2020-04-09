param (
    [Parameter(Mandatory=$true)][string[]]$ClusterNames
    )

$return = New-Object -TypeName PSObject 

foreach ($clusterName in $ClusterNames){
    $disks = Get-VM -ComputerName (Get-ClusterNode -Cluster $ClusterNames) | where {$_.State -eq 'Running'} | Get-VMHardDiskDrive
    foreach ($disk in $disks) {
        if (-Not (Get-Member -inputobject $return -name $disk.VMName -MemberType Properties)){
            $element = [System.Collections.ArrayList]@()
            Add-Member -InputObject $return -MemberType NoteProperty -Name $disk.VMName $element # $count.InstanceName
        }
        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name "{#DISK.NUMBER}" -Value "$($disk.ControllerNumber).$($disk.ControllerLocation)"
        $obj | Add-Member -MemberType NoteProperty -Name "{#DISK.PATH}" -Value $disk.Path
        $obj | Add-Member -MemberType NoteProperty -Name "{#DISK.TYPE}" -Value $disk.ControllerType
        $return."$($disk.VMName)" += $obj
    }
}
ConvertTo-JSON $return -Compress | Out-File -NoNewline C:\zabbixWorkingFolder\clusterDiskDiscovery.json
 
