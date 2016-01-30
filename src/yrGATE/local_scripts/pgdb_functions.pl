#!/usr/bin/perl
# This file is probably deprecated. Updated URLs to reflect new PlantGDB structure, just in case.
# Dan Rasmussen, 2009-10-23

init_plantgdb();

sub init_plantgdb{
  if ($PRM->{chr} =~ /Zm/i){
    $GV->{speciesName} = "Zea mays";
  }elsif($PRM->{chr} =~ /Sb/i){
    $GV->{speciesName} = "Sorghum bicolor";
  }else{
    $GV->{speciesName} = "Zea mays & Sorghum bicolor";
  }
}


sub getGenomeSequence_plantgdb{
  # uses html page for retrieving sequence
  my $link = "http://www.plantgdb.org/cgi-bin/search/display.cgi?Action=FASTA&hit_names=$PRM->{chr}";
  my $seq = get($link);
  $seq =~ s/.+?<pre>>.+?\n//is;  # remove all html up to defline
  $seq =~ s/<\/pre>.+//is; # remove trailing html
  $seq =~ s/\W//sg; # remove all line breaks
  $seq = substr($seq,$PRM->{start}-1,$PRM->{end}-1); # takes substring of GSS sequence
  return $seq;
}

sub getImageMap_plantgdb{
  # returns image html + image map + scale variable
    my $link = "http://www.plantgdb.org/search/display/GSScontig_Display.php?UCA=0&Display_GSSmem=0&Display_EST=1&Display_ProteinAGS=0&Display_Protein=1&startPos=$PRM->{start}&endPos=$PRM->{end}&Seq_ID=$PRM->{chr}&imageWidth=$PRM->{imgWidth}&UCA=1&username=$PRM->{USERid}";
    # needs to return $PRM->{GenomeSequence} and scale information
    my $imagelinkALL = get("${link}&imagemapFlag=1");
    $imagelinkALL .= "<img src=\"${link}&imageFlag=1\" border=\"0\" useMap=\"#GSScontig_GSS\" />";
    return $imagelinkALL;
}


sub getScale_plantgdb{
my $zeroPos = int($PRM->{start});
my $StartX=35;
my $Margin=35;
my $imgWidth = $PRM->{imgWidth};
my $zeroPos =  $PRM->{start};
my $seqLen =$PRM->{end} - $zeroPos + 1;
my $scale=$seqLen/($PRM->{imgWidth}-$StartX-$Margin);
$scale = sprintf("%.2f", $scale);
return ($scale,$zeroPos,$StartX,$Margin);
}



sub GenomeContextLink_plantgdb{
  my ($chr,$lp,$rp) = @_;
  my $link = "$GV->{rootPATH}search/display/data.php?Seq_ID=$chr";
  return $link;
}


sub headerExtra{

  my $s;
  # add script
  $s .= "Other yrGATE Databases:<script>
        function changeDb(){
			url = document.forms[0].otherDb.options[document.forms[0].otherDb.selectedIndex].value;
			if (url == ''){return;}
			location.href = url;
        }
        </script>";
  $s .= "<select name='otherDb' onchange='changeDb();'>";
  foreach my $d (['Arabidopsis','AtGDB'],['Rice','OsGDB'],['Maize','ZmGDB'],['Maize, Sorghum','PlantGDB-GSS'],['Others','']){
    my ($org,$db) = @$d;
    my $url = $GV->{rootPATH};
    chop $url;
    $url .= "$GV->{CGIPATH}";
    $url =~ s/$GV->{dbTitle}/$db/;
    if ($org eq "Others"){
		$s .= "<option value='http://www.plantgdb.org/prj/Genome_browser/'>Others</option>";
    }else{
		$s .= "<option value='${url}CommunityCentral.pl' ";
		$s .= ($GV->{CGIPATH} =~ /$db/) ? " selected " : "";
		$s .= " >$org - $db</option>";
    }
  }
  $s .= "</select>";
  return $s;
}


1;
