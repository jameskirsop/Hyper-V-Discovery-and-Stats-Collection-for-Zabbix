param (
    [Parameter(Mandatory=$true)][string[]]$ClusterNames
    )

[regex]$rx = "(?<=\\\\).*(?=\\\\)"
[regex]$instance = "^.*(?=:)"
[regex]$cpuid = "(?<=\s)[0-9]*$"

$return = New-Object -TypeName PSObject
foreach ($ClusterName in $ClusterNames){
    $myCounters = (Get-Counter -ListSet "Hyper-V Hypervisor Virtual Processor" -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name).Paths `
        | Where-Object {($_ -like "*Run Time*") -or ($_ -like "*MWAIT Instructions Forwarded/sec")}
    foreach ($count in (Get-Counter -Counter $myCounters -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name).CounterSamples){
       if ($count.InstanceName -eq '_total'){
            continue
        }
        if (-Not (Get-Member -inputobject $return -name $instance.Match($count.InstanceName) -MemberType Properties)){
            $element = New-Object -TypeName PSObject
            Add-Member -InputObject $return -MemberType NoteProperty -Name $instance.Match($count.InstanceName) $element # $count.InstanceName
        }

        if (-Not (Get-Member -inputobject $return.$($instance.Match($count.InstanceName)) -name $cpuid.Match($count.InstanceName) -MemberType Properties)){
            $element = New-Object -TypeName PSObject
            Add-Member -InputObject $return.$($instance.Match($count.InstanceName)) -MemberType NoteProperty -Name $cpuid.Match($count.InstanceName) $element # $count.InstanceName
        }

        $return.$($instance.Match($count.InstanceName)).$($cpuid.Match($count.InstanceName)) | Add-Member -MemberType NoteProperty -Name $count.Path.split("\")[-1] $count.CookedValue
    }
}

$return | ConvertTo-Json -Compress | Out-File -NoNewline C:\zabbixWorkingFolder\clusterCPUStats.json 
