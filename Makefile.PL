use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Flickr-API-Lite';
all_from 'lib/Flickr/API/Lite.pm';

requires 'Mouse';
requires 'HTTP::Response';
requires 'JSON';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;
