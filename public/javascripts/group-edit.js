$(function() {
		$("li .person").draggable({
				helper: 'clone',
				cursor: 'move'
		});
		$("li .group").droppable({
			drop: function(event, ui) {
        //alert('dropped!');
				$("<li class='person'></li>").text(ui.draggable.text()).appendTo(this);
			}
		});


	});
