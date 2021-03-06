# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Alvaro Simon Garcia <Alvaro.SimonGarcia@UGent.be>
#

# 


declaration template components/opennebula/schema;

include 'quattor/schema';
include 'pan/types';
include 'quattor/aii/opennebula/schema';

type directory = string with match(SELF, '[^/]+/?$');

type opennebula_mysql_db = {
    "server" ? string
    "port" ? type_port
    "user" ? string
    "passwd" ? string
    "db_name" ? string
};

type opennebula_db = {
    include opennebula_mysql_db
    "backend" : string with match(SELF, "^(mysql|sqlite)$")
} with is_consistent_database(SELF);

@documentation{
check if a specific type of database has the right attributes
}
function is_consistent_database = {
    db = ARGV[0];
    if (db['backend'] == 'mysql') {
        req = list('server', 'port', 'user', 'passwd', 'db_name');
        foreach(idx; attr; req) {
            if(!exists(db[attr])) {
                error(format("Invalid mysql db! Expected '%s' ", attr));
                return(false);
            };
        };
    };
    true;
};

type opennebula_log = {
    "system" : string = 'file' with match (SELF, '^(file|syslog)$')
    "debug_level" : long(0..3) = 3
} = dict();

type opennebula_federation = {
    "mode" : string = 'STANDALONE' with match (SELF, '^(STANDALONE|MASTER|SLAVE)$')
    "zone_id" : long = 0
    "master_oned" : string = ''
} = dict();

type opennebula_im = {
    "executable" : string = 'one_im_ssh'
    "arguments" : string
    "sunstone_name" ? string
} = dict();

type opennebula_im_mad_collectd = {
    include opennebula_im
} = dict("executable", 'collectd', "arguments", '-p 4124 -f 5 -t 50 -i 20');

type opennebula_im_mad_kvm = {
    include opennebula_im
} = dict("arguments", '-r 3 -t 15 kvm', "sunstone_name", 'KVM');

type opennebula_im_mad_xen = {
    include opennebula_im
} = dict("arguments", '-r 3 -t 15 xen4', "sunstone_name", 'XEN');

type opennebula_im_mad = {
    "collectd" : opennebula_im_mad_collectd
    "kvm" : opennebula_im_mad_kvm
    "xen" ? opennebula_im_mad_xen
} = dict();

type opennebula_vm = {
    "executable" : string = 'one_vmm_exec'
    "arguments" : string
    "default" : string
    "sunstone_name" : string
    "imported_vms_actions" : string[] = list(
        'terminate',
        'terminate-hard',
        'hold',
        'release',
        'suspend',
        'resume',
        'delete',
        'reboot',
        'reboot-hard',
        'resched',
        'unresched',
        'disk-attach',
        'disk-detach',
        'nic-attach',
        'nic-detach',
        'snapshot-create',
        'snapshot-delete',
    )
    "keep_snapshots" : boolean = true
} = dict();

type opennebula_vm_mad_kvm = {
    include opennebula_vm
} = dict("arguments", '-t 15 -r 0 kvm', "default", 'vmm_exec/vmm_exec_kvm.conf', "sunstone_name", 'KVM');

type opennebula_vm_mad_xen = {
    include opennebula_vm
} = dict("arguments", '-t 15 -r 0 xen4', "default", 'vmm_exec/vmm_exec_xen4.conf');

type opennebula_vm_mad = {
    "kvm" : opennebula_vm_mad_kvm
    "xen" ? opennebula_vm_mad_xen
} = dict();

type opennebula_tm_mad = {
    "executable" : string = 'one_tm'
    "arguments" : string = '-t 15 -d dummy,lvm,shared,fs_lvm,qcow2,ssh,ceph,dev,vcenter,iscsi_libvirt'
} = dict();

type opennebula_datastore_mad = {
    "executable" : string = 'one_datastore'
    "arguments" : string  = '-t 15 -d dummy,fs,lvm,dev,iscsi_libvirt,vcenter -s shared,ssh,ceph,fs_lvm,qcow2,vcenter'
} = dict();

type opennebula_hm_mad = {
    "executable" : string = 'one_hm'
} = dict();

type opennebula_auth_mad = {
    "executable" : string = 'one_auth_mad'
    "authn" : string = 'ssh,x509,ldap,server_cipher,server_x509'
} = dict();

type opennebula_tm_mad_conf = {
    "name" : string = "dummy"
    "ln_target" : string = "NONE"
    "clone_target" : choice('SYSTEM', 'NONE', 'SELF') = "SYSTEM"
    "shared" : boolean = true
    "ds_migrate" ? boolean
    "driver" ? choice('raw', 'qcow2')
    "allow_orphans" ? string
    "tm_mad_system" ? string
    "ln_target_ssh" ? string
    "clone_target_ssh" ? string
    "disk_type_ssh" ? string
    "ln_target_shared" ? string
    "clone_target_shared" ? string
    "disk_type_shared" ? string
} = dict();

@documentation{
The  configuration for each driver is defined in DS_MAD_CONF.
These values are used when creating a new datastore and should not be modified
since they defined the datastore behavior.
}
type opennebula_ds_mad_conf = {
    @{name of the transfer driver, listed in the -d option of the DS_MAD section}
    "name" : string = "dummy"
    @{comma separated list of required attributes in the DS template}
    "required_attrs" : string[] = list('')
    @{specifies whether the datastore can only manage persistent images}
    "persistent_only" : boolean = false
    "marketplace_actions" ? string
} = dict();

@documentation{
The  configuration for each driver is defined in MARKET_MAD_CONF.
These values are used when creating a new marketplace and should not be modified
since they define the marketplace behavior.
A public marketplace can be removed even if it has registered apps.
}
type opennebula_market_mad_conf = {
    @{name of the market driver}
    "name" : string = "one"
    @{comma separated list of required attributes in the Market template}
    "required_attrs" : string[] = list('')
    @{list of actions allowed for a MarketPlaceApp.
        monitor: the apps of the marketplace will be monitored.
        create: the app in the marketplace.
        delete: the app from the marketplace.
    }
    "app_actions" : string[] = list('monitor')
    @{set to TRUE for external marketplaces}
    "public" ? boolean
} = dict();

@documentation{
The following attributes define the default cost for Virtual Machines that don't have
a CPU, MEMORY or DISK cost.
This is used by the oneshowback calculate method.
}
type opennebula_default_cost = {
    "cpu_cost" : long = 0
    "memory_cost" : long = 0
    "disk_cost" : long = 0
} = dict();

@documentation{
VNC_BASE_PORT is deprecated since OpenNebula 5.0
OpenNebula will automatically assign start + vmid,
allowing to generate different ports for VMs so they do not collide.
}
type opennebula_vnc_ports = {
    @{VNC port pool for automatic VNC port assignment,
    if possible the port will be set to START + VMID}
    "start" : long(5900..65535) = 5900
    "reserved" ? long
} = dict() with {deprecated(0, "VNC_BASE_PORT is deprecated since OpenNebula 5.0"); true; };

@documentation{
LAN ID pool for the automatic VLAN_ID assignment.
This pool is for 802.1Q networks (Open vSwitch and 802.1Q drivers).
The driver will try first to allocate VLAN_IDS[START] + VNET_ID
}
type opennebula_vlan_ids = {
    @{first VLAN_ID to use}
    "start" : long = 2
    "reserved" ? long
} = dict();

@documentation{
Automatic VXLAN Network ID (VNI) assignment.
This is used or vxlan networks.
NOTE: reserved is not supported by this pool
}
type opennebula_vxlan_ids = {
    @{first VNI (Virtual Network ID) to use}
    "start" : long = 2
} = dict();

@documentation{
Drivers to manage different marketplaces, specialized for the storage backend.
}
type opennebula_market_mad = {
    @{path of the transfer driver executable, can be an absolute path or
    relative to $ONE_LOCATION/lib/mads (or /usr/lib/one/mads/ if OpenNebula was
    installed in /)
    }
    "executable" : string = 'one_market'
    @{arguments for the driver executable:
        -t number of threads, i.e. number of repo operations at the same time
        -m marketplace mads separated by commas
    }
    "arguments" : string = '-t 15 -m http,s3,one'
} = dict();

@documentation{
check if a specific type of datastore has the right attributes
}
function is_consistent_datastore = {
    ds = ARGV[0];
    if (ds['ds_mad'] == 'ceph') {
        if (ds['tm_mad'] != 'ceph') {
            error("for a ceph datastore both ds_mad and tm_mad should have value 'ceph'");
        };
        req = list('disk_type', 'bridge_list', 'ceph_host', 'ceph_secret', 'ceph_user', 'ceph_user_key', 'pool_name');
        foreach(idx; attr; req) {
            if(!exists(ds[attr])) {
                error(format("Invalid ceph datastore! Expected '%s' ", attr));
            };
        };
    };
    if (ds['ds_mad'] == 'fs') {
        if (ds['tm_mad'] != 'shared') {
            error("for a fs datastore only 'shared' tm_mad is supported for the moment");
        };
    };
    if (ds['type'] == 'SYSTEM_DS') {
        if (ds['tm_mad'] == 'ceph') {
            error("system datastores do not support '%s' TM_MAD", ds['tm_mad']);
        };
    };
    if (ds['ds_mad'] == 'dev') {
        if (ds['tm_mad'] != 'dev') {
            error("for a RDM datastore both ds_mad and tm_mad should have value 'dev'");
        };
        if(!exists(ds['disk_type'])) {
            error("Invalid RDM datastore! Expected 'disk_type'");
        };
    };
    # Checks for other types can be added here
    true;
};

@documentation{
check if a specific type of vnet has the right attributes
}
function is_consistent_vnet = {
    vn = ARGV[0];
    # phydev is only required by vxlan networks
    if (vn['vn_mad'] == 'vxlan') {
        if (!exists(vn['phydev'])) {
            error("VXLAN vnet requires 'phydev' value to attach a bridge");
        };
    # if not the bridge is mandatory
    } else {
        if (!exists(vn['bridge'])) {
            error(format("vnet with 'vn_mad' '%s' requires a 'bridge' value", vn['vn_mad']));
        };
    };
    true;
};

@documentation{
type for ceph datastore specific attributes.
ceph_host, ceph_secret, ceph_user, ceph_user_key and pool_name are mandatory
}
type opennebula_ceph_datastore = {
    "ceph_host" ? string[]
    "ceph_secret" ? type_uuid
    "ceph_user" ? string
    "ceph_user_key" ? string
    "pool_name" ? string
    "rbd_format" ? long(1..2)
};

@documentation{
type for vnet ars specific attributes.
type and size are mandatory
}
type opennebula_ar = {
    "type" : string with match(SELF, "^(IP4|IP6|IP4_6|ETHER)$")
    "ip" ? type_ipv4
    "size" : long (1..)
    "mac" ? type_hwaddr
    "global_prefix" ? string
    "ula_prefix" ? string
};

@documentation{
type for an opennebula datastore. Defaults to a ceph datastore (ds_mad is ceph).
shared DS is also supported
}
type opennebula_datastore = {
    include opennebula_ceph_datastore
    "bridge_list" ? string[]  # mandatory for ceph ds, lvm ds, ..
    "datastore_capacity_check" : boolean = true
    "disk_type" ? choice('RBD', 'BLOCK', 'CDROM', 'FILE')
    "ds_mad" : choice('fs', 'ceph', 'dev') = 'ceph'
    @{set system Datastore TM_MAD value.
        shared: The storage area for the system datastore is a shared directory across the hosts.
        vmfs: A specialized version of the shared one to use the vmfs file system.
        ssh: Uses a local storage area from each host for the system datastore.
        ceph: Uses Ceph storage backend.
    }
    "tm_mad" : choice('shared', 'ceph', 'ssh', 'vmfs', 'dev') = 'ceph'
    "type" : string = 'IMAGE_DS' with match (SELF, '^(IMAGE_DS|SYSTEM_DS)$')
    @{datastore labels is a list of strings to group the datastores under a given name and filter them
    in the admin and cloud views. It is also possible to include in the list
    sub-labels using a common slash: list("Name", "Name/SubName")}
    "labels" ? string[]
    "permissions" ? opennebula_permissions
    @{Adds the datastore to the given clusters}
    "clusters" ? string[]
} = dict() with is_consistent_datastore(SELF);

type opennebula_vnet = {
    "bridge" ? string
    "vn_mad" : string = 'dummy' with match (SELF, '^(802.1Q|ebtables fw|ovswitch|vxlan|vcenter|dummy)$')
    "gateway" ? type_ipv4
    "gateway6" ? type_network_name
    "dns" ? type_ipv4
    "network_mask" ? type_ipv4
    "network_address" ? type_ipv4
    "guest_mtu" ? long
    "context_force_ipv4" ? boolean
    "search_domain" ? string
    "bridge_ovs" ? string
    "vlan" ? boolean
    "vlan_id" ? long(0..4095)
    "ar" ? opennebula_ar
    @{vnet labels is a list of strings to group the vnets under a given name and filter them
    in the admin and cloud views. It is also possible to include in the list
    sub-labels using a common slash: list("Name", "Name/SubName")}
    "labels" ? string[]
    @{set network filter to avoid IP spoofing for the current vnet}
    "filter_ip_spoofing" ? boolean
    @{set network filter to avoid MAC spoofing for the current vnet}
    "filter_mac_spoofing" ? boolean
    @{Name of the physical network device that will be attached to the bridge (VXLAN)}
    "phydev" ? string
    @{MTU for the tagged interface and bridge (VXLAN)}
    "mtu" ? long(1500..)
    "permissions" ? opennebula_permissions
    @{Adds the vnet to the given clusters}
    "clusters" ? string[]
} = dict() with is_consistent_vnet(SELF);

@documentation{
Set OpenNebula hypervisor options and their virtual clusters (if any)
}
type opennebula_host = {
    @{set OpenNebula hosts type.}
    'host_hyp' : string = 'kvm' with match (SELF, '^(kvm|xen)$')
    @{set the network driver in your hosts.
    This option is not longer used by ONE >= 5.x versions.}
    'vnm_mad' ? string with match (SELF, '^(dummy|ovswitch|ovswitch_brcompat)$')
    @{Set the hypervisor cluster. Any new hypervisor is always included within
    "Default" cluster.
    Hosts can be in only one cluster at a time.}
    "cluster" ? string
};

@documentation{
Set OpenNebula regular users and their primary groups.
By default new users are assigned to the users group.
}
type opennebula_user = {
    "ssh_public_key" ? string[]
    "password" ? string
    "group" ? string
    @{user labels is a list of strings to group the users under a given name and filter them
    in the admin and cloud views. It is also possible to include in the list
    sub-labels using a common slash: list("Name", "Name/SubName")}
    "labels" ? string[]
} = dict();

@documentation{
Set a group name and an optional decription
}
type opennebula_group = {
    "description" ? string
    "labels" ? string[]
} = dict();

@documentation{
Set OpenNebula clusters and their porperties.
}
type opennebula_cluster = {
    include opennebula_group
    @{In percentage. Applies to all the Hosts in this cluster.
    It will be subtracted from the TOTAL CPU.
    This value can be negative, in that case you’ll be actually
    increasing the overall capacity so overcommiting host capacity.}
    "reserved_cpu" ? long
    @{In KB. Applies to all the Hosts in this cluster.
    It will be subtracted from the TOTAL MEM.
    This value can be negative, in that case you’ll be actually
    increasing the overall capacity so overcommiting host capacity.}
    "reserved_mem" ? long
} = dict();

@documentation{
type for vmgroup roles specific attributes.
}
type opennebula_vmgroup_role = {
    @{The name of the role, it needs to be unique within the VM Group}
    "name" : string
    @{Placement policy for the VMs of the role}
    "policy" ? choice('AFFINED', 'ANTI_AFFINED')
    @{Defines a set of hosts (by their ID) where the VMs of the role can be executed}
    "host_affined" ? string[]
    @{Defines a set of hosts (by their ID) where the VMs of the role cannot be executed}
    "host_anti_affined" ? string[]
};


@documentation{
Set OpenNebula vmgroups and their porperties.
}
type opennebula_vmgroup = {
    include opennebula_group
    "role" ? opennebula_vmgroup_role[]
    @{List of roles whose VMs has to be placed in the same host}
    "affined" ? string[]
    @{List of roles whose VMs cannot be placed in the same host}
    "anti_affined" ? string[]
} = dict();


type opennebula_remoteconf_ceph = {
    "pool_name" : string
    "host" : string
    "ceph_user" ? string
    "staging_dir" ? directory = '/var/tmp'
    "rbd_format" ? long(1..2)
    "qemu_img_convert_args" ? string
};

@documentation{
Type that sets the OpenNebula
oned.conf file
}
type opennebula_oned = {
    "db" : opennebula_db
    "default_device_prefix" ? string = 'hd' with match (SELF, '^(hd|sd|vd)$')
    "onegate_endpoint" ? string
    "manager_timer" ? long
    "monitoring_interval" : long = 60
    "monitoring_threads" : long = 50
    "host_per_interval" ? long
    "host_monitoring_expiration_time" ? long
    "vm_individual_monitoring" ? boolean
    "vm_per_interval" ? long
    "vm_monitoring_expiration_time" ? long
    "vm_submit_on_hold" ? boolean
    "max_conn" ? long
    "max_conn_backlog" ? long
    "keepalive_timeout" ? long
    "keepalive_max_conn" ? long
    "timeout" ? long
    "rpc_log" ? boolean
    "message_size" ? long
    "log_call_format" ? string
    "scripts_remote_dir" : directory = '/var/tmp/one'
    "log" : opennebula_log
    "federation" : opennebula_federation
    "port" : type_port = 2633
    "vnc_base_port" : long = 5900
    "network_size" : long = 254
    "mac_prefix" : string = '02:00'
    "datastore_location" ? directory = '/var/lib/one/datastores'
    "datastore_base_path" ? directory = '/var/lib/one/datastores'
    "datastore_capacity_check" : boolean = true
    "default_image_type" : string = 'OS' with match (SELF, '^(OS|CDROM|DATABLOCK)$')
    "default_cdrom_device_prefix" : string = 'hd' with match (SELF, '^(hd|sd|vd)$')
    "session_expiration_time" : long = 900
    "default_umask" : long = 177
    "im_mad" : opennebula_im_mad
    "vm_mad" : opennebula_vm_mad
    "tm_mad" : opennebula_tm_mad
    "datastore_mad" : opennebula_datastore_mad
    "hm_mad" : opennebula_hm_mad
    "auth_mad" : opennebula_auth_mad
    "market_mad" : opennebula_market_mad
    "default_cost" : opennebula_default_cost
    "listen_address" : type_ipv4 = '0.0.0.0'
    "vnc_ports" : opennebula_vnc_ports
    "vlan_ids" : opennebula_vlan_ids
    "vxlan_ids" : opennebula_vxlan_ids
    "tm_mad_conf" : opennebula_tm_mad_conf[] = list(
        dict("ds_migrate", true),
        dict("name", "lvm", "clone_target", "SELF"),
        dict(
            "name", "shared",
            "ds_migrate", true,
            "tm_mad_system", "ssh",
            "ln_target_ssh", "SYSTEM",
            "clone_target_ssh", "SYSTEM",
            "disk_type_ssh", "FILE",
        ),
        dict("name", "fs_lvm", "ln_target", "SYSTEM"),
        dict(
            "name", "qcow2",
            "driver", "qcow2",
        ),
        dict("name", "ssh", "ln_target", "SYSTEM", "shared", false, "ds_migrate", true),
        dict("name", "vmfs"),
        dict(
            "name", "ceph",
            "clone_target", "SELF",
            "ds_migrate", false,
            "driver", "raw",
            "allow_orphans", "mixed",
            "tm_mad_system", "ssh,shared",
            "ln_target_ssh", "SYSTEM",
            "clone_target_ssh", "SYSTEM",
            "disk_type_ssh", "FILE",
            "ln_target_shared", "NONE",
            "clone_target_shared", "SELF",
            "disk_type_shared", "rbd",
        ),
        dict("name", "iscsi_libvirt", "clone_target", "SELF", "ds_migrate", false),
        dict(
            "name", "dev",
            "clone_target", "NONE",
            "tm_mad_system", "ssh,shared",
            "ln_target_ssh", "SYSTEM",
            "clone_target_ssh", "SYSTEM",
            "disk_type_ssh", "BLOCK",
            "ln_target_shared", "NONE",
            "clone_target_shared", "SELF",
            "disk_type_shared", "BLOCK",
        ),
        dict("name", "vcenter", "clone_target", "NONE"),
    )
    "ds_mad_conf" : opennebula_ds_mad_conf[] = list(
        dict(),
        dict(
            "name", "ceph",
            "required_attrs", list('DISK_TYPE', 'BRIDGE_LIST', 'CEPH_HOST', 'CEPH_USER', 'CEPH_SECRET'),
            "marketplace_actions", "export",
        ),
        dict(
            "name", "dev",
            "required_attrs", list('DISK_TYPE'),
            "persistent_only", true,
        ),
        dict(
            "name", "iscsi_libvirt",
            "required_attrs", list('DISK_TYPE', 'ISCSI_HOST'),
            "persistent_only", true,
        ),
        dict(
            "name", "fs",
            "marketplace_actions", "export",
        ),
        dict(
            "name", "lvm",
            "required_attrs", list('DISK_TYPE', 'BRIDGE_LIST'),
        ),
        dict(
            "name", "vcenter",
            "required_attrs", list('VCENTER_CLUSTER'),
            "persistent_only", true,
            "marketplace_actions", "export",
        ),
    )
    "market_mad_conf" : opennebula_market_mad_conf[] = list(
        dict("public", true),
        dict(
            "name", "http",
            "required_attrs", list('BASE_URL', 'PUBLIC_DIR'),
            "app_actions", list('create', 'delete', 'monitor'),
        ),
        dict(
            "name", "s3",
            "required_attrs", list('ACCESS_KEY_ID', 'SECRET_ACCESS_KEY', 'REGION', 'BUCKET'),
            "app_actions", list('create', 'delete', 'monitor'),
        ),
    )
    "vm_restricted_attr" : string[] = list(
        "CONTEXT/FILES", "NIC/MAC", "NIC/VLAN_ID", "NIC/BRIDGE",
        "NIC_DEFAULT/MAC", "NIC_DEFAULT/VLAN_ID", "NIC_DEFAULT/BRIDGE",
        "DISK/TOTAL_BYTES_SEC", "DISK/READ_BYTES_SEC", "DISK/WRITE_BYTES_SEC",
        "DISK/TOTAL_IOPS_SEC", "DISK/READ_IOPS_SEC", "DISK/WRITE_IOPS_SEC",
        "CPU_COST", "MEMORY_COST", "DISK_COST",
        "PCI", "EMULATOR", "RAW", "USER_PRIORITY", "SOURCE",
    )
    "image_restricted_attr" : string = 'SOURCE'
    "vnet_restricted_attr" : string[] = list(
        "VN_MAD", "PHYDEV", "VLAN_ID", "BRIDGE", "CONF",
        "BRIDGE_CONF", "IP_LINK_CONF",
        "AR/VN_MAD", "AR/PHYDEV", "AR/VLAN_ID", "AR/BRIDGE",
    )
    "inherit_datastore_attr" : string[] = list(
        "CEPH_HOST", "CEPH_SECRET", "CEPH_KEY", "CEPH_USER", "CEPH_CONF",
        "POOL_NAME", "ISCSI_USER", "ISCSI_USAGE",
        "ISCSI_HOST", "GLUSTER_HOST", "GLUSTER_VOLUME",
        "DISK_TYPE", "ALLOW_ORPHANS", "VCENTER_ADAPTER_TYPE",
        "VCENTER_DISK_TYPE", "VCENTER_DS_REF", "VCENTER_DS_IMAGE_DIR",
        "VCENTER_DS_VOLATILE_DIR", "VCENTER_INSTANCE_ID",
    )
    "inherit_image_attr" : string[] = list(
        "ISCSI_USER", "ISCSI_USAGE", "ISCSI_HOST", "ISCSI_IQN",
        "DISK_TYPE", "VCENTER_ADAPTER_TYPE", "VCENTER_DISK_TYPE",
    )
    "inherit_vnet_attr" : string[] = list(
        "VLAN_TAGGED_ID", "BRIDGE_OVS", "FILTER_IP_SPOOFING", "FILTER_MAC_SPOOFING", "MTU",
        "INBOUND_AVG_BW", "INBOUND_PEAK_BW", "INBOUND_PEAK_KB", "OUTBOUND_AVG_BW",
        "OUTBOUND_PEAK_BW", "OUTBOUND_PEAK_KB", "OUTBOUND_PEAK_KB", "BRIDGE_CONF",
        "IP_LINK_CONF", "VCENTER_NET_REF", "VCENTER_SWITCH_NAME", "VCENTER_SWITCH_NPORTS",
        "VCENTER_PORTGROUP_TYPE", "VCENTER_CCR_REF", "VCENTER_INSTANCE_ID",
    )
};


type opennebula_instance_types = {
    "name" : string
    "cpu" : long(1..)
    "vcpu" : long(1..)
    "memory" : long
    "description" ? string
} = dict();

@documentation{
type for opennebula service common RPC attributes.
}
type opennebula_rpc_service = {
    @{OpenNebula daemon RPC contact information}
    "one_xmlrpc" : type_absoluteURI = 'http://localhost:2633/RPC2'
    @{authentication driver to communicate with OpenNebula core}
    "core_auth" : string = 'cipher' with match (SELF, '^(cipher|x509)$')
};

@documentation{
Type that sets the OpenNebula
sunstone_server.conf file
}
type opennebula_sunstone = {
    include opennebula_rpc_service
    "env" : string = 'prod' with match (SELF, '^(prod|dev)$')
    "tmpdir" : directory = '/var/tmp'
    "host" : type_ipv4 = '127.0.0.1'
    "port" : type_port = 9869
    "sessions" : string = 'memory' with match (SELF, '^(memory|memcache)$')
    "memcache_host" : string = 'localhost'
    "memcache_port" : type_port = 11211
    "memcache_namespace" : string = 'opennebula.sunstone'
    "debug_level" : long (0..3) = 3
    "auth" : string = 'opennebula' with match (SELF, '^(sunstone|opennebula|x509|remote)$')
    "encode_user_password" ? boolean
    "vnc_proxy_port" : type_port = 29876
    "vnc_proxy_support_wss" : string = 'no' with match (SELF, '^(no|yes|only)$')
    "vnc_proxy_cert" : string = ''
    "vnc_proxy_key" : string = ''
    "vnc_proxy_ipv6" : boolean = false
    "lang" : string = 'en_US'
    "table_order" : string = 'desc' with match (SELF, '^(desc|asc)$')
    @{Set default views directory}
    "mode" : string = 'mixed'
    "marketplace_username" ? string
    "marketplace_password" ? string
    "marketplace_url" : type_absoluteURI = 'http://marketplace.opennebula.systems/appliance'
    "oneflow_server" : type_absoluteURI = 'http://localhost:2474/'
    "instance_types" : opennebula_instance_types[] = list (
        dict("name", "small-x1", "cpu", 1, "vcpu", 1, "memory", 128,
                "description", "Very small instance for testing purposes"),
        dict("name", "small-x2", "cpu", 2, "vcpu", 2, "memory", 512,
                "description", "Small instance for testing multi-core applications"),
        dict("name", "medium-x2", "cpu", 2, "vcpu", 2, "memory", 1024,
                "description", "General purpose instance for low-load servers"),
        dict("name", "medium-x4", "cpu", 4, "vcpu", 4, "memory", 2048,
                "description", "General purpose instance for medium-load servers"),
        dict("name", "large-x4", "cpu", 4, "vcpu", 4, "memory", 4096,
                "description", "General purpose instance for servers"),
        dict("name", "large-x8", "cpu", 8, "vcpu", 8, "memory", 8192,
                "description", "General purpose instance for high-load servers"),
    )
    "routes" : string[] = list("oneflow", "vcenter", "support")
};

@documentation{
Type that sets the OpenNebula
oneflow-server.conf file
}
type opennebula_oneflow = {
    include opennebula_rpc_service
    @{host where OneFlow server will run}
    "host" : type_ipv4 = '127.0.0.1'
    @{port where OneFlow server will run}
    "port" : type_port = 2474
    @{time in seconds between Life Cycle Manager steps}
    "lcm_interval" : long = 30
    @{default cooldown period after a scale operation, in seconds}
    "default_cooldown" : long = 300
    @{default shutdown action
    terminate : OpenNebula >= 5.0.0
    shutdown : OpenNebula < 5.0.0
    }
    "shutdown_action" : string = 'terminate' with match (SELF, '^(shutdown|shutdown-hard|terminate|terminate-hard)$')
    @{default numner of virtual machines that will receive the given call in each interval
    defined by action_period, when an action is performed on a role}
    "action_number" : long(1..) = 1
    "action_period" : long(1..) = 60
    @{default name for the Virtual Machines created by OneFlow.
    You can use any of the following placeholders:
        $SERVICE_ID
        $SERVICE_NAME
        $ROLE_NAME
        $VM_NUMBER
    }
    "vm_name_template" : string = '$ROLE_NAME_$VM_NUMBER_(service_$SERVICE_ID)'
    @{log debug level
        0 = ERROR
        1 = WARNING
        2 = INFO
        3 = DEBUG
    }
    "debug_level" : long(0..3) = 2
};

@documentation{
Type that sets the OpenNebula
VMM kvmrc conf files
}
type opennebula_kvmrc = {
    "lang" : string = 'C'
    "libvirt_uri" : string = 'qemu:///system'
    "qemu_protocol" : string = 'qemu+ssh' with match (SELF, '^(qemu\+ssh|qemu\+tcp)$')
    "libvirt_keytab" ? string
    "shutdown_timeout" : long = 300
    "force_destroy" ? boolean
    "cancel_no_acpi" ? boolean
    "default_attach_cache" ? string with match (SELF, '^(default|none|writethrough|writeback|directsync|unsafe)$')
    "migrate_options" ? string
    "default_attach_discard" ? string with match (SELF, '^(ignore|off|unmap|on)$')
};

@documentation{
Type that sets the OpenNebula
VNM (Virtual Network Manager) configuration file on the nodes
}
type opennebula_vnm_conf = {
    @{set to true to check that no other vlans are connected to the bridge.
     Works with 802.1Q and VXLAN.}
    "validate_vlan_id" : boolean = false
    @{enable ARP Cache Poisoning Prevention Rules for Open vSwitch.}
    "arp_cache_poisoning" : boolean = true
    @{base multicast address for each VLAN. The mc address is :vxlan_mc + :vlan_id.
    Used by VXLAN.}
    "vxlan_mc" : type_ipv4 = '239.0.0.0'
    @{Time To Live (TTL) should be > 1 in routed multicast networks (IGMP).
    Used by VXLAN.}
    "vxlan_ttl" : long = 16
};

@documentation{
Type that sets the OpenNebula conf
to contact to ONE RPC server
}
type opennebula_rpc = {
    "port" : type_port = 2633
    "host" : string = 'localhost'
    "user" : string = 'oneadmin'
    "password" : string
} = dict();

@documentation{
Type that sets the OpenNebula
untouchable resources
}
type opennebula_untouchables = {
    "datastores" ? string[]
    "vnets" ? string[]
    "users" ? string[]
    "groups" ? string[]
    "hosts" ? string[]
    "clusters" ? string[]
    "vmgroups" ? string[]
};


@documentation{
Type to define ONE basic resources
datastores, vnets, hosts names, etc
}
type component_opennebula = {
    include structure_component
    'datastores' ? opennebula_datastore{}
    'groups' ? opennebula_group{}
    'users' ? opennebula_user{}
    'vnets' ? opennebula_vnet{}
    'clusters' ? opennebula_cluster{}
    'vmgroups' ? opennebula_vmgroup{}
    'hosts' ? opennebula_host{}
    'rpc' ? opennebula_rpc
    'untouchables' ? opennebula_untouchables
    'oned' ? opennebula_oned
    'sunstone' ? opennebula_sunstone
    'oneflow' ? opennebula_oneflow
    'kvmrc' ? opennebula_kvmrc
    @{set vnm remote configuration}
    'vnm_conf' ? opennebula_vnm_conf
    @{set ssh host multiplex options}
    'ssh_multiplex' : boolean = true
    @{in some cases (such a Sunstone standalone configuration with apache),
    some OpenNebula configuration files should be accessible by a different group (as apache).
    This variable sets the group name to change these files permissions.}
    'cfg_group' ? string
} = dict();
