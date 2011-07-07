use strict;
use warnings;
use Test::More;
use Flickr::API::Lite;
use Data::Dumper;
sub p { print STDERR Dumper(@_) }

my $content = <<'...';
<?xml version="1.0" encoding="utf-8" ?>
<rsp stat="ok">
<photoid>3952779017</photoid>
</rsp>
...
my $r = HTTP::Response->new(200, 'ok', [], $content);
my $res = Flickr::API::Lite::UploadResponse->new(res => $r);
is $res->error, undef;
is $res->photo_id, 3952779017;

# finalize
done_testing;

