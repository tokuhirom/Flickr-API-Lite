use strict;
use warnings;
use Test::More;
use Flickr::API::Lite;
use Data::Dumper;
use POSIX qw(strftime);

sub now { 'ok' }
# sub now { strftime "%a %b %e %H:%M:%S %Y", localtime }

sub p { print STDERR Dumper(@_) }
plan skip_all => 'this test requires ENV[TEST_FLICKR_API_KEY] and ENV[TEST_FLICKR_API_SECRET] and ENV[TEST_FLICKR_AUTH_TOKEN]' unless $ENV{TEST_FLICKR_API_KEY} && $ENV{TEST_FLICKR_API_SECRET} && $ENV{TEST_FLICKR_AUTH_TOKEN};

# initialize
my $api = Flickr::API::Lite->new(key => $ENV{TEST_FLICKR_API_KEY}, secret => $ENV{TEST_FLICKR_API_SECRET});

do {
    # make request object
    my $req = $api->make_upload_request({photo => ['t/images/test.jpg'], auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}});
    isa_ok $req, 'HTTP::Request';
    is $req->method, 'POST';
};

do {
    # valid request.
    my $photo = do {
        open my $fh, '<', 't/images/test.jpg' or die $!;
        local $/;
        <$fh>;
    };
 #  p( $api->make_upload_request({title => now().'.b', photo => 'THIS_IS_PHOTO', auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}}) );
 #  p( $api->make_upload_request({title => now().'.b', photo => ['foo'], auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}}) );
 #  my $r = $api->make_upload_request({title => now().'.b', photo => ['foo'], auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}});
 #  $api->ua->request($r));
    my $res = $api->upload({title => now().'.b', photo => \$photo, auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}});
    is $res->error(), undef, 'valid, by string';
    like $res->photo_id, qr/^\d+$/;
};
die;

do {
    # valid request.
    my $res = $api->upload({title => now().'.a', photo => 't/images/test.jpg', auth_token => $ENV{TEST_FLICKR_AUTH_TOKEN}});
    is $res->error(), undef, 'valid, by file';
    like $res->photo_id, qr/^\d+$/;
};


# finalize
done_testing;

