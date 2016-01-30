#!/usr/bin/perl

require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

$Oseq = (param('Oseq'))? param('Oseq') : param('OriginalGenomeSequence');
$GenomeEdits = ( param('GenomeEdits') ) ? param('GenomeEdits') : param('GSeqEdits') ;
$NewEdit = param('NewEdit');
$start = param('start');

@editsArr = split /\n/, $GenomeEdits;
%edits = %editStr = ();
$htmlEdit = "";
for ($i=0;$i<scalar(@editsArr);$i++){
    @att = split /\,/, $editsArr[$i];
    $edits{$att[0]} = $att[1];
    ($editStr{$att[0]}) = $att[2] =~ /(\w+)/;
    $htmlEdit .= ($att[1] eq "c") ? "change to $att[2] at bp $att[0]" : ($att[1] eq "d") ? " deletion at bp $att[0]" : " insertion of $att[2] at bp $att[0]";
    $htmlEdit .= "\t <a href=''>delete</a><br>";
    $htmlEdit2 .= $editsArr[$i];
}



$GenomeEdits = "";

# make edit table
sub bykey{ $a <=> $b}

$editTable = "<table border='1'><tr><th>Type of Edit</th><th>bp Position</th><th>New Base(s)</th></tr>";
for my $k (sort bykey keys %edits){
    $GenomeEdits .= ( ($GenomeEdits eq "") ? "" : "\n")."$k,$edits{$k},$editStr{$k}";

    $editTable .= "<tr><td>";
    $editTable .= ($edits{$k} eq "change") ? "change" : ($edits{$k} eq "delete") ? "deletion" : "insertion";
    $editTable .= "</td><td>$k</td><td>";
    $editTable .= ($edits{$k} ne "d" ) ? ($edits{$k} ne "c" ) ? "<input type=text name='$k,$edits{$k}' value='$editStr{$k}' onChange='changeEdit();'>" :"<input type='text' name='$k,$edits{$k}' value='$editStr{$k}' onChange='changeEdit();' size='1' maxlength='1'>" :"<input type='hidden' name='$k,d'>";
    $editTable .= "</td><td><a href='javascript:deleteEdit($k);'>remove edit</a></td></tr>";
}
$editTable .= "<tr><td><select name='ET'><option value='delete'>deletion</option><option value='change'>change</option><option value='insert'>insertion</option></select></td><td><input type='text' name='EBP'></td><td><input type='text' name='ES'></td><td><input type='button' onclick='addEdit();' value='Add New Edit'</td></tr>";
$editTable .= "</table";



## create alignment from GenomeEdits and links to change
@base = $Oseq =~ /./g;
$Nseq = "";


$Nstr = $NseqF = $Gstr = "<span class='bp'>$base[0]</span>";
$Gstr = "$base[0]";
$Sstr = "<table cellspacing='0' cellpadding='0' border='0' class='bp'><tr><td class='bp'>&nbsp;</td>";
$GbaseCount = $start+1; # first base cannot be edited
for (my $i=1;$i<scalar(@base);$i++){ # first base cannot be edited
    $scaleF = $i + $start;
  $scaleF =~ s/(\d)/$1 /g;
  $Sstr .= (! ( ($i+1)%10) ) ? "<td>$scaleF</td>" : "<td>&nbsp;</td>";



  if($edits{$i+$start} eq "change"){
    $Gstr .= "$base[$i]";
    $Nstr .= "<a id='bp$GbaseCount' !href='javascript:eB($GbaseCount);'><span style='color:red'>$editStr{$i+$start}</span></a>";
    $NseqF .= "$editStr{$i}";
    $GbaseCount++;
  }elsif ($edits{$i+$start} eq "delete"){
    $Gstr .= "$base[$i]";
    $Nstr .= "<a id='bp$GbaseCount' !href='javascript:eB($GbaseCount);'><span style='color:red'>-</span></a>";
    $GbaseCount++;
  }else{

    $Gstr .= $base[$i];
    $Nstr .= "<a id='bp$GbaseCount' href='javascript:eB($GbaseCount);'>$base[$i]</a>";
    $NseqF .= "$base[$i]";
    $GbaseCount++;
  }
  if($edits{$i+$start} eq "insert"){

    $Gstr .= ( "-" x length($editStr{$i+$start}) );
    $Nstr .= "<a !id='bpI".($GbaseCount-1)."' !href='javascript:eB($GbaseCount-1);'><span style='color:red'>$editStr{$i+$start}</span></a>";
    $NseqF .= $editStr{$i};
    $Sstr .= "<td>".("&nbsp;" x length($editStr{$i+$start}))."<\/td>";
  }
}
$Sstr .= "</tr></table>";

## fix for disappearing long strings in browser
if (length($Gstr) > 3000){
    my $fGstr;
    my $i;
    for ($i=0;$i<length($Gstr)/3000;$i=$i+3000){
	$fGstr .= "<span class='bp'>".substr($Gstr,$i,$i+3000)."</span>";
    }
    $fGstr .= "<span class='bp'>".substr($Gstr,$i)."</span>";
    $Gstr = $fGstr;
}



my $header = printTitle("Sequence Editor",1);

my $page =<<END_OF_PAGE;

<html>
<head>
<script type='text/javascript'>

var lastclickedNum = "";
function eB(num){
//  alert(num);
  document.forms.GenomeEditfrm.EBP.value = num;
  if (lastclickedNum != ""){
    document.getElementById("bp" + lastclickedNum).style.background = 'white';
    if (document.getElementById("bpI" + lastclickedNum)){
      document.getElementById("bpI" + lastclickedNum).style.background = 'white';
    }
  }
  document.getElementById("bp" + num).style.background = 'yellow';
  if (document.getElementById("bpI" + num)){
    document.getElementById("bpI" + num).style.background = 'yellow';
  }


lastclickedNum = num;
}

function addBase(bp){
  var NAstr = prompt("Enter the base(s) you would like to add at position "+ bp + ".");
}

function addEdit(){
   var NewEditType = document.forms.GenomeEditfrm.ET.options[document.forms.GenomeEditfrm.ET.selectedIndex].value;
   var NewEditStr = document.forms.GenomeEditfrm.ES.value;
    if (document.forms.GenomeEditfrm.EBP.value == ""){
	alert("Please specify a basepair location for this edit.\\nYou can click on a base in the edited sequence to select a location or you may type it in.");
	return;
    }
   for (i=0;i<document.GenomeEditfrm.length;i++){
       tArr = document.GenomeEditfrm.elements[i].name.split(",");
       if (tArr[0] == document.forms.GenomeEditfrm.EBP.value){
	   alert("You already have an edit at bp" + document.forms.GenomeEditfrm.EBP.value + " please remove this edit before adding a new one at this location.");
	   return;
       }
   }
   if (((NewEditType == "insert") || (NewEditType == "c"))&&(NewEditStr == "")){
       alert("Please specify new base(s) for this edit");
       return;
   }
   if ((NewEditType == "change")&&(NewEditStr.length > 1)){
       alert("'Change' edits are for one base at a time.\\nReduce your New Base entry to one base or choose 'Insertion' edit.");
       return;
   }
   if (NewEditType == "delete"){
       document.forms.GenomeEditfrm.ES.value = "";
   }

    newE =  document.forms.GenomeEditfrm.EBP.value + "," + NewEditType + "," + document.forms.GenomeEditfrm.ES.value;
    document.forms.GenomeEditfrm.GenomeEdits.value = (document.forms.GenomeEditfrm.GenomeEdits.value) ? document.forms.GenomeEditfrm.GenomeEdits.value + "\\n" + newE : newE;
    document.forms.GenomeEditfrm.submit();
}

function changeEdit(){
   newS = "";
   for (i=0;i<document.GenomeEditfrm.length;i++){
       if (document.GenomeEditfrm.elements[i].name.match(",")){
        if (document.GenomeEditfrm.elements[i].name.match(",delete")){
            newS = ( (newS == "") ? "" : newS + "\\n") + document.GenomeEditfrm.elements[i].name + ",";
        }else{
	  if (document.GenomeEditfrm.elements[i].value == ""){
	      alert("To remove an annotation, click 'remove edit'");
	      document.forms.GenomeEditfrm.submit();
	      return;
	  }
              newS = ((newS == "") ? "" : newS + "\\n") + document.GenomeEditfrm.elements[i].name + "," + document.GenomeEditfrm.elements[i].value;

        }
       }
   }
   document.forms.GenomeEditfrm.GenomeEdits.value = newS;
   document.forms.GenomeEditfrm.submit();
}

function deleteEdit(num){

    var dP = new RegExp(dR);
    //alert(document.forms.GenomeEditfrm.GenomeEdits.value.match(dP));
    if (!document.forms.GenomeEditfrm.GenomeEdits.value.match(dP)){
      var dR = num + ".+?\\n";
      var dP = new RegExp(dR);
    }
    if(document.forms.GenomeEditfrm.GenomeEdits.value.match(dP)){
      document.forms.GenomeEditfrm.GenomeEdits.value = document.forms.GenomeEditfrm.GenomeEdits.value.replace(dP,"");
    }else{
      dR = num + ".+";
      dP = new RegExp(dR); 
      document.forms.GenomeEditfrm.GenomeEdits.value = document.forms.GenomeEditfrm.GenomeEdits.value.replace(dP,"");
    }
    document.forms.GenomeEditfrm.submit();
}

function addEdits(){
    opener.addGenomeEdits(document.forms["GenomeEditfrm"].GenomeEdits.value);
}

</script>
<style type='text/css'>
    .bp {font-family:Courier;font-size:14px;color:black;}
    .bp a{text-decoration:none;color:black}
    .main {font-family:arial;font-size:12px;color:black}
</style>
<title>yrGATE: Sequence Editor</title>
</head>


<body class="main">


$header
<form name='GenomeEditfrm' method='post'>

<br><br><br>
<table class="main">
<tr><td valign='top' width='200'>
Scale of Database Genome Sequence<br><br><br>
Database Genome Sequence<br><br>
Your Edited Genome Sequence<br>
</td>
<td>
<div style="overflow:auto;height:250px;width:500px;position:relative;">
<table>
<tr><td class='bp'>
$Sstr
</td></tr><tr><td height='30' class='bp'>
$Gstr
</td></tr><tr><td height='30' class='bp'>
$Nstr
</td></tr></table>
</div>
</td>
</tr>
</table>
<br>
<br>
$editTable
<pre>
</pre>
<input style='background:yellow' type='button' value="Add Edits to Annotation Record" onclick="addEdits();">
<br><br>
<input type='button' value="Close Sequence Editor" onclick="window.close();">
<input type='hidden' name="Oseq" value="$Oseq">
<textarea style='visibility:hidden' name="GenomeEdits" id="GenomeEdits" rows='5' cols='20'>$GenomeEdits</textarea>
<input type='hidden' name="start" value="$start">


</form>
</body>
</html>
END_OF_PAGE

print header();
print $page;
