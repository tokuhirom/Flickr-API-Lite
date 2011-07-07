package Flickr::API::Lite;
use strict;
use warnings;
use 5.008008;
our $VERSION = '0.01';
use LWP::UserAgent;
use Digest::MD5 ();
use URI;
use 5.008001;
use HTTP::Request::Common;
use Flickr::API::Lite::Response;
use Flickr::API::Lite::UploadResponse;
use Encode;

use Mouse;

has secret => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has key => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has ua => (
    is   => 'ro',
    isa  => 'LWP::UserAgent',
    lazy => 1,
    default => sub {
        my $ua = LWP::UserAgent->new(agent => __PACKAGE__."/$VERSION");
        $ua;
    },
);

has auth_uri => (
    is => 'ro',
    isa => 'Str',
    default => 'http://www.flickr.com/services/auth/',
);

has rest_uri => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://www.flickr.com/services/rest/',
);

has upload_uri => (
    is      => 'ro',
    isa     => 'Str',
    default => 'http://api.flickr.com/services/upload/',
);

sub sign_args {
    my ($self, $args) = @_;

    my $sig  = $self->secret;

    for my $key (sort {$a cmp $b} keys %{$args}) {
        my $value = (defined($args->{$key})) ? $args->{$key} : "";
        $sig .= $key . $value;
    }

    return Digest::MD5::md5_hex(Encode::encode_utf8($sig));
}

sub make_auth_url {
    my ($self, $perms, $frob)  = @_;

    my @args = (
        'api_key' => $self->key,
        'perms'   => $perms
    );

    if ($frob) {
        push @args, 'frob' => $frob;
    }

    my $uri = URI->new($self->auth_uri);
    $uri->query_form(@args, api_sig => $self->sign_args({@args}));
    return $uri;
}

sub make_request {
    my ($self, $api_method, $args) = @_;

    $args->{method} = $api_method;
    $args->{api_key} = $self->key;
    $args->{api_sig} = $self->sign_args($args);

    return POST(
        $self->rest_uri,
        \%$args,
    );
}

sub make_upload_request {
    my ($self, $args) = @_;

     die "Missing 'auth_token' argument" unless $args->{'auth_token'};
    $args->{api_key} = $self->key;
    if (!ref $args->{photo}) {
        $args->{photo} = [$args->{photo}]
    } elsif (ref($args->{photo}) eq 'SCALAR') {
        $args->{photo} = ['flickr.jpg', '', Content_Type => 'image/jpeg', Content => ${$args->{photo}}];
    }

    # photo is _not_ included in the sig
    $args->{api_sig} = $self->sign_args(
        +{
            map { $_ => $args->{$_} }
                grep !/^photo$/, keys %$args
            }
    );

    return POST(
        $self->upload_uri,
        'Content_Type' => 'multipart/form-data',
        Content => \%$args,
    );
}

sub upload {
    my ($self, $method, $args) = @_;
    my $req = $self->make_upload_request($method, $args);
    my $res = $self->ua->request($req);
    return Flickr::API::Lite::UploadResponse->new(res => $res);
}


sub execute_method {
    my ($self, $method, $args) = @_;
    $args->{format} = 'json';
    my $req = $self->make_request($method, $args);
    my $res = $self->ua->request($req);
    return Flickr::API::Lite::Response->new(res => $res);
}


no Mouse; __PACKAGE__->meta->make_immutable();
__END__

=encoding utf8

=head1 NAME

Flickr::API::Lite - yet another Flickr API library

=head1 SYNOPSIS

    use Flickr::API::Lite;

    my $api = Flickr::API::Lite->new(key = "YOUR API KEY", secret => "YOUR API SECRET");
    $api->make_auth_url($perms); # => make authentication url.

    my $res = $api->execute_method('flickr.test.echo', {'hello' => 'world'});

=head1 DESCRIPTION

Flickr::API::Lite is a yet another lightweight flickr client library.

=head1 METHODS

=over 4

=item $api->make_request('flickr.test.echo', {'hello' => 'world'})

return value is instance of HTTP::Request.

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

L<Flickr::API>

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
