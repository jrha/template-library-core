# #
# Software subject to following license(s):
#   The Apache Software License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0.txt)
#   null
#

# #
# Current developer(s):
#   Luis Fernando Muñoz Mejías <Luis.Munoz@UGent.be>
#

# #
# Author(s): Michel Jouvin, Gabor Gombas, Ben Jones
#

# #
# dhcp, 24.10.0-rc5, rc5_1, Wed Nov 13 2024
#

unique template quattor/aii/dhcp/schema;

# Information needed for creating the Kickstart file
type structure_dhcp_dhcp_info = {
    "tftpserver" ? string
    "options" ? string{}
};

bind "/system/aii/dhcp" = structure_dhcp_dhcp_info;
