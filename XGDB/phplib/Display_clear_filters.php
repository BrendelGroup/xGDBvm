<?php  // This script is called by one of several php scripts when user wants to clear search filters which are stored as session variables
// arguments: table dbid n index redirect
$table_core=htmlspecialchars($_GET['table']); // unique dataset identifier, e.g. pep gene put pep2 cpgat_gene
$dbid=htmlspecialchars($_GET['dbid']); // e.g. GDB001
$n=($_GET['n']); //number of independent queries configured- used to build session ID
$index=htmlspecialchars($_GET['index']); //track array index from SITEDEF.php. We use it here to build a redirect URL; Examples: track=0 for PEP[0] or (more compex) track=EST-0 for EST[0]
$redirect=htmlspecialchars($_GET['redirect']); //e.g. Loci; Proteins; Transcripts
if($redirect=="Loci"){$name="DisplayLoci.php";}
elseif($redirect=="Proteins"){$name="DisplayProteins.php";}
elseif($redirect=="Transcripts"){$name="DisplayTranscripts.php";}
else{$name="DisplayLoci.php";}
session_start();

if($n<10 && $n>0 && isset($_GET['table']) && isset($_GET['dbid']) && isset($_GET['n']) & isset($_GET['index']) )
{
   $session_core="${table_core}${dbid}";
   $i=1;
   while($i<=$n) //unset each possible query session variable for that table
   {  
	   $s_passed="${session_core}passed${i}";
	   unset ($_SESSION[$s_passed]);
	   $s_field="${session_core}field${i}";
	   unset ($_SESSION[$s_field]);
	   $s_word="${session_core}word${i}";
	   unset ($_SESSION[$s_word]);
	   $s_link="${session_core}link${i}";
	   unset ($_SESSION[$s_link]);  $i++;
   }
   $s_query="${session_core}query"; 
   unset ($_SESSION[$s_query]); // this is the entire query string (not sure it's necessary to unset since it's rebuilt dynamically)
   header("Location: $name?GDB=${dbid}&track=${index}");
}
else
{
echo "Error";
}
?>

/* examples
$gene_table.${DBid}passed${i}
putGDB007passed1
put2GDB007field1
transGDB007word1
*/