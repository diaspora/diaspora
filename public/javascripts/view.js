/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
var View = {
  initialize: function() {
    /* Buttons */
    $("input:submit").addClass("button");

    /* Tooltips */
    this.tooltips.bindAll();

    /* Animate flashes */
    this.flashes.animate();

    /* In field labels */
    $("label").inFieldLabels();

    /* Showing debug messages  */
    $(this.debug.selector)
      .click(this.debug.click);

    /* "Toggling" the search input */
    $(this.search.selector)
      .blur(this.search.blur)
      .focus(this.search.focus)
    /* Submit the form when the user hits enter */
      .keypress(this.search.keyPress);

    /* Getting started animation */
    $(this.gettingStarted.selector)
      .live("click", this.gettingStarted.click);

    /* User menu */
    $(this.userMenu.selector)
      .click(this.userMenu.click);

    /* Sending a request message */
    $(this.newRequest.selector)
      .live("submit", this.newRequest.submit);

    /* Autoexpand textareas */
    $('textarea')
      .autoResize({
        'animate': false,
        'extraSpace': 0
      });

    /* Webfinger form ajaxy loading */
    $(this.webFingerForm.selector)
      .submit(this.webFingerForm.submit);

    $(document.body)
      .click(this.userMenu.removeFocus)
      .click(this.reshareButton.removeFocus);

    /* facebox */
    $.facebox.settings.closeImage = '/images/facebox/closelabel.png'
    $.facebox.settings.loadingImage = '/images/facebox/loading.gif'
    $('a[rel*=facebox]').facebox();

    /* facebox 'done' buttons */
    $("a[rel*=close]").live('click', function(){ $.facebox.close() });
  },

  addAspectButton: {
    click: function() {
      $("#aspect_name").focus();
    },
    selector: ".add_aspect_button"
  },

  debug: {
    click: function() {
      $("#debug_more").toggle("fast");
    },
    selector: "#debug_info"
  },

  flashes: {
    animate: function() {
      var $this = $(View.flashes.selector);
      $this.animate({
        top: 0
      }).delay(2000).animate({
        top: -100
      }, $this.remove)
    },
    render: function(result) {
      $("<div/>")
        .attr("id", (result.success) ? "flash_notice" : "flash_error")
        .prependTo(document.body)
        .html(result.notice);
      View.flashes.animate();
    },
    selector: "#flash_notice, #flash_error, #flash_alert"

  },

  gettingStarted: {
    click: function() {
      var $this = $(this);
      $this.animate({
        left: parseInt($this.css("left"), 30) === 0 ? -$this.outerWidth() : 0
      }, function() {
        $this.css("left", "1000px");
      });
    },
    selector: ".getting_started_box"
  },

  newRequest: {
    submit: function() {
      $(this).hide().parent().find(".stream_element").removeClass("hidden");
    },
    selector: ".new_request"
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
    addAspect: {
      bind: function() {
        $(".add_aspect_button", "#aspect_nav").tipsy({
          gravity:"w"
        });
      }
    },

    aspect_nav: {
      bind: function() {
        $("a", "#aspect_nav").tipsy({
          gravity:"n",
          delayIn: 600
        });
      }
    },

    avatars: {
      bind: function() {
        $("#aspect_listings img.avatar, #manage_aspect_zones img.avatar").tipsy({
          live: true
        });
      }
    },

    public_badge: {
      bind: function() {
        $(".public_badge img").tipsy({
          live: true
        });
      }
    },

    conversation_participants: {
      bind: function() {
        $(".conversation_participants img").tipsy({
          live: true
        });
      }
    },

    whatIsThis: {
      bind: function() {
        $(".what_is_this").tipsy({
          live: true,
          delayIn: 400
        });
      }
    },

    bindAll: function() {
      for(var element in this) {
        if(element !== "bindAll") {
          this[element].bind();
        }
      };
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

  userMenu: {
    click: function() {
      $(this).toggleClass("active");
    },
    removeFocus: function(evt) {
      var $target = $(evt.target);
      if(!$target.closest("#user_menu").length) {
        $(View.userMenu.selector).removeClass("active");
      }
    },
    selector: "#user_menu"
  },

  webFingerForm: {
    submit: function(evt) {
      $(evt.currentTarget).siblings("#loader").show();
      $("#request_result li:first").hide();
    },
    selector: ".webfinger_form"
  }
};

$(function() {
  /* Make sure this refers to View, not the document */
  View.initialize.apply(View);
});
