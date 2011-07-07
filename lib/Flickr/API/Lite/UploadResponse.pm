use warnings;
use strict;

package Flickr::API::Lite::UploadResponse;
use Mouse;
use HTTP::Response;

has res => (
    is       => 'ro',
    isa      => 'HTTP::Response',
    required => 1,
);

has photo_id  => (
    is => 'ro',
    isa => 'Maybe[Int]',
    lazy => 1,
    default => sub {
        my $self = shift;
        if ($self->res->code == 200 && $self->res->content =~ m{<rsp\s*stat="ok">.+<photoid>\s*([0-9]+)\s*</photoid>}s) {
            return $1;
        } else {
            return;
        }
    }
);

sub error {
    my $self = shift;
    my $res = $self->res;
    if ($res->code != 200){
        return "API returned a non-200 status code (@{[ $res->code ]} @{[ $res->status_line ]})";
    }

    my $content = $self->res->content;
    if ($self->photo_id) {
        return; # succeeded.
    } elsif ($content =~ m{<err\s*([^/]+?)\s*/>}) {
        my $err = $1;
        my ($code) = ($err =~ /code="(\d+)"/);
        my ($msg) = ($err =~ /msg="([^"]+)"/);
        $msg = _unescape($msg);
        return qq{fail "$code" "$msg"};
    } else {
        return "[BUG] unknown response type: $content";
    }
}

sub _unescape {
    my $data = shift;
    $data =~ s/&lt;/</sg;
    $data =~ s/&gt;/>/sg;
    $data =~ s/&quot;/"/sg;
    $data =~ s/&amp;/&/sg;
    $data;
}

no Mouse; __PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Flickr::API::Lite::UploadResponse - 

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

