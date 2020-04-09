import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('host',type=str)
args = parser.parse_args()

with open('C:\zabbixWorkingFolder\clusterCpuDiscovery.json',encoding="utf16") as f:
    d = json.load(f)

ret = {'data':[]}
try:
    ret['data'] = d[args.host.replace('_vhost','')]
except KeyError as error:
    ret['data'] = []

print(json.dumps(ret))