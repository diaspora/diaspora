var WebSocketReceiver = {
  initialize: function(url) {
    var ws = new WebSocket(url);
    WSR.socket = ws;

    //Attach onmessage to websocket
    ws.onmessage = WSR.onMessage;
    ws.onclose = function() {
      if (websocket_enabled) {
       /* Diaspora.widgets.notifications.showNotification({
          html: '<div class="notification">' +
              Diaspora.widgets.i18n.t("web_sockets.disconnected") +
            '</div>',
          incrementCount: false
        }); TODO:figure out why this fires so often */

        WSR.debug("socket closed");
      }
    };
    ws.onopen = function() {
      ws.send(location.pathname);
      WSR.debug("connected...");
    };
  },

  onMessage: function(evt) {
      var obj = jQuery.parseJSON(evt.data);

      if(obj['class'].match(/^notifications/)) {
        WebSocketReceiver.processNotification(obj);
      } else if (obj['class'] == 'people') {
        WSR.debug("got a " + obj['class']);
        WebSocketReceiver.processPerson(obj);

      } else {
        debug_string = "got a " + obj['class'];
        if(obj.aspect_ids !== undefined){
          debug_string +=  " for aspects " + obj.aspect_ids;
        }

        WSR.debug(debug_string);

        if (obj['class']=="retractions") {
          WebSocketReceiver.processRetraction(obj.post_id);

        } else if (obj['class']=="comments") {
          WebSocketReceiver.processComment(obj.post_id, obj.comment_id, obj.html, {
            'notification': obj.notification,
            'mine?': obj['mine?'],
            'my_post?': obj['my_post?']
          });

        } else if (obj['class']=="likes") {
          WebSocketReceiver.processLike(obj.post_id, obj.html);

        } else {
          WebSocketReceiver.processPost(obj['class'], obj.post_id, obj.html, obj.aspect_ids);
        }
      }
  },

  processPerson: function(response) {
    var form = $('.webfinger_form');
    form.siblings('#loader').hide();
    var result_ul = form.siblings('#request_result');
    if(response.status == 'fail') {
      result_ul.siblings('.error').show();
      result_ul.find('.error').text(response.response).show();
    } else {
      $('#people_stream').prepend(response.html).slideDown('slow', function(){});
      var first_li = result_ul.find('li:first');
      first_li.hide();
      first_li.after(response.html);
      result_ul.find("[name='request[into]']").val(result_ul.attr('aspect_id'));
      result_ul.children(':nth-child(2)').slideDown('fast', function(){});
    }
  },


  processNotification: function(notification){
    Diaspora.widgets.notifications.showNotification(notification);
  },

  processRetraction: function(post_id){
    $("#" + post_id).fadeOut(400, function() {
      $(this).remove();
    });
    if($("#main_stream")[0].childElementCount === 0) {
      $("#no_posts").fadeIn(200);
    }
  },

  processComment: function(postGUID, commentGUID, html, opts) {

    if( $("#"+commentGUID).length === 0 ) {
      var post = $("#"+postGUID),
          prevComments = $('.comment.posted', post);

      if(prevComments.length > 0) {
        prevComments.last().after(
          $(html).fadeIn("fast", function(){})
        );
      } else {
        $('.comments', post).append(
          $(html).fadeIn("fast", function(){})
        );
      }

      var toggler = $('.toggle_post_comments', post).parent();

      if(toggler.length > 0){
        toggler.html(
          toggler.html().replace(/\d+/,$('.comments', post).find('li').length)
        );

        if( !$(".comments", post).is(':visible') ) {
          toggler.click();
        }

        if( $(".show_comments", post).hasClass('hidden') ){
          $(".show_comments", post).removeClass('hidden');
        }
      }
    }

    Diaspora.widgets.timeago.updateTimeAgo();
    Diaspora.widgets.directionDetector.updateBinds();
  },

  processLike: function(targetGUID, html) {
    $('.likes', "#" + targetGUID).first().html(html);
  },

  processPost: function(className, postId, html, aspectIds) {
    if(WebSocketReceiver.onPageForAspects(aspectIds)) {
      ContentUpdater.addPostToStream(postId, html);
    }
  },

  onPageForClass: function(className) {
    return (location.href.indexOf(className) != -1 );
  },

  onPageForAspects: function(aspectIds) {
    var streamIds = $('#main_stream').attr('data-guids'),
        found = false;

    $.each(aspectIds, function(index, value) {
      if(WebSocketReceiver.onStreamForAspect(value, streamIds)) {
        found = true;
        return false;
      }
    });
    return found;
  },

  onStreamForAspect: function(aspectId, streamIds) {
    return (streamIds.search(aspectId) != -1);
  },

  onPageOne: function() {
      var c = document.location.search.charAt(document.location.search.length-1);
      return ((c === '') || (c === '1'));
  },
  debug: function(str) {
    $("#debug").append("<p>" +  str);
  }
};
var WSR = WebSocketReceiver;

