#!/usr/bin/perl -w

use CGI ":all";

print header, start_html('Retrieve Legend');

print "
<script language=\"JavaScript\"><!--
function flip(name,src) {
  if (document.images)
    document.images[name].src = \"./xGDBLegend.cgi?SELopt=\" + src;
}
//--></script>
";

print "<table align=left>\n";
if (param("SELopt")) {
  my $option = param("SELopt");
  print "<tr><td colspan=2 align=center><img name=legend src=\"./xGDBLegend.cgi?SELopt=$option\"></td></tr>";
}
else {
  print "<tr><td colspan=2 align=center><img name=legend src=\"./xGDBLegend.cgi\"></td></tr>";
}
print "
<tr>
  <td valign=top>
    <table>
      <tr>
        <td colspan=4><b>Retrieve sequences from genome</b></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=5_prime|ex onClick=flip('legend','5_prime|ex')></td>
        <td>5\' region</td>
        <td>[Exclude neighboring gene seq.]</td>
        <td></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=5_prime|in onClick=flip('legend','5_prime|in')></td>
        <td></td>
        <td>[Include neighboring gene seq.]</td>
        <td></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=3_prime|ex onClick=flip('legend','3_prime|ex')></td>
        <td>3\' region</td>
        <td>[Exclude neighboring gene seq.]</td>
        <td></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=3_prime|in onClick=flip('legend','3_prime|in')></td>
        <td></td>
        <td>[Include neighboring gene seq.]</td>
        <td></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=allExons onClick=flip('legend','allExons')></td>
        <td colspan=3>All exons</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=allIntrons onClick=flip('legend','allIntrons')></td>
        <td colspan=3>All introns</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=entireUnspliced onClick=flip('legend','entireUnspliced')></td>
        <td colspan=3>Entire transcript region, unspliced [exons & introns] (+1 to end)</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=entireAligned onClick=flip('legend','entireAligned')></td>
        <td colspan=3>Entire transcript region, spliced & aligned [cDNA] (+1 to end)</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=entireTranslated onClick=flip('legend','entireTranslated')></td>
        <td colspan=3>Entire translated region, spliced & aligned [Annotated gene only]</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=flankStart onClick=flip('legend','flankStart')></td>
        <td colspan=3>Flanking region of translation start site (ATG)</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=fullRegion|ex onClick=flip('legend','fullRegion|ex')></td>
        <td colspan=2>Entire region as a single FASTA file<br><small>(unspliced, including any specified 5' or 3' sequence)</small></td>
        <td>[Exclude neighboring gene seq.]</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=fullRegion|in onClick=flip('legend','fullRegion|in')></td>
        <td colspan=2></td>
        <td>[Include neighboring gene seq.]</td>
      </tr>
    </table>
  </td>

  <td valign=top>
    <table>
      <tr>
        <td colspan=2><b>Retrieve sequences from original queries</b></td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=fullQuery onClick=flip('legend','fullQuery')></td>
        <td>Entire query sequence</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=allExonsQuery onClick=flip('legend','allExonsQuery')></td>
        <td>All exons</td>
      </tr>
      <tr>
        <td><input type=radio name=SELopt value=transSeqQuery onClick=flip('legend','transSeqQuery')></td>
        <td>Entire translated region [Annotated gene only]</td>
      </tr>
    </table>
  </td>
</tr>
";
print "</table>\n";
print end_html;
