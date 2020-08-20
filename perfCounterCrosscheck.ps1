$ClusterName = ''
$healthChecksURL =  "" #Used to ping healthChecks.io on success 

$SMTPServer = ""
$SMTPPort = 25
$MailTo = @("bob@mybob.com")
$MailFrom = "robot@mybob.com"

$return = New-Object -TypeName PSObject
$setCounters = New-Object System.Collections.Generic.HashSet[string]

$myCounters = (Get-Counter -ListSet "Hyper-V Hypervisor Virtual Processor" -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name).Paths | Where-Object {($_ -like "*Run Time*")}
foreach ($count in (Get-Counter -Counter $myCounters -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name).CounterSamples){
    if ($count.InstanceName -eq '_total'){ continue }
    [void]$setCounters.Add([string]$count.InstanceName.split(":")[0])
}

$setHosts = New-Object System.Collections.Generic.HashSet[string]
foreach ($vhost in Get-VM -ComputerName (Get-ClusterNode -Cluster $ClusterName).Name){
    [void]$setHosts.Add($vhost.name.ToLower())
}

$setCounters.ExceptWith($setHosts)
$final = [System.Collections.Generic.List[string]]$setCounters
$final.Sort()

$htmlMessage = "<h3>$($ClusterName)</h3>"
$htmlMessage += "<ul>"
foreach($item in $final){
    $htmlMessage += "<li>$($item)</li>"
}
$htmlMessage += "</ul>"

Send-MailMessage -From $MailFrom -To $MailTo -Subject "Mismatached VM Performance Counters" -Body $htmlmessage -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort

Invoke-RestMethod $healthChecksURL
