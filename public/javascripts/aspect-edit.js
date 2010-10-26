/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

function decrementRequestsCounter() {
  var $new_requests     = $(".new_requests");
  var request_html      = $new_requests.html();
  var old_request_count = request_html.match(/\d+/);

  if( old_request_count == 1 ) {
    $new_requests.html(
      request_html.replace(/ \(\d+\)/,'')
    );
  } else {
    $new_requests.html(
      request_html.replace(/\d+/,old_request_count-1)
    );
  }
}

// Dragging person between aspects
$(function() {
  $("ul .person").draggable({
    revert: true,
    start: function(event,ui){
      $(this).children("img").animate({'height':80, 'width':80, 'opacity':0.8},200);
      $(this).children("img").tipsy("hide");
      $(".draggable_info").fadeIn(100);
    },
    drag: function(event,ui){
      $(this).children("img").tipsy("hide"); //ensure this is hidden
    },
    stop: function(event,ui){
      $(this).children("img").animate({'height':70, 'width':70, 'opacity':1},200);
      $(".draggable_info").fadeOut(100);
    }
  });

  $(".aspect ul.dropzone").droppable({
    hoverClass: 'active',
    drop: function(event, ui) {

      var dropzone = $(this);
      var person   = ui.draggable;

      if( person.hasClass('request') ){
        $.ajax({
          type: "DELETE",
          url: "/requests/" + person.attr('data-guid'),
          data: {"accept" : true, "aspect_id" : dropzone.attr('data-aspect_id') },
          success: function(data){
            decrementRequestsCounter();
          }
        });
      };


      if( dropzone.attr('data-aspect_id') != person.attr('data-aspect_id' )){
        $.ajax({
          url: "/aspects/move_friend/",
          data: {"friend_id" : person.attr('data-guid'),
                 "from"      : person.attr('data-aspect_id'),
                 "to"        : { "to" : dropzone.attr('data-aspect_id') }},
          success: function(data){
            person.attr('data-aspect_id', dropzone.attr('data-aspect_id'));
          }});
        }

      $(this).closest("ul").append(person);
    }
  });


  $(".aspect_remove ul").droppable({
    hoverClass: 'active',
    drop: function(event, ui) {

      var person = ui.draggable;

      if ( person.attr('data-guid').length == 1 ) {
        alert("You can not remove the person from the last aspect");

      } else {
        if( !person.hasClass('request') ){

          $.ajax({
            type: "POST",
            url: "/aspects/remove_from_aspect",
            data:{
                  'friend_id' : person.attr('data-guid'),
                  'aspect_id' : person.attr('data-aspect_id') }
          });
        }
      person.fadeOut(400, function(){person.remove();});
      }
    }
  });


});


// Person deletion
$(".delete").live("click", function() {

  var person = $(this).closest("li.person");

  if (person.hasClass('request')){

    if( confirm("Ignore request?") ){
      var request_id = person.attr("data-guid");

      $.ajax({
        type: "DELETE",
        url: "/requests/" + request_id,
        success: function () {
          decrementRequestsCounter();
        }
      });
    }

  } else {

    if( confirm("Remove this person from all aspects?") ){
      var person_id = $(this).closest("li.person").attr('data-guid');

      $.ajax({
        type: "DELETE",
        url: "/people/" + person_id,
        success: function() {
          person.fadeOut(200);
        }
      });
    }
  }
});


// Editing aspect name
$(".aspect h3").live('focus', function() {

  var $this = $(this);
  var id    = $this.closest("li.aspect").attr("data-guid");
  var link  = "/aspects/"+ id;

  $this.keypress(function(e) {
    if (e.which == 13) {
      e.preventDefault();
      $this.blur();

      //save changes
      $.ajax({
        type: "PUT",
        url: link,
        data: {"aspect" : {"name" : $this.text() }}
      });
    }
    //update all other aspect links
    $this.keyup(function(e) {
      $("#aspect_nav a[href='"+link+"']").text($this.text());
    });
  });
});
