#!/usr/bin/python3.10
import string
import json
import os

num_disks = os.environ['NUM_DISKS']
ip_host = os.environ['IP']
lvm_scheme = os.environ['LVM'].split(" | ")

disk_unit_number = lvm_scheme[0].split(",")
disk_sizes = lvm_scheme[1].split(",")
disk_mounts = lvm_scheme[2].split(",")
disk_labels = []
lvm_map = {}

for index in range(len(disk_sizes)):
    disk_labels.append(f"/dev/sd{string.ascii_lowercase[1:][index]}")
    
for index, mount in enumerate(disk_mounts):
    mount = mount.strip()
    if not lvm_map.get(mount, False):
        lvm_map[mount] = ([], [], [])

    size = int(disk_sizes[index].strip())
    unit = disk_unit_number[index].strip()
    label = disk_labels[int(unit) - 1]

    lvm_map[mount][0].append(size)
    lvm_map[mount][1].append(label)
    lvm_map[mount][2].append(unit)

lvm_variable = []

for mount in list(lvm_map.keys()):
    mount = mount.strip()

    lvm_variable.append(
        {
            "vg": f"vg-infra-{lvm_map[mount][2][0]}",
            "lv": f"lv-infra-{lvm_map[mount][2][0]}-{mount.split('/')[-1]}",
            "disks": lvm_map[mount][1],
            "size": sum(lvm_map[mount][0]) - (len(lvm_map[mount][0]) * 4),
            "mnt": mount
        }
    )

inventory = {
    "all": {"hosts": [ip_host],
            "vars": {"lvm_list": lvm_variable, "num_disks": num_disks}
            },
}

print(json.dumps(inventory))
