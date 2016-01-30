package GFFann;
use base "AnnotationTrack";

our(%IDspace,%TYPE,%Progeny);

do 'SITEDEF.pl';

use DBI;

sub _init{
  my $self = shift;
  
  $self->{primaryColor} = (exists($self->{primaryColor})) ? $self->{primaryColor} : '#FFC642'; # orange 5-1-14 JPD

  $self->SUPER::_init(@_);

  $self->{db_table} = (exists($self->{project_gff_table})) ? $self->{project_gff_table} : (exists($self->{db_table})) ? $self->{db_table} : 'user_gff_annotation';
  $self->{projectsTable} = (exists($self->{projecsTable})) ? $self->{projectsTable} : (exists($DBver[ $self->{db_id} ]->{projectsTable})) ? $DBver[ $self->{db_id} ]->{projectsTable} : 'projects';
  $self->{sessionProjectsTable} = (exists($self->{sessionProjecsTable})) ? $self->{sessionProjectsTable} : (exists($DBver[ $self->{db_id} ]->{sessionProjectsTable})) ? $DBver[ $self->{db_id} ]->{sessionProjectsTable} : 'sessionprojects';
  $self->{pid} = (exists($self->{pid}))? $self->{pid} : 0;
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: "UGA-$self->{pid}";
  if(!exists($self->{dbh})){
  	my $projectHOST =
	  ( exists( $DBver[ $self->{db_id} ]->{PROJECThost} ) )
	  ? $DBver[ $self->{db_id} ]->{PROJECThost}
	  : ( exists( $DBver[ $self->{db_id} ]->{DBhost} ) )
	  ? $DBver[ $self->{db_id} ]->{DBhost}
	  : $DB_HOST;
	my $projectUSER =
	  ( exists( $DBver[ $self->{db_id} ]->{PROJECTuser} ) )
	  ? $DBver[ $self->{db_id} ]->{PROJECTuser}
	  : ( exists( $DBver[ $self->{db_id} ]->{DBuser} ) )
	  ? $DBver[ $self->{db_id} ]->{DBuser}
	  : $DB_USER;
	my $projectPASS =
	  ( exists( $DBver[ $self->{db_id} ]->{PROJECTpass} ) )
	  ? $DBver[ $self->{db_id} ]->{PROJECTpass}
	  : ( exists( $DBver[ $self->{db_id} ]->{DBpass} ) )
	  ? $DBver[ $self->{db_id} ]->{DBpass}
	  : $DB_PASSWORD;
	my $projectDB =
	  ( exists( $DBver[ $self->{db_id} ]->{PROJECTdb} ) )
	  ? $DBver[ $self->{db_id} ]->{PROJECTdb}
	  : $DBver[ $self->{db_id} ]->{DB};
	$self->{dbh} = DBI->connect( "DBI:mysql:${projectDB}:${projectHOST}",
		$projectUSER, $projectPASS, { RaiseError => 1 } );
	$self->{dbh}->{FetchHashKeyName} = 'NAME_lc';
  }
  
  $self->{'das_supported_types'} = ( exists( $self->{'das_supported_types'} ) ) ? $self->{'das_supported_types'} : 
        {       'five_prime_noncoding_exon'=>{typelist=>1,method=>$self->{'trackname'}}, 
                'five_prime_coding_exon_noncoding_region'=>{typelist=>1,method=>$self->{'trackname'}}, 
                'five_prime_coding_exon_coding_region'=>{typelist=>1,method=>$self->{'trackname'}},
                'coding_exon'=>{typelist=>1,method=>$self->{'trackname'}}, 
                'three_prime_coding_exon_coding_region'=>{typelist=>1,method=>$self->{'trackname'}}, 
                'three_prime_coding_exon_noncoding_region'=>{typelist=>1,method=>$self->{'trackname'}}, 
                'three_prime_noncoding_exon'=>{typelist=>1,method=>$self->{'trackname'}},
                'exon'=>{typelist=>1,method=>$self->{'trackname'}},
                'noncoding_exon'=>{typelist=>1,method=>$self->{'trackname'}}, 
        };

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (geneId IN ($idlist))";
  };
  $self->updateSQL();
  
}

sub updateSQL {
  my $self = shift; 

  my $viewableSQL = "(c.pid = $self->{pid}) &&";

  $self->{gsegSQL_BASE}=  $self->{SQL_BASE}         = qq{SELECT c.uid,c.geneId,c.gseg_gi as chr,c.strand,c.l_pos,c.r_pos,c.gene_structure,c.description,c.note,c.CDSstart,c.CDSstop,c.transcript_id,c.glyph_style FROM $self->{db_table} as c };

  $self->{gsegREGION_QUERY} = $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE $viewableSQL (c.gseg_gi=?)&&(c.r_pos>=?)&&(c.l_pos<=?) };

  $self->{gsegDESC_QUERY} = $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE $viewableSQL (MATCH (description,comment) AGAINST (? IN BOOLEAN MODE)) };

  $self->{gsegUID_QUERY} = $self->{chrUID_QUERY}     = qq{SELECT c.geneId FROM $self->{db_table} as c WHERE $viewableSQL (c.uid=?)        };

  $self->{gsegQUERY} = $self->{chrQUERY}         = qq{$self->{SQL_BASE} WHERE $viewableSQL (c.geneId=?) };

  $self->{'das_QUERY'} = [qq{$self->{SQL_BASE} WHERE $viewableSQL (1)}] if(!exists($self->{'das_QUERY'}));
  $self->{'dasSEGMENT_QUERY'} = "$self->{SQL_BASE} WHERE $viewableSQL (c.gseg_gi=?)" if(!exists($self->{'dasSEGMENT_QUERY'}));
  $self->{'dasREGION_QUERY'} = [$self->{chrREGION_QUERY}] if(!exists($self->{'dasREGION_QUERY'}));
}

sub getTRACKCELL {
  my $self = shift;
  my ( $argHR, $imgfn ) = @_;
  my ( $html, $color, $name );

  my ($stdcheck) = ('checked');

  ($name)  = $self->{dbh}->selectrow_array("SELECT pname FROM $self->{projectsTable} WHERE (pid=$self->{pid})");
  $color = $self->{primaryColor};
  $html  = "<img id='$self->{resid}' class='cth-button xgdb-track-delete' src='${IMAGEDIR}xgdb-delete.png'>";

  return ( $html, $color, $name );
}

sub structINFO{
  my $self = shift;
  my ($type,$record,$argHR) = @_;
  my ($c,$c_a,$c_s,$c_d,$label,$str,@pgs);
  
  return undef if(!(defined($record) && exists($record->{uid})));

  if(defined($record->{glyph_style})&&($record->{glyph_style} ne '')){
  	$c = $c_a = $c_s = $c_d = $record->{glyph_style};
  }else{
  	$c = $c_a = $c_s = $c_d = $self->{primaryColor};
  }
  
  $label = (exists($record->{geneid}))?$record->{geneid}:$self->{geneid};
  
  ($str) = $record->{gene_structure} =~ /^\D*(.*)/;
  @pgs = split(/[^\d]+/,$str);

  if($record->{strand} eq 'r'){
    @pgs = reverse @pgs;
  }

  return ["${type}$record->{uid}",
	  {label=>$label,color=>$c,arrowColor=>$c_a,startColor=>$c_s,dotColor=>$c_d,drawArrowhead=>1},
	  @pgs];
}

sub loadGFF3{
	my $self = shift;
	my($argHR) = @_;
	return 0 if(!exists($argHR->{GFFfile})||($argHR->{GFFfile} eq ''));
	return -1 if(!open(INF,$argHR->{GFFfile}));	
  
	while(<INF>){
    	last if((/^\#\#FASTA/)||(/^>/));
    	$self->GFF_process($argHR) if(/^\#\#\#/);
    
    	next if((/^\s*$/)||(/^\#/));
    	$self->GFF_register_entry($self->GFF_readline($_));
  	}
  	$self->GFF_process($argHR);
  
  	return 1;
}

sub GFF_process {
  my $self = shift;
  my($argHR) = @_;
  
  ## process annotations
  $self->annotation2DB($argHR);
  
  %IDspace=();
  %TYPE=();
  %Progeny=();

}

sub annotation2DB {
  my $self = shift;
  my($argHR) = @_;
  foreach my $type (keys(%TYPE)){
  	next if(($type eq 'CDS') || ($type eq 'mRNA') || ($type eq 'exon') || ($type eq 'intron') || ($type eq 'gene'));
  	foreach $ID (keys(%{$TYPE{$type}})){
  		my $gseg_gi = (exists($argHR->{gsegXref}) && exists($argHR->{gsegXref}->{$IDspace{$ID}->[0]->{seqid}}))?$argHR->{gsegXref}->{$IDspace{$ID}->[0]->{seqid}} : $IDspace{$ID}->[0]->{seqid};
    	my $geneId  =(exists($IDspace{$ID}->[0]->{attributes}->{Name}))?$IDspace{$ID}->[0]->{attributes}->{Name}:$ID;
    	my $strand  =($IDspace{$ID}->[0]->{strand} eq '+')?'f':'r';
    	my $glyphColor = (exists($IDspace{$ID}->[0]->{attributes}->{GlyphColor}))?$IDspace{$ID}->[0]->{attributes}->{GlyphColor}:'#000000';
    	
    	my @annSTRUCTURE = ();
    	@annSTRUCTURE = ($IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end});
    	@annSTRUCTURE = sort {return $a<=>$b;} @annSTRUCTURE;
    	my $gene_structure = ($IDspace{$ID}->[0]->{strand} eq '+')?"join(":"complement(join(";
    	for(my $x=0;$x<$#annSTRUCTURE;$x+=2){
      		$gene_structure .= $annSTRUCTURE[$x] . ".." . $annSTRUCTURE[$x+1] . ",";
    	}
    	chop($gene_structure);
    	$gene_structure .= ($IDspace{$ID}->[0]->{strand} eq '+')?")":"))";
    	
    	my $sql = "INSERT INTO $self->{db_table} (uid,pid,gseg_gi,geneId,strand,l_pos,r_pos,gene_structure,CDSstart,CDSstop,glyph_style) VALUES (0,$argHR->{pid},'$gseg_gi','$geneId','$strand',$IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end},'$gene_structure','NULL','NULL','$glyphColor')";
    	if(exists($self->{dbh}) && ($self->{dbh} ne '')){
      		#print STDERR "${sql};\n";
      		$self->{dbh}->do($sql);
    	}else{
      		print STDERR "${sql};\n";
    	}
  	}
  }
  foreach $ID (keys(%{$TYPE{mRNA}})){
    my $gseg_gi = (exists($argHR->{gsegXref}) && exists($argHR->{gsegXref}->{$IDspace{$ID}->[0]->{seqid}}))?$argHR->{gsegXref}->{$IDspace{$ID}->[0]->{seqid}} : $IDspace{$ID}->[0]->{seqid};
    my $geneId  =(exists($IDspace{$ID}->[0]->{attributes}->{Name}))?$IDspace{$ID}->[0]->{attributes}->{Name}:$ID;
    my $strand  =($IDspace{$ID}->[0]->{strand} eq '+')?'f':'r';

    my @annSTRUCTURE = ();
    if(exists($Progeny{$ID}->{exon})){
      foreach $GFFexon (@{$Progeny{$ID}->{exon}}){
	push(@annSTRUCTURE,$GFFexon->{start},$GFFexon->{end});
      }
    }else{
      @annSTRUCTURE = ($IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end});
    }
    @annSTRUCTURE = sort {return $a<=>$b;} @annSTRUCTURE;
    my $gene_structure = ($IDspace{$ID}->[0]->{strand} eq '+')?"join(":"complement(join(";
    for(my $x=0;$x<$#annSTRUCTURE;$x+=2){
      $gene_structure .= $annSTRUCTURE[$x] . ".." . $annSTRUCTURE[$x+1] . ",";
    }
    chop($gene_structure);
    $gene_structure .= ($IDspace{$ID}->[0]->{strand} eq '+')?")":"))";

    my $CDSleft  = $IDspace{$ID}->[0]->{end};
    my $CDSright = -1;
    if(exists($Progeny{$ID}->{CDS})){
      foreach $GFFcds (@{$Progeny{$ID}->{CDS}}){
	$CDSleft = ($GFFcds->{start} < $CDSleft)? $GFFcds->{start} : $CDSleft;
	$CDSright = ($GFFcds->{end} > $CDSright)? $GFFcds->{end} : $CDSright;
      }
    }
    my $CDSstart = ($CDSright == -1)?'NULL':($IDspace{$ID}->[0]->{strand} eq '+')? $CDSleft:$CDSright;
    my $CDSstop  = ($CDSright == -1)?'NULL':($IDspace{$ID}->[0]->{strand} eq '+')? $CDSright:$CDSleft;

    my $sql = "INSERT INTO $self->{db_table} (uid,pid,gseg_gi,geneId,strand,l_pos,r_pos,gene_structure,CDSstart,CDSstop) VALUES (0,$argHR->{pid},'$gseg_gi','$geneId','$strand',$IDspace{$ID}->[0]->{start},$IDspace{$ID}->[0]->{end},'$gene_structure',$CDSstart,$CDSstop)";
    if(exists($self->{dbh}) && ($self->{dbh} ne '')){
      #print STDERR "${sql};\n";
      $self->{dbh}->do($sql);
    }else{
      print STDERR "${sql};\n";
    }
  }  
}

sub GFF_readline {
  my $self = shift;
  my ($GFFline) = @_;
  chomp($GFFline);
  my @col = split("\t",$GFFline);
  my %att = split(/[=;]/,$col[8]);
  return {seqid  =>$col[0],
	  source =>$col[1],
	  type   =>$col[2],
	  start  =>$col[3],
	  end    =>$col[4],
	  score  =>$col[5],
	  strand =>$col[6],
	  phase  =>$col[7],
	  attributes =>\%att
	 };
}

sub GFF_register_entry {
  my $self = shift;
  my ($GFFentry) = @_;
  
  my $ID=(exists($GFFentry->{attributes}->{ID}))?$GFFentry->{attributes}->{ID}:"__defaultID_".$UID++;

  if(exists($IDspace{$ID})){
    push(@{$IDspace{$ID}},$GFFentry);
  }else{
    $IDspace{$ID} = [$GFFentry];
    if(exists($TYPE{$GFFentry->{type}})){
      if(exists($TYPE{$GFFentry->{type}}->{$ID})){
	$TYPE{$GFFentry->{type}}->{$ID}++
      }else{
	$TYPE{$GFFentry->{type}}->{$ID} = 1;
      }
    }else{
      $TYPE{$GFFentry->{type}} = {$ID=>1};
    }
  }
  if(exists($GFFentry->{attributes}->{Parent})){
    foreach $parent (split(',',$GFFentry->{attributes}->{Parent})){
      if(exists($Progeny{$parent})){
	if(exists($Progeny{$parent}->{$GFFentry->{type}})){
	  push(@{$Progeny{$parent}->{$GFFentry->{type}}},$GFFentry);
	}else{
	  $Progeny{$parent}->{$GFFentry->{type}} = [$GFFentry];
	}
      }else{
	$Progeny{$parent}={$GFFentry->{type} => [$GFFentry]};
      }
    }
  }
}

1;
