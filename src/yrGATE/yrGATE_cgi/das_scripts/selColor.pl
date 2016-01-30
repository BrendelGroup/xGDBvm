#!/usr/bin/perl
use CGI ":all";
use Bio::Graphics;

@colors = Bio::Graphics::Panel->color_names();
@colors = sort @colors;
$num = param("num");

$HTML = "<html><body><table>";
for (my $i=0;$i<scalar(@colors);$i++){
    $HTML .= "<tr><td bgcolor='$colors[$i]'><a href=\"javascript:opener.document.forms.selFrm['Color$num'].value = '$colors[$i]'; opener.setBColor();; window.close();\">$colors[$i]</a></td></tr>\n";
}
$HTML .= "</table></body></html>";

print header();
print $HTML;
