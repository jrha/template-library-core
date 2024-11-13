# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Tim Bell <tim.bell@cern.ch>
#

# 
# #
# hostsfile, 24.10.0-rc5, rc5_1, Wed Nov 13 2024
#

unique template components/hostsfile/config-rpm;

"/software/packages" = pkg_repl("ncm-hostsfile", "24.10.0-rc5_1", "noarch");
