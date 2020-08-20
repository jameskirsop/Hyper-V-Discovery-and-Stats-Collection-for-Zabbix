# HyperV Discovery and Stats Collection for Zabbix

This collection of scipts allows for CPU and disk i/o monitoring of one or more Hyper-V Clusters via a Zabbix Agent installed on a cluster Domain Controller. It provides monitoring of these resources at the hypervisor level on a per-VM basis, so you can determine which VM's may be causing performance issues on a cluster or require additional resources.

## Requirements
This collection of scripts uses a domain account to read data from the cluster and write it as JSON blobs to `C:\zabbixWorkingFolder` on the host running Zabbix Agent. This account requires the following permissions:
* Allow-Read permissions on the Cluster (can be provided by the Cluster Properties Window from Failover Cluster Manager)
* Membership in the local 'Performance Monitor Users' group on each node in the cluster.
* Log on as Batch Job permissions on the server running the Agent
* The Zabbix Agent running as this user
* Read/Write access to the `C:\zabbixWorkingFolder` directory

The project has been built and tested against Zabbix 4.0 (LTS) using 4.0.19 Agents, Proxies and Servers.

Within the `C:\zabbixWorkingFolder` directory, you'll need an extracted copy of the [Python Embedded](https://docs.python.org/3.7/using/windows.html#embedded-distribution) archive. Our `UserParameters` in the Agent configuration file refer to python.exe living in `C:\zabbixWorkingFolder\python37e\`, but you could adjust your UserParameters configuration to refer to a different location. Only features of the Python Standard Library are used, so there's no need for additional modules to be installed via `pip`. For example:

```UserParameter=hyperv_cpustats[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\cpu_statcollection.py" "$1" "$2" "$3"```

## Setup
Files in the `collectors` directory can live in your `zabbixWorkingFolder` and be setup as Scheduled Tasks. Here is some sample PowerShell commands to set up a Scheduled Task. Adjust the `-ClusterNames`, `domain\username` and `New-TimeSpam -Minutes 30` and `Register-ScheduledTask` Name sections to taste
```
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "-noprofile -Command `"C:\zabbixWorkingFolder\cpu_discovery_collector.ps1 -ClusterNames 'sampleClusterName1','sampleClusterName2'`""
$principal = New-ScheduledTaskPrincipal -UserId domain\username -LogonType Password -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 30) 
$credential = $Host.UI.PromptForCredential("Task creds","Enter details","","domain\username")
Register-ScheduledTask "Collect Zabbix Agent VM Disk Discovery - DR Clusters" –Action $action –Trigger $trigger –User $credential.UserName -Password $credential.GetNetworkCredential().Password
```
These scheduled tasks need to be created for the 5 Powershell scripts in the `collectors` directory. They create JSON files that the userparams read to feedback to Zabbix.

Import the `hyperv_vm.xml` template into Zabbix and apply it to the Domain Controller where you have installed Zabbix Agent and created `zabbixWorkingFolder` and set the scheduled tasks. Make sure you also setup UserParameters (see below for the complete collection).

## Why are you using Python?!
We found that calling scripts to return values to Zabbix via `powershell.exe` took significantly more CPU, and therefore execution time than running scripts that performed the same, or similar jobs via Python. Both the Zabbix Agent and Proxy regularly saw issues where the execution time of the PowerShell script exceeded 30 seconds (Zabbix's maximium value). This also meant that the CPU on the cluster's Domain Controller became constantly pegged at 100% utilisation, and the Agent couldn't return data quickly enough leading to incomplete monitoring data. We now see peaks of CPU utilisation while the PowerShell collectors are running, but the average CPU utilisation on the same host is well below 50% when returning the same number of values via UserParameters calling Python Embedded.

## Sample User Parameter Configuration for Zabbix Agent
```
UserParameter=hyperv_discovery,C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -noninteractive -file "C:\Program Files\ZabbixAgent\conf\userparams\vm_discovery.ps1"
UserParameter=hyperv_currentnode[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\vm_currentnode.py" "$1"
UserParameter=hyperv_cpudiscovery[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\cpu_discovery.py" "$1"
UserParameter=hyperv_cpustats[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\cpu_statcollection.py" "$1" "$2" "$3"
UserParameter=hyperv_diskdiscovery[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\discovery_disk.py" "$1"
UserParameter=hyperv_diskstats_v2[*],C:\zabbixWorkingFolder\python37e\python "C:\Program Files\ZabbixAgent\conf\userparams\statcollection_disk_v2.py" "$1" "$2"
```

## Performance Counter Weirdness
We've discovered that in some instances, the names of the hosts represented in Performance Counters differ from the current name of the VM. The `perfCounterCrosscheck.ps` script can be used to produce a list of VM's performance counters where they don't match an known VM name on the cluster.