// Javascript for interfacing the context track images/lists with jquery ui Sortable objects
// Shannon Schlueter, 05-2009

function toggleProjEntry(pval){
  if(pval == "NEWPROJECT"){
    $('#GFFproject').val("");
    $('#GFFproject').removeAttr('readonly');
  }else{
    $('#GFFproject').val("Add to project: " + $('#GFFselect option:selected').text());
    $('#GFFproject').attr('readonly','readonly');
  }
}

        $(function() {
                $(".context_region").sortable({items: '.context_track',axis: 'y'});
                $("#addTrackDialog").load(CGIPATH + 'xGDBaddTrack.pl');
                $("#addTrackDialog").click(function(event) {
                
// upated this section for user add track feature Schlueter 12-2011
                        if(($(event.target).hasClass('ajaxSubmit'))&&($(event.target).hasClass('ajaxUpload'))&&(!$(event.target).hasClass('ui-state-disabled'))) {
				$('#GFFloading').ajaxStart(function(){$(this).show();}).ajaxComplete(function(){$(this).hide();});
        			$.ajaxFileUpload ({     url:CGIPATH + 'xGDBparseGFF.pl',
                                			secureuri:false,
                                			fileElementId:'GFFfile',
                                			success: function (html) {
  $("#GFFdialog").html(html.body.innerHTML);
                                			},
                                			error: function (data, status, e) { alert(e); }
                          			});
                        }else if(($(event.target).hasClass('ajaxSubmit'))&&(!$(event.target).hasClass('ui-state-disabled'))) {
// end update section
                                var dataObj = new Object();
                                $('#addTrackDialog .ajaxParam').each( function() {
                                        dataObj[$(this).attr('id')] = $(this).attr('value');
                                });
                                $.get(CGIPATH + 'xGDBaddTrack.pl',
                                        dataObj,
                                        function(html) {
                                                $("#addTrackDialog").html(html);
                                        }
                                );
                        }else if($(event.target).hasClass('ui-selectable')){
                                $(event.target).toggleClass("ui-selected").siblings().removeClass("ui-selected");
                                if($('.ui-selected').hasClass('ui-selected')) {
                                        $('.ajaxSubmit').removeClass('ui-state-disabled').val($(event.target).attr('id'));
                                }else{
                                        $('.ajaxSubmit').addClass('ui-state-disabled');
                                }
                        }
                });
                $("#addTrackDialog").dialog({
                        bgiframe: true,
                        autoOpen: false,
                        height: 400,
			width: 600,
                        modal: true,
                        buttons: {
                                'Add Track': function() {
                                        var dataObj = new Object();
                                        $('#addTrackDialog .ajaxParam').each( function() {
                                                dataObj[$(this).attr('id')] = $(this).attr('value');
                                        });
                                        $.get(CGIPATH + 'xGDBaddTrack.pl',
                                                dataObj,
                                                function(html) {
                                                        $("#addTrackDialog").html(html);
                                                }
                                        );
                                },
                                Cancel: function() {
                                        $(this).dialog('close');
                                        $("#addTrackDialog").load(CGIPATH + 'xGDBaddTrack.pl');
                                }
                        }
                });
                $(":button:contains('Add Track')").attr('disabled','disabled').addClass('ui-state-disabled');
                $('.cth-toggle').click( function(){
			var ctId = Number($(this).parents('.context_track').attr('id'));
			var ctToggleUP = 0;
			if(! $(this).hasClass('toggle-up')){ ctToggleUP = 1; }
			$.get(CGIPATH + 'xGDBupdateSession.pl',{'track_resid':ctId,'track-toggled':ctToggleUP});
                        $(this).parent().siblings('.context_track_image').slideToggle();
			$(this).parent().toggleClass('toggle-up');
                        $(this).toggleClass('toggle-up');
                });
                $('.xgdb-track-delete').click( function(){
                        var ct = $(this).parents('.context_track');
                        var ctId = Number(ct.attr('id'));

                        // Ajax call to remove this dynamic (user-defined) track from the session store
                        $.get(CGIPATH + 'xGDBupdateSession.pl',{'track-delete':ctId});

                        // Adjust all context_track with greater id's (-1)
                        ct.siblings('.context_track').each( function(){
                                if(Number($(this).attr('id')) > ctId){
                                        $(this).attr('id',($(this).attr('id') - 1));
                                }
                        });

                        // Remove this context_track from sortable list and from display
                        ct.remove();
                        $(".context_region").trigger('sortupdate');
            	});
		$('.xgdb-track-option').click( function(){
			if(! $(this).hasClass('current') ){
				var cti = $(this).parents('.context_track').children('.context_track_image');
				var ctId = Number($(this).parents('.context_track').attr('id'));
				$.get(CGIPATH + 'xGDBupdateSession.pl',{'track_resid':ctId,'track-selectedImageOption':$(this).attr('id')});
				cti.children('.xgdb-track-image-current').removeClass('xgdb-track-image-current').addClass('xgdb-track-image-option');
				cti.children('img#' + $(this).attr('id')).removeClass('xgdb-track-image-option').addClass('xgdb-track-image-current');
				$(this).siblings('.xgdb-track-option').toggleClass('current');
				$(this).toggleClass('current');
			}
		});

	});

