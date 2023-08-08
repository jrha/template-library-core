unique template components/spma/config-common-yum;

# Prefix for packages/groups
prefix '/software';
'groups' ?= dict();

# Package to install
'packages' = pkg_repl("ncm-spma", "23.6.0-rc3_1", "noarch");

# Set prefix to root of component configuration.
prefix '/software/components/spma';
'register_change' ?= list(
    "/software/groups",
    "/software/packages",
    "/software/repositories",
);
