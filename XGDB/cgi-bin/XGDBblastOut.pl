#!/usr/bin/perl
#modified by ZmDB/PlantGDB staffs from original Lincoln Stein's Blast used at CSHL
#Last modified by Qunfeng: query by GI or Acc or GSScontigID
# $Id: PlantGDBblast,v 1.2 2008/01/29 15:45:30 plantgdb Exp $

use CGI qw/:standard :html escapeHTML sub/;
use IO::File;
do 'SITEDEF.pl';
my $BlastOutput=param('BlastOutput');
my $dbArray = param('db');
$dbArray =~ s/\n$//g;
my @dbArray = split (/,/,$dbArray);
print header();

print '<!DOCTYPE html
	PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"
	 \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">
	<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en-US\" xml:lang=\"en-US\">
	<head>
	<title>blastAllGDB Output</title>
	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\" />
	<link media="screen" href="/XGDB/css/Chr_GDBstyle.css" rel="stylesheet" type="text/css">
	</head>';



print start_html();
print '<div id="blast_output">';
print    h1('XGDB Blast Results');
        print "<h2>You have selected the following databases:</h2><ul>";
foreach my $dbArraymember (@dbArray){
            print "<li>$dbArraymember</li>";
		#print br();
        }
        print '</ul>';
	#print br();
	#$| = 1; #auto-flush output
open(B, "$BlastOutput");
my $BlastOutput1 = ' ';
my $queryID;
while(<B>){
	my $line = $_;
        if($line =~ /Query=\s+(\S+)/){
            $queryID = $1;
            $line = "<a name=\"$queryID\">$line</a>";
        }
	my $hitFullName;
	if ($line =~ />(\S+)/){
		$hitFullName=$1;
		$seqURL ='/' . $xGDB . '/cgi-bin/findRecord.pl?id=' . $hitName;
		#$line = "<a name=\"$queryID.$hitFullName\"></a><a href=\"$seqURL\" target=\"_blank\">$line</a>";
		$line = "<a name=\"$queryID.$hitFullName\"></a><a href=\"$seqURL\" target=\"_blank\"></a>$line";
	}
        $BlastOutput1 .= "$line";
}
STDOUT->flush;
close B;
my @blocks = split(/Reference:/, $BlastOutput1);
print '<table id="blast_summary" border=1>';
print '<caption>BLAST Result Summary</caption>';
        print '<tr><th>Query ID</th><th>#of hits</th><th>Hit (Subject) ID</th><th>BLAST Score</th><th>BLAST E-value</th></tr>';
foreach my $block (@blocks){
	 next unless ($block =~ /Query=/);
    my ($query) = $block =~ /Query=\s+(\S+)/;
    if($block !~ /Sequences producing significant alignments:/){
        #if there is no match
        print "<tr><td>$query</td><td align=\"center\">0</td><td></td><td></td><td></td></tr>";
        next;
    }
    my ($hits) = $block =~ /(Sequences producing significant alignments:\s+.*?)\<a href=/s;
    my @hitlines = split(/\n/, $hits);
    shift @hitlines; #rid of sequence producing
    my @hits;
    foreach my $hitline (@hitlines){
        next unless ($hitline =~ /^\w/);
        push(@hits, $hitline);
    }
    my $hitsize = @hits;
    #<input type=submit name=\"Action\" value=\"Display selected hits in FASTA format\">
    print "<tr>";
	print "
           <td rowspan=$hitsize><a href=\"#$query\">$query</a><br>";
           if(@hits){
           print "
           <form style=\"padding:10px\" method=\"post\" action=\"/cgi-bin/search/selectedDisplay.cgi\">" . '
           <input type="submit" name="Action" value="Display">
           <select name="BlastSelect">
           <option value="all">all hits</option>
           <option value="selected">selected hits</option>
           </select>
           </td>';
           }#end if(@hits)
	print "<td rowspan=\"$hitsize\" align=\"center\">$hitsize</td>";

        my $allHits;
	foreach my $hitline (@hits){
        $hitline =~ s/^\s+//g;
        $hitline =~ s/\s+$//g;
        my ($hit, $score, $evalue) = $hitline =~ /^(\S+).*?\s+(\S+)\s+(\S+)$/;
        my $hitcheck;
	  	 if ($hit =~ /gnl/){
			my $reformedHit = $hit;
			$reformedHit =~ s/\|/ /g;
			my ($A,$B,$C)= split(' ',$reformedHit);
			$hitcheck =$C;	
                 }elsif($hit =~ /gi_(\d+)/ || $hit =~ /gi\|(\d+)/){
                         $hitcheck = $1;
                 }else{
                         $hitcheck = $hit;
                 }
        $allHits .= ":$hitcheck";
         print "<td><input type=\"checkbox\" name=\"BlastHits\" value=\"$hitcheck\">
                <a href=\"#$query.$hit\">$hit</a></td><td align=right>$score</td>
                <td align=\"right\">$evalue</td></tr>";
    }
        $allHits =~ s/^://; #get rid of the first :
        print "<input type=\"hidden\" name=\"AllBlastHits\" value=\"$allHits\">";
        print '</form>';

 }
        print '</table>';

print '<pre id="blast_output">';
print $BlastOutput1;
print '</pre></div>';

