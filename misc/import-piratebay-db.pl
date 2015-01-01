#!/usr/bin/perl

use strict;
use warnings;
use DBI;

## config
my $torrent_file = '/home/cit/complete';
my $db_username  = 'bt_crawler';
my $db_password  = 'bt_crawler';
my $db_name      = 'bt_crawler';

## connect to database
my $dbh = DBI->connect("DBI:Pg:database=$db_name", $db_username, $db_password);

## read piratebay database in
open(my $fh, "<", $torrent_file);
my @list = <$fh>;
close $fh;

foreach my $entry (@list) {
    chomp($entry);
    my ($id, $name, $size, $seeders, $leechers, $info_hash) = $entry =~ /^(\d+)\|(.*)\|(\d+)\|(\d+)\|(\d+)\|(.*)$/;

    my $sth = $dbh->prepare("INSERT INTO torrents VALUES(DEFAULT, ?, ?, ?, ?, ?, ?, false)");
    $sth->execute($id, $name, $size, $seeders, $leechers, $info_hash);
}

$dbh->disconnect();
