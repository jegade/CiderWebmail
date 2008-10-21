package CiderWebmail::Util;

use warnings;
use strict;

use MIME::Words qw/ decode_mimewords /;
use DateTime;
use DateTime::Format::Mail;

sub decode_header {
    my ($o) = @_;

    return '' unless $o->{header};

    my $header;

    foreach ( decode_mimewords( $o->{header} ) ) {
        if ( @$_ > 1 ) {
            unless (eval {
                    my $converter = Text::Iconv->new($_->[1], "utf-8");
                    $header .= $converter->convert( $_->[0] );
                }) {
                warn "unsupported encoding: $_->[1]";
                $header .= $_->[0];
            }
        } else {
            $header .= $_->[0];
        }
    }

    return $header;
}

sub date_to_datetime {
    my ($o) = @_;

    return '' unless $o->{date};

    #some mailers specify (CEST)... Format::Mail isn't happy about this
    #TODO better solution
    $o->{date} =~ s/\([a-zA-Z]+\)$//;

    my $dt = DateTime::Format::Mail->new();
    $dt->loose;

    my $date = eval { $dt->parse_datetime($o->{date}) };
    unless ($date) {
        warn "$@ parsing $o->{date}";
        $date = DateTime->from_epoch(epoch => 0); # just return a DateTime object so we can continue
    }

    return $date;
}

1;
