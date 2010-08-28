$('#move_friends_link').live( 'click', 
    function(){
      $.post('/groups/move_friends',
        {'moves' : $('#group_list').data()},
        function(){ $('#group_title').html("Groups edited successfully!");});
    });

$(function() {
		$("li .person").draggable({
		  revert: true
    });
		$(".group ul").droppable({

			drop: function(event, ui) {
				//$("<li class='person ui-draggable'></li>").text(ui.draggable.text()).appendTo(this).draggable();
        var move = {};
        move[ 'friend_id' ] = ui.draggable[0].id
        move[ 'to' ] = $(this)[0].id;
        move[ 'from' ] = ui.draggable[0].getAttribute('from_group_id');
        if (move['to'] == move['from']){
          $('#group_list').data( ui.draggable[0].id, []);
        } else{
          $('#group_list').data( ui.draggable[0].id, move);
        }

        $(this).closest("ul").append(ui.draggable)
			}
		});

    

	});
