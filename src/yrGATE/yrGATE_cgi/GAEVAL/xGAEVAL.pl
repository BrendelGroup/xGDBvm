#!/usr/bin/perl
use lib '/xGDBvm/src/yrGATE/yrGATE_cgi/GAEVAL/perllib';
use DBI;
use Getopt::Long qw/:config no_ignore_case bundling/;
use gaeval::sql;
use gaeval::load;

our($argHR,$dbUSER,$dbPASS);
($dbUSER,$dbPASS) = ('gaeval','');
$argHR = {GFFfile =>'',
	  _opt_xref_filename => '',
	  dsn => "DBI:mysql:gaeval:localhost",
	  GAEVAL_ANN_TBL => 'gaeval_annotation',
	  GAEVAL_SUPPORT_TBL=> 'gaeval_annotation_support',
	  GAEVAL_PROPERTIES_TBL=> 'gaeval_annotation_properties',
	  GAEVAL_ESOURCE_TBL => 'gaeval_evidence_source',
	  GAEVAL_EVIDENCE_TBL => 'gaeval_evidence',
	  GAEVAL_ISO_TABLES=>[{ISO_TBL  => 'gaeval_annotation_ISE',
			       PGS_TBL  => 'gaeval_evidence',
			       SEQ_TBL  => 'gaeval_evidence_source',
			       _HAS_CLONEPAIRS => 1
			      }],
	  CUSTOM_EVIDENCE_TYPES=>{}
	 };
my ($cleanDB,$skipAnalysis,$skipReport,$skipISEreload,$confFILE,@customEvType);
GetOptions("a|load_only_annotations" => sub { $argHR->{_opt_load_evidence}=0;},
	   "e|load_only_evidence" => sub { $argHR->{_opt_load_annotation}=0;},
	   "clean_db" => \$cleanDB,
	   "noanalysis|skip_analysis" => \$skipAnalysis,
	   "noreport|skip_report" => \$skipReport,
	   "noreload|skip_ise_reload" => \$skipISEreload,
	   "load_match" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"match");},
	   "load_cDNA_match" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"cDNA_match");},
	   "load_EST_match" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"EST_match");},
	   "load_translated_nucleotide_match" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"nucleotide_match");},
	   "load_nucleotide_to_protein_match" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"nucleotide_to_protein_match");},
	   "load_nucleotide_motif" => sub { $argHR->{_opt_all_evtype}=0; push(@{$argHR->{CUSTOM_EVIDENCE_TYPES}},"nucleotide_motif");},
	   "ignore_default_evidence" => sub { $argHR->{_opt_all_evtype}=0; },
	   "evidence_type=s" => \@customEvType,
	   "A|annotation_tablename=s" => \$argHR->{GAEVAL_ANN_TBL},
	   "S|sequence_tablename=s" => \$argHR->{GAEVAL_ESOURCE_TBL},
	   "E|evidence_tablename=s" => \$argHR->{GAEVAL_EVIDENCE_TBL},
	   "X|crossref=s" => \$argHR->{_opt_xref_filename},
	   "G|GFF=s" => \$argHR->{GFFfile},
	   "C|configuration=s" => \$confFILE
	   );
foreach my $evtype (@customEvType){$argHR->{CUSTOM_EVIDENCE_TYPES}->{$evtype} = 1;}

do $confFILE if(defined($confFILE)&&(-r $confFILE)&&($confFILE =~ /\.pl$/));

my $GA = gaeval::sql->new();
$GA->{dsn} = $argHR->{dsn};
$GA->{db_table} = $argHR->{GAEVAL_ANN_TBL};
$GA->{GAEVAL_SUPPORT_TBL}= $argHR->{GAEVAL_SUPPORT_TBL};
$GA->{GAEVAL_PROPERTIES_TBL}= $argHR->{GAEVAL_PROPERTIES_TBL};
$GA->{GAEVAL_ISO_TABLES} = $argHR->{GAEVAL_ISO_TABLES};
$GA->{ANNselect}= $argHR->{ANNselect} if(exists($argHR->{ANNselect}));

$argHR->{DBhandle} = $GA->{dbh} = DBI->connect($GA->{dsn},$dbUSER,$dbPASS,{ RaiseError => 1 });

$GA->initializeDB() if($cleanDB);
gaeval::load::loadGFF($argHR) if($argHR->{GFFfile} ne '');
$GA->seed_ALL_ISO_TBLS() if(!$skipISEreload);

my @reports = ();
push(@reports,\&report) if(!$skipReport);
$GA->analyze({ANN_UID_LOOP_PROCS => \@reports}) if(!$skipAnalysis);




sub report{
  my ($gob) = @_;
  my ($integScore,$CDSlength,$UTR5length,$UTR3length) = $gob->calc_integrity();
  
  #my ($integScore,$CDSlength,$UTR5length,$UTR3length) = $gob->calc_integrity();
  $integScore = sprintf('%.2f',$integScore);
  my $annlength  = $UTR5length + $CDSlength + $UTR3length;
  my $exCov      = $gob->{BC_MATCHES}->{EXON_coverage} * 100;
  $exCov = sprintf('%.0f',$exCov) . '%';
  my $bound5cov = abs($gob->{BC_MATCHES}->{BOUND_5prime});
  $bound5cov = (!$bound5cov)?
    "   This boundary is supported and consistent with the evidence alignments":
    ($gob->{BC_MATCHES}->{BOUND_5prime} < 0)?
    "   Evidence supports the extension of this annotation boundary by $bound5cov bases":
    "   This annotation boundary extends $bound5cov bases beyond the nearest evidence alignment";
  my $bound3cov = abs($gob->{BC_MATCHES}->{BOUND_3prime});
  $bound3cov = (!$bound3cov)?
    "   This boundary is supported and consistent with the evidence alignments":
    ($gob->{BC_MATCHES}->{BOUND_3prime} < 0)?
    "   Evidence supports the extension of this annotation boundary by $bound3cov bases":
    "   This annotation boundary extends $bound3cov bases beyond the nearest evidence alignment";
  my $con_intCNT = scalar(keys(%{$gob->{BC_MATCHES}->{INTRONS_confirmed}}));
  my $uns_intCNT = scalar(keys(%{$gob->{BC_MATCHES}->{INTRONS_unsupported}}));
  my $intCNT     = $con_intCNT + $uns_intCNT;

  my $intronAnalysis = ''; my $i=0;
  my @iorder = sort {return $a<=>$b} (keys(%{$gob->{BC_MATCHES}->{INTRONS_confirmed}}),keys(%{$gob->{BC_MATCHES}->{INTRONS_unsupported}}));
  @iorder = reverse @iorder if($gob->{ann_DBdata}->{strand} eq 'r');
  foreach my $intStr (@iorder){
    my($donor,$acceptor) = split(':',$intStr);
    $i++;$donor++; $acceptor--;
    ($donor,$acceptor) = ($acceptor,$donor) if($gob->{ann_DBdata}->{strand} eq 'r');
    $intronAnalysis .= "   Intron $i ( ${donor}..$acceptor )\n";
    if(exists($gob->{BC_MATCHES}->{INTRONS_unsupported}->{$intStr})){
      $intronAnalysis .= "    NO SUPPORTING EVIDENCE\n";
    }else{
      my $cnt = scalar(@{$gob->{BC_MATCHES}->{INTRONS_confirmed}->{$intStr}});
      $intronAnalysis .= "    Supporting Alignments: $cnt\n";
    }

  }
  $intronAnalysis = "   ** No Individual Introns Analyzed **\n" if($intronAnalysis eq '');



  my $props = '';
  ## Ambiguous Annotation Overlap
  my $aoProp = '';
  if(keys(%{$gob->{aoaINFO}->{AMB_annotations}})){
    $aoProp = "  Ambiguously Overlapping Annotations Detected:\n";
    foreach my $aoaHR (sort {return $a->{OAgeneId} cmp $b->{OAgeneId};} values(%{$gob->{aoaINFO}->{AMB_annotations}})){
      $aoProp .= "   $aoaHR->{OAgeneId}\n";
      $aoProp .= "    Ambiguous evidence:\n";
      foreach my $ev (sort {return $a cmp $b;} keys %{$aoaHR->{AmbISO}}){
	my $supCNT = scalar(keys(%{$aoaHR->{AmbISO}->{$ev}}));
	$aoProp .= "     $ev ($supCNT alignments)\n";
      }
    }
  }
  $props .= ($aoProp ne '')?$aoProp:"  No Ambiguously Overlapping Annotations Detected\n";

  ## Alternative Structure
  my $asProp = '';
  if(keys(%{$gob->{asiINFO}})){
    $asProp = "\n  Incongruent Introns Detected:\n";
    foreach my $intStr (sort {return $a<=>$b} (keys(%{$gob->{asiINFO}}))){
      my $supCNT = exists($gob->{BC_MATCHES}->{INTRONS_confirmed}->{$intStr})?scalar(@{$gob->{BC_MATCHES}->{INTRONS_confirmed}->{$intStr}}):0;
      my($donor,$acceptor) = split(':',$intStr);
      $donor++; $acceptor--;
      ($donor,$acceptor) = ($acceptor,$donor) if($gob->{ann_DBdata}->{strand} eq 'r');
      $asProp .= "   ${donor}..$acceptor\n";
      if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_alt_isoform})){
	$asProp .= "     Alternatively Annotated Intron\n";
	$asProp .= "      Supporting evidence: $supCNT\n";
      }
      if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_conflicting})){
	my $conCNT = scalar(@{$gob->{asiINFO}->{$intStr}->{INTRONS_conflicting}->{ISO_PGS}});
	my $supCNT = exists($gob->{BC_MATCHES}->{INTRONS_confirmed}->{$intStr})?scalar(@{$gob->{BC_MATCHES}->{INTRONS_confirmed}->{$intStr}}):0;
#	$asProp .= "     Conflicting Intron [The annotated intron is incompatible with an evidence alignment]\n";
	$asProp .= "     Conflicting Intron\n";
	$asProp .= "      Conflicting evidence: $conCNT\n";
	$asProp .= "      Supporting evidence: $supCNT\n";
      }
      if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_alternative})){
	my $supCNT = scalar(@{$gob->{asiINFO}->{$intStr}->{INTRONS_alternative}->{ISO_PGS}});
#	$asProp .= "     Alternative Intron [Evidence alignment supports this intron which is incompatible with the annotation]\n";
	$asProp .= "     Alternative Intron\n";
	$asProp .= "      Supporting evidence: $supCNT\n";
	if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented})){
	  foreach my $annSet ( sort { return ($a eq 'LOCAL')?-1:$a<=>$b; } 
			       keys(%{$gob->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}})){
	    my $docCNT = scalar(@{$gob->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}->{$annSet}});
	      $asProp .= ($annSet eq 'LOCAL')?
		"      Documented by Local Annotation Isoforms: $docCNT\n":
		"      Documented by $annSet Annotations: $docCNT\n";
	    foreach my $matchAR (@{$gob->{asiINFO}->{$intStr}->{INTRONS_alternative}->{documented}->{$annSet}}){
	      $asProp .= "       ${annSet}:$matchAR->[1]\n";
	    }
	  }
	}
      }
      if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_additional})){
	my $supCNT = scalar(@{$gob->{asiINFO}->{$intStr}->{INTRONS_additional}->{ISO_PGS}});
#	$asProp .= "     Additional Intron [Evidence alignment supports this intron which is beyond the annotation boundaries]\n";
	$asProp .= "     Additional Intron\n";
	$asProp .= "      Supporting evidence: $supCNT\n";
	if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented})){
	  foreach my $annSet ( sort { return ($a eq 'LOCAL')?-1:$a<=>$b; } 
			       keys(%{$gob->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}})){
	    my $docCNT = scalar(@{$gob->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}->{$annSet}});
	      $asProp .= ($annSet eq 'LOCAL')?
		"      Documented by Local Annotation Isoforms: $docCNT\n":
		"      Documented by $annSet Annotations: $docCNT\n";
	    foreach my $matchAR (@{$gob->{asiINFO}->{$intStr}->{INTRONS_additional}->{documented}->{$annSet}}){
	      $asProp .= "       ${annSet}:$matchAR->[1]\n";
	    }
	  }
	}
      }
      if(exists($gob->{asiINFO}->{$intStr}->{INTRONS_erroneous})){
	$asProp .= "     Erroneous (Pseudo) Intron\n";
      }
    }
  }
  $props .= ($asProp ne '')?$asProp:"\n  No Alternative Splicing/Structures Detected\n";

  ## Complex mRNA
  my $cmProp = '';
  if(keys(%{$gob->{cmINFO}->{CM_Fission}})){
    $cmProp .= "\n  Putative 'Fission' site detected:\n";
    foreach my $cps (keys(%{$gob->{cmINFO}->{CM_Fission}})){
      my $supCNT = scalar(@{$gob->{cmINFO}->{CM_Fission}->{$cps}->{TPS}});
      $cmProp .= "   $cps\n    Supporting Evidence: ${supCNT}\n";
      if(exists($gob->{cmINFO}->{CM_Fission}->{$cps}->{documented})){
	foreach my $annSRC (keys %{$gob->{cmINFO}->{CM_Fission}->{$cps}->{documented}}){
	  $cmProp .= "    Documented by '${annSRC}' annotations:\n";
	  foreach my $ann_hr (values %{$gob->{cmINFO}->{CM_Fission}->{$cps}->{documented}->{$annSRC}}){
	    $cmProp .= "     $ann_hr->{geneid}\n";
	  }
	}
      }
    }
  }
  if(keys(%{$gob->{cmINFO}->{CM_AltCPS}})){
    $cmProp .= "\n  Alternative Cleavage / PolyA site detected:\n";
    foreach my $cps (keys(%{$gob->{cmINFO}->{CM_AltCPS}})){
      my $supCNT = scalar(@{$gob->{cmINFO}->{CM_AltCPS}->{$cps}->{TPS}});
      $cmProp .= "   $cps\n    Supporting Evidence: ${supCNT}\n";
      if(exists($gob->{cmINFO}->{CM_AltCPS}->{$cps}->{documented})){
	foreach my $annSRC (keys %{$gob->{cmINFO}->{CM_AltCPS}->{$cps}->{documented}}){
	  $cmProp .= "    Documented by '${annSRC}' annotations:\n";
	  foreach my $ann_hr (values %{$gob->{cmINFO}->{CM_AltCPS}->{$cps}->{documented}->{$annSRC}}){
	    $cmProp .= "     $ann_hr->{geneid}\n";
	  }
	}
      }
    }
  }
  if(keys(%{$gob->{cmINFO}->{CM_Fusion}})){
    $cmProp .= "\n  Putative gene 'Fusion' detected:\n";
    foreach my $fusdan (values(%{$gob->{cmINFO}->{CM_Fusion}})){
      $cmProp .= "   $fusdan->{geneid}\n";
      if(exists($fusdan->{PGS_bridged})){
	$cmProp .= "    Bridged by contiguous evidence:\n";
	foreach my $ise_hr (@{$fusdan->{PGS_bridged}}){
	  $cmProp .= "     $ise_hr->{pgsGI}\n";
	}
      }
      if(exists($fusdan->{CP_bridged})){
	$cmProp .= "    Bridged by clone-pair evidence:\n";
	foreach my $ise_hr (@{$fusdan->{CP_bridged}}){
	  $cmProp .= "     $ise_hr->{pGI} -- $ise_hr->{sGI}\n";
	}
      }
    }
  }
      
  $props .= ($cmProp ne '')?$cmProp:"\n  No Complex Transcript Processing Detected\n";



  print <<END_OF_REPORT;
Annotation: $gob->{ann_DBdata}->{geneid}
 Genomic Source: $gob->{ann_DBdata}->{gseg_gi}
 Structure: $gob->{ann_DBdata}->{gene_structure}
 Open Reading Frame: $gob->{ann_DBdata}->{cdsstart} to $gob->{ann_DBdata}->{cdsstop}   
 5\` UTR length:  $UTR5length
 CDS length:     $CDSlength
 3\` UTR length:  $UTR3length
 Total length:   $annlength
 
 Structure Analysis:
  Integrity Score (0-1): $integScore
  Exon Sequence Coverage: $exCov
  5\` Terminus
$bound5cov
  3\` Terminus
$bound3cov
  Introns (total|confirmed|unsupported): $intCNT | $con_intCNT | $uns_intCNT
  Individual Intron Support:
$intronAnalysis
 Incongruency Analysis:
$props
\#\#

END_OF_REPORT

}
