#!/usr/bin/perl -WT
# -*- cperl -*-

# Meteoroid PlusCart save server

use CGI;
use DBI;
use DBD::mysql;



my %reasons = ( 0x0000, "No reason",
                0x0001, "Unknown command",
                0x0002, "Bad slot specification",
                0x0003, "Extra data after command",
                0x0004, "Insufficient data",
                0x0005, "Can not load data"
               );



sub sendReply ($$) {
  my ($type, $body) = @_;
  my $internalLength = 1 + (length $body);
  my $externalLength = 1 + $internalLength;
  print "Content-Type: application/octet-stream\n";
  print "Content-Length: $externalLength\n\n";
  binmode STDOUT;
  print (pack C => $internalLength);
  print $type;
  print $body;
  exit 0;
}

sub sendErrorCode ($) {
  my ($code) = @_;
  my $reason = $reasons{ $code } || "($code)";
  printf STDERR "Error: Replying with error code FF%04x\n", $code;
  sendReply E => (pack V => $code);
}

sub shiftPost ($) {
  my ($chars) = @_;
  if (length $post < $chars) {
    sendErrorCode 0x0004;
  }
  my $shift = substr $post, 0, $chars;
  $post = substr $post, $chars;
  return $shift;
}

sub assertDone () {
  unless (0 == length $post) {
    sendErrorCode 0x0003;
  }
}

sub readSlot () {
  my $slot = ord (shiftPost 1);
  if ($slot < 0xa or $slot > 0xb) {
    sendErrorCode 0x0002;
  }
  return $slot;
}

sub dbQuery ($@) {
  my ($sql, @data) = @_;
  my $dbh = DBI->connect('dbi:mysql:test', 'dbuser', 'dbauth');
  my $sth = $dbh->prepare($sql);
  $sth->execute(@data);
  return $sth;
}

sub printNothing ($) {
  my ($error) = @_;
  print STDERR "Error: $error\n";
  print <<END;
Content-Type: text/html

<!DOCTYPE html>
<html>
<head>
<title> Meteoroid for Atari 2600 </title>
</head>
<body>
<h1> Meteoroid for Atari 2600 </h1>
<h4> Error: $error </h4>
<p> This URL is used internally by the PlusCart for Atari 2600 cloud saves for the game <i>Meteoroid</i>. </p>
<p> <a href="/games/Meteoroid/">Find out more.</a> </p>
</body>
</html>
END
  exit 0;
}



my $q = new CGI;

unless ($q->param()) {
  printNothing "No parameters";
}
unless ($q->header('Content-Type') eq 'application/octet-stream') {
  printNothing "Wrong Content-Type";
}
$q->header('PlusStore-ID') =~ /^v([^ ]+) ([a-fA-F0-9]{24})/;
my ($plusCartVersion, $uniqueID) = ($1, $2);
unless ($plusCartVersion && $uniqueID) {
  printNothing "No PlusStore-ID header";
}

my $post = $q->param('POSTDATA');

binmode $post;

{
  my $cookie = shiftPost(6);
  unless ($cookie eq "METR0\n") {
    printNothing("No Meteoroid magic cookie");
  }
}

my $command = shiftPost(1);
if ($command eq 'P') { # Peek
  my $slot = readSlot;
  assertDone;
  my $sth = dbQuery "SELECT 1 FROM plus_cart_saves WHERE id='$uniqueID' AND slot=$slot";
  my @peeked = $sth->fetchrow_array;
  if ($peeked[0] == 1) {
    sendReply P => (pack C => 1);
  } else {
    sendReply P => (pack C => 0);
  }
} elsif ($command eq 'E') { # Erase
  my $slot = readSlot;
  assertDone;
  dbQuery "DELETE FROM plus_cart_saves WHERE id='$uniqueID' AND slot=$slot";
  sendReply D => (pack C => 1);
} elsif ($command eq 'S') { # Save
  my $slot = readSlot;
  my $data = shiftPost 64;
  my $sth = dbQuery "REPLACE INTO plus_cart_saves (id, slot, data) VALUES ('$uniqueID', $slot, ?)", $data;
  sendReply S => (pack 'C' => 1);
} elsif ($command eq 'L') { # Load
  my $slot = readSlot;
  assertDone;
  my $sth = dbQuery "SELECT data FROM plus_cart_saves WHERE id='?' AND slot='?'";
  my @result = $sth->fetchrow_array;
  if (64 == length $result[0]) {
    sendReply L => $result[0];
  }
  sendErrorCode 0x0005;
}

sendErrorCode 0x0001;

