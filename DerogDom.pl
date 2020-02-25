#!/usr/bin/perl
#
# DerogDom.pl
# Written and tested on Ubuntu 12.x
# By	Kirk Greene <kgreene@directdefense.com>
#
# Copyright 2013 DirectDefense, Inc. All rights reserved.
# http://www.directdefense.com/
# Providing Strategic and Proactive Security Services
# 
# Public Release Version 1.0 - May 2013
#
# Script to enumerate derogatory domain names for a given domain
#
# The following script was written to automate the process of
# trying to discover derogatory domain names that have been
# registered that may have a negative effect on a companies
# image and/or reputation. In short, I was tired of manually
# entering derogatory domain names in a browser and decided
# to automate the process.
#
# NOTE: You need to supply below your own Snapito API key
#	http://snapito.com/paid-api.jsp
#
# Usage:
#	perl DerogDom.pl -d <domain> -i <dictionary input file> -t <top level domains>
#
#	-d 	Domain to check against. (ex. abc.com).
#	-i	Dictionary file containing derogatory names to check for. One per line.
#	-t	Top level domains to be used. Default is com,org,net,us.
#		You can though enter your own (ex. -t com,net) or select "all" to use the 
# 		following generic level domains: aero,asia,biz,cat,com,coop,info,int,jobs,
#		mobi,museum,name,net,org,post,pro,tel,travel,xxx
#
#	Exmaple:
#	perl DerogDom.pl -d abc.com -i derogatory_names.txt -t com
#
#	This will check for the following given that derogatory_names.txt includes only 
#	the word "sucks" for example.
#	sucksabc.com
#	sucks-abc.com
#	abcsucks.com
#	abc-sucks.com
#
# As you can imagine, the more derogatory names in you list and the more top level
# domains that are used, the longer the script will take to complete.
#
# End result will be a html report (<domain_derogdom_rpt.html>) and png images within a
# <domain>_derog_images directory. 
#
#	Enjoy and use at your own risk:-)
#
#
####################################################
#	Perl Mods Used
####################################################

use Net::DNS;
use IO::File;
use Getopt::Long qw(:config no_ignore_case bundling);

####################################################
# User Snapito API Key - Must be assigned to screens
####################################################

$apikey = "";

####################################################
#	Main
####################################################

check_opts();
assign_opts();
open_logfile();
create_derogdoms();
search_derogdoms();
close_logfile();
exit;

#############################################################
#	Assign Options
#############################################################
sub assign_opts {

	$domain = $opt_d;
	($domft, $dombk) = split /\./,$domain; # need to break it up for now

	if (!defined @opt_t) {
		@tld = ("com","org","net","us");
	} elsif ($opt_t[0] eq "all") {
		@tld = ("aero","asia","biz","cat","com","coop","info","int","jobs","mobi","museum","name","net","org","post","pro","tel","travel","us","xxx");
	} else {
		@tld = split(/,/,join(',',@opt_t));
	}

	$derogfile = $opt_i;

}

#############################################################
# Open the Log file
#############################################################
sub open_logfile {

	print "DerogDom.pl\n";
	print "Written and tested on Ubuntu 12.x\n";
	print "By Kirk Greene <kgreene\@directdefense.com>\n\n";

	print "Copyright 2013 DirectDefense, Inc. All rights reserved.\n";
	print "http://www.directdefense.com/\n";
	print "Providing Strategic and Proactive Security Services\n\n";
 
	print "Public Release Version 1.0 - May 2013\n\n\n";

	# HTML Reporting
	
	open (RPT,">$domft\_derogdom\_rpt\.html") or die "Can't open the damn html file??";

	print RPT "<!DOCTYPE html>\n";
	print RPT "<html>\n";
	print RPT "<head>\n";
	print RPT "<title>DerogDom</title>\n";
	print RPT "<meta name=\"version\" content=\"Public Release Version 1.0 - May 2013\">\n";
	print RPT "<meta name=\"tested on\" content=\"Written and tested on Ubuntu 12.x\">\n";
	print RPT "<meta name=\"author\" content=\"By Kirk Greene <kgreene\@directdefense.com>\">\n";
	print RPT "<meta name=\"copyright\" content=\"Copyright 2013 DirectDefense, Inc. All rights reserved.\">\n";
	print RPT "</head>\n";
	print RPT "<body>\n\n";
	
	print RPT "<h1><center>Derogatory Domain Report<br>for $domain</center></h1>\n";
	print RPT "<center>By Kirk Greene at DirectDefense Inc.<br>Public Release Version 1.0 - May 2013</center><br>\n\n";

	# Create Index Table
	print RPT "<p><h2>Contents</h2></p>\n";
	print RPT "<ol><li><a href=\"#founddoms\">Found Derogatory Domains</a></li>\n<li><a href=\"#screens\">Screen Captures</a></li>\n<li><a href=\"#whois\">Whois Information</a></li>\n<li><a href=\"#derogdoms\">Created and Tested Derogatory Domains</a></li></ol>\n";

}

#############################################################
# Close the Log file
#############################################################
sub close_logfile {

	print "\n\nThanks for playing!!\n\n";

	# Found Derogatory Names
	print RPT "<p><h2><a id=\"founddoms\">1. Found Derogatory Domains</a></h2></p>\n";
	print RPT "<table border=\"1\">\n";
		print RPT "<tr>\n<th>Domain</th>\n<th>IP Address</th>\n</tr>\n";
	foreach $resdom (keys %resderogdom) {
		print RPT "<tr>\n<td>$resdom</td>\n<td>$resderogdom{$resdom}</td>\n</tr>\n";
	}
	print RPT "</table>\n";
	
	# Screen Captures
	print RPT "<p><h2><a id=\"screens\">2. Screen Captures</a></h2></p>\n";
	print RPT "<table border=\"1\">\n";
	foreach $imgfile (@results) {
		chomp $imgfile;
		print RPT "<tr>\n<th>$imgfile</th>\n</<tr>\n";
		print RPT "<tr>\n<td><img src=\"$imgdir/$imgfile.png\"></td>\n</tr>";
	}
	print RPT "</table>";
	
	#  Whois Information
	print RPT "<p><h2><a id=\"whois\">3. Whois Information</a></h2></p>\n";
	print RPT "<table border=\"1\">\n";
	foreach $whoisvalues ( keys %whoishtml) {
		print RPT "<tr>\n<th>$whoisvalues</th>\n</<tr>\n";
		print RPT "<tr>\n<td>$whoishtml{$whoisvalues}</td>\n</tr>";
	}
	print RPT "</table>\n";
		
	# Derogatory Domains Created and Tested
	print RPT "<p><h2><a id=\"derogdoms\">4. Created and Tested Derogatory Domains</a></h2></p>\n";
	foreach $derogdomval (@derogdoms) {
		chomp($derogdomval);
		print RPT "$derogdomval<br>\n";
	}
	
  print RPT "</html>\n";
	print RPT "</body>\n";

	close (RPT);

}

#############################################################
# Create derogatory domains to test
#############################################################
sub create_derogdoms {
	print "\n------------------------------------------\n\n";
	print "Creating derogatory names from $derogfile\n";
	print "\n------------------------------------------\n\n";

	# Add the derogatory name to the beginning 

	$f = new IO::File($derogfile) || die "Couldn't open file for reading: $!\n";

	while (<$f>){
        	chomp $_;
		foreach $tldval (@tld) {
        		$begdom = "$_$domft\.$tldval";
       			push(@derogdoms,$begdom);
		}	
        }

	# Add the derogatory name to the beginning with hyphen 

	$g = new IO::File($derogfile) || die "Couldn't open file for reading: $!\n";

	while (<$g>){
        	chomp $_;
		foreach $tldval (@tld) {
        		$begdomhy = "$_\-$domft\.$tldval";
        		push(@derogdoms,$begdomhy);
		}
        }

	# Add the derogatory name to the end 

	$h = new IO::File($derogfile) || die "Couldn't open file for reading: $!\n";

	while (<$h>){
        	chomp $_;
		foreach $tldval (@tld) {
        		$enddom = "$domft$_\.$tldval";
        		push(@derogdoms,$enddom);
		}
        }   

	# Add the derogatory name to the end with hyphen

	$j = new IO::File($derogfile) || die "Couldn't open file for reading: $!\n";

	while (<$j>){
        	chomp $_;
		foreach $tldval (@tld) {
        		$enddomhy = "$domft\-$_\.$tldval";
        		push(@derogdoms,$enddomhy);
		}
        }   
                   
	foreach $val (@derogdoms) {
		print LOG "$val\n";
		print "$val\n";
	}

	# Whois info - Ya I know getto coding

	print "\n------------------------------------------\n\n";
	print "Whois information\n";
	print "\n------------------------------------------\n\n";

	foreach $found_derogdoms(@derogdoms) {

	    	chomp $found_derogdoms;
		@whois_info = `whois $found_derogdoms`;
		$chk = "0";
		foreach $who_val (@whois_info) {
			if ( ($who_val =~ m/^Not found:/) || ($who_val =~ m/^No match for/) || ($who_val =~ m/^NOT FOUND/i) ) {
				print "No Whois information found for $found_derogdoms\n";
				$whoishtml{$found_derogdoms} = $who_val;
				$chk = "1";
				} elsif ($who_val =~ m/^WHOIS LIMIT EXCEEDED/) { 
					print "Whois limit exceeded for $found_derogdoms - May want to manually look this one up\n";
					$whoishtml{$found_derogdoms} = $who_val;
					$chk = "1";
				}
			}

		if ($chk eq "0") {
			print "\n\n";
			print "Whois information for $found_derogdoms\n";
			print "--------------------------------------\n\n";
			$who_html = "";
			foreach $whoisval (@whois_info) {
				print "$whoisval";
				$who_html .= "$whoisval<br>";
				}
			$whoishtml{$found_derogdoms} = $who_html;

			print "\n\n";
			print "--------------------------------------\n\n";
			print "\n\n";
		}
	}
}

#############################################################
# Search for derogatory names using created list
#############################################################
sub search_derogdoms {

	print "\n------------------------------------------\n\n";
	print "Looking up derogatory names now\n";
	print "\n------------------------------------------\n\n";

	foreach $domval (@derogdoms) {

	undef(@derogdom);
	$res = Net::DNS::Resolver->new;
	$res->tcp_timeout(7);
	$query = $res->search($domval);
	if ($query) {
      		foreach $rr ($query->answer) {
        		if ($rr->type eq "A"){
       		 		print $rr->string, "\n";
       		 		@derogdomhtml = $rr->string;
				foreach $derognames (@derogdomhtml) {
					($fval0,$fval1,$fval2,$fval3,$fval4) = split(/\s+/,$derognames);
					chomp($fval0);
                			chomp($fval4);
                			chop($fval0);
					$resderogdom{$fval0} = $fval4;
					}
				@derogdom = split('\s+',$rr->string);
       				push @results,$derogdom[0]; #push the derogatory domian into an array
          			}
      			}
  		}
	}

	# Take Screen Captures of these bad domains - again getto
	# Thanks Tony for this piece:-)

	print "\n-----------------------------------------------------\n\n";
	print "Finally, let's take some screen captures of the domains\n";
	print "\n-----------------------------------------------------\n\n";

	if ($apikey ne "") {
		$imgdir = $domft . "_derog_images";
		system("mkdir $imgdir");
		
		foreach $screenshot (@results) {
			chomp $screenshot;
			chop $screenshot;
			system("wget http://api.snapito.com/web/$apikey/full/$screenshot?fast -O $imgdir/$screenshot.png");
			print "Screen shot of $screenshot saved to $imgdir/$screenshot.png\n";
		}
	} else {
		print "No defined Snapito API key to take a screen capture\n";
	}
}

###########################################################
# Check/Validate Options
###########################################################

sub check_opts {
	$result = GetOptions (
		"d=s" => \$opt_d,	# Get the domain
		"i=s" => \$opt_i,	# dictionary file to use
		"t=s" => \@opt_t,	# Top level domain(s)
	);

	# Check for options d and i not gven
	unless ($opt_d && $opt_i) {
		print "You need to supply both option d and i?\n";
		&cmdline; 
	}

}

#####################################
##          Option Menu		   ##
#####################################

sub cmdline {
    print "
   Derogatory Domain Script (DerogDom.pl)

   Ver 1.0
   By Kirk Greene <kgreene\@directdefense.com>

   The following options are avaialable for this script. Note that 
   options -d (domain) and -i (dictionary file of derogatory names)
   are required.  

     Usage:\n
	-d	Domain to check against (ex. abc.com)
	-i	Dictionary file containing derogatory names to check for. 
		One word per line. See sample file that came with the script.
    	-t	Top level domains to be used. Default is com,org,net,us.
		You can enter your own seperated by a comma (ex. -t com,net) 
		or enter \"all\" to use the following generic level domains: 
		aero,asia,biz,cat,com,coop,info,int,jobs,mobi,museum,name,
		net,org,post,pro,tel,travel,xxx
		
	At the conclusion of the script an html report will be generated
	named after the domain you used (ex. abc_derogdom_rpt.html). Additionally,
	any derogatory domains found will have a screen capture image taken
	and save in the following format: derogatory_domain.png
		
   Examples:

	To use top level com,net,org,us domains:
	example: $0 -d abc.com -i derog_names.txt

	To use custom domains:
    	example: $0 -d abc.com -i derog_names.txt -t com,net

	To use all generic domains:
    	example: $0 -d abc.com -i derog_names.txt -t all

   NOTE: You need to edit the script and put in your own Snapito API key.
	 http://snapito.com/paid-api.jsp\n\n";

    exit;
}
