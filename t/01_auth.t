use strict;
use warnings;
use Test::More;
use Flickr::API::Lite;

my $api = Flickr::API::Lite->new(secret => 'fuck', key => 'you');
is $api->sign_args({a => 'b'}), '89836822bdc1a0e63e1a3d337035d136';
is $api->make_auth_url('delete')->as_string, 'http://www.flickr.com/services/auth/?api_key=you&perms=delete&api_sig=5a00dadfb3cd31372562f10664fcc253';

done_testing;
