csvTo301rewrite
============

Introduction
--------------
A nice simple little perl helper script that parses a CSV file with two colums - The current url and the redirect url - and spits out a text file with a block of formatted mod_rewrite 301 redirect statements.  Handy if you're working on migrating a site with a large number of urls, but the architecture prevents implementing a DB solution and the only alternative is a block of statements in the .htaccess file!

collect the existing relative url e.g. /aboutus.htm?user=2 and the relative destination link e.g. /about/tim

**Note: ** v0.1 adds /? to the end of the redirect statement so that the querystring isn't appended to the new url - i.e. this script creates redirects for unique friendly urls without querystring

Requirements
-----------------
perl (obviously!)

Text::CSV cpan module (type "cpan Text::CSV" into terminal window to install)

Usage
--------
 perl csvto301rewrite.pl "**/path/to/csvfile.csv**" "**/path/for/output.txt**" "**http(s)://baseurl of destination**"
 
	perl csvto301rewrite.pl "data.csv" "output.txt" "http://www.website.com"
 
 Example of output to output.txt
 ------------------------------------
 
RewriteCond %{REQUEST_URI} ^/aboutus\.htm$
RewriteCond %{QUERY_STRING} ^user=2$
RewriteRule ^(.*)$ http://www.baseurl/about/tim/? [L,R=301]
RewriteCond %{QUERY_STRING} ^user=3$
RewriteRule ^(.*)$ http://www.baseurl/about/jane/? [L,R=301]