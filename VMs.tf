locals {
vms  = {  
# Start space for configuration

"vm1-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {1:1}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}": "10.101.5.104"}
    },
    "vm_disks"      : {
    1: {"${local.disk["ssd"]}": "10G"},
    2: {"${local.disk["ssd"]}": "20G"}
    },
    "lvm"           : {
    1: "/opt",
    2: "/mnt"
    }
}

"vm2-terra": {
    "os"            : "${local.os["ubuntu"]["20.04"]}",
    "hardware"      : {2:2}, #CPU:RAM
    "vm_ip"         : {
    1: {"${local.net["srvc"]}" : "10.101.5.91"}
    }
}

# End space for configuration
}
}