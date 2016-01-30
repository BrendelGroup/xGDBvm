package UCAann;
use base "AnnotationTrack";

do 'SITEDEF.pl';
require LWP::UserAgent;
use DBI;
use CGI ":all";
use CGI::SSI;

sub _init{
  my $self = shift;

  $self->{'MOD_DAS_SET_FeatureTypeCategory'} = $self->_makeClosure(sub{return "UCA";});

  $self->SUPER::_init(@_);
  $self->{db_table} = (exists($self->{db_table})) ? $self->{db_table} : 'user_gene_annotation';
  my $yrGATEdbName = $self->{yrGATE_dbname} = (exists($self->{yrGATE_dbname}))?$self->{yrGATE_dbname}:$DBver[$#DBver]->{DB};
  my $yrGATEdbVer = $self->{yrGATE_dbver} = (exists($self->{yrGATE_dbver}))?$self->{yrGATE_dbver}:$self->{db_id};
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'UCA';

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

#  do "$self->{DSO_MOD}" if(exists($self->{DSO_MOD}));
#  $self->{VALIDATE_ID} = \&MOD_VALIDATE_ID if(exists(&MOD_VALIDATE_ID));
  $self->updateSQL();

}

sub updateSQL {
  my $self = shift; 

 my $UCAviewableSQL = ($self->{USERfname} eq "ADMIN") ?  "(dbName = '$self->{yrGATE_dbname}')&&(dbVer = $self->{yrGATE_dbver})&&" : "(dbName = '$self->{yrGATE_dbname}')&&(dbVer = $self->{yrGATE_dbver})&&((USERid = '$self->{USERid}')||(status = 'ACCEPTED'))&&"; # You have to be either ADMIN or owner of the annotation to view it; temporarily suspended until we can figure out how to write USERid to sessions table (broken).

#   my $UCAviewableSQL = "(dbName = '$self->{yrGATE_dbname}')&&(dbVer = $self->{yrGATE_dbver})&&"; #temporary - lets everyone view everyone's annotations that are SUBMITTED or SAVED.

  $self->{gsegSQL_BASE}=  $self->{SQL_BASE}         = qq{SELECT uid, c.geneId, c.chr,c.strand,c.l_pos,c.r_pos,c.gene_structure,c.description,c.comment,c.CDSstart,c.CDSstop,c.status,c.modDate,c.geneAliases,c.proteinAliases,c.proteinId,c.comment,c.USERid as owner,c.evidence,c.description,c.CDSstart,c.CDSstop FROM user_gene_annotation as c };

  $self->{gsegREGION_QUERY} = $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE $UCAviewableSQL (c.chr=?)&&(c.r_pos>=?)&&(c.l_pos<=?) };

  $self->{gsegDESC_QUERY} = $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE $UCAviewableSQL (MATCH (description,comment) AGAINST (? IN BOOLEAN MODE)) };

  $self->{gsegUID_QUERY} = $self->{chrUID_QUERY}     = qq{SELECT c.geneId FROM user_gene_annotation as c WHERE $UCAviewableSQL (c.uid=?)        };

  $self->{gsegQUERY} = $self->{chrQUERY}         = qq{$self->{SQL_BASE} WHERE $UCAviewableSQL (c.geneId=?) };

  $self->{'das_QUERY'} = [qq{$self->{SQL_BASE} WHERE $UCAviewableSQL (1)}] if(!exists($self->{'das_QUERY'}));
  $self->{'dasSEGMENT_QUERY'} = [qq{$self->{SQL_BASE} WHERE $UCAviewableSQL (c.chr=?)}] if(!exists($self->{'dasSEGMENT_QUERY'}));
  $self->{'dasREGION_QUERY'} = [$self->{chrREGION_QUERY}] if(!exists($self->{'dasREGION_QUERY'}));

}

sub loadREGION {
  my $self = shift;
  my ($argHR) = @_;

  $self->{USERid} = $argHR->{USERid};
  $self->{USERfname} = $argHR->{USERfname};
  $self->updateSQL();

  return $self->SUPER::loadREGION(@_);
}

sub selectRECORD {
  my $self = shift;
  my ($argHR) = @_;

  $self->{USERid} = $argHR->{USERid};
  $self->{USERfname} = $argHR->{USERfname};
  $self->updateSQL();

  return $self->SUPER::selectRECORD(@_);
}

sub showRECORD{
  #jfdenton changes Sept-13
  my $ua = LWP::UserAgent->new(ssl_opts=>{verify_hostname=>0});
  my $self = shift;
  my ($argHR) = @_;
  @$argHR{'recordTYPE','selectedRECORD'} = $self->selectRECORD($argHR); ## need to check undefs

  if(exists($argHR->{DEBUG}) && $argHR->{DEBUG}){
    print STDERR "[DSO/UCAann.pm] Accessing yrGATE record using SSI <${ucaPATH}AnnotationRecord.pl?ssisession=$argHR->{AUTHsession}&uid=$argHR->{selectedRECORD}->{uid}&dbid=$argHR->{dbid}>\n";
  }
  #my $ssi = CGI::SSI->new();
  #"${ucaPATH}
  my $link = $rootPATH . "src/yrGATE/yrGATE_cgi/AnnotationRecord.pl?ssisession=$argHR->{AUTHsession}&uid=$argHR->{selectedRECORD}->{uid}&dbid=$argHR->{dbid}&GDB=${xGDB}";
  #print STDERR $link;
  #my $result = $ssi->include(virtual => "/src/yrGATE/yrGATE_cgi/AnnotationRecord.pl?ssisession=$argHR->{AUTHsession}&uid=$argHR->{selectedRECORD}->{uid}&dbid=$argHR->{dbid}");
  my $res = $ua->get($link);
  my $htmlHR = {-title=>"${SITENAMEshort} $self->{trackname}:$self->{geneid}",
		-bgcolor=>"#FFFFFF",
	       };
  my $script;

  ## Adjust header start/end (l_pos,r_pos) to region local to selected record
  $self->setRegionLocal($argHR);

  return ($htmlHR,$script,$res->decoded_content);
}

1;
