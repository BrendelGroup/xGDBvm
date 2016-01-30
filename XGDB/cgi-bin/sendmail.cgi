#!/usr/bin/perl
#author: Qunfeng Dong
#send email notice to TE nest users


        my $submitterEmail = shift;
	my $URL = shift;
#        my $sequence = shift;
        my $curatorEmail = 'plantgdb@iastate.edu';

#print STDERR "mail: $submitterEmail\t$URL\n";

my @URL = split(/\#/,$URL);


        #send thanks email to submitter
        my $subject_to_submitter = 'TE nest results';
        open(MAIL, "| /usr/sbin/sendmail -t");
        print MAIL "To: $submitterEmail\n";
        print MAIL "From: $curatorEmail\n";
        print MAIL "Subject: $subject_to_submitter\n\n";
        print MAIL "Dear colleague:\n\n";
        print MAIL "Your TE nest run has completed.  The results can be accessed at the links below\n\n";
        for(my $x=0;$x<@URL;$x++)
          {
          if($URL[$x] =~ m/LTR/)
            {
            print MAIL "TE nest annotation table: $URL[$x]\n"; 
            }
           elsif($URL[$x] =~ m/masked/)
            {
            print MAIL "Repeat masked fasta file: $URL[$x]\n";
            }
           elsif($URL[$x] =~ m/svg/)
            {
            print MAIL "TE nest svg display file: $URL[$x]\n";
            }
          }
        print MAIL "\nThe output of the TE nest svg display program generates svg format (http://www.w3.org/Graphics/SVG/) image file.\n";
        print MAIL "You will need Firefox 1.5 browser (downloadable from http://www.mozilla.com/firefox/) to correctly view the image.\n\n";
        print MAIL "Thank you for using TE nest.\n";
        close(MAIL);

        open(MAIL, "| /usr/sbin/sendmail -t");
        print MAIL "To: TE_nest\@yahoo.com\n";
        print MAIL "From: $curatorEmail\n";
        print MAIL "Subject: TE nest user results\n\n";
        print MAIL "$submitterEmail\n\n";
        for(my $x=0;$x<@URL;$x++)
          {
          if($URL[$x] =~ m/LTR/)
            {
            print MAIL "TE nest annotation table: $URL[$x]\n\n";
            }
          }
#        print MAIL "$sequence\n\n";
        close(MAIL);


