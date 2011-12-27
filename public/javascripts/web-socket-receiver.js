var WSR = WebSocketReceiver = {
  initialize: function(url) {
    WSR.socket = new WebSocket(url);

    WSR.socket.onmessage = WSR.onMessage;
    WSR.socket.onopen = function() {
      WSR.socket.send(location.pathname);
    };
  },

  onMessage: function(evt) {
    var message = $.parseJSON(evt.data);

    if(message["class"].match(/^notifications/)) {
      Diaspora.page.header.notifications.showNotification(message);
    }
    else {
      console.log("new content");
    }
  },

  onPageForAspects: function(aspectIds) {
    var streamIds = $("#main_stream").attr("data-guids"),
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
  }
};
