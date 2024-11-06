declaration template components/network/types/network/backend/nmstate;

@{implement types specific for nmstate / nmstate.pm}

type structure_network_backend_specific = {
    @{let NetworkManager manage the dns}
    "manage_dns" : boolean = false
    @{let ncm-network cleanup inactive connections}
    "clean_inactive_conn" : boolean = true
};

function network_valid_route = {
    if (exists(SELF['command'])) {
        if (length(SELF) != 1) error("Cannot use command and any of the other attributes as route");
    } else {
        if (!exists(SELF['address']))
            error("Address is mandatory for route (in absence of command)");
        if (exists(SELF['prefix']) && exists(SELF['netmask']))
            error("Use either prefix or netmask as route");
    };

    if (exists(SELF['prefix'])) {
        network_valid_prefix(SELF);
    };

    true;
};