#! /usr/bin/perl -w
open (MYFile, "$ARGV[0]");
my $xGDB = $ARGV[1];
my $table = $ARGV[2];
while (<MYFile>){
	my @list= split(/\t/,$_);
	my $id = "$list[0]";
	my $Des = "$list[1]";
	$Des =~ s/\n$//g;
	$Des =~ s/['"]//g;
	my $erro=qx(echo "update $table set description='$Des' where geneId='$id'"| mysql -pxgdb -u gdbuser $xGDB);
}
	
