var WebSocketReceiver = {
  initialize: function(url) {
    ws = new WebSocket(url);

    //Attach onmessage to websocket
    ws.onmessage = WSR.onMessage;
    ws.onclose = function() { WSR.debug("socket closed"); };
    ws.onopen = function() {
      ws.send(location.pathname);
      WSR.debug("connected...");
    };
  },

  onMessage: function(evt) {
      var obj = jQuery.parseJSON(evt.data);
      if(obj['class'] == 'notifications') {
        WebSocketReceiver.processNotification(obj);
      } else if (obj['class'] == 'people') {
        WSR.debug("got a " + obj['class']);
        WebSocketReceiver.processPerson(obj);

      } else {
        WSR.debug("got a " + obj['class'] + " for aspects " + obj.aspect_ids);

        if (obj['class']=="retractions") {
          WebSocketReceiver.processRetraction(obj.post_id);

        } else if (obj['class']=="comments") {
          WebSocketReceiver.processComment(obj.post_id, obj.comment_id, obj.html, {
            'notification': obj.notification,
            'mine?': obj['mine?'],
            'my_post?': obj['my_post?']
          });

        } else {
          WebSocketReceiver.processPost(obj['class'], obj.post_id, obj.html, obj.aspect_ids);
        }
      }
  },

  processPerson: function(response) {
    form = $('.webfinger_form');
    form.siblings('#loader').hide();
    result_ul = form.siblings('#request_result');
    if(response.status == 'fail') {
      result_ul.siblings('.error').show();
      result_ul.find('.error').text(response.response).show();
    } else {
      $('#people_stream').prepend(response.html).slideDown('slow', function(){});
      var first_li = result_ul.find('li:first');
      first_li.hide()
      first_li.after(response.html);
      result_ul.find("[name='request[into]']").val(result_ul.attr('aspect_id'));
      result_ul.children(':nth-child(2)').slideDown('fast', function(){});
    }
  },


  processNotification: function(notification){
    var nBadge = $("#notification_badge_number");

    nBadge.html().replace(/\d+/, function(num){
      nBadge.html(parseInt(num)+1);
    });

    if(nBadge.hasClass("hidden")){
      nBadge.removeClass("hidden");
    }

    $('#notification').html(notification['html'])
      .fadeIn(200)
      .delay(8000)
      .fadeOut(200, function(){
        $(this).html("");
      });
  },

  processRetraction: function(post_id){
    $("*[data-guid='" + post_id + "']").fadeOut(400, function() {
      $(this).remove();
    });
    if($("#main_stream")[0].childElementCount == 0) {
      $("#no_posts").fadeIn(200);
    }
  },

  processComment: function(postId, commentId, html, opts) {

    if( $(".comment[data-guid='"+commentId+"']").length == 0 ) {

      post = $("*[data-guid='"+postId+"']'");
      $('.comments li:last', post ).before(
        $(html).fadeIn("fast", function(){})
      );
      toggler = $('.show_post_comments', post);

      if(toggler.length > 0){
        toggler.html(
          toggler.html().replace(/\d+/,$('.comments', post).find('li').length -1)
        );

        if( !$(".comments", post).is(':visible') ) {
          toggler.click();
        }

        if( $(".show_comments", post).hasClass('hidden') ){
          $(".show_comments", post).removeClass('hidden');
        }
      }
    }
  },

  processPost: function(className, postId, html, aspectIds) {
    if(WebSocketReceiver.onPageForAspects(aspectIds)) {
      WebSocketReceiver.addPostToStream(postId, html);
    }
  },

  addPostToStream: function(postId, html) {
    if( $(".stream_element[data-guid='" + postId + "']").length == 0 ) {
      var showMessage = function() {
        $("#main_stream:not('.show')").prepend(
          $(html).fadeIn("fast", function() {
            $("#main_stream").find("label").first().inFieldLabels();
          })
        );
      };

      if( $("#no_posts").is(":visible") ) {
        $("#no_posts").fadeOut(400, showMessage()).hide();
      } else {
        showMessage();
      }
    }
  },

  onPageForClass: function(className) {
    return (location.href.indexOf(className) != -1 );
  },

  onPageForAspects: function(aspectIds) {
    if(location.pathname == '/aspects' && WebSocketReceiver.onPageOne()) {
      return true
    }
    var found = false;
    $.each(aspectIds, function(index, value) {
      if(WebSocketReceiver.onPageForAspect(value)) {
        found = true;
      };
    });
    return found;
  },

  onPageForAspect: function(aspectId) {
    return (location.href.indexOf(aspectId) != -1 )
  },

  onPageOne: function() {
      var c = document.location.search.charAt(document.location.search.length-1);
      return ((c =='') || (c== '1'));
  },
  debug: function(str) {
    $("#debug").append("<p>" +  str);
  }
};
var WSR = WebSocketReceiver;

