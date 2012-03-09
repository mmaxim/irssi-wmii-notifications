use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '1.00';
%IRSSI = (
    authors => 'Mike Maxim',
    contact => 'mike.maxim@gmail.com',
    name    => 'wmii notifier',
    description => 'Alert user through wmii bottom var',
    license => 'Public'
);

#------------------------------------------------------------------------------

sub wmii_clear_note {
    my ($type, $name) = @_;

    open STDERR, '>/dev/null';
    system("wmiir remove /rbar/irssi_" . $type . '_' . $name);
}

#------------------------------------------------------------------------------

sub wmii_create_note {
    my ($type, $name) = @_;

    open STDERR, '>/dev/null';
    my $echo_cmd = 'echo \'#ffffff #ff0000 #aaaaaa irssi alert - ' . $type . ' - ' . 
                    $name . '\''; 
    my $cmd = $echo_cmd . ' | wmiir create /rbar/irssi_' . $type . '_' .$name;

    system($cmd);
}

#------------------------------------------------------------------------------

sub get_nick {
    my $server = Irssi::active_server();
    return $server->{nick};
}

#------------------------------------------------------------------------------

sub map_type_name {
    my $ty = $_[0];
    if ($ty eq "QUERY") {
        return "privmsg";
    } elsif ($ty eq "CHANNEL") {
        return "chanmsg";
    } else {
        return "";
    }
}

#------------------------------------------------------------------------------

sub clear_note {
    my ($data, $server, $witem, $type) = @_;
    if (length($data) > 0) {
        wmii_clear_note($type, $data);
    } elsif ($witem->{type} eq "QUERY" ||
             $witem->{type} eq "CHANNEL") {
        wmii_clear_note(map_type_name($witem->{type}), $witem->{name}); 
    }
}

#------------------------------------------------------------------------------

sub cmd_clear_note {
    my @arg = @_;
    my ($data, $server, $witem, $type) = @_;
    
    if (length($data) > 0) {
        if (substr($data, 0, 1) eq '#') {
            push(@arg, 'chanmsg');
        } else {
            push(@arg, 'privmsg');
        }
    } else {
        push(@arg, '');
    }

    clear_note(@arg);
}

#------------------------------------------------------------------------------

sub event_windowchanged {
    my ($window, $window_old) = @_;

    my $witem = $window->{active};
    wmii_clear_note(map_type_name($witem->{type}), $witem->{name});
}

#------------------------------------------------------------------------------

sub event_messagepublic {
    my ($server, $msg, $nick, $address, $target) = @_;
    my @keywords = ("okdev", "okevents", get_nick());
    foreach (@keywords) {
        if ($msg =~ m/$_/) {
            wmii_create_note('chanmsg', $target);
            last;
        }
    }
}

#------------------------------------------------------------------------------

sub event_messageprivate {
    my ($server, $msg, $nick, $address) = @_;
    wmii_create_note('privmsg', $nick); 
}

#------------------------------------------------------------------------------

sub event_mymessageprivate {
    my ($server, $msg, $target, $orig_target) = @_;
    wmii_clear_note('privmsg', $orig_target);
}

#------------------------------------------------------------------------------

Irssi::command_bind wclear => \&cmd_clear_note;
Irssi::signal_add("window changed", "event_windowchanged");
Irssi::signal_add("message public", "event_messagepublic");
Irssi::signal_add("message private", "event_messageprivate");
Irssi::signal_add("message own_private", "event_mymessageprivate");

#------------------------------------------------------------------------------

