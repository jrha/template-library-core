# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Charles Loomis <charles.loomis@cern.ch>
#

# 
# #
# filecopy, 24.10.0-rc5, rc5_1, Wed Nov 13 2024
#

unique template components/filecopy/config-common;

include 'components/filecopy/schema';

# Set prefix to root of component configuration.
prefix '/software/components/filecopy';

#'version' = '24.10.0-rc5';
#'package' = 'NCM::Component';

'active' ?= true;
'dispatch' ?= true;
