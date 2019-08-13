# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Jaroslaw Polok <jaroslaw.polok@cern.ch>
#   Alan Fitton <Alan.Fitton@morganstanley.com>
#   Michel Jouvin <jouvin@lal.in2p3.fr>
#

# 
# #
# afsclt, 18.12.0-rc8, rc8_1, Tue Aug 13 2019
#

unique template components/afsclt/config;

include 'components/afsclt/schema';

"/software/packages" = pkg_repl("ncm-afsclt", "18.12.0-rc8_1", "noarch");

# Set prefix to root of component configuration.
prefix '/software/components/afsclt';

'version' = '18.12.0';
'active' ?= true;
'dispatch' ?= true;
'dependencies/pre' ?= list("spma");
