/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

var AspectFilters = {
  selectedGUIDS: [],
  requests: 0,
  initialize: function(){
    AspectFilters.initializeSelectedGUIDS();
    AspectFilters.interceptAspectLinks();
    AspectFilters.interceptAspectNavLinks();
  },
  initializeSelectedGUIDS: function(){
    $("#aspect_nav .aspect_selector").each(function(){
      var button = $(this),
          guid = button.attr('data-guid');

      if(guid && location.href.search("a_ids..="+guid+"(#|&|$)") != -1){
        button.parent().addClass('active');
        AspectFilters.selectedGUIDS.push(guid);
        $("#aspect_nav li.all_aspects").removeClass('active');
      }
    });
  },
  interceptAspectLinks: function(){
    $("a.hard_aspect_link").live("click", AspectFilters.aspectLinkClicked);
  },
  aspectLinkClicked: function(e){
    var link = $(this);
    e.preventDefault();
    if( !link.hasClass('aspect_selector') ){
      AspectFilters.switchToAspect(link);
    }

    // remove focus
    this.blur();

    $('html, body').animate({scrollTop:0}, 'fast');
  },
  switchToAspect: function(aspectLi){
    AspectFilters.requests++;

    var guid = aspectLi.attr('data-guid');

    // select correct aspect in filter list & deselect others
    $("#aspect_nav li.active").removeClass('active');
    aspectLi.addClass('active');

    AspectFilters.fadeOut();

    AspectFilters.performAjax( aspectLi.attr('href'));
  },
  interceptAspectNavLinks: function(){
    $("#aspect_nav a.aspect_selector").click(function(e){
      e.preventDefault();

      AspectFilters.requests++;

      // loading animation
      AspectFilters.fadeOut();

      // filtering //////////////////////
      var $this = $(this),
          listElement = $this.parent(),
          guid = $this.attr('data-guid'),
          homeListElement = $("#aspect_nav li.all_aspects");

      if( listElement.hasClass('active') ){
        // remove filter
        var idx = AspectFilters.selectedGUIDS.indexOf( guid );
        if( idx != -1 ){
          AspectFilters.selectedGUIDS.splice(idx,1);
        }
        listElement.removeClass('active');

        if(AspectFilters.selectedGUIDS.length === 0){
          homeListElement.addClass('active');
        }

      } else {
        // append filter
        if(AspectFilters.selectedGUIDS.indexOf( guid == 1)){
          AspectFilters.selectedGUIDS.push( guid );
        }
        listElement.addClass('active');

        homeListElement.removeClass('active');
      }

       AspectFilters.performAjax(AspectFilters.generateURL());
    });
  },
  generateURL: function(){
    var baseURL = location.href.split("?")[0];

    // generate new url
    baseURL = baseURL.replace('#','');
    baseURL += '?';
    for(i=0; i < AspectFilters.selectedGUIDS.length; i++){
      baseURL += 'a_ids[]='+ AspectFilters.selectedGUIDS[i] +'&';
    }

    if(!$("#publisher").hasClass("closed")) {
      // open publisher
      baseURL += "op=true";
    } else {
      // slice last '&'
      baseURL = baseURL.slice(0,baseURL.length-1);
    }
    return baseURL;
  },
  performAjax: function(newURL) {
    var post = $("#publisher textarea").val(),
        photos = {};

    //pass photos
    $('#photodropzone img').each(function(){
      var img = $(this);
      var guid = img.attr('data-id');
      var url = img.attr('src');
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
        AspectFilters.requests--;
        // fill in publisher
        // (not cached because this element changes)

        var textarea = $("#publisher textarea");
        var photozone = $('#photodropzone');

        if( post !== "" ) {
          textarea.val(post);
          textarea.focus();
        }

        var photos_html = "";
        for(var key in photos){
          $("#publisher textarea").addClass("with_attachments");
          photos_html = photos_html + "<li style='position:relative;'> " + ("<img src='" + photos[key] +"' data-id='" + key + "'>") +  "</li>";
        }

        // reinit listeners on stream
        photozone.html(photos_html);
        Diaspora.Page.publish("stream/reloaded");

        // fade contents back in
        if(AspectFilters.requests === 0){
          AspectFilters.fadeIn();
        }
      }
    });
  },
  fadeIn: function(){
    $("#aspect_stream_container").fadeTo(100, 1);
    $("#aspect_contact_pictures").fadeTo(100, 1);
  },
  fadeOut: function(){
    $("#aspect_stream_container").fadeTo(100, 0.4);
    $("#aspect_contact_pictures").fadeTo(100, 0.4);
  }
}
$(document).ready(function(){
  AspectFilters.initialize();
});
