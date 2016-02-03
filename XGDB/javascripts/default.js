// Jquery scripts

//Binds the referenced functions to be executed whenever the DOM is ready to be traversed and manipulated.
$(document).ready(function() {
 showHide();
 stripeTable();
 tableSorter();
 refreshPage();
});
  
// Show/hide a div
function showHide() {
  $('div.showhide> div').hide();
  $('div.showhide> p').click(function() {
	$(this).next().slideToggle('slow');
  });
};


/*for striping tables other than tablesort*/
function stripeTable() {
  $('table.striped tbody tr:odd').addClass('odd');
  $('table.striped tbody tr:even').addClass('even');
   $('table.striped tr').mouseover(
    function () {
 $('table.striped tr').removeClass('highlight');
 $(this).addClass('highlight');
 });
};

/*sortable table columns using jquery.tablesorter.js. Added highlight function from stripeTable*/
function tableSorter() {
	//alert("table sorter");
//$("#myTable").tablesorter( { widgets: ['zebra']} ); /*sortList: [[0,0], [1,0]],*/
	$("#myTable").tablesorter({headers:{0:{sorter:false}}});
$('#myTable tr').mouseover(
    function () {
 $('#myTable tr').removeClass('highlight');
 $(this).addClass('highlight');
 });
};

function refreshPage(){
	$('.refresh').click(function() {
		location.reload();
	});
};


// #### JQuery based function to support video launch in a dialog window; it passes movieid as cgi parameter

//NOTE: the scripts below should be synchronized with default_xgdb.js

$(function() {
        $('#video_dialog').dialog({bgiframe:true,autoOpen:false,height:600,width:800,modal:true});
});

$(function() {
        $('.video-button').css('cursor','pointer');
        $('.video-button').attr('src', '/images/qtvideo.png');
        $('.video-button').mouseover(function(){ this.src =  '/images/qtvideo_hover.png'; });
        $('.video-button').mouseout(function(){ this.src = '/images/qtvideo.png'; });
        $('.video-button').click(function(event) {
                $.get('/XGDB/help/av/movie.php',
                        { 'movieid[]': [this.id, this.title] },
                        function(html) {
                                $('#video_dialog').html(html);
                        }
                );
                $('#video_dialog').dialog('open');
        });
});

//For video, hosted  on  YouTube
$(function() {
        $('.ytvideo-button').css('cursor','pointer');
        $('.ytvideo-button').attr('src', '/images/flvideo.png');
        $('.ytvideo-button').mouseover(function(){ this.src =  '/images/ytvideo_hover.png'; });
        $('.ytvideo-button').mouseout(function(){ this.src = '/images/ytvideo.png'; });
        $('.ytvideo-button').click(function(event) {
                $.get('/XGDB/phplib/ytmovie.php',
                        { 'movieid[]': [this.name, this.title] },
                        function(html) {
                                $('#video_dialog').html(html);
                        }
                );
                $('#video_dialog').dialog('open');
        });
});


//For FLASH video, hosted  on  vimeo
$(function() {
        $('.flvideo-button').css('cursor','pointer');
        $('.flvideo-button').attr('src', '/images/flvideo.png');
        $('.flvideo-button').mouseover(function(){ this.src =  '/images/flvideo_hover.png'; });
        $('.flvideo-button').mouseout(function(){ this.src = '/images/flvideo.png'; });
        $('.flvideo-button').click(function(event) {
                $.get('/XGDB/phplib/flmovie.php',
                        { 'movieid[]': [this.name, this.title] },
                        function(html) {
                                $('#video_dialog').html(html);
                        }
                );
                $('#video_dialog').dialog('open');
        });
});

//For help images e.g. track color codes that appear as a dialog box. See css style a.image_dialog_link for anchor and hover styling.
$(function() {
        $('.image-button').css('cursor','pointer');
        $('.image-button').click(function(event) {
                $.get('/XGDB/phplib/help_image.php',
                        { 'imageid[]': [this.id, this.title] },
                        function(html) {
                                $('#image_dialog').html(html);
                        }
                );
                $('#image_dialog').dialog('open');
        });
        $('#image_dialog').dialog({bgiframe:true,autoOpen:false,height:640,width:480,modal:true});
});

// #### id-based JQuery function to support a context-sensitive help system where context provides the filename and title for an include file. A similar system is in place for XGDB help (see /XGDB/javascripts/default_xgdb.js)

$(function() {
        $('.help-button').css('cursor','help');
        $('.help-button').attr('src', '/XGDB/images/help-icon.png');
        $('.help-button').mouseover(function(){ this.src = '/XGDB/images/help-icon_hover.png'; });
        $('.help-button').mouseout(function(){ this.src = '/XGDB/images/help-icon.png'; });
        $('.help-button').click(function(event) {
                $.get(  '/XGDB/phplib/xGDB_help.php',
                        { 'context[]': [this.id, this.title] },
                        function(html) {
                                $('#help_dialog').html(html);
                        }
                );
                $('#help_dialog').dialog('open');
        });
        $('#help_dialog').dialog({bgiframe:true,autoOpen:false,width:600,height:600,modal:false});
});


// #### name-based JQuery function to support a context-sensitive help system where context provides the filename and title for an include file. A similar system is in place for XGDB help (see /XGDB/javascripts/default_xgdb.js)

$(function() {
        $('.help-button2').css('cursor','help');
        $('.help-button2').attr('src', '/XGDB/images/help-icon.png');
        $('.help-button2').mouseover(function(){ this.src = '/XGDB/images/help-icon_hover.png'; });
        $('.help-button2').mouseout(function(){ this.src = '/XGDB/images/help-icon.png'; });
        $('.help-button2').click(function(event) {
                $.get(  '/XGDB/phplib/xGDB_help.php',
                        { 'context[]': [this.name, this.title] },
                        function(html) {
                                $('#help_dialog').html(html);
                        }
                );
                $('#help_dialog').dialog('open');
        });
        $('#help_dialog').dialog({bgiframe:true,autoOpen:false,width:600,height:600,modal:false});
});


// ### This script loads a specified logfile in a Jquery UI dialog window. In your html code, create an image or anchor element with class='logfile-button', ID=[logfile name] (minus the '.log'), and title= [GDBnnn]. 
// ### The corresponding logfile should be placed in the directory path specified by the php script referenced below.
$(function() {
        $('.logfile-button').css('cursor','help');
        $('.logfile-button').attr('src', '/XGDB/images/logfile-icon.png');
        $('.logfile-button').mouseover(function(){ this.src = '/XGDB/images/logfile-icon_hover.png'; });
        $('.logfile-button').mouseout(function(){ this.src = '/XGDB/images/logfile-icon.png'; });
        $('.logfile-button').click(function(event) {
                $.get(  '/XGDB/phplib/xGDB_logfile.php',
                        { 'context[]': [this.id, this.title] },
                        function(html) {
                                $('#logfile_dialog').html(html);
                        }
                );
                $('#logfile_dialog').dialog('open');
        });
        $('#logfile_dialog').dialog({bgiframe:true,autoOpen:false,height:500,width:800,modal:true});
});
        

// ### This script loads data about a fasta file in a Jquery UI dialog window. In your html code, create an image or anchor element with class='validatefile-button' 
// ### The corresponding file should be placed in the directory path specified by the php script referenced below.
$(function() {
        $('.validatefile-button').css('cursor','help');
        $('.validatefile-button').attr('src', '/XGDB/images/information.png');
//        $('.validatefile-button').mouseover(function(){ this.src = '/XGDB/images/validatefile-icon_hover.png'; });
//        $('.validatefile-button').mouseout(function(){ this.src = '/XGDB/images/validatefile-icon.png'; });
        $('.validatefile-button').click(function(event) {
         $('#validatefile_dialog').html("<h2>Analyzing file contents - please be patient!</h2><h3>(For large files, this can take up to a minute or more)</h3><div id=\"wrapper\" style=\"width:100%; text-align:center\"><img src=\"/XGDB/images/DNA_small.gif\" /></div>"); 
                $.get(  '/XGDB/phplib/xGDB_validatefile.php',
                        { 'context[]': [this.id, this.title] },
                        function(html) {
                                $('#validatefile_dialog').html(html);
                        }
                );
                $('#validatefile_dialog').dialog('open');
        });
        $('#validatefile_dialog').dialog({bgiframe:true,autoOpen:false,height:700,width:800,modal:true});
});

// ### This script loads status history about a remote job in a Jquery UI dialog window. In your html code, create an image or anchor element with class='validatefile-button', name=[Admin.jobs uid]. 
// ### The corresponding file should be placed in the directory path specified by the php script referenced below.
$(function() {
        $('.job_status-button').css('cursor','help');
        $('.job_status-button').attr('src', '/XGDB/images/information.png');
        $('.job_status-button').click(function(event) {
         $('#job_status_dialog').html("<h2>Status History</h2><div id=\"wrapper\" style=\"width:100%; text-align:center\"><img src=\"/XGDB/images/DNA_small.gif\" /></div>"); 
                $.get(  '/XGDB/phplib/xGDB_job_status.php',
                        { 'context[]': [this.id] },
                        function(html) {
                                $('#job_status_dialog').html(html);
                        }
                );
                $('#job_status_dialog').dialog('open');
        });
        $('#job_status_dialog').dialog({bgiframe:true,autoOpen:false,height:700,width:800,modal:true});
});
