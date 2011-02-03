use inc::Module::Install;
name 'Nigiri';
all_from 'lib/Nigiri.pm';
readme_from 'lib/Nigiri.pm';
readme_markdown_from 'lib/Nigiri.pm';
githubmeta;

requires 'DBI';
requires 'DBIx::Inspector';
requires 'Package::Stash';

tests 't/*.t';
author_tests 'xt';

build_requires 'DBD::SQLite';
build_requires 'Test::More';
auto_set_repository;
WriteAll;
