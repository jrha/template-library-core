# #
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

# #
# Current developer(s):
#   Luis Fernando Muñoz Mejías <Luis.Munoz@UGent.be>
#

# #
# Author(s): Germán Cancio, Marco Emilio Poleggi, Michel Jouvin, Jan Iven, Mark R. Bannister
#



unique template components/spma/config-rpm;
include { 'components/spma/schema' };
include { 'components/spma/functions' };

include { 'components/spma/config-common' };

# Package to install
"/software/packages" = pkg_repl("ncm-spma", "14.2.1-1", "noarch");

'/software/components/spma/packager' = 'yum';
"/software/components/spma/register_change" ?= list("/software/packages",
                                                    "/software/repositories");
"/software/components/spma/run" ?= "yes";
