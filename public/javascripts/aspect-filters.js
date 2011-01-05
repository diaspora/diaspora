/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(document).ready(function(){
  var selectedGUIDS = [],
      requests = 0;

  $("#aspect_nav li").each(function(){
    var button = $(this),
        guid = button.attr('data-guid');

    if(guid && location.href.match(guid)){
      button.addClass('selected');
      selectedGUIDS.push(guid);
    }
  });

  $("#aspect_nav a.aspect_selector").click(function(e){
    e.preventDefault();

    requests++;

    // loading animation
    $("#aspect_stream_container").fadeTo(100, 0.4);

    // get text from box
    var post = $("#publisher textarea").val();

    // filtering //////////////////////
    var $this = $(this),
        listElement = $this.parent(),
        guid = listElement.attr('data-guid'),
        baseURL = location.href.split("?")[0],
        homeListElement = $("#aspect_nav a.home_selector").parent();

    if( listElement.hasClass('selected') ){
      // remove filter
      var idx = selectedGUIDS.indexOf( guid );
      if( idx != -1 ){
        selectedGUIDS.splice(idx,1);
      }
      listElement.removeClass('selected');

      if(selectedGUIDS.length == 0){
        homeListElement.addClass('selected');
      }

    } else {
      // append filter
      if(selectedGUIDS.indexOf( guid == 1)){
        selectedGUIDS.push( guid );
      }
      listElement.addClass('selected');

      homeListElement.removeClass('selected');
    }

    // generate new url
    baseURL = baseURL.replace('#','');
    baseURL += '?';
    for(i=0; i < selectedGUIDS.length; i++){
      baseURL += 'a_ids[]='+ selectedGUIDS[i] +'&';
    }

    if(!$("#publisher").hasClass("closed")) {
      // open publisher
      baseURL += "op=true";
    } else {
      // slice last '&'
      baseURL = baseURL.slice(0,baseURL.length-1);
    }
    ///////////////////////////////////

    $.ajax({
      url : baseURL,
      dataType : 'script',
      success  : function(data){
        requests--;

        // fill in publisher
        // (not cached because this element changes)
        $("#publisher textarea").val(post);

        $('html, body').animate({scrollTop:0}, 'fast');

        // reinit listeners on stream
        Stream.initialize();

        // fade contents back in
        if(requests == 0){
          $("#aspect_stream_container").fadeTo(100, 1);
        }
      }
    });

  });
});
