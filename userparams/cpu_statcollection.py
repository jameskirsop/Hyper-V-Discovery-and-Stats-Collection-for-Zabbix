import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('hostname',type=str)
parser.add_argument('check',type=str)
parser.add_argument('cpu_id',type=str)
# parser.add_argument('disk',type=str)
args = parser.parse_args()

niceNameMap = {
    'wait':'mwait instructions forwarded/sec',
    'logical_runtime':'% total run time',
    'guest_runtime':'% \guest run time',
}

with open('C:\zabbixWorkingFolder\clusterCPUStats.json',encoding="utf16") as f:
    d = json.load(f)

try:
    print(d[args.hostname.replace('_vhost','').lower()][args.cpu_id][niceNameMap[args.check]])
except KeyError as error:
    print(None)