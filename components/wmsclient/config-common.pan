# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Michel Jouvin <jouvin@lal.in2p3.fr>
#

# #
# Author(s): Jane SMITH, Joe DOE
#

# #
# wmsclient, 24.10.0-rc2, rc2_1, Wed Nov 06 2024
#

unique template components/wmsclient/config-common;

include 'components/wmsclient/schema';

# Set prefix to root of component configuration.
prefix '/software/components/wmsclient';

'version' = '24.10.0';
#'package' = 'NCM::Component';

'active' ?= true;
'dispatch' ?= true;
