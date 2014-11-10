# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   David Groep <davidg@nikhef.nl>
#

# #
# Author(s): Jane SMITH, Joe DOE
#

# #
      # pbsclient, 14.10.0-rc3, rc3_1, 20141110-1446
      #

unique template components/pbsclient/config-xml;

include { 'components/pbsclient/config-common' };

# Set prefix to root of component configuration.
prefix '/software/components/pbsclient';

# Embed the Quattor configuration module into XML profile.
'code' = file_contents('components/pbsclient/pbsclient.pm'); 
