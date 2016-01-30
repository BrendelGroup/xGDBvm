#!/usr/bin/perl -I/xGDBvm/src/yrGATE/yrGATE_cgi/
# yrGATE portal for GENSCAN

#use LWP::Simple;
use CGI ":all";
use LWP::UserAgent;
#use HTTP::Request::Common qw(POST);
use HTTP::Request::Common;
require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

$seq = param("GenomeSequence");
$start = param("start");
$model = (param('-o')) ? param('-o') : $portalvar->{GENSCAN_speciesmodel};


print header();

if ($seq eq ""){
    print STDERR "No genome sequence defined.";
    exit;
}

print "<html><head><title>yrGATE Portal to GENSCAN<\/title><\/head>
<body>

<form name='genscanportal' method='post'>
<table width='100%' cellspacing='0'>
<tr><td bgcolor='orange'></td><td bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:24px'>yrGATE Portal to GENSCAN</span></td></tr>
<tr><td width='100' valign='top' bgcolor='orange'><span style='font-family:Arial;font-weight:bold;font-size:12px'>
click on yellow buttons to add exons<br>

<!-- portal parameters-->
Organism: <select name='-o' onchange='genscanportal.submit();'>
<option ".( ($model eq "Vertebrate") ? "selected='selected'" : "").">Vertebrate
<option ".( ($model eq "Arabidopsis") ? "selected='selected'" : "").">Arabidopsis
<option ".( ($model eq "Maize") ? "selected='selected'" : "").">Maize
</select>

</span>
<input type='hidden' name='GenomeSequence' value='$seq'>
<input type='hidden' name='start' value='$start'>


<\/td>";

print "<td><a href='http://genes.mit.edu/GENSCAN.html' target=_new>GENSCAN<\/a><br>";

$link = "http://genes.mit.edu/cgi-bin/genscanw_py.cgi";

my $ua = new LWP::UserAgent;

        my %tags = ();
        $tags{'-s'} = $seq;
        $tags{'-e'} = (param('-e')) ? param('-e') : '1.00';
        $tags{'-o'} = $model;
        $tags{'Action'} = "Run GENSCAN";
        $tags{'-n'} = "";
        $tags{'-p'} = "Predicted CDS and peptides";
        $tags{'-u'} = "";
        $tags{'-a'} = "";
        #[%tags]

        my $req = POST($link,
                Content_Type => 'form-data',
                Content => [
			'-s'  => $seq,
			'-o'  => $model,
			'-e'  => "1.00",
			'-n' => "",
			'-p'  => "Predicted CDS and peptides",
			'-u'  => "",
			'-a'  => "",
			'Action' => "Run GENSCAN",
	]
        );
        my $resp = $ua->request($req);
        $page1 .= $resp->error_as_HTML unless $resp->is_success;
        if ($resp->is_success){
          $page1 = $resp->content();
        #$page .= $resp->content();  
        }else{
          $page1 = "Portal currently unavailable. Please try again later.";
        }
#jfd added this section because of inverted html, it will read a string as a file, and write it out as string

my @a_out;
my @a_str;
my @str;


open my ($str_fh), '<', \$page1;

while( <$str_fh>)
 {
 my($line) = $_;
 chomp($line);
 @a_str = split('\n', $_);
 foreach $str (@a_str) {
   push (@a_out, "$str");
  }
 }
my $page1 = "";
foreach $str (@a_out)
{ 
  $page1 .= "$str\n";
}


($data_table) = $page1 =~ /(exons:.+?<\/pre>)/si;
@exons = $data_table =~ /(\s+\d+\.\d+\s+\w+.+?)\n/g;
($data_table) = $page1 =~ /(exons:.+?-\n)/si;;
for ($i=0;$i<scalar(@exons);$i++){
  ($c1,$c2) = $exons[$i] =~ /\s+(\d+)\s+(\d+)/;
  ($score) = $exons[$i] =~ /(\d+\.\d+)\s+\d+\.\d+$/;
  $c1a = $c1 + $start - 1; #GenScan first position = 1;
  $c2a = $c2 + $start - 1; 
  $exons[$i] =~ s/$c1/$c1a/;
  $exons[$i] =~ s/$c2/$c2a/;
  $score = ($score) ? $score : 0;
  $data_table .= $exons[$i]." <input type='button' style='background-color:yellow' value='Add Exon to Annotation' onclick='opener.addUDE($c1a,$c2a,\"GENSCAN\",$score)'>\n";
}
$data_table .= "<\/pre>";


$page1 =~ s/exons:.+?<\/pre>/$data_table/si;
$page1 =~ s/Click <a.+?s\)//isg;
$page1 =~ s/^.+?<br>//is;
$page1 =~ s/$seq</body>/<\/td><\/tr><\/table><\/body>/i;

if (length($seq) > 400000){
  print "Sequence too large for GENSCAN portal.";
}else{
  print $page1;
}

