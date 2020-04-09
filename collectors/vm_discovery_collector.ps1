param (
    [Parameter(Mandatory=$true)][string[]]$ClusterNames
    )

$vmobjects = @()
$vmArray = New-Object -TypeName PSObject
    
for ($ClusterName in $ClusterNames){
    $VMs = Get-VM -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name
    foreach($VM in $VMs){
        $obj = New-Object -TypeName psobject
        $obj | Add-Member -MemberType NoteProperty -Name "{#VMNAME}" -Value $($VM.Name)
        $obj | Add-Member -MemberType NoteProperty -Name "{#NODENAME}" -Value $($VM.ComputerName)
        Add-Member -InputObject $vmArray -MemberType NoteProperty -Force -Name $($vm.Name) $($vm.ComputerName)
        $vmobjects += $obj
    }
}
# ConvertTo-JSON $vmobjects  -Compress | Write-Host -NoNewline

$export = New-Object -TypeName PSObject
Add-Member -InputObject $export -MemberType NoteProperty -Name data $vmobjects

ConvertTo-JSON $export -Compress | Out-File -NoNewline C:\zabbixWorkingFolder\vmdiscovery.json
$($vmArray | ConvertTo-Json) | Out-File -FilePath C:\zabbixWorkingFolder\vmToHostMap.json