@{
    type definitions for filesystems
}
declaration template quattor/filesystems;

@documentation{
    desc = check that no duplicate mountpoints or blockdevices are used
    arg = array of structure_filesystem, from quattor/types/system
}
function filesystems_uniq_paths = {
    mounts = dict();
    blockdevs = dict();
    foreach (idx; data; ARGV[0]){
        bd = data['block_device'];
        mp = data['mountpoint'];
        if (exists(mounts[escape(mp)])) {
            error(format('Duplicate mountpoint %s in filesystems', mp));
        } else {
            mounts[escape(mp)] = 1;
        };
        if (exists(blockdevs[escape(bd)]) && bd != 'tmpfs') {
            error(format('Duplicate blockdevice %s used in filesystems', bd));
        } else {
            blockdevs[escape(bd)] = 1;
        };
    };
    true;
};

@{
    Filestystem definition
}
type structure_filesystem = {
    @{ Block device filesystem resides on, references an entry in /software/components/blockdevices }
    "block_device" : string with exists ("/system/blockdevices/" + SELF)
    "format" : boolean
    "preserve" : boolean
    "mountpoint" : string
    "mount" : boolean
    "mountopts" : string = "defaults"
    "type" : string with match (SELF, "^(ext[2-4]|reiserfs|reiser4|xfs|swap|vfat|jfs|ntfs|tmpfs|none)$")
    @{ Quota percentage }
    "quota" ? long
    @{ Dump frequency }
    "freq" : long = 0
    @{ fsck pass number }
    "pass" : long = 0
    @{ Extra options passed to mkfs }
    "mkfsopts" ? string
    @{ Options for filesystem tuning commands (tune2fs, xfs_admin...) }
    "tuneopts" ? string
    @{ Filesystem label, as in LABEL=foo }
    "label" ? string
    @{ If true, anaconda formats the filesystem. If undef/false, --noformat is used. }
    "ksfsformat" ? boolean
};
