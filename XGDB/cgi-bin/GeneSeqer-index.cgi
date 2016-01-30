#!/usr/bin/perl
# GeneSeqer.cgi - A web-based front end for GeneSeqer
#
# dos2unix comment:	The Linux dos2unix in default mode converts the input file and writes output to it (-o flag is default
#			behavior).  Note that this is different on Solaris, where the "convertedfile" argument has to be given following the "originalfile" argument.  Thus, in Linux we issue dos2unix file-2-be-converted but in 
#		Solaris we would need to repeat the argument to replace the file: dos2unix file-2-be-converted file-2-be-converted
#			This version of the script is for Linux.  Comments added by Volker, Aug. 23, 2012
#
# Update: April 9, 2006 (MW) 1. addded portal flag Update: November 9, 2004 (VB) Update: Feb 10, 2003 (Dong) 1. recognize all array databases (EST, PUT, cDNA, HTC); 2. Javascript to hide/show individual plant

# Jimmy (jfd) reworked this script for xGDBvm


use CGI ":all"; 
do 'sitedef.pl'; 
$portalFlag = param('portal');

#global variables
my $taxonomyURL = 'http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Undef&lvl=0&srchmode=1&name='; 
my $nusers = 20; #number of GeneSeqer allowed to run on the server at the same time 
my $IndexDir = "${PLANTGDB_GENESEQERDIR}Index/";#$PLANTGDB_GENESEQERDIR;#'/DATA/PlantGDB/Index/GeneSeqer/Index/'; #location of predefined MakeArray files 
my $TmpDir = $PLANTGDB_TMPDIR; #temporary directory for file creation
#Binary Paths
my $GSQweb = "${PLANTGDB_CGIDIR}GeneSeqer/GeneSeqerWS"; #GeneSeqer binary for webservice 
my $GSQeml = "${PLANTGDB_CGIDIR}GeneSeqer/GeneSeqer"; #GeneSeqer binary for email-service 
my $GBKgetit = "${PLANTGDB_CGIDIR}GeneSeqer/xgetGBseq2GBK"; #script for retrieving seq by acc number 
my $ResultSummary = "${PLANTGDB_CGIDIR}GeneSeqer/ResultSummary.pl"; #script for generating short summary table 
my $wait_gs = "${PLANTGDB_CGIDIR}GeneSeqer/pl-wait-gs"; 
my $parseGBK = "${PLANTGDB_CGIDIR}GeneSeqer/parseGBKannotation.pl";
my $gsview = ($portalFlag ne "1") ? "${PLANTGDB_CGIDIR}GeneSeqer/PlantGDBgsview.pl" : "${PLANTGDB_CGIDIR}GeneSeqer/Portalgsview.pl"; 
my $dos2unix = '/usr/bin/dos2unix';

#Plant Classification http://plants.usda.gov/classification/
my @Dicot =@dicotArray; my @Monocot = @monocotArray; my @Grass = @grassArray;
#Web Links
my $FastaFormat = a({-href=>'http://www.ncbi.nlm.nih.gov/BLAST/fasta.html'}, 'FASTA format');
#AtGDB/OsGDB only CGI parameters
my $Flag = param('GDBFlag'); 
my $chr = param('chr');
#my $l_pos = param('_a'); my $r_pos = param('_b'); my $range = "$l_pos"."-"."$r_pos";
$chr = 'AtChr'. $chr if ($Flag =~ /AT/ and $chr =~ /^\d+$/); 
$chr = 'MtChr'. $chr if ($Flag =~ /MT/ and $chr =~ /^\d+$/); 
$chr = 'OsChr'. $chr if ($Flag =~ /OS/ and $chr =~ /^\d+$/); 
$chr = 'PtChr'. $chr if ($Flag =~ /PT/ and $chr =~ /^\d+$/); 
$chr = 'VvChr'. $chr if ($Flag =~ /VV/ and $chr =~ /^\d+$/); 
$chr = 'SbChr'. $chr if ($Flag =~ /SB/ and $chr =~ /^\d+$/); 
$chr = 'LjChr'. $chr if ($Flag =~ /LJ/ and $chr =~ /^\d+$/); 
$chr = 'BdChr'. $chr if ($Flag =~ /BD/ and $chr =~ /^\d+$/); 
$chr = 'chr'. $chr if ($Flag =~ /ZM/ and $chr =~ /^\d+$/); 
$chr = 'Chr'. $chr if ($Flag =~ /GM/ and $chr =~ /^\d+$/);

#$chr = 1 if(!param('chr'));
if (!defined ($Flag)){
	$Flag = 'PlantGDB';
}
#CGI parameters
my $GP = param('_gdnap'); my $GDNA = param('gdnaf'); my $Species = param('species'); 
my $Seq_Type = param('seq_type'); 
my $hidden_GDNA = param('hidden_gdnaf'); #for passing in the previously uploaded file (too bad file upload doesn't allow default value) 
my $L = param('_l'); 
my $F = param('_f');
 my $ACC = param('acc'); 
if (param('GDBFlag')=~/CPGDB/){
	$ACC = 'contig_'.$ACC 
if ($ACC>10000);
	$ACC = 'supercontig_'.$ACC if ($ACC<10000);
}
if (param('GDBFlag')=~/PEGDB/){
        $ACC = 'scaffold_'.$ACC;
}
my @Darray = param('_d'); #changed by Dong from single DB choice to multiple choices
 my $EP = param('_estp'); 
my $E = param('_e');
my $QP = param('_trgpp'); 
my $Q = param('_q'); my $S = param('_s'); 
my $A = param('_a'); 
my $B = param('_b'); 
my $R = param('_r'); 
my $email = param('email'); 
my $stringency =param('_strgcy');
###############################
###  main code starts here ###
###############################
##############Ann added:##############
### default $stringency strict "-x 30 -y 45 -z 60"######
if (param('_strgcy')){ 
  $stringency =param('_strgcy');
}else{
	$stringency = "strict ";
}
# IF A GENOMIC DNA INPUT FILE WAS PROVIDED BY PASTING OR UPLOAD THEN GeneSeqer IS EXECUTED WITH APPROPRIATE PARAMETERS
if (param('RunGSQ') && (param('_gdnap') || param('gdnaf') || param('hidden_gdnaf') || param('acc') || param('chr'))){
  #add param('RunGSQ') by Dong in order to dynamically copy/paste query from PlantGDB genomic Sequence display page Check input query sequences
  if (!(param('_estp') || param('_e') || param('_q') || param('_trgpp') || param('_d'))) {
    print header;
    print start_html('GeneSeqer Output');
    print br;
    print h3("No ESTs were provided. To display a list of potential splice
		sites, please use the",
	     a({href=>"http://bioinformatics.iastate.edu/cgi-bin/sp.cgi"},"SplicePredictor"),
	     "program. To make spliced alignments, please use the preprocessed
		EST databases or provide your own cDNA/EST targets.");
    print end_html();
    exit;
  }
  # Check input query sequences! Pre-processed DNA database CANNOT be combined with user-supplied EST/cDNA
  if(@Darray && ($EP||$E)){
    print header, start_html('error in data input');
    print "<h3>Error</h3><p color=\"red\">At this time we do not allow pre-processed databases to be combined with user supplied EST/cDNA sequences as input! We appologize for the inconvenience .</p>";
    print end_html();
    exit;
  }
## INITIALIZE COMMAND PARAMETERS
my $GSQ_binary = $GSQweb; 
my $speciesMODEL = "-s Arabidopsis"; 
my $queryDNA_lib = "";
my $queryDNA_user = ""; 
my $queryPROTEIN_lib = ""; 
my $queryPROTEIN_user = ""; 
my $genomicTARGET = ""; 
my $genomicSTART = ""; 
my $genomicEND = ""; 
my $strand = "-R"; 
my $outputFILE = ""; 
my $htmlOUTPUT = ""; 
my $workingOUTPUT = "/dev/null";
## [$ufname] -- create session ID and session tmp file directory
  my $ufname = int(time() ) . '_' . $$;
  (-e "${TmpDir}tmp-$ufname") || system("mkdir ${TmpDir}tmp-$ufname;");
  chdir("${TmpDir}tmp-$ufname/"); #otherwise dos2unix doesn't work
##print out the parameters being passed and used later by processGShit.pl

open(CGI, ">${TmpDir}tmp-$ufname/CGIdat"); 
flock (CGI,2);
#get what CGI parameters being passed and used later by processGShit.pl
if(defined $GP && $GP =~ /\w+/){
        print CGI "_gdnap=$GP";
	print CGI "\n";	print CGI '&&';	print CGI "\n";
}
if(defined $chr && $chr =~ /\w+/){
        print CGI "chr=$chr";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $Flag){
	print CGI "GDBFlag=$Flag";
	print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $GDNA && $GDNA =~ /\w+/){
	print CGI "gdnaf=$GDNA";
	print CGI "\n"; print CGI '&&'; print CGI "\n";
        print CGI "hidden_gdnaf=${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname"; #record where it's being uploaded
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $L && $L =~ /\w+/){
        print CGI "_l=$L";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $F && $F =~ /\w+/){
        print CGI "_f=$F";
	print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $ACC && $ACC =~ /\w+/){
        print CGI "acc=$ACC";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $S && $S =~ /\w+/){
        print CGI "_s=$S";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $A && $A =~ /\w+/){
        print CGI "_a=$A";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $B && $B =~ /\w+/){
        print CGI "_b=$B";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
if(defined $R && $R =~ /\w+/){
        print CGI "_r=$R";
        print CGI "\n"; print CGI '&&'; print CGI "\n";
}
close(CGI);
## [$genomicTARGET] --Create Genomic input file
if ($Flag eq 'PlantGDB'){
  open (GDNAFP,"> ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname");
  flock (GDNAFP,2);
  $genomicTARGET = "-l ";
  if (($ACC)||($L eq 'GenBank')){
      $L = 'GenBank';
      $genomicTARGET = "-g ";
  }
  $genomicTARGET .= "${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname";
  if (!defined $L || $L eq 'plain '){
      if ($F){ $F = ">SQ;" . "$F\n";}
      else{ $F = ">SQ; your-sequence\n";}
      print GDNAFP $F;
  }
  if ($GP){print GDNAFP $GP ."\n";}
  if ($GDNA){ while (<$GDNA>){ print GDNAFP $_;}}
  print GDNAFP "\n";
###### $ACC GBK format acc or sequece ID are good but not Scaford number in PpGDB or GxGDB########
  #if (($ACC =~ /[a-z]/i) or (($ACC>10000) and ($Flag =~ /GXGDB/)) ){
  if ($ACC =~ /[a-z]/i) {
      system "perl $GBKgetit $ACC >> ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname";
      my $GBflag = qx(grep -c 'LOCUS' ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname);
      if($GBflag == 0){
	#NCBI server is probably busy, added by Dong
	   print header, start_html('error when retrieving sequence from GenBank');
	   print "<h3>Error</h3><p style=\"color: red;\">We can not retrieve your sequence from GenBank (its server might be busy). Please check if your accession number is correct or try it again later!</p>";
    	   print end_html();
    	  exit;
	}
  }
  system("mv $hidden_GDNA ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname") if($hidden_GDNA);
  system "$dos2unix ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname";
}
elsif ($Flag =~ /^(\S)(\S)GDB$/) {
	my $DNAseq;
	my $L1;
	my $L2;
	my $L3;
        $L1=$1;
        $L2=$2;
        $L3=$2;
        $L2=~ tr/A-Z/a-z/;
        $L3=~ tr/a-z/A-Z/;
        my $xGDB= $L1.$L2.'GDB';
	if ($xGDB=~ /Gx/){
		$L2='m';
		$L3='M';
	}	
	$genomicTARGET .= "-L ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname ";
	if ($xGDB=~ /CpGDB/){
		$ACC = 'supercontig_'.$ACC if ($ACC<10000);
		$ACC = 'contig_'.$ACC if ($ACC>10000);
	}
	if ($xGDB=~ /PeGDB/ or $xGDB=~ /SmGDB/){
                $ACC = 'scaffold_'.$ACC;
        }
	if ($ACC and ($xGDB=~ /Pp/ or $xGDB=~ /Rc/ or $xGDB=~ /Gx/ or $xGDB=~ /Me/ or $xGDB=~ /Mg/ or $xGDB=~ /Cs/ or $xGDB=~ /Si/) or $xGDB=~ /Cp/ or $xGDB=~ /Pe/ or $xGDB=~ /Sm/){
		 $DNAseq = qx(/usr/local/bin/blastdbcmd -db /DATA/PlantGDB/Index/Blast/${L1}${L2}GDB/${L1}${L3}bac -entry $ACC);
		$DNAseq =~ s/gi\|/Scaffold/g;
	}else{
		$DNAseq = qx(/usr/local/bin/blastdbcmd -db /DATA/PlantGDB/Index/Blast/${xGDB}/${L1}${L3}genome -entry $chr);
		$DNAseq =~ s/>lcl//;
        	$DNAseq = ">".$chr." ".$DNAseq;
	}
	open (GDNAFP,"> ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname");
	flock (GDNAFP,2);
	print GDNAFP $DNAseq;
}
## [$queryDNA_user] -- create EST/cDNA query file from user-supplied sequences
  if ($EP || $E){
      open (ESTFP,"> ${TmpDir}tmp-$ufname/gs_estf.dat-$ufname");
      flock (ESTFP,2);
      $queryDNA_user = "-e ${TmpDir}tmp-$ufname/gs_estf.dat-$ufname";
      #need to deal with windows carraige-return character ???
      if ($EP){print ESTFP $EP ."\n";}
      if ($E){
	  	while (<$E>){ print ESTFP $_;}
      }
      close ESTFP;
      #add by Dong to check if input is fasta
      my $FastaFlag = qx(grep -c '^>' ${TmpDir}tmp-$ufname/gs_estf.dat-$ufname);
      if($FastaFlag == 0){
           print header, start_html('error input');
           print "<h3>Error</h3><p style=\"color: red;\">Please provide <b>FASTA</b> format EST/cDNA sequences</p>";
           print end_html();
          exit;
        }
      system "$dos2unix ${TmpDir}tmp-$ufname/gs_estf.dat-$ufname";
  }
## [$queryPROTEIN_user] -- create PROTEIN query file from user-supplied sequences
  if ($QP || $Q) {
      open (TRGPFP,"> ${TmpDir}tmp-$ufname/gs_trgpf.dat-$ufname");
      flock (TRGPFP,2);
      $queryPROTEIN_user = "-q ${TmpDir}tmp-$ufname/gs_trgpf.dat-$ufname";
      #need to deal with windows carraige-return character ???
      if ($QP) {print TRGPFP $QP ."\n";}
      if ($Q) {
	  while (<$Q>) {print TRGPFP $_;}
      }
      close TRGPFP;
      #add by Dong to check if input is fasta
      my $FastaFlag = qx(grep -c '^>' ${TmpDir}tmp-$ufname/gs_trgpf.dat-$ufname);
      if($FastaFlag == 0){
           print header, start_html('error input');
           print "<h3>Error</h3><p style=\"color: red;\">Please provide <b>FASTA</b> format protein sequences</p>";
           print end_html();
          exit;
        }
      system "$dos2unix ${TmpDir}tmp-$ufname/gs_trgpf.dat-$ufname";
  }
## [$queryDNA_lib] -- include pre-defined EST/cDNA libraries [$queryPROTEIN_lib] -- includde pre-defined PROTEIN libraries
  opendir(DIR, "$IndexDir");
  my @indexFiles = readdir(DIR);#get MakeArray Indecies for each plant
  closedir(DIR); print STDERR "$IndexDir index directory -- \n";
  my %Index; #e.g. key=HVtug; value=HVtug1 ...
  foreach my $indexFile (@indexFiles){
      #########Modify here if more database type other than protein,EST, ESTtug, and cDNA is added
      next unless ($indexFile =~ /(\w+)(\.mRNA\.EST\.ContaminationMaskX\.fasta)\d+$/ || $indexFile =~ /(\w+)(\.PUT\.fasta)\d+$/ || $indexFile =~ /(\w+)(\.mRNA\.PLN\.ContaminationMaskX\.fasta)\d+$/);
      my ($key) = $1.$2;
      my $IndexFile = $IndexDir.$indexFile;
#print STDERR "$indexFile filename \n";
	if(!exists $Index{$key}){
		$Index{$key} = "$IndexFile ";
		#print STDERR "$Index{$key} filename index key \n";
	}else{
		$Index{$key} .= "$IndexFile ";
		#print STDERR "$Index{$key} else case filename index key \n";
	}
  }#end foreach
	############################################################hard code for now DONG########################################
  #gather Index selections
# Renish- index creation on the fly ---
if(@Darray){
	my ($D1,$plant1) = (0,0);
	# my %DNA_db; #GeneSeqer query library (index), use hash to prevent duplicate entries my %Protein_db; #GeneSeqer query library (no makearray index though) ### will be used when GeneSeqer2 is ready
	foreach $D1 (@Darray){
		print STDERR "$D1 dollar D1 \n";
	
		if(!exists $Index{$D1}){
			print STDERR "here \n\n\n";
			#system ("cd /DATA/PlantGDB/Index/GeneSeqer/tmp");
			system ("cp /DATA/PlantGDB/Index/Blast/PlantDNA/$D1 /tmp/GSQ/$D1");
			# print STDERR "here1 \n\n\n";
			chdir "/tmp/GSQ";
			system("/usr/local/bin/MakeArray /tmp/GSQ/$D1 > makearray_log");
			# print STDERR "here2 \n\n\n";
		}
	}
}
				 opendir(DIR, "/tmp/GSQ");
                                 my @indexFiles1 = readdir(DIR);#get MakeArray Indecies for each plant
                                closedir(DIR);
                                #print STDERR "$IndexDir index directory -- \n";
                                $IndexDirtemp = "/tmp/GSQ/";
                                # my %Index; #e.g. key=HVtug; value=HVtug1 ...
                                 foreach my $indexFile2 (@indexFiles1){
                               # print STDERR "$indexFile2 filenames in tmp \n\n\n";
 #########Modify here if more database type other than protein,EST, ESTtug, and cDNA is added
 next unless ($indexFile2 =~ /(\w+)(\.mRNA\.EST\.ContaminationMaskX\.fasta)$/ || $indexFile2 =~ /(\w+)(\.PUT\.fasta)\$/ || $indexFile2 =~ /(\w+)(\.mRNA\.PLN\.ContaminationMaskX\.fasta)$/ || $indexFile2 =~ 
/(\w+)(\.mRNA\.HTC\.ContaminationMaskX\.fasta)$/);
			#	print STDERR "inside compare \n\n";
				 my ($key1) = $1.$2;
                                 my $IndexFile1 = $IndexDirtemp.$indexFile2;
                         #       print STDERR "$IndexFile1 filename \n";
                                 if(!exists $Index{$key1}){
                                  $Index{$key1} = "$IndexFile1 ";
                          #              print STDERR "$Index{$key1} filename index key \n";
                                 }else{
                                  $Index{$key1} .= "$IndexFile1 ";
                           #             print STDERR "$Index{$key1} else case filename index key \n";
                                        }
                                  }#end foreach
# end of code changes made by renish -------------
  if(@Darray){
      my ($D,$plant) = (0,0);
      my %DNA_db; #GeneSeqer query library (index), use hash to prevent duplicate entries
      my %Protein_db; #GeneSeqer query library (no makearray index though) ### will be used when GeneSeqer2 is ready
      foreach $D (@Darray){
	  if($D =~ /^ALL/){
	      if($D =~ /PLANT/){
		  if($D =~ /est$/){
		      foreach $plant (@PlantList){
			  if(exists $Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /tug$/){
		      foreach $plant (@PlantList){
			  if(exists $Index{"$plant.PUT.fasta"}){$DNA_db{$Index{"$plant.PUT.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /cdna$/){
		      foreach $plant (@PlantList){
			  if(exists $Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		}elsif($D =~ /htc$/){
                      foreach $plant (@PlantList){
                          if(exists $Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}} = 'DNA';}
                      }
		  }elsif($D =~ /protein$/){
		      foreach $plant (@PlantList){
			  if(exists $Index{"${plant}protein"}){$DNA_db{$Index{"${plant}protein"}} = 'Protein';}
		      }
		  }
	      }elsif($D =~ /DICOT/){
		  if($D =~ /est$/){
		      foreach $plant (@Dicot){
			  if(exists $Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /tug$/){
		      foreach $plant (@Dicot){
			  if(exists $Index{"$plant.PUT.fasta"}){$DNA_db{$Index{"$plant.PUT.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /cdna$/){
		      foreach $plant (@Dicot){
			  if(exists $Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		}elsif($D =~ /htc$/){
                      foreach $plant (@Dicot){
                          if(exists $Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}} = 'DNA';}
                      }
		  }elsif($D =~ /protein$/){
		      foreach $plant (@Dicot){
			  if(exists $Index{"${plant}protein"}){$DNA_db{$Index{"${plant}protein"}} = 'Protein';}
		      }
		  }
	      }elsif($D =~ /MONOCOT/){
		 if($D =~ /est$/){
		      foreach $plant (@Monocot){
			  if(exists $Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /tug$/){
		      foreach $plant (@Monocot){
			  if(exists $Index{"$plant.PUT.fasta"}){$DNA_db{$Index{"$plant.PUT.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /cdna$/){
		      foreach $plant (@Monocot){
			  if(exists $Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}){$DNA_db{$Index{"plant.mRNA.PLN.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /protein$/){
		      foreach $plant (@Monocot){
			  if(exists $Index{"${plant}protein"}){$DNA_db{$Index{"${plant}protein"}} = 'Protein';}
		      }
		  }
	      }elsif($D =~ /GRASS/){
		  if($D =~ /est$/){
		      foreach $plant (@Grass){
			  if(exists $Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.EST.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /tug$/){
		      foreach $plant (@Grass){
			  if(exists $Index{"$plant.PUT.fasta"}){$DNA_db{$Index{"$plant.PUT.fasta"}} = 'DNA';}
		      }
		  }elsif($D =~ /cdna$/){
		      foreach $plant (@Grass){
			  if(exists $Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.PLN.ContaminationMaskX.fasta"}} = 'DNA';}
		      }
		}elsif($D =~ /htc$/){
                      foreach $plant (@Grass){
                          if(exists $Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}){$DNA_db{$Index{"$plant.mRNA.HTC.ContaminationMaskX.fasta"}} = 'DNA';}
                      }
		  }elsif($D =~ /protein$/){
		      foreach $plant (@Grass){
			  if(exists $Index{"${plant}protein"}){$DNA_db{$Index{"${plant}protein"}} = 'Protein';}
		      }
		  }
	      }
	  }else{
	      $DNA_db{$Index{$D}} = 'DNA' if ($D !~ /protein$/);
	      $Protein_db{$Index{$D}} = 'Protein' if ($D =~ /protein$/);
#print STDERR "$DNA_db{$Index{$D}} dna db index.. \n\n";
		 if(exists $Index{$D}) {print STDERR " $Index{$D} index D \n\n";}
	
	  }
# print STDERR "$DNA_db{$Index{$D}} dna db index.. \n\n"; print STDERR "$Index{$D} db index.. \n\n";
      }
      #build -D option of GeneSeqer
      my @DNA_db_Keys = keys %DNA_db;
      my $DNA_db_index = join(' ', @DNA_db_Keys);
      $queryDNA_lib = "-D $DNA_db_index " if (defined $DNA_db_index && $DNA_db_index =~ /\w+/);
      #build -Q option of GeneSeqer !! WAIT TILL GSQ2 !!
      my @Protein_db_Keys = keys %Protein_db;
      my $Protein_db_index = join(' ', @Protein_db_Keys);
      $queryPROTEIN_lib = "-Q $Protein_db_index " if (defined $Protein_db_index && $Protein_db_index =~ /\w+/);
  }
## [$speciesMODEL] -- select splice site model
  if (($S eq 'Arabidopsis') or ($Flag eq 'ATGDB')){$speciesMODEL = "-s Arabidopsis";}
  elsif ($S eq 'maize'){$speciesMODEL = "-s maize";}
  elsif (($S eq 'rice') or ($Flag eq 'OSGDB')){$speciesMODEL = "-s rice";}
  elsif (($S eq 'Medicago') or ($Flag eq 'MTGDB')){$speciesMODEL = "-s Medicago";}
	elsif (!defined ($S)){
		if ($Flag eq 'OSGDB'){
			$speciesMODEL = "-s rice";
		}
		if ($Flag eq 'MTGDB'){
			$speciesMODEL = "-s Medicago";
		}
	}
	
## [$genomicSTART] -- select region start [$genomicEND] -- select region end
  $genomicSTART = "-a $A" if($A);
  $genomicEND = "-b $B" if($B);
## [$strand] -- select alignment strand
  if ($R eq 'reverse '){$strand = '-r';}
  elsif ($R eq 'original '){$strand = '-f';}
## [$outputFILE] -- name the output file
  $outputFILE = "-o ${TmpDir}tmp-$ufname/gs_sorted-output-${ufname}.html ";
#### PROCESS / EXECUTE
  if (param('Click')){
	if ($stringency =~ /moderate/){
		$strLevel ="-x 16 -y 24 -z 48";
	}elsif ($stringency =~ /low/){
		$strLevel ="-x 12 -y 12 -z 30";
############  Ann Added 07/06/07##############
	}else {
		$strLevel ="-x 30 -y 45 -z 60";
	}
    #Process via email
    $GSQ_binary = $GSQeml;
    $workingOUTPUT = "/dev/null";
    $htmlOUTPUT = (param('HTML'))? "-h" : "";
    my $command = "$wait_gs; ";
    $command .= "touch ${TmpDir}tmp-$ufname/running-gs-$ufname; ";
    $command .= "$GSQ_binary $speciesMODEL $strLevel $htmlOUTPUT $strand $genomicSTART $genomicEND " .
      "$queryDNA_lib $queryDNA_user $queryPROTEIN_lib $queryPROTEIN_user " .
      "$outputFILE $genomicTARGET > ${workingOUTPUT}; ";
    $command .= "cat ${TmpDir}tmp-$ufname/gs_sorted-output-${ufname}.html | mail ${email}; ";
    $command .= "rm ${TmpDir}tmp-$ufname/running-gs-$ufname;"; print STDERR "$command I am here mmmmmmmmmmmmmmmmmmmmmmmmmm\n";
    system("( $command ) &");
    print header;
    print start_html('GeneSeqer Output');
    print p;
    print h3("Thank you for using GeneSeqer. The output of the submitted job
              will be sent to ",$email,".");
    print hr;
    print end_html();
    exit;
  }else{
    #Process online
    $GSQ_binary = $GSQweb;
    $workingOUTPUT = "${TmpDir}tmp-$ufname/gs_output-$ufname";
    $htmlOUTPUT = "-h";
    ## SERVER LOAD CHECK
	my $w = `ps -af|egrep 'GeneSeqerWS' |egrep -v 'grep' | wc -l`;
#	my $w = qx(ps ax | egrep 'GeneSeqerWS' | egrep -v 'egrep' | wc -l);
    #my $w = `ps ax | egrep "/PlantGDB/cgi-bin/GeneSeqer/GeneSeqer" | egrep -v "egrep" | wc -l`;
    if ($w >= $nusers) {sleep 30;}
	$w = `ps -af|egrep 'GeneSeqerWS' |egrep -v 'grep' | wc -l`;
    #$w = `ps ax | egrep "GeneSeqerWS" | egrep -v "egrep" | wc -l`; $w = `ps ax | egrep "/PlantGDB/cgi-bin/GeneSeqer/GeneSeqer" | egrep -v "egrep" | wc -l`;
    if ($w >= $nusers) {
      print header;
      print start_html('GeneSeqer Output');
      print p;
      print h3("The server is busy at this time.");
      print p;
      print h3("Please accept output by email (repost your data and supply
		   your email address) or try again later.");
      print p;
      print end_html();
      exit;
    }
    #####
    my $command = "touch ${TmpDir}tmp-$ufname/running-gs-$ufname; ";
#############
############  Ann Added 06/06/06##############
	if ($stringency =~ /moderate/){
		$strLevel ="-x 16 -y 24 -z 48";
	}elsif ($stringency =~ /low/){
		$strLevel ="-x 12 -y 12 -z 30";
############  Ann Added 07/06/07##############
	}else {
		$strLevel ="-x 30 -y 45 -z 60";
	}
	$command .= "$GSQ_binary $speciesMODEL $strLevel $htmlOUTPUT $strand $genomicSTART $genomicEND " .
      "$queryDNA_lib $queryDNA_user $queryPROTEIN_lib $queryPROTEIN_user " .
      "$outputFILE $genomicTARGET > ${workingOUTPUT}; "; 

    print STDERR "mmmmmmmmmmmmmmmmmmmm $command \n\n";
################# end of Ann's add.####################


	#    $command .= "$GSQ_binary $speciesMODEL $htmlOUTPUT $strand $genomicSTART $genomicEND " .
	#     "$queryDNA_lib $queryDNA_user $queryPROTEIN_lib $queryPROTEIN_user " . "$outputFILE $genomicTARGET > ${workingOUTPUT}; ";
	################## we use fasta format instead of Genbank format for genome data #############
	if ($Flag eq 'ATGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/ATchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img AT${chr};";
	}elsif ($Flag eq 'OSGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/OSchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img OS${chr};";
	}elsif ($Flag eq 'MTGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/OSchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img MT${chr};";
	}elsif ($Flag eq 'PTGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/OSchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img PT${chr};";
	}elsif ($Flag eq 'VVGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/OSchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img VV${chr};";
	}elsif ($Flag eq 'SBGDB'){
		#$command .= "$parseGBK /DATA/PlantGDB/Index/GeneSeqer/GenomeDATA/OSchr${chr} ${TmpDir}/tmp-$ufname/gs_sorted-output-${ufname}.html_img SB${chr};";
	}elsif ($Flag eq 'PlantGDB'){
    	if ($L eq 'GenBank'){
	#$command .= "$parseGBK ${TmpDir}tmp-$ufname/gs_gdnaf.dat-$ufname ${TmpDir}tmp-$ufname/gs_sorted-output-${ufname}.html_img; ";
    }
	}
    $command .= "$gsview gs_sorted-output-$ufname $ufname ${TmpDir}tmp-$ufname > /dev/null; ";
    my $URL = url(); #check if it's PlantGDBgs.cgi or AtGDBgs.cgi for later usage
    $command .= "$ResultSummary ${TmpDir}tmp-$ufname/gs_sorted-output-${ufname}.html $URL ${TmpDir}tmp-$ufname/CGIdat; ";
    $command .= "rm ${TmpDir}tmp-$ufname/running-gs-$ufname;";
    system("( $command ) >/dev/null 2>&1 &"); #We pipe stdout and stderr to /dev/null so that the browser does not wait for the background command to finish before proceeding.
    print ("Location:$SERVER${PLANTGDB_WEBCGIURL}GeneSeqer/PlantGDBwatch-gs.cgi?ufname=$ufname&rrate=60\n\n");
    exit;
  }
} else {
use HTML::Template; 
my $CGI = CGI->new(); 
my $formTemplate = new HTML::Template(
	filename => $PLANTGDB_DIR . "tool/GeneSeqer/GeneSeqer.html",
	associate => $CGI,
	loop_context_vars => 1,
	global_vars => 1,
	die_on_bad_params => 0 ); 
print $CGI->header(); 
$formTemplate->param(
	acc => $ACC,
	chr => $chr,
	GDBFlag =>$Flag,
	_a => $A,
	_b => $B, ); 
print $formTemplate->output();
}
