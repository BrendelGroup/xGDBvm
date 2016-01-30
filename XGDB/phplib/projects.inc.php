						<?php
						//Get all projects
							$project_query ="SELECT distinct a.db_name, a.project, a.description, a.source FROM ".$DBid.".projects AS a JOIN ".$DBid.".gdb_projects AS b ON a.uid=b.project_uid WHERE a.db_name='".$GDB."' ORDER BY a.project";
							$get_projects = $project_query;
							$check_get_projects = mysql_query($get_projects);
							
							$project_table = "<div style=\"padding:25px\" ><div><h2>Query</h2><p>".$project_query."</p></div><table class=\"featuretable highlight normalheading\" >
							<col width=\"10%\" />
							<col width=\"30%\" />
							<col width=\"30%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<col width=\"3%\" />
							<thead>
								<tr style=\"border:1px solid #CCC\">
									<th rowspan=\"2\" title=\"Project Name\" align=\"center\">Project Name  <br /></th>
									<th rowspan=\"2\" title=\"Description\" align=\"center\">Description</th>
									<th rowspan=\"2\" title=\"Click to view source\" align=\"center\">Source</th>
									<th rowspan=\"2\" style=\"text-align: center\">Total <br /> Loci*<br /></th>
									<th rowspan=\"2\" style=\"text-align: center\">Low<br />Quality<br />Loci*&nbsp;<img style=\"margin-top:0.5em\" id=\"displayprojects_low_q\" title=\"Click for explanation\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" class=\"xgdb-help-button\" /></th>
									<th rowspan=\"2\" style=\"text-align: center\">Loci <br /> with<br /> annota-<br />tions*</th>
									<th style=\"text-align: center\" colspan=\"9\">Annotations in CommunityCentral&nbsp;<img style=\"margin-top:0.5em\" id=\"displayloci_annoclass\" title=\"Click for explanation\" src=\"/XGDB/images/help-icon.png\" alt=\"?\" class=\"xgdb-help-button\" /></th>
								</tr>
								<tr>
									<th style=\"text-align: center; background-color:#EEE; color: #175A7F\">Total</th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"confirm annotation\" src=\"/XGDB/images/confirm.gif\" alt=\"conf\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"extend or trim annotation\" src=\"/XGDB/images/extend.gif\" alt=\"ext\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"improve annotation\" src=\"/XGDB/images/improve.gif\" alt=\"impr\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"add new variant annotation\" src=\"/XGDB/images/add.gif\" alt=\"var\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"annotate new locus\" src=\"/XGDB/images/newlocus.gif\" alt=\"new\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"recommend delete annotation\" src=\"/XGDB/images/delete.gif\" alt=\"del\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"structure problem not resolved\" src=\"/XGDB/images/notresolv.gif\" alt=\"notres\" /></th>
									<th style=\"text-align: center; background-color:#EEE\"><img title=\"genome sequence edit(s) applied\" src=\"/XGDB/images/edit.gif\" alt=\"edit\" /></th>
								</tr>
								</thead>
							<tbody>
							";
							while ($data_array = mysql_fetch_array($check_get_projects)) // for each project
							{
							//pull data from DB to correspond with headers
								$db_name = $data_array['db_name'];
								$project = $data_array['project'];
								$project_string=preg_replace('/\s/', '_', $project);
								$project_display = "<a href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=".$project_string."\">".$project."</a>";
								$description = $data_array['description'];
								$source = $data_array['source'];
								$source_display =  preg_match('/(.*)(http.*)([\S,.*\$])?/', $source, $matches) ? $matches[1]."<a href=\"".$matches[2]."\">".$matches[2]."</a>".$matches[3] : $source;
								$proj_total_query="SELECT DISTINCT a.locus_id FROM ".$DBtable." as a LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE c.project_name='".$project."'";								
								$get_proj_total = $proj_total_query;
								$check_get_proj_total = mysql_query($get_proj_total);
								$entries_proj = mysql_num_rows($check_get_proj_total);
								$entries_proj_display = "<a title=\"click to view all loci in this Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=".$project_string."\">".$entries_proj."</a>";
							//Total low quality projects
								$lq_proj_total_query="SELECT DISTINCT a.locus_id FROM ".$DBtable." as a LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE a.coverage>.75 AND a.integrity<.75  AND c.project_name='".$project."'";								
								$get_lq_proj_total = $lq_proj_total_query;
								$check_get_lq_proj_total = mysql_query($get_lq_proj_total);
								$entries_lq_proj = mysql_num_rows($check_get_lq_proj_total);
								$entries_lq_proj_display = "<a style=\"color:#D8526B\" title=\"click to view low quality loci in this Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=".$project_string."&amp;coverage=gt.75&amp;integrity=lt.75\">".$entries_lq_proj."</a>";
							//Total loci annotated
								$loci_total_query="SELECT DISTINCT a.locus_id FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' and (c.project_name='".$project."' or b.category='".$project."') AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW')";								
								$get_loci_total = $loci_total_query;
								$check_get_loci_total = mysql_query($get_loci_total);
								$entries_loci = mysql_num_rows($check_get_loci_total);
								$entries_loci_display = "<a title=\"click to view re-annotated loci in this Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=".$project_string."&amp;status=all\">".$entries_loci."</a>";
							//Total annotations
								//$anno_total_query="SELECT b.annotation_class FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' and (c.project_name='".$project."' or b.category='".$project."') AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW')";								
								$anno_total_query="SELECT geneId from ".$DBid.".user_gene_annotation where dbName='".$DBid."GDB' AND dbVer='".$myDBver."' and category='".$project."' AND (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW') AND 1";
								$get_anno_total = $anno_total_query;
								$check_get_anno_total = mysql_query($get_anno_total);
								$entries_anno = mysql_num_rows($check_get_anno_total);
								$entries_anno_display = "<a title=\"click to view yrGATE annotations for this Project\" href=\"/yrGATE/".$DBid."/CommunityCentral.pl?db_ver=".$myDBver."&amp;search_field=category&amp;search_term=".$project_string."\">".$entries_anno."</a>";
							//confirm category
								$confirm_query=$anno_total_query." AND annotation_class='Confirm'";
								$get_confirm = $confirm_query;
								$check_get_confirm = mysql_query($get_confirm);
								$entries_confirm = mysql_num_rows($check_get_confirm);
							//extend category
								$extend_query=$anno_total_query." AND annotation_class='Extend or Trim'";
								$get_extend = $extend_query;
								$check_get_extend = mysql_query($get_extend);
								$entries_extend = mysql_num_rows($check_get_extend);
							//improve category
								$improve_query=$anno_total_query." AND annotation_class='Improve'";
								$get_improve = $improve_query;
								$check_get_improve = mysql_query($get_improve);
								$entries_improve = mysql_num_rows($check_get_improve);
							//variant category
								$variant_query=$anno_total_query." AND annotation_class='Variant'";
								$get_variant = $variant_query;
								$check_get_variant = mysql_query($get_variant);
								$entries_variant = mysql_num_rows($check_get_variant);								
							//new locus category
								$new_locus_query="SELECT annotation_class FROM ".$DBid.".user_gene_annotation WHERE dbName='".$DBid."GDB' AND dbVer='".$myDBver."' and category='".$project."' AND (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW') AND annotation_class='New Locus'";								
								$get_new_locus = $new_locus_query;
								$check_get_new_locus = mysql_query($get_new_locus);
								$entries_new_locus = mysql_num_rows($check_get_new_locus);
							//delete category
								$delete_query=$anno_total_query." AND annotation_class='Delete'";
								$get_delete = $delete_query;
								$check_get_delete = mysql_query($get_delete);
								$entries_delete = mysql_num_rows($check_get_delete);
							//not_resolv category
								$not_resolv_query=$anno_total_query." AND annotation_class='Not Resolved'";
								$get_not_resolv = $not_resolv_query;
								$check_get_not_resolv = mysql_query($get_not_resolv);
								$entries_not_resolv = mysql_num_rows($check_get_not_resolv);
							//dna_edits
								$dna_edits_query=$anno_total_query." AND GSeqEdits !=''";
								$get_dna_edits = $dna_edits_query;
								$check_get_dna_edits = mysql_query($get_dna_edits);
								$entries_dna_edits = mysql_num_rows($check_get_dna_edits);
							//Write table
								$project_table .= 
								"<tr>
									<td style=\"text-align: left\">$project_display </td>
									<td style=\"text-align: left\">$description $lq_proj_total_query</td>
									<td style=\"text-align: left\">$source_display</td>
									<td style=\"text-align: center; font-weight:bold;\">$entries_proj_display</td>
									<td style=\"text-align: center; font-weight:bold;\">$entries_lq_proj_display</td>
									<td style=\"text-align: center; font-weight:bold\">$entries_loci_display</td>
									<td style=\"text-align: center; font-weight:bold; background-color:#EEE\">$entries_anno_display</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$entries_confirm</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$entries_extend</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_improve</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_variant</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_new_locus</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$entries_delete</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$entries_not_resolv</td>
									<td style=\"text-align: center; background-color:#D1E9FF\">$entries_dna_edits</td>
								</tr>";
							}						
					//non-project data totals:
							//pull data from DB to correspond with headers
								$db_name = $data_array['db_name'];
								$project_display = "<i>Genes with no project assignment</i>";
								$description = "<span class=\"italic\">Loci can be associated with a project; see wiki for details</span>";
								$source_display =  "N/A";
							//Total loci with no project
								$proj_total_query="SELECT DISTINCT locus_id FROM ".$DBtable."  WHERE locus_id not in (SELECT DISTINCT a.locus_id FROM ".$DBtable." as a JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id)";								
								$get_proj_total = $proj_total_query;
								$check_get_proj_total = mysql_query($get_proj_total);
								$entries_proj = mysql_num_rows($check_get_proj_total);
								$entries_proj_display = "<a title=\"click to view all loci with no Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=no_project\">".$entries_proj."</a>";
							//Total low quality loci with no project
								$lq_proj_total_query="SELECT DISTINCT locus_id FROM ".$DBtable." WHERE coverage>.75 AND integrity<.75 AND locus_id not in (SELECT DISTINCT a.locus_id FROM ".$DBtable." as a JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id)";								
								$get_lq_proj_total = $lq_proj_total_query;
								$check_get_lq_proj_total = mysql_query($get_lq_proj_total);
								$entries_lq_proj = mysql_num_rows($check_get_lq_proj_total);
								$entries_lq_proj_display = "<a style=\"color:#D8526B\" title=\"click to view low quality loci with no Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=no_project&amp;coverage=gt.75&amp;integrity=lt.75\">".$entries_lq_proj."</a>";
							//Total loci annotated with no project
								$loci_total_query="SELECT DISTINCT a.locus_id FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW') AND a.locus_id not in (SELECT DISTINCT a.locus_id FROM ".$DBtable." as a JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id)";								
								$get_loci_total = $loci_total_query;
								$check_get_loci_total = mysql_query($get_loci_total);
								$entries_loci = mysql_num_rows($check_get_loci_total);
								$entries_loci_display = "<a title=\"click to view all annotations with no Project\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;project=no_project&amp;status=all\">".$entries_loci."</a>";
							//Total annotations with no project
								$anno_total_query="SELECT annotation_class from ".$DBid.".user_gene_annotation where dbName='".$DBid."GDB' AND dbVer='".$myDBver."' AND (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW') AND (category ='' or category='none')";
							//	$anno_total_query="SELECT b.annotation_class FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW') AND b.category =''";								
								$get_anno_total = $anno_total_query;
								$check_get_anno_total = mysql_query($get_anno_total);
								$entries_anno = mysql_num_rows($check_get_anno_total);
								$entries_anno_display = "<a title=\"click to view all yrGATE annotations with no Project\" href=\"/yrGATE/".$DBid."GDB/CommunityCentral.pl?db_ver=".$myDBver."\">".$entries_anno."</a>";
							//confirm category
								$confirm_query=$anno_total_query." AND annotation_class='Confirm'";
								$get_confirm = $confirm_query;
								$check_get_confirm = mysql_query($get_confirm);
								$entries_confirm = mysql_num_rows($check_get_confirm);
							//extend category
								$extend_query=$anno_total_query." AND annotation_class='Extend or Trim'";
								$get_extend = $extend_query;
								$check_get_extend = mysql_query($get_extend);
								$entries_extend = mysql_num_rows($check_get_extend);
							//improve category
								$improve_query=$anno_total_query." AND annotation_class='Improve'";
								$get_improve = $improve_query;
								$check_get_improve = mysql_query($get_improve);
								$entries_improve = mysql_num_rows($check_get_improve);
							//variant category
								$variant_query=$anno_total_query." AND annotation_class='Variant'";
								$get_variant = $variant_query;
								$check_get_variant = mysql_query($get_variant);
								$entries_variant = mysql_num_rows($check_get_variant);								
							//new locus category
								$new_locus_query="SELECT annotation_class FROM ".$DBid.".user_gene_annotation WHERE dbName='".$DBid."GDB' AND dbVer='".$myDBver."' and category='".$project."' AND (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW') AND annotation_class='New Locus' AND (category ='' or category='none')";								
								$get_new_locus = $new_locus_query;
								$check_get_new_locus = mysql_query($get_new_locus);
								$entries_new_locus = mysql_num_rows($check_get_new_locus);
							//delete category
								$delete_query=$anno_total_query." AND annotation_class='Delete'";
								$get_delete = $delete_query;
								$check_get_delete = mysql_query($get_delete);
								$entries_delete = mysql_num_rows($check_get_delete);
							//not_resolv category
								$not_resolv_query=$anno_total_query." AND annotation_class='Not Resolved'";
								$get_not_resolv = $not_resolv_query;
								$check_get_not_resolv = mysql_query($get_not_resolv);
								$entries_not_resolv = mysql_num_rows($check_get_not_resolv);
							//dna_edits
								$dna_edits_query=$anno_total_query." AND GSeqEdits !=''";
								$get_dna_edits = $dna_edits_query;
								$check_get_dna_edits = mysql_query($get_dna_edits);
								$entries_dna_edits = mysql_num_rows($check_get_dna_edits);
	
								$project_table .= 
								"<tr>
									<td style=\"text-align: left\">$project_display$</td>
									<td style=\"text-align: left\">$description</td>
									<td style=\"text-align: left\">$source_display</td>
									<td style=\"text-align: center; font-weight:bold\">$entries_proj_display</td>
									<td style=\"text-align: center; font-weight:bold\">$entries_lq_proj_display</td>
									<td style=\"text-align: center; font-weight:bold\">$entries_loci_display</td>
									<td style=\"text-align: center; font-weight:bold; background-color:#EEE\">$entries_anno_display</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$entries_confirm</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$entries_extend</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_improve</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_variant</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$entries_new_locus</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$entries_delete</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$entries_not_resolv</td>
									<td style=\"text-align: center; background-color:#D1E9FF\">$entries_dna_edits</td>
								</tr>";

				//ALL data totals:
							//pull data from DB to correspond with headers
								$db_name = $data_array['db_name'];
								$project_display = "TOTALS*";
								$description = "All loci / annotations";
								$source_display =  "N/A";
							//All loci
								$all_loci_query="SELECT DISTINCT locus_id FROM ".$DBtable." ";								
								$get_all_loci = $all_loci_query;
								$check_get_all_loci = mysql_query($get_all_loci);
								$all_entries_loci = mysql_num_rows($check_get_all_loci);
								$all_entries_loci_display = "<a title=\"click to view all loci\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;destroy=true\">".$all_entries_loci."</a>";
							//All low quality loci
								$all_lq_loci_query="SELECT DISTINCT locus_id FROM ".$DBtable." WHERE coverage>.75 AND integrity<.75";								
								$get_all_lq_loci = $all_lq_loci_query;
								$check_get_all_lq_loci = mysql_query($get_all_lq_loci);
								$all_entries_lq_loci = mysql_num_rows($check_get_all_lq_loci);
								$all_entries_lq_loci_display = "<a style=\"color:#D8526B\" title=\"click to view low quality loci\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;coverage=gt.75&amp;integrity=lt.75\">".$all_entries_lq_loci."</a>";
							//All loci annotated
								$all_anno_loci_query="SELECT DISTINCT a.locus_id FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW')";								
								$get_all_anno_loci = $all_anno_loci_query;
								$check_get_all_anno_loci = mysql_query($get_all_anno_loci);
								$all_entries_anno_loci = mysql_num_rows($check_get_all_anno_loci);
								$all_entries_anno_loci_display = "<a title=\"click to view all loci annotated\" href=\"/XGDB/phplib/DisplayLoci.php?source=".$Source."&amp;GDB=".$DBid."&amp;status=all\">".$all_entries_anno_loci."</a>";
							//All annotations
  								$all_anno_query="SELECT annotation_class from ".$DBid.".user_gene_annotation where dbName='".$DBid."GDB' AND dbVer='".$myDBver."' AND (status='ACCEPTED' or status='SUBMITTED_FOR_REVIEW')";
							//	$all_anno_query="SELECT distinct b.geneId FROM ".$DBtable." AS a LEFT JOIN ".$DBid.".user_gene_annotation AS b ON a.locus_id=b.locusId LEFT JOIN ".$DBid.".gdb_projects AS c ON c.locus_id=a.locus_id WHERE b.dbName='".$DBid."GDB' AND b.dbVer='".$myDBver."' AND (b.status='ACCEPTED' or b.status='SUBMITTED_FOR_REVIEW')";								
								$get_all_anno = $all_anno_query;
								$check_get_all_anno = mysql_query($get_all_anno);
								$all_entries_anno = mysql_num_rows($check_get_all_anno);
								$all_entries_anno_display = "<a title=\"click to view all yrGATE annotations\" href=\"/yrGATE/".$DBid."GDB/CommunityCentral.pl?db_ver=".$myDBver."\">".$all_entries_anno."</a>";
							//all confirm category
								$all_confirm_query=$all_anno_query." AND annotation_class='Confirm'";
								$get_all_confirm = $all_confirm_query;
								$check_get_all_confirm = mysql_query($get_all_confirm);
								$all_entries_confirm = mysql_num_rows($check_get_all_confirm);
							//all extend category
								$all_extend_query=$all_anno_query." AND annotation_class='Extend or Trim'";
								$get_all_extend = $all_extend_query;
								$check_get_all_extend = mysql_query($get_all_extend);
								$all_entries_extend = mysql_num_rows($check_get_all_extend);
							//all improve category
								$all_improve_query=$all_anno_query." AND annotation_class='Improve'";
								$get_all_improve = $all_improve_query;
								$check_get_all_improve = mysql_query($get_all_improve);
								$all_entries_improve = mysql_num_rows($check_get_all_improve);
							//all variant category
								$all_variant_query=$all_anno_query." AND annotation_class='Variant'";
								$get_all_variant = $all_variant_query;
								$check_get_all_variant = mysql_query($get_all_variant);
								$all_entries_variant = mysql_num_rows($check_get_all_variant);								
							//all new locus category
								$all_new_locus_query=$all_anno_query." AND annotation_class='New Locus'";
								$get_all_new_locus = $all_new_locus_query;
								$check_get_all_new_locus = mysql_query($get_all_new_locus);
								$all_entries_new_locus = mysql_num_rows($check_get_all_new_locus);
							//delete category
								$all_delete_query=$all_anno_query." AND annotation_class='Delete'";
								$get_all_delete = $all_delete_query;
								$check_get_all_delete = mysql_query($get_all_delete);
								$all_entries_delete = mysql_num_rows($check_get_all_delete);
							//all not_resolv category
								$all_not_resolv_query=$all_anno_query." AND annotation_class='Not Resolved'";
								$get_all_not_resolv = $all_not_resolv_query;
								$check_get_all_not_resolv = mysql_query($get_all_not_resolv);
								$all_entries_not_resolv = mysql_num_rows($check_get_all_not_resolv);
							//all dna_edits
								$all_dna_edits_query=$all_anno_query." AND GSeqEdits !=''";
								$get_all_dna_edits = $all_dna_edits_query;
								$check_get_all_dna_edits = mysql_query($get_all_dna_edits);
								$all_entries_dna_edits = mysql_num_rows($check_get_all_dna_edits);
	
								$project_table .= 
								"<tr style=\"background-color: #CCC; border: 2px solid #AAA\">
									<td style=\"text-align: left\">$project_display</td>
									<td style=\"text-align: left\">$description $proj_total_query $lq_proj_total_query</td>
									<td style=\"text-align: left\">$source_display</td>
									<td style=\"text-align: center; font-weight:bold\">$all_entries_loci_display</td>
									<td style=\"text-align: center; font-weight:bold\">$all_entries_lq_loci_display</td>
									<td style=\"text-align: center; font-weight:bold\">$all_entries_anno_loci_display</td>
									<td style=\"text-align: center; font-weight:bold; background-color:#EEE\">$all_entries_anno_display</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$all_entries_confirm</td>
									<td style=\"text-align: center; background-color:#D6FFEB\">$all_entries_extend</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$all_entries_improve</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$all_entries_variant</td>
									<td style=\"text-align: center; background-color:#FAFFC6\">$all_entries_new_locus</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$all_entries_delete</td>
									<td style=\"text-align: center; background-color:#FFD3CE\">$all_entries_not_resolv</td>
									<td style=\"text-align: center; background-color:#D1E9FF\">$all_entries_dna_edits</td>
								</tr>";

								
								$project_table .= "</tbody></table></div>";
							
							echo $project_table;
							?>

