/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

$(function(){
  var selectedGUIDS = [];

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

    // loading animation
    $("#main_stream").fadeTo(100, 0.4);


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
    baseURL += '?';
    for(i=0; i < selectedGUIDS.length; i++){
      baseURL += 'a_ids[]='+ selectedGUIDS[i] +'&';
    }
    baseURL = baseURL.slice(0,baseURL.length-1);
    ///////////////////////////////////


    //window.location = baseURL;
    $.ajax({
      url : baseURL,
      dataType : 'script',
      success  : function(data){
        $("#main_stream").fadeTo(100, 1);
      }
    });

  });
});
