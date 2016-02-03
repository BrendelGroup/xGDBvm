<div class="dialogcontainer">
	<h2 class="bottommargin1">Datastore Not Connected</h2>
		 
<h3>Symptom: </h3>
<ul class="bullet1">
    <li>Data Volumes table (<i>Manage -> Configure/Create -> Data Volumes</i>) shows <br />"<span class="plaintext largerfont">Transport end point not connected</span>"</li>
    <li>Typing <span class="plaintext largerfont">$ df -kh</span> from the shell gives the same error message
</ul>

<h3>Probably cause</h3>
<ul class="bullet1">
    <li>Your Data Store may have become unconnected</li>
    <li>The Data Store itself may be encountering network problems.</li>
</ul>

<h3>Possible solutions</h3> 
<ul class="bullet1">
    <li>Try unmounting and then remounting your Data Store:
        <ul class="bullet1">
            <li>Log in to iPlant using <span class="plaintext largerfont">$ iinit</span> (as outlined in 0README-iPlant)
            </li>
            <li>Unmount using <span class="plaintext largerfont">$ sudo /usr/bin/fusermount -u -z /xGDBvm/data</span>
            </li>
            <li>Remount using <span class="plaintext largerfont">irodsFs /xGDBvm/data -o max_readahead=0 -o allow_other -o nonempty</span></li>
            </ul>
        </li>
    <li>.
</ul>

			<span class="heading normalfont linkback"> <a class="smallerfont" href="/XGDB/help/troubleshoot.php#trouble_datastore_disconnected">View this in Help Context</a> (troubleshoot.php/trouble_datastore_disconnected)</span>
</div>


