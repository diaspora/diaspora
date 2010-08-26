$(function() {
		$("li .person").draggable({
		  revert: true
    });
		$(".group ul").droppable({

			drop: function(event, ui) {
        $(this).closest("ul").append(ui.draggable)
				//$("<li class='person ui-draggable'></li>").text(ui.draggable.text()).appendTo(this).draggable();
			}
		});


	});
