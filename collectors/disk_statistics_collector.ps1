param (
    [Parameter(Mandatory=$true)][string[]]$ClusterNames
    )

[regex]$rx = "(?<=\\\\).*(?=\\\\)"

$return = New-Object -TypeName PSObject
foreach ($ClusterName in $ClusterNames){
    foreach ($count in ((Get-Counter -ErrorAction stop -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name -Counter "\hyper-v virtual storage device(*)\*").CounterSamples) | sort InstanceName,Path){
        if ($count.InstanceName -eq 'iso'){
            continue
        }
        if (-Not (Get-Member -inputobject $return -name $count.InstanceName -MemberType Properties)){
            $element = New-Object -TypeName PSObject
            Add-Member -InputObject $return -MemberType NoteProperty -Name $count.InstanceName $element # $count.InstanceName
        }
        $return."$($count.InstanceName)" | Add-Member -MemberType NoteProperty -Name $count.Path.split("\")[-1] $count.CookedValue
    }
}

$return | ConvertTo-Json -Compress | Out-File -NoNewline C:\zabbixWorkingFolder\clusterDiskStats.json