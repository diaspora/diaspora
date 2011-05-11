var WebSocketReceiver = {
  initialize: function(url) {
    this.debuggable = true;
    this.url = url;
    this.socket = new WebSocket(url);

    this.socket.onmessage = WSR.onMessage;
    this.socket.onclose = function() {
      Diaspora.widgets.notifications.showNotification({
        html: '<div class="notification">' +
            Diaspora.widgets.i18n.t("web_sockets.disconnected") +
          '</div>',
        incrementCount: false
      });

      WSR.debug("Socket closed");
    };

    this.socket.onopen = $.proxy(function() {
      this.socket.send(location.pathname);
      WSR.debug("Connected to " + this.url + "...");
    }, this);
  },

  onMessage: function(evt) {
    var message = jQuery.parseJSON(evt.data);WSR.debug("WebSocket received " + message.class, message)

    if(message.class.match(/^notifications/)) {
      WebSocketReceiver.processNotification(message);
    }
    else if(message.class === "people") {
      WebSocketReceiver.processPerson(message);
    }
    else {
      if(message.class === "retractions") {
        WebSocketReceiver.processRetraction(message.post_id);
      }
      else if(message.class === "comments") {
        WebSocketReceiver.processComment(message);
      }
      else if(message.class === "likes") {
        WebSocketReceiver.processLike(message.post_id, message.html);
      }
      else {
        WebSocketReceiver.processPost(message.post_id, message.html, message.aspect_ids);
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

  processRetraction: function(postId){
    $("*[data-guid='" + postId + "']").fadeOut(400, function() {
      $(this).remove();
    });
    if($("#main_stream")[0].childElementCount === 0) {
      $("#no_posts").fadeIn(200);
    }
  },

  processComment: function(comment) {
    ContentUpdater.addCommentToPost(comment.comment_id, comment.post_id, comment.html);
  },

  processLike: function(postId, html) {
    var post = $("*[data-guid='"+postId+"']");
    $(".likes_container", post).fadeOut('fast').html(html).fadeIn('fast');
  },

  processPost: function(postId, html, aspectIds) {
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
      }
    });
    
    return found;
  },

  onStreamForAspect: function(aspectId, streamIds) {
    return (streamIds.search(aspectId) != -1);
  },

  debug: function() {
    if(this.debuggable && typeof console !== "undefined") {
      console.log.apply(console, arguments);
    }
  }
};
var WSR = WebSocketReceiver;

