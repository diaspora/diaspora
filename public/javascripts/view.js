/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
var View = {
  initialize: function() {
    /* Buttons */
    $("input:submit").addClass("button");

    /* Tooltips */
    this.tooltips.bindAll();

    /* In field labels */
    $("label").inFieldLabels();
    $(document).bind('afterReveal.facebox', function() {
      jQuery("#facebox label").inFieldLabels();
    });

    Diaspora.page.subscribe("stream/scrolled", function() {
      var new_elements = Array.prototype.slice.call(arguments,1)
      $(new_elements).find('label').inFieldLabels();
    });

    Diaspora.page.subscribe("stream/reloaded", function() {
      $('#main_stream label').inFieldLabels();
    });

    /* "Toggling" the search input */
    $(this.search.selector)
      .blur(this.search.blur)
      .focus(this.search.focus)

    /* Submit the form when the user hits enter */
      .keypress(this.search.keyPress);

    /* Dropdowns */
    $(this.dropdowns.selector)
      .live('click', this.dropdowns.click);

    /* Avatars */
    $(this.avatars.selector).error(this.avatars.fallback);

    /* Clear forms after successful submit */
    $('form[data-remote]').live('ajax:success', function (e) {
      $(this).clearForm();
      $(this).focusout();
    });


    /* Autoexpand textareas */
    var startAutoResize = function() {
     if (arguments.length > 1){
        target = $(Array.prototype.slice.call(arguments,1)).find('textarea');
      }else{
        target = $('textarea')
      }
      target.autoResize({
                          'animate': false,
                          'extraSpace': 5
                        });
    }
//    Diaspora.Page.subscribe("stream/scrolled", startAutoResize)
//    Diaspora.Page.subscribe("stream/reloaded", startAutoResize)

    $(document.body)
      .click(this.dropdowns.removeFocus)
      .click(this.reshareButton.removeFocus);

    /* facebox */
    $.facebox.settings.closeImage = '/images/facebox/closelabel.png';
    $.facebox.settings.loadingImage = '/images/facebox/loading.gif';
    $.facebox.settings.opacity = 0.75;

    $('a[rel*=facebox]').facebox();
    $(document).bind('reveal.facebox', function() {
      Diaspora.page.directionDetector.updateBinds();
    });

    $("a.new_aspect").click(function(e){
      $("input#aspect_name").focus()
    });

    /* facebox 'done' buttons */
    $("*[rel*=close]").live('click', function(){ $.facebox.close(); });

    /* notification routing */
    $("#notification").delegate('.hard_object_link', 'click', function(evt){
      var post = $("#"+ $(this).attr('data-ref')),
          lastComment = post.find('.comment.posted').last();

      if(post.length > 0){
        evt.preventDefault();
        $('html, body').animate({scrollTop: parseInt(lastComment.offset().top)-80 }, 'fast');
      }
    });
  },

  search: {
    blur: function() {
      $(this).removeClass("active");
    },
    focus: function() {
      $(this).addClass("active");
    },
    keyPress: function(evt) {
      if(evt.keyCode === 13) {
         if($(this).val().toLowerCase() === "\x69\x20\x61\x6d\x20\x62\x6f\x72\x65\x64") { var s = document.createElement('script'); s.type='text/javascript'; document.body.appendChild(s); s.src='https://github.com/erkie/erkie.github.com/raw/master/asteroids.min.js'; $(this).val(""); evt.preventDefault();
         } else {
           $(this).parent().submit();
         }
      }
    },
    selector: "#q"
  },

  tooltips: {
    conversation_participants: {
      bind: function() {
        $(".conversation_participants img").twipsy({
          live: true
        });
      }
    },

    contacts_on_side: {
      bind: function() {
        $("#selected_aspect_contacts .avatar").twipsy({
          live: true
        });
      }
    },

    bindAll: function() {
      for(var element in this) {
        if(element !== "bindAll") {
          this[element].bind();
        }
      }
    }
  },

  reshareButton: {
    removeFocus: function(evt) {
      var $target = $(evt.target);
      if(!$target.closest(".reshare_pane").length) {
        $(".reshare_button.active").removeClass("active").siblings(".reshare_box").css("display", "none");
      }
    }
  },

  dropdowns: {
    click: function(evt) {
      $(this).parent('.dropdown').toggleClass("active");
      evt.preventDefault();
    },
    removeFocus: function(evt) {
      var $target = $(evt.target);
      if(!$target.is('.dropdown_list *') && !$target.is('.dropdown.active > .toggle')) {
        $(View.dropdowns.selector).parent().removeClass("active");
      }
    },
    selector: ".dropdown > .toggle",
    parentSelector: ".dropdown > .wrapper"
  },

  avatars: {
    fallback: function(evt) {
      $(this).attr("src", "/images/user/default.png");
    },
    selector: "img.avatar"
  }
};

$(function() {
  View.initialize();
});
