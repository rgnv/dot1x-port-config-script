#!/usr/bin/perl

if( $#ARGV != 1 ) { 
	print "Syntax: cutover.pl <show int status output file> <desired output file>\n\n"; 
	exit;
}
my ($sec, $min, $hr, $day, $mon, $year) = localtime;
my $timestamp = sprintf("%02d%02d%04d_%02d%02d%02d", $mon + 1, $day, 1900 + $year, $hr, $min, $sec); 

# Grab cmd line arguments
my $input = $ARGV[0];
my $output = $ARGV[1]."_$timestamp.txt";

# Open input file.
open FH, $input or die "Couldn't open $input for reading, $!.\n";

# Create output file.
open OUTPUT, ">$output" or die "Couldn't create $output for reading, $!.\n";

print "NOTE: Be sure that you removed all interfaces from the output that you don't want to apply 802.1X configuration to.\n";
print "\nReading file..\n\n";

while (<FH>) {
	my ($int, $name, $status, $vlan) = 0;
	
	# Parse file into array split by whitespace.
	my @arr = split ( /\s{2,}/, $_ );
	
	# Go through each array item to find interface and VLAN
	foreach my $ln (sort { $a <=> $b } keys @arr) {
		if ( $arr[$ln] =~ m/^Gi|Fa[0-9\/]+$/ ) {
			$int = $arr[$ln];
		} elsif ( $arr[$ln] =~ m/^[0-9]+$/ ) {
			$vlan = $arr[$ln];
		}
	}
	
	# Skip if the variables are empty (usually result of a header/empty row).
	next unless ( $int && $vlan );
	
	print "$int is on $vlan. Writing interface configuration to file.\n";
	
	# Write interface config to file.
		print OUTPUT "interface $int
 switchport mode access
 authentication event fail action next-method
 authentication event server dead action reinitialize vlan $vlan
 authentication event server alive action reinitialize
 authentication host-mode multi-auth
 authentication order dot1x mab
 authentication priority dot1x mab
 authentication port-control auto
 authentication control-direction in
 authentication periodic
 authentication timer reauthenticate server
 authentication violation restrict
 authentication open
 mab
 dot1x pae authenticator
 dot1x timeout tx-period 10\n!\n";
 
}

# Close files.
close FH;
close OUTPUT;

# Check to see if any output was written.. If not, delete the file and die.
$filesize = -s $output;
if ( $filesize == 0 ) { 
	unlink $output; 
	die "ERROR: No output written. Please check input file for correct format. Output file removed. \n";
} else {
	print "Please open $output for your configuration.\n";
}
