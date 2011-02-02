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

    if(guid && location.href.search("a_ids..="+guid+"(&|$)") != -1){
      button.addClass('selected');
      selectedGUIDS.push(guid);
    }
  });


  $("a.hard_aspect_link").live("click", function(e){
    e.preventDefault();
    requests++;

    var guid = $(this).attr('data-guid');

    // select correct aspect in filter list & deselect others
    $("#aspect_nav li").each(function(){
      var $this = $(this);
      if( $this.attr('data-guid') == guid){
        $this.addClass('selected');
      } else {
        $this.removeClass('selected');
      }
    });

    // loading animation
    $("#aspect_stream_container").fadeTo(100, 0.4);
    $("#aspect_contact_pictures").fadeTo(100, 0.4);

    performAjax( $(this).attr('href'));
  });

  $("#aspect_nav a.aspect_selector").click(function(e){
    e.preventDefault();

    requests++;

    // loading animation
    $("#aspect_stream_container").fadeTo(100, 0.4);
    $("#aspect_contact_pictures").fadeTo(100, 0.4);

    // filtering //////////////////////
    var $this = $(this),
        listElement = $this.parent(),
        guid = listElement.attr('data-guid'),
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

     performAjax(generateURL());
  });


  function generateURL(){
    var baseURL = location.href.split("?")[0];

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
    return baseURL;
  }

  function performAspectUpdate(home){
      // update the open aspects in the user
      updateURL = "/users/" + $('div.avatar').children('img').attr("data-owner_id");
      updateURL += '?';
      if(home == 'home'){
        updateURL += 'user[a_ids][]=home';
      } else {
        for(i=0; i < selectedGUIDS.length; i++){
          updateURL += 'user[a_ids][]='+ selectedGUIDS[i] +'&';
        }
      }

      $.ajax({
        url : updateURL,
        type: "PUT",
        });

  }

  if($("a.home_selector").parent().hasClass("selected")){
    performAspectUpdate("home");
  }

  function performAjax(newURL) {
    var post = $("#publisher textarea").val(),
        photos = {};


    //pass photos
    $('#photodropzone img').each(function(){
      var img = $(this);
      guid = img.attr('data-id');
      url = img.attr('src');
      photos[guid] = url;
    });



    // set url
    // some browsers (Firefox for example) don't support pushState
    if (typeof(history.pushState) == 'function') {
      history.pushState(null, document.title, newURL);
    }

    $.ajax({
      url : newURL,
      dataType : 'script',
      success  : function(data){
        requests--;
        // fill in publisher
        // (not cached because this element changes)

        var textarea = $("#publisher textarea");
        var photozone = $('#photodropzone')

        if( post != "" ) {
          textarea.val(post);
          textarea.focus();
        }

        var photos_html = "";
        for(var key in photos){
          $("#publisher textarea").addClass("with_attachments");
          photos_html = photos_html + "<li style='position:relative;'> " + ("<img src='" + photos[key] +"' data-id='" + key + "'>") +  "</li>";
        };


        $('html, body').animate({scrollTop:0}, 'fast');

        // reinit listeners on stream
        photozone.html(photos_html);
        Stream.initialize();

        // fade contents back in
        if(requests == 0){
          $("#aspect_stream_container").fadeTo(100, 1);
          $("#aspect_contact_pictures").fadeTo(100, 1);
          performAspectUpdate();
        }
      }
    });

  }

});
