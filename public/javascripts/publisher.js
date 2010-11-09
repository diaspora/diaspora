/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var Publisher = {

  initialize: function() {
    $("ul .person").draggable({
      revert: true,
      start: AspectEdit.startDrag,
      drag: AspectEdit.duringDrag,
      stop: AspectEdit.stopDrag
    });

    $(".aspect ul.dropzone").droppable({
      hoverClass: 'active',
      drop: AspectEdit.onDropMove
    });

    $(".delete").live("click", AspectEdit.deletePerson);
    $(".aspect h3").live('focus', AspectEdit.changeName);
  },

  startDrag: function() {
    AspectEdit.animateImage($(this).children("img").first());
    $(".draggable_info").fadeIn(100);
  },
  
  animateImage: function(image) {
    image.animate({'height':80, 'width':80, 'opacity':0.8}, 200);
    image.tipsy("hide");
  },

  duringDrag: function(event, ui) {
    $(this).children("img").tipsy("hide"); //ensure this is hidden
  },

  stopDrag: function(event, ui) {
    $(this).children("img").animate({'height':70, 'width':70, 'opacity':1}, 200);
    $(".draggable_info").fadeOut(100);
  },

  onDropMove: function(event, ui) {
    var dropzone = $(this);
    var person = ui.draggable;

    if (person.hasClass('request')) {
      $.ajax({
        type: "DELETE",
        url: "/requests/" + person.attr('data-guid'),
        data: {"accept" : true, "aspect_id" : dropzone.attr('data-aspect_id') },
        success: function(data) {
          AspectEdit.decrementRequestsCounter();
          person.removeClass('request');
        }
      });
    }

    if (dropzone.attr('data-aspect_id') != person.attr('data-aspect_id')) {
      $.ajax({
        url: "/aspects/move_friend/",
        data: {"friend_id" : person.attr('data-guid'),
          "from"      : person.attr('data-aspect_id'),
          "to"        : { "to" : dropzone.attr('data-aspect_id') }},
        success: function(data) {
          person.attr('data-aspect_id', dropzone.attr('data-aspect_id'));
        }});
    }

    dropzone.closest("ul").append(person);
  },

  deletePersonFromAspect: function(person) {

    var person_id = person.attr('data-guid');

    if( $(".person[data-guid='"+ person_id +"']").length == 1) {
      alert("You can not remove the person from the last aspect");

    } else {
      if (!person.hasClass('request')) {

        $.ajax({
          type: "POST",
          url: "/aspects/remove_from_aspect",
          data:{
            'friend_id' : person_id,
            'aspect_id' : person.attr('data-aspect_id') }
        });
      }
      person.fadeOut(400, function() {
        person.remove();
      });
    }
  },

  changeName:  function() {

    var $this = $(this);
    var id = $this.closest("li.aspect").attr("data-guid");
    var link = "/aspects/" + id;

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
        $("#aspect_nav a[href='" + link + "']").text($this.text());
      });
    });
  },

  deletePerson: function() {
    var person = $(this).closest("li.person");

    if (person.hasClass('request')) {
      if (confirm("Ignore request?")) {
        var request_id = person.attr("data-guid");

        $.ajax({
          type: "DELETE",
          url: "/requests/" + request_id,
          success: function () {
            AspectEdit.decrementRequestsCounter();
          }
        });
      }
    } else {
      if (confirm("Also remove this person from all aspects?")) {
        var person_id = $(this).closest("li.person").attr('data-guid');

        $.ajax({
          type: "DELETE",
          url: "/people/" + person_id,
          success: function() {
            $(".person[data-guid='"+ person_id +"']").fadeOut(200);
          }
        });
      } else {
        AspectEdit.deletePersonFromAspect(person);
      }
    }
  },

  decrementRequestsCounter: function() {
    var $new_requests = $(".new_requests");
    var request_html = $new_requests.html();
    var old_request_count = request_html.match(/\d+/);

    if (old_request_count == 1) {
      $new_requests.html(
        request_html.replace(/ \(\d+\)/, '')
        );
    } else {
      $new_requests.html(
        request_html.replace(/\d+/, old_request_count - 1)
        );
    }
  }
};

$(document).ready(Publisher.initialize);

