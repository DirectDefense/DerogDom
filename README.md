DerogDom.pl<br>
Kirk Greene <kgreene@directdefense.com><br>
http://www.DirectDefense.com<br>

INTRODUCTION
============

Script to enumerate derogatory domain names for a given domain.

FEATURES
========

The following script was written to automate the process of
trying to discover derogatory domain names that have been
registered that may have a negative effect on a companies
image and/or reputation. In short, I was tired of manually
entering derogatory domain names in a browser and decided
to automate the process.

End result will be a html report (<domain_derogdom_rpt.html>) 
and png images within a <domain>_derog_images directory.

CONSIDERATIONS
==============
<OL>
<li>You need to supply your own Snapito API key http://snapito.com/paid-api.jsp.<br>
	Edit the script and place the key inbetween the quotes.

<li>The following perl modules are used:<br>
	Net::DNS<br>
	IO::File<br>
	Getopt::Long<br>

Finally, being a perl script, the script should run on almost any platform. However, <br>
since the other components of this script require specific libraries, we have only tested<br>
it on Ubuntu Linux 12.x at this time.

USAGE
=====

Running this script:

Usage:

	perl DerogDom.pl -d <domain> -i <dictionary input file> -t <top level domains>

	-d 	Domain to check against. (ex. abc.com).
	-i	Dictionary file containing derogatory names to check for. One per line.
	-t	Top level domains to be used. Default is com,org,net,us.
		You can though enter your own (ex. -t com,net) or select "all" to use the 
		following generic level domains: aero,asia,biz,cat,com,coop,info,int,jobs,
		mobi,museum,name,net,org,post,pro,tel,travel,xxx

	Exmaple:
	perl DerogDom.pl -d abc.com -i derogatory_names.txt -t com

	This will check for the following given that derogatory_names.txt includes only 
	the word "sucks" for example.
	sucksabc.com
	sucks-abc.com
	abcsucks.com
	abc-sucks.com

As you can imagine, the more derogatory names in you list and the more top level
domains that are used, the longer the script will take to complete.

COPYRIGHT
=========

DerogDom.pl<br>
Created by Kirk Greene<br>
Copyright (C) 2013 DirectDefense, Inc.<br>
 
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
