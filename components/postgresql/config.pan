#
# Software subject to following license(s):
#   Apache 2 License (http://www.opensource.org/licenses/apache2.0)
#   Copyright (c) Responsible Organization
#

#
# Current developer(s):
#   wouter.depypere@ugent.be <wouter.depypere@ugent.be>
#



unique template components/postgresql/config;

include 'components/postgresql/schema';

bind '/software/components/postgresql' = postgresql_component;

'/software/packages' = pkg_repl('ncm-postgresql', '18.12.0-rc3_1', 'noarch');

include if_exists('components/postgresql/site-config');

prefix '/software/components/postgresql';
'active' ?= true;
'dispatch' ?= true;
'version' ?= '18.12.0';
'dependencies/pre' ?= list('spma');
