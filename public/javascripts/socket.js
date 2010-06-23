$(document).ready(function(){
    function debug(str){ $("#debug").append("<p>" +  str); };

    ws = new WebSocket("ws://localhost:8080/");
    ws.onmessage = function(evt) { 
		$("#stream").prepend($(evt.data).fadeIn("fast")); 
		};
    ws.onclose = function() { debug("socket closed"); };
    ws.onopen = function() {
      debug("connected...");
      //ws.send("hello server");
      // ws.send("hello again");
    };
});
