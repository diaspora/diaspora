var WebSocketReceiver = {
  initialize: function(url) {
    ws = new WebSocket(url);

    //Attach onmessage to websocket
    ws.onmessage = WSR.onMessage;
    ws.onclose = function() { debug("socket closed"); };
    ws.onopen = function() {
      ws.send(location.pathname);
      WSR.debug("connected...");
    };
  },
  
  onMessage: function(evt) {
      var obj = jQuery.parseJSON(evt.data);
      if(obj['notice']){
        WebSocketReceiver.processNotification(obj['notice']);

      }else if (obj['class'] == 'people'){
        WSR.debug("got a " + obj['class']);
        WebSocketReceiver.processPerson(obj);

      }else{
        WSR.debug("got a " + obj['class'] + " for aspects " + obj['aspect_ids']);

        if (obj['class']=="retractions"){
          WebSocketReceiver.processRetraction(obj['post_id']);

        }else if (obj['class']=="comments"){
          WebSocketReceiver.processComment(obj['post_id'], obj['comment_id'], obj['html'], {'notification':obj['notification'], 'mine?':obj['mine?'], 'my_post?':obj['my_post?']})

        }else{
          WebSocketReceiver.processPost(obj['class'], obj['post_id'], obj['html'], obj['aspect_ids'])
        }
      }
  },
processPerson: function(response){
    form = $('.webfinger_form');
    form.siblings('#loader').hide();
    result_ul = form.siblings('#request_result');
    if(response['status'] == 'fail'){
      result_ul.siblings('.error').show();
      result_ul.find('.error').text(response['response']).show();
    }else{
      $('#people_stream').prepend(response['html']).slideDown('slow', function(){});
      var first_li = result_ul.find('li:first');
      first_li.hide()
      first_li.after(response['html']);
      result_ul.find("[name='request[into]']").val(result_ul.attr('aspect_id'));
      result_ul.children(':nth-child(2)').slideDown('fast', function(){});
    }
  },


  processNotification: function(html){
    $('#notification').html(html).fadeIn(200).delay(4000).fadeOut(200, function(){ $(this).html("");});
  },

  processRetraction: function(post_id){
    $("*[data-guid='"+post_id+"']").fadeOut(400, function(){$(this).remove()});
    if($("#main_stream")[0].childElementCount == 0){
      $("#no_posts").fadeIn(200);
    }
  },

  processComment: function(postId, commentId, html, opts){

    if( $(".comment[data-guid='"+commentId+"']").length == 0 ){

      post = $("*[data-guid='"+postId+"']'");
      $('.comments li:last', post ).before(
        $(html).fadeIn("fast", function(){})
      );
      toggler = $('.show_post_comments', post);

      if(toggler.length > 0){
        toggler.html(
          toggler.html().replace(/\d+/,$('.comments', post)[0].childElementCount -1)
        );

        if( !$(".comments", post).is(':visible') ){
          toggler.click();
        }
      }

      if( !opts['mine?'] && opts['my_post?']) {
        WebSocketReceiver.processNotification(opts['notification']);
      }
    }
  },

  processPost: function(className, postId, html, aspectIds){
    if(WebSocketReceiver.onPageForAspects(aspectIds)){
      if( $("#no_posts").is(":visible") ){
        $("#no_posts").fadeOut(400, WebSocketReceiver.addPostToStream(postId, html)).hide();
      } else {
        WebSocketReceiver.addPostToStream(postId, html);
      }
    }
  },

  addPostToStream: function(postId, html){
    if( $(".message[data-guid='"+postId+"']").length == 0 ){
      $("#main_stream:not('.show')").prepend(
        $(html).fadeIn("fast", function(){
          $("#main_stream").find("label").first().inFieldLabels();
        })
      );
    }
  },

  onPageForClass: function(className){
    return (location.href.indexOf(className) != -1 );
  },

  onPageForAspects: function(aspectIds){
    if(location.pathname == '/' && WebSocketReceiver.onPageOne()){
      return true
    }
    var found = false;
    $.each(aspectIds, function(index, value) {
      if(WebSocketReceiver.onPageForAspect(value)){ found = true };
    });
    return found;
  },

  onPageForAspect: function(aspectId){
    return (location.href.indexOf(aspectId) != -1 )
  },

  onPageOne: function() {
      var c = document.location.search.charAt(document.location.search.length-1);
      return ((c =='') || (c== '1'));
  },
  debug: function(str){
    $("#debug").append("<p>" +  str); 
  }
};
var WSR = WebSocketReceiver
