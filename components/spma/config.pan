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
# Author(s): Germán Cancio, Marco Emilio Poleggi, Michel Jouvin, Jan Iven, Mark R. Bannister, Jindrich Novy, James Adams
#

# #
# spma, 24.10.0, 1, Fri Nov 22 2024
#

unique template components/spma/config;

variable SPMA_BACKEND ?= 'yum';

include format('components/spma/%s/schema', SPMA_BACKEND);
include 'components/spma/functions';

include 'components/spma/config-common';
include format('components/spma/%s/config', SPMA_BACKEND);
