import json
import argparse

with open(r'C:\zabbixWorkingFolder\clusterDiskStats.json',encoding="utf16") as f:
    d = json.load(f)

parser = argparse.ArgumentParser()
parser.add_argument('check',type=str)
parser.add_argument('disk',type=str)

args = parser.parse_args()

#print(diskpath)
diskpath = args.disk.replace("\\","-").lower()

try:
    if args.check ==  "vdisk_read_count":
        print(d[diskpath]["read count"])
    elif args.check ==  "vdisk_read_operations":
        print(d[diskpath]["read operations/sec"])
    elif args.check ==  "vdisk_write_operations":
        print(d[diskpath]["write operations/sec"])
    elif args.check ==  "vdisk_read_bytes":
        print(d[diskpath]["read bytes/sec"])
    elif args.check ==  "vdisk_write_bytes":
        print(d[diskpath]["write bytes/sec"])
except KeyError as error:
    print('')