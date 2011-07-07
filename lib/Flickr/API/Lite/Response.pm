use warnings;
use strict;

package Flickr::API::Lite::Response;
use Mouse;
use HTTP::Response;
use JSON ();

has res => (
    is       => 'ro',
    isa      => 'HTTP::Response',
    required => 1,
);

has data => (
    is   => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $content = $self->res->content;
        $content =~ s{^jsonFlickrApi\((.+)\)$}{$1};
        JSON::decode_json($content);
    }
);

sub error {
    my $self = shift;
    my $res = $self->res;
    if ($res->code != 200){
        return "API returned a non-200 status code (@{[ $res->code ]} @{[ $res->status_line ]})";
    }

    my $dat = $self->data;
    if ($dat->{'stat'} ne 'ok') {
        return $dat->{'stat'} . ' "' . $dat->{code} . '" "' . $dat->{message} . '"';
    } else {
        return;
    }
}

no Mouse; __PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

Flickr::API::Lite::Response - 

=head1 SYNOPSIS

  # $res is instance of HTTP::Response
  my $r = Flickr::API::Lite::Response->new(res => $res);
  if (my $err = $r->error) {
     die $err;
  } else {
     use Data::Dumper;
     print Dumper($r->data);
  }

=head1 DESCRIPTION

The response class for Flickr::API::Lite.

=cut
