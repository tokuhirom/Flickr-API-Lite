use strict;
use warnings;
use utf8;
use Test::More;
use Flickr::API::Lite;
use Data::Dumper;
sub p { print STDERR Dumper(@_) }
plan skip_all => 'this test requires ENV[TEST_FLICKR_API_KEY] and ENV[TEST_FLICKR_API_SECRET]' unless $ENV{TEST_FLICKR_API_KEY} && $ENV{TEST_FLICKR_API_SECRET};

my $api = Flickr::API::Lite->new(key => $ENV{TEST_FLICKR_API_KEY}, secret => $ENV{TEST_FLICKR_API_SECRET});
my $req = $api->make_request('flickr.test.echo' => {a => 'わっほい'});
isa_ok $req, 'HTTP::Request';
is $req->method, 'POST';
my $res = $api->execute_method('flickr.test.echo' => {a => 'わっほい'});
is $res->error(), undef;
is_deeply $res->data,
  {
    'a'       => { '_content' => 'わっほい' },
    'format'  => { '_content' => 'json' },
    'api_sig' => { '_content' => '4c7b1968b11cd9504f716206288618c9' },
    'method'  => { '_content' => 'flickr.test.echo' },
    'api_key' => { '_content' => '68c90fa56422690d05ebdcfc889c0be0' },
    'stat'    => 'ok'
  };

done_testing;
