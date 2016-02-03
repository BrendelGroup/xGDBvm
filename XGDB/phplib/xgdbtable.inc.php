<table id="GenomeBrowsers" class="featuretable smallerfont striped topmargin1" summary="Description of xGDB Genome Browser features">
	<thead>
		<tr class="shade">
			<th scope="col">GDB</th>
			<th scope="col" width="145">Species</th>
			<th scope="col" width="60">Type</th>
			<th scope="col">Assembly</th>
			<th scope="col">GeneModels</th>
		</tr>
	</thead>
	<tbody>
	<?php // Modifying this section? See also /prj/GenomeBrowser/index.php and /help/xgdb.php
		foreach ($xGDB as $key=>$value) // GDBs alphabetized in /phplib/sitedef.php
		{
			$common_link_text = '<a title="Genome Database" href="/' . $key . '/">';
				$gdb_link_data = $common_link_text . $key . '</a>';
				$display_key = $key;?>
			<tr>
				<td><?php echo $gdb_link_data; ?></td>
				<td class="species"><?php echo $value ?></td>
				<td><?php echo $GDB_INFO[$key]['type'] ?></td>
				<td><a href="<?php echo $GDB_INFO[$key]['sourceURL'] ?>"><?php echo $GDB_INFO[$key]['Assembly'] ?></a></td>
				<td><a href="<?php echo $GDB_INFO[$key]['sourceURL'] ?>"><?php echo $GDB_INFO[$key]['GeneModel'] ?></a></td>
			</tr><?php
		} ?>
	</tbody>
</table>
