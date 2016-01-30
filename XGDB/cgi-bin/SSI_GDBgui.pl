#!/usr/bin/perl
use CGI ":all";
use GDBgui;

do 'SITEDEF.pl';
do 'getPARAM.pl';

## Capture cgi_param from SSI query string
$cgi_paramHR->{htmlHR}->{-title} = param(PAGE_TITLE) if(param(PAGE_TITLE));
if(param('JAVASCRIPT')){
  $cgi_paramHR->{htmlHR}->{-script} = [];
  foreach (param('JAVASCRIPT')){
    push(@{$cgi_paramHR->{htmlHR}->{-script}},{-src=>"${JSPATH}".$_});
  }
}
##

my $GDBpage = new GDBgui();

print header();

if(path_info() eq "/THREE_COLUMN_HEADER/"){
  $GDBpage->printXGDB_StartHtml($cgi_paramHR);
  $GDBpage->print_SiteHeader($cgi_paramHR);
  $GDBpage->print_LeftSidebar($cgi_paramHR);
  $GDBpage->print_RightSidebar($cgi_paramHR);

}elsif(path_info() eq "/TWO_COLUMN_HEADER/"){
  $GDBpage->printXGDB_StartHtml($cgi_paramHR);
  $GDBpage->print_SiteHeader($cgi_paramHR);
  $GDBpage->print_LeftSidebar($cgi_paramHR);

}elsif(path_info() eq "/STANDARD_HEADER/"){
  $GDBpage->printXGDB_StartHtml($cgi_paramHR);
  $GDBpage->print_SiteHeader($cgi_paramHR);
  $GDBpage->print_LeftSidebar($cgi_paramHR);

}elsif(path_info() eq "/STANDARD_FOOTER/"){
  $GDBpage->print_SiteFooter($cgi_paramHR);
  $GDBpage->printXGDB_EndHtml($cgi_paramHR);

}elsif(path_info() eq "/START_HTML/"){
  $GDBpage->printXGDB_StartHtml($cgi_paramHR);
}elsif(path_info() eq "/SITE_HEADER/"){
  $GDBpage->print_SiteHeader($cgi_paramHR);
}elsif(path_info() eq "/LEFT_SIDEBAR/"){
  $GDBpage->print_LeftSidebar($cgi_paramHR);
}elsif(path_info() eq "/RIGHT_SIDEBAR/"){
  $GDBpage->print_RightSidebar($cgi_paramHR);
}elsif(path_info() eq "/SITE_FOOTER/"){
  $GDBpage->print_SiteFooter($cgi_paramHR);
}elsif(path_info() eq "/END_HTML/"){
  $GDBpage->printXGDB_EndHtml($cgi_paramHR);
}elsif(path_info() eq "/TEST/"){
  print h3("[GDBgui] Parameters:");
  foreach (param()){
    print "$_ = " . param($_) . "<BR>\n";
  }
}
