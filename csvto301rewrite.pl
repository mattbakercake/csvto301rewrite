#!/usr/bin/perl

## v0.1
## 11/06/2013 dev@mikesierra.net

##
#	csvto301rewrite.pl parses 2 column csv and generates
#	txt file with formatted apache mod_rewrite 301 redirects
#	that can be pasted into .htaccess file
##

use strict;
use warnings;
use Text::CSV;

## globally accessible variables
my $validArgs = checkArgs(); # boolean
my %redirects; # hash of hashes containing redirects as $redirects{url}{querystring} = newurl

##
#	Code - constructor if you will!
##
if ($validArgs) {
	parseCSV();
	orderHash();
	writeTxtFile();
} else {
	print "\l\n Please supply arguements:  \l\n\l\n perl csvto301.pl \"path/to/file.csv\"  \"outputfile.txt\" \"http(s)://redirecturl\"\l\n";
}
## end of code

##
#	checkArgs subroutine checks that the script has been
#	called with the correct number of aguements, and that 
#	the last one at least appears to be a url
#
#	returns: boolean
##
sub checkArgs {
	if (!defined $ARGV[0] || !defined $ARGV[1] || !defined $ARGV[2]) {
		return 0;
	} else {
		if ($ARGV[2] !~ /^http[s]?:\/\/[\w\/.]*/) {
			return 0;
			last;
		}
		return 1;
	}
}

##
#	parseCSV subroutine attempts to open specified csv file,
#	parse it spit values into @columns array
#	sets key=>value pair in  global %redirects hash
##
sub parseCSV {
	my $file = $ARGV[0];
	my $csv = Text::CSV->new();
	my $count = 0;
	my @columns;

	open (CSV, "<", $file) or die " cannot open file \"$file\": $!";
	while (<CSV>) { # for each line of the csv
		if ($csv->parse($_)) { #call the parse function of Text::CSV
			 @columns = $csv->fields();	#add values to array
			 $redirects{$columns[0] } = $columns[1]; #add array values to global hash
			 $count++;
		} else {
			my $err = $csv->error_input;
				print "Failed to parse line: $err";
		}
	}
	close CSV;
	
	print "parsed $count lines in \"$file\"\l\n";
}

##
#	orderHash subroutine splits key=>value pairs in
#	global %redirects hash, splits the key into url and
#	querystring parts and rewrites %redirects as a 
#	hash of hashes $redirects{url}{querystring} = {newurl}
##
sub orderHash {
	my %hash;
	
	while (my ($key,$value) = each(%redirects)) { # foreach key=>value in %redirects hash
		my @urlParts = split('\?', $key); # split the key url into uri and querystring
		$urlParts[0] =~ s/\./\\./; # escape . in uri 
		
		# $hash = {
		#					url1 = {
		#								querystring => newurl
		#								querystring => newurl
		#							}
		#					url2 = {
		#								querystring => newurl
		#							}
		#				}
		$hash{$urlParts[0]}{$urlParts[1]} = $value; # create hash above - duplicate hash keys essentially append values to existing hash
	}
	
	%redirects = %hash;
	
}

##
#	writeTxtFile subroutine creates a text file, loops through the
#	global %redirects hash of hashes and appends apache
#	mod_rewrite 301 redirect statements to it.  It adds /? to 
# 	end of url so that the querystring is excluded from the new url
#	i.e. the redirect is absolutely as the 2nd column of the csv file
## 
sub writeTxtFile {
	my $file = $ARGV[1];
	my $baseUrl = $ARGV[2];
	my $qs;
	
	open (FILE, ">>", $file) or die " cannot open file \"$file\": $!";
	while (my ($key,$value) = each(%redirects)) {
		print FILE "RewriteCond %{REQUEST_URI} ^$key\$\l\n";
		while (my ($key,$value) = each $value) {
			print FILE "RewriteCond %{QUERY_STRING} ^$key\$\l\n";
			if ($value =~ /\/$/) {
				$qs = '?';
			} else {
				$qs = '/?';
			}
			print FILE "RewriteRule ^(.*)\$ $baseUrl$value$qs [L,R=301]\l\n";
		}
		print FILE "\l\n";
	}
	close(FILE);
	print "Redirect statements written to \"$file\"";
}
    