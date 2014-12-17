package Perinci::Sub::Convert::default_lang;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(convert_property_default_lang);

our %SPEC;

$SPEC{convert_property_default_lang} = {
    v => 1.1,
    summary => 'Convert default_lang property in Rinci function metadata',
    args => {
        meta => {
            schema  => 'hash*', # XXX defhash
            req     => 1,
            pos     => 0,
        },
        new => {
            summary => 'New value',
            schema  => ['str*'],
            req     => 1,
            pos     => 1,
        },
    },
    result_naked => 1,
};
sub convert_property_default_lang {
    my %args = @_;

    my $meta = $args{meta} or die "Please specify meta";
    my $new  = $args{new} or die "Please specify new";

    # collect defhashes
    my @dh = ($meta);
    push @dh, @{ $meta->{links} } if $meta->{links};
    push @dh, @{ $meta->{examples} } if $meta->{examples};
    push @dh, $meta->{result} if $meta->{result};
    push @dh, values %{ $meta->{args} } if $meta->{args};
    push @dh, grep {ref($_) eq 'HASH'} @{ $meta->{tags} };

    my $i = 0;
    for my $dh (@dh) {
        $i++;
        my $old = $dh->{default_lang} // "en_US";
        return if $old eq $new && $i == 1;
        $dh->{default_lang} = $new;
        for my $prop (qw/summary description/) {
            my $propold = "$prop.alt.lang.$old";
            my $propnew = "$prop.alt.lang.$new";
            next unless defined($dh->{$prop}) ||
                defined($dh->{$propold}) || defined($dh->{$propnew});
            if (defined $dh->{$prop}) {
                $dh->{$propold} //= $dh->{$prop};
            }
            if (defined $dh->{$propnew}) {
                $dh->{$prop} = $dh->{$propnew};
            } else {
                delete $dh->{$prop};
            }
            if (defined $dh->{$propnew}) {
                delete $dh->{$propnew};
            }
        }
    }
    $meta;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Perinci::Sub::Convert::default_lang qw(convert_property_default_lang);
 convert_property_default_lang(meta => $meta, new => 'id_ID');


=head1 SEE ALSO

L<Rinci>

=cut
