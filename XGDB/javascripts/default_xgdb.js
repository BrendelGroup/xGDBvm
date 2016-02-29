// Jquery scripts

//Binds the referenced functions to be executed whenever the DOM is ready to be traversed and manipulated.
$(document).ready(function() {
showHideRows1();
showHideRows2();
showHideRows3();
showHideRows4();
 showHide();
 stripeTable();
 //tableSorter();
 });
 
 //for CommunityCentral. to do: abstract class so only one function needed for 4 classes
  function showHideRows1() {
    $('tr.ACCEPTED').show();
  $('tr.catRowACCEPTED td').click(function(event) {
	$('tr.ACCEPTED').toggle();
  });
  };

  function showHideRows2() {
    $('tr.REJECTED').show();
  $('tr.catRowREJECTED td').click(function(event) {
	$('tr.REJECTED').toggle();
  });
  };

  function showHideRows3() {
    $('tr.SUBMITTED_FOR_REVIEW').show();
  $('tr.catRowSUBMITTED_FOR_REVIEW td').click(function(event) {
	$('tr.SUBMITTED_FOR_REVIEW').toggle();
  });
  };
 
   function showHideRows4() {
    $('tr.SAVED').show();
  $('tr.catRowSAVED td').click(function(event) {
	$('tr.SAVED').toggle();
  });
  };
 
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

//sortable table columns using jquery.tablesorter.js. Added highlight function from stripeTable.COMMENTED OUT - IT BREAKS XGDB SHOWHIDE
//function tableSorter() {
//$("#myTable").tablesorter( { widgets: ['zebra']} ); /*sortList: [[0,0], [1,0]],*/
//$('#myTable tr').mouseover(
//    function () {
// $('#myTable tr').removeClass('highlight');
// $(this).addClass('highlight');
// });
//};



// #### JQuery ui based function to support video launch in a dialog window. Launches a modal window using jquery ui dialog. At onclick, the tag id of the video-buttom image  (set to the name of the movie file or its id if hosted) is passed as a cgi variable to the driver script (e.g. movie.php), accessible via php $_GET  There are two scripts, one for quicktime and one for flash (hosted).

//NOTE: the scripts below should be synchronized with /Product/javascript/default.js

$(function() {
        $('#video_dialog').dialog({bgiframe:true,autoOpen:false,height:480,width:700,modal:true});
});


$(function() {
        $('.video-button').css('cursor','pointer');
        $('.video-button').attr('src', '/XGDB/images/video_blue35px.png');
        $('.video-button').mouseover(function(){ this.src =  '/XGDB/images/video_blue35px.png'; });
        $('.video-button').mouseout(function(){ this.src = '/XGDB/images/video_blue35px.png'; });
        $('.video-button').click(function(event) {
                $.get('/XGDB/help/av/movie.php',
                        { 'movieid[]': [this.name, this.title] },
                        function(html) {
                                $('#video_dialog').html(html);
                        }
                );
                $('#video_dialog').dialog('open');
        });
});

$(function() {
        $('.flvideo-button').css('cursor','pointer');
        $('.flvideo-button').attr('src', '/XGDB/images/video_blue35px.png');
        $('.flvideo-button').mouseover(function(){ this.src =  '/XGDB/images/video_blue35px.png'; });
        $('.flvideo-button').mouseout(function(){ this.src = '/XGDB/images/video_blue35px.png'; });
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

//Opens an image specified by the enclosing tag id and launched by /xGDBvm/XGDB/help/image.php. Image must have the same name as the id, plus the '.png' suffix, and must be stored in /xGDB m/XGDB/help/includes
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

// #### JQuery based function to support a context-sensitive help system where context provides the filename and title for an include file.
$(function() {
        $('.xgdb-help-button').css('cursor','help');
        $('.xgdb-help-button').attr('src', '/XGDB/images/help-icon.png');
        $('.xgdb-help-button').mouseover(function(){ this.src = '/XGDB/images/help-icon_hover.png'; });
        $('.xgdb-help-button').mouseout(function(){ this.src = '/XGDB/images/help-icon.png'; });
        $('.xgdb-help-button').click(function(event) {
                $.get('/XGDB/phplib/xGDB_help.php',
                        { 'context[]': [this.id, this.title] },
                        function(html) {
                                $('#help_dialog').html(html);
                        }
                );
                $('#help_dialog').dialog('open');
        });
        $('#help_dialog').dialog({bgiframe:true,autoOpen:false,height:640,width:640,modal:true});
});

 

// ### This script loads data about a fasta file in a Jquery UI dialog window. In your html code, create an image or anchor element with class='validatefile-button', ID=[file name and path] (minus the '.fa'), and title= [filename]. 
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