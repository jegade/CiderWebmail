package CiderWebmail::Mailbox;

use warnings;
use strict;

use CiderWebmail::Message;
use Mail::Address;

sub new {
    my ($class, $c, $o) = @_;

    die unless $o->{mailbox};

    my $mailbox = {
        mailbox => $o->{mailbox},
        c => $c,
    };

    bless $mailbox, $class;
}

sub mailbox {
    my ($self) = @_;

    return $self->{mailbox};
}

sub list_messages_hash {
    my ($self, $o) = @_;
    
    if (defined($o->{uids})) {
        return $self->{c}->model('IMAPClient')->get_headers_hash($self->{c}, { mailbox => $self->{mailbox}, uids => $o->{uids}, headers => [qw/From Subject Date/] });
    } else {
        return $self->{c}->model('IMAPClient')->get_headers_hash($self->{c}, { mailbox => $self->{mailbox}, sort => $o->{sort}, headers => [qw/From Subject Date/] });
    }
}

sub uids {
    my ($self, $o) = @_;

    return $o->{filter}
        ? $self->{c}->model('IMAPClient')->simple_search($self->{c}, { mailbox => $self->{mailbox}, searchfor => $o->{filter}, sort => $o->{sort} })
        : $self->{c}->model('IMAPClient')->get_folder_uids($self->{c}, { mailbox => $self->{mailbox}, sort => $o->{sort} });
}

sub simple_search {
    my ($self, $o) = @_;
   
    $o->{searchfor} = "ALL" unless $o->{searchfor};

    return $self->{c}->model('IMAPClient')->simple_search($self->{c}, { mailbox => $self->{mailbox}, searchfor => $o->{searchfor}, sort => $o->{sort} });
}


1;
