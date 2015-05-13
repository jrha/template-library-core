# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Luis Fernando Muñoz Mejías <mejias@delta.ft.uam.es>
#

# 
# #
# syslogng, 15.4.0-rc2, rc2_1, 20150513-1258
#

unique template components/syslogng/config;

include { 'components/syslogng/config-common' };
include { 'components/syslogng/config-rpm' };
