package GBKann;
use base "AnnotationTrack";

do 'SITEDEF.pl';

use DBI;
use CGI ":all";

sub hello{
  my $self = shift;
  print "hello I'm a ";
  $self->SUPER::whatami();
  print "$self->{DSOname}\n";
}

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{db_table} = (exists($self->{db_table})) ? $self->{db_table} : 'gene_annotation';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'Genbank mRNA';

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

  #### specifc query strings ####
  my $DB_TABLE = $self->{db_table};

  my $predef_das_QUERY = (exists($self->{'das_QUERY'}))?1:0;
  my $predef_dasSEGMENT_QUERY = (exists($self->{'dasSEGMENT_QUERY'}))?1:0;
  my $predef_dasREGION_QUERY = (exists($self->{'dasREGION_QUERY'}))?1:0;
  $self->{'das_QUERY'} = [] if(!$predef_das_QUERY);
  $self->{'dasSEGMENT_QUERY'} = [] if(!$predef_dasSEGMENT_QUERY);
  $self->{'dasREGION_QUERY'} = [] if(!$predef_dasREGION_QUERY);

  if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE}){
    $self->{SQL_BASE}         = qq{SELECT c.uid,c.geneId,c.chr,c.strand,c.l_pos,c.r_pos,c.gene_structure,c.description,c.note,c.CDSstart,c.CDSstop,c.transcript_id FROM chr_${DB_TABLE} as c };

    $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (c.chr=?)&&(c.r_pos>=?)&&(c.l_pos<=?) };
    $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (description,note) AGAINST (? IN BOOLEAN MODE) };
    $self->{chrUID_QUERY}     = qq{SELECT c.geneId FROM chr_${DB_TABLE} as c WHERE (c.uid=?) };
    $self->{chrQUERY}         = qq{$self->{SQL_BASE} WHERE (? IN (c.geneId,c.transcript_id)) };

    push(@{$self->{'das_QUERY'}},$self->{SQL_BASE}) if(!$predef_das_QUERY);
    push(@{$self->{'dasSEGMENT_QUERY'}},"$self->{SQL_BASE} WHERE (c.chr=?)") if(!$predef_dasSEGMENT_QUERY);
    push(@{$self->{'dasREGION_QUERY'}},$self->{chrREGION_QUERY}) if(!$predef_dasREGION_QUERY);
   
  }

  if((exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE}) || $self->{gsegSRC}){
    $self->{gsegSQL_BASE}     = qq{SELECT ga.uid,ga.gseg_gi,ga.geneId,ga.strand,ga.l_pos,ga.r_pos,ga.gene_structure,ga.description,ga.note,ga.CDSstart,ga.CDSstop,ga.transcript_id FROM gseg_${DB_TABLE} as ga };

    $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (ga.gseg_gi=?)&&(ga.r_pos>=?)&&(ga.l_pos<=?) };
    $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE MATCH (description,note) AGAINST (? IN BOOLEAN MODE) };
    $self->{gsegUID_QUERY}    = qq{SELECT ga.geneId FROM gseg_${DB_TABLE} as ga WHERE (ga.uid=?) };
    $self->{gsegQUERY}        = qq{$self->{gsegSQL_BASE} WHERE (? IN (ga.geneId,ga.transcript_id)) };

    push(@{$self->{'das_QUERY'}},$self->{gsegSQL_BASE}) if(!$predef_das_QUERY);
    push(@{$self->{'dasSEGMENT_QUERY'}},"$self->{gsegSQL_BASE} WHERE (ga.gseg_gi=?)") if(!$predef_dasSEGMENT_QUERY);
    push(@{$self->{'dasREGION_QUERY'}},$self->{gsegREGION_QUERY}) if(!$predef_dasREGION_QUERY);

  }

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (geneId IN ($idlist))||(transcript_id IN ($idlist))";
  };

#  do "$self->{DSO_MOD}" if(exists($self->{DSO_MOD}));
#  $self->{VALIDATE_ID} = \&MOD_VALIDATE_ID if(exists(&MOD_VALIDATE_ID));

}

1;
