#!/usr/bin/env perl

# Parse an ssh known_hosts file for names, and create a model resource file
# listing those nodes.

use Modern::Perl qw/2012/;
use Path::Tiny;
use YAML::Tiny;
use JSON::MaybeXS;

my @files;
my $nodes=YAML::Tiny->new({});
my %RE;
my $username;
my $json=JSON->new->pretty->canonical->allow_blessed->convert_blessed;

# Common regular expressions for later use
$RE{dec255} = qr{ (?: 2 5 [0-5] | 2 [0-4] [0-9] | [01]? [0-9]? [0-9] ) }x;
$RE{dec31} = qr{ (?: [0-9] | [1-2] [0-9] | 3 [0-2] ) }x;
$RE{ipv4} = qr{ (?: (?: $RE{dec255} \. ){3} $RE{dec255} ) ( \/ ( $RE{dec31} ) )? }x;
$RE{ipv6} = qr{ (?: [0-9a-f:]{3,} ) }x;
$RE{dnsseg} = qr{ (?: [a-z0-9\-]{1,255} ) }x;
$RE{hostname} = qr{ (?: (?: $RE{dnsseg} \. )* $RE{dnsseg} ) }x;
$RE{dnspat} = qr{ (?: [a-z0-9\-\*\?]{1,255} ) }x;
$RE{hostpat} = qr{ (?: (?: $RE{dnspat} \. )* $RE{dnspat} ) }x;
$RE{optport} = qr{ (?: : ( \d{1,5} ) )? }x;

# A known_hosts file can contain multiple different types of patterns
sub parse_host_pattern {
  my $entry=shift;
  my $pattern={ port => 22 };
  # [name] or [name]:port
  if ($entry =~ s{^!}{}) {
    $pattern->{negate} = 1;
  }
  if ($entry =~ m{\A \[ ($RE{hostname} | $RE{ipv4} | $RE{ipv6} ) \] $RE{optport} \z}x) {
    $pattern->{name}=$1;
    $pattern->{port}=$2 if (defined $2 and length $2);
  }
  elsif ($entry =~ m{\A ( $RE{hostname} | $RE{ipv4} | $RE{ipv6} ) \z}x) {
    $pattern->{name}=$1;
  }
  elsif ($entry =~ m{\A ( $RE{ipv4} ) $RE{optport} }x) {
    $pattern->{name}=$1;
    $pattern->{port}=$2 if (defined $2 and length $2);
  }
  else {
    return; # did not parse!
  }
  return $pattern;
}

sub parse_kh_entry {
  my $line=shift;
  my $filename=shift;
  my $lineno=shift;
  my %entry=( _line => $line );
  my %record=(osFamily => 'unix', known_hosts_file => $filename->stringify );
  my @patterns;

  # skip blank lines and comment lines
  return if ($line =~ m{\A \s* (?: # .* )? \z});

  if ($line =~ m{\A (?: \@ (cert-authority | revoked) \s+ )? \s* (\S+) \s+ (\S+) \s+ (\S+) (?: \s* (\S .*?) )? \s* \z}x) {
    $entry{marker} = $1 if (defined $1 and length $1);
    $entry{patterns}=[split /,/, $2];
    $entry{type}=$3;
    $entry{key}=$4;
    $record{known_hosts_comment}=$5 if (defined $5 and length $5);
  }
  else {
    warn "$0: ${filename}[${lineno}]: parse error: ${line}\n";
    return;
  }

  for my $pattern (map { parse_host_pattern $_ } @{$entry{patterns}}) {
    next if not defined $pattern;
    next if ($pattern->{negate});
    if (not exists $record{hostname}) {
      if ($pattern->{port} == 22) {
        $record{hostname}=$pattern->{name};
      }
      else {
        $record{hostname}=$pattern->{name} . ':' . $pattern->{port};
      }
      $record{nodename}=$pattern->{name};
    }
    push @{$entry{aliases}}, $pattern->{name} if ($pattern->{name} =~ m{[a-z]});
  }

  $entry{record}=\%record;
  print $json->encode(\%entry), "\n";
  return \%entry;

}

while(@ARGV) {
  my $opt=shift @ARGV;
  if ($opt eq '--') {
    push @files, map { path $_ } @ARGV;
    undef @ARGV;
  }
  elsif ($opt eq '--username') {
    $username=shift @ARGV;
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

for my $file (@files) {
  my $lineno=0;
  for my $line ($file->lines_raw({chomp => 1})) {
    $lineno += 1;
    my $entry=parse_kh_entry $line, $file, $lineno;
    next unless defined $entry;
    next unless exists $entry->{record};
    my $record=$entry->{record};
    my $nodename=$record->{nodename};
    $nodes->[0]->{$nodename} = $record;
  }
}

print $nodes->write_string;
