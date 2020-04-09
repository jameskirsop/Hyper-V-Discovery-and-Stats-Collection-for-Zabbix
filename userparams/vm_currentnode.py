import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('hostname',type=str)
args = parser.parse_args()

with open("C:\zabbixWorkingFolder\\vmToHostMap.json",encoding="utf16") as f:
    d = json.load(f)

try:
    print(d[args.hostname])
except KeyError as error:
    print(None)