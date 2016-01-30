package TIGRtu;
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

  $self->{db_table}  = (exists($self->{db_table})) ? $self->{db_table} : 'chr_tigr_tu';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'TIGRtu';

  #### specifc query strings ####
  $self->{SQL_BASE}         = qq{SELECT c.uid,c.geneId,c.chr,c.strand,c.l_pos,c.r_pos,c.gene_structure,c.description,c.note,c.CDSstart,c.CDSstop,c.transcript_id FROM $self->{db_table} AS c };

  $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (c.chr=?)&&(c.r_pos>=?)&&(c.l_pos<=?) };

  $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (description,note) AGAINST (? IN BOOLEAN MODE) };

  $self->{chrUID_QUERY}     = qq{SELECT c.geneId FROM  $self->{db_table} as c WHERE (c.uid=?) };

  $self->{chrQUERY}         = qq{$self->{SQL_BASE} WHERE  ? IN (c.geneId,c.model_id,c.transcript_id,c.model_chr_id,c.transcript_chr_id)	};


  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (geneId IN ($idlist))||(transcript_id IN ($idlist))||(model_id IN ($idlist))||(transcript_chr_id IN ($idlist))||(model_chr_id IN ($idlist))";
  };

}

1;
