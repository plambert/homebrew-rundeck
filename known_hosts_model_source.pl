#!/usr/bin/env perl

# Parse an ssh known_hosts file for names, and create a model resource file
# listing those nodes.

use Modern::Perl qw/2012/;
use Path::Tiny;
use JSON::MaybeXS;
use List::Util qw/first/;

my @files;
my $nodes={};
my %RE;
my $include_username=1;
my $username;
my $include_known_hosts_file=1;
my $include_ips=1;
my $include_comment;
my $json=JSON->new->canonical->allow_blessed->convert_blessed->allow_nonref;
my $cache={};

sub maybe_encode {
  my $string=shift;
  return $string unless ($string =~ m{[^a-z0-9_\-:=\+%/\.]}i);
  return $json->encode($string);
}

sub sortable {
  my $string=shift;
  if ($string =~ m{^(?:\d{1,3}\.){3}\d{1,3}$}) {
    $string =~ s{(\d+)}{sprintf "%03d", $1}eg;
    $string="02-$string";
  }
  elsif ($string =~ m{^[0-9a-f:]*?:[0-9a-f:]*$}) {
    my ($a, $b) = split /::/, $string;
    my @a=map { '0'x(4 - length $_) . $_ } split /:/, $a;
    my @b=map { '0'x(4 - length $_) . $_ } split /:/, $b;
    unshift @b, '0000' while (@a + @b < 8);
    $string="01-" . join ':', @a, @b;
  }
  else {
    $string="00-" . join '.', reverse split /\./, $string =~ s{(\d+)}{sprintf '%09d', $1}egr;
  }
  return $string;
}

sub sort_by_nodename {
  ($cache->{$a} //= sortable $a) cmp ($cache->{$b} //= sortable $b);
}

sub parse_kh_entry {
  my $line=shift;
  my $filename=shift;
  my $lineno=shift;
  my @names;
  my $entry={
     osType => 'unix',
     _line => $line,
  };
  my $port;

  # skip blank lines, comments, and markers (@cert-authority or @revoked)
  return if ($line =~ m{^\s* (?: [\#\@] .* ) $}x);
  $line =~ s{^\s*(\S+)\s.*$}{$1}; # remove everything after the first whitespace
  @names=split /,/, $line; # get the individual patterns

  return unless @names;

  for my $name (@names) {
    if ($name =~ s{^\[(.+)\]:(\d+)$}{$1}) {
      if (defined $port and $port != $2) {
        warn "$0: ${filename}[$line]: multiple ports defined in the same line, using the first\n";
      }
      else {
        $port=$2;
      }
    }
    if (not exists $entry->{nodename}) {
      $entry->{nodename}=$name;
    }
    elsif ($entry->{nodename} !~ m{[a-z]}i and $name =~ m{[a-z]}i) {
      $entry->{nodename}=$name;
    }
  }
  if (defined $port and $port != 22) {
    $entry->{hostname}=sprintf '%s:%d', $entry->{nodename}, $port;
  }
  else {
    $entry->{hostname}=$entry->{nodename};
  }

  return $entry;

}

while(@ARGV) {
  my $opt=shift @ARGV;
  if ($opt eq '--') {
    push @files, map { path $_ } @ARGV;
    undef @ARGV;
  }
  elsif ($opt eq '--include-comment') {
    $include_comment=1;
  }
  elsif ($opt eq '--no-include-comment') {
    undef $include_comment;
  }
  elsif ($opt eq '--no-include-filename') {
    undef $include_known_hosts_file;
  }
  elsif ($opt eq '--include-filename') {
    $include_known_hosts_file=1;
  }
  elsif ($opt eq '--no-include-username') {
    undef $include_username;
  }
  elsif ($opt eq '--include-username') {
    $include_username=1;
  }
  elsif ($opt eq '--username') {
    $username=shift @ARGV;
    $include_username=1;
  }
  elsif ($opt eq '--include-ips') {
    $include_ips=1;
  }
  elsif ($opt eq '--no-include-ips') {
    undef $include_ips;
  }
  elsif ($opt =~ m{^-}) {
    die "$0: ${opt}: unknown option";
  }
  else {
    push @files, path $opt;
  }
}

# Use default file if none were given
push @files, path '~', '.ssh', 'known_hosts' unless @files;

# Use default username if none was given
unless (defined $username) {
  if (defined $ENV{USER}) {
    $username=$ENV{USER};
  }
  else {
    $username=qx{whoami};
    chomp $username;
  }
}

my $prefix_removed;
for my $file (@files) {
  my $lineno=0;
  for my $line ($file->lines_raw({chomp => 1})) {
    $lineno += 1;
    my $entry=parse_kh_entry $line, $file, $lineno;
    next unless defined $entry;
    $entry->{known_hosts_file} = $file->stringify if $include_known_hosts_file;
    $entry->{username} = $username if $include_username;
    $nodes->{$entry->{nodename}} = $entry;
  }
}

printf "# Rundeck Nodes generated %s\n", scalar localtime;
printf "---\n";
for my $node (sort sort_by_nodename (keys %$nodes)) {
  next if (not $include_ips and $node =~ m{^([\d\.]+|[\da-f]*:[\da-f]*)$}i);
  printf "# %s\n", $nodes->{$node}->{_line} if ($include_comment);
  printf "%s:\n", maybe_encode($node);
  for my $key (sort keys %{$nodes->{$node}}) {
    next if ($key =~ m{^_});
    printf "  %s: %s\n", maybe_encode($key), maybe_encode($nodes->{$node}->{$key});
  }
  printf "\n";
}
