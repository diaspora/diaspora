/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
var View = {
  initialize: function() {
    /* Buttons */
    $("input[type='submit']").addClass("button");

    /* Tooltips */
    this.tooltips.bindAll();

    /* Animate flashes */
    this.flashes.animate();

    /* In field labels */
    $("label").inFieldLabels();

    /* Focus aspect name on fancybox */
    $(this.addAspectButton.selector)
      .click(this.addAspectButton.click);

    /* Showing debug messages  */
    $(this.debug.selector)
      .click(this.debug.click);

    /* "Toggling" the search input */
    $(this.search.selector)
      .blur(this.search.blur)
      .focus(this.search.focus);

    /* Getting started animation */
    $(this.gettingStarted.selector)
      .live("click", this.gettingStarted.click);

    /* Submitting the status message form when the user hits enter */
    $(this.publisher.selector)
      .keydown(this.publisher.keydown);

    /* User menu */
    $(this.userMenu.selector)
      .click(this.userMenu.click);

    /* Sending a request message */
    $(this.newRequest.selector)
      .live("submit", this.newRequest.submit);

    /* Button fancyboxes */
    $(this.fancyBoxButtons.selectors.join(", "))
      .fancybox({
         'titleShow': false,
         'hideOnOverlayClick': false
      });

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
  },

  addAspectButton: {
    click: function() {
      $("#aspect_name").focus();
    },
    selector: ".add_aspect_button"
  },

  fancyBoxButtons: {
    selectors: [
      ".add_aspect_button",
      ".manage_aspect_contacts_button",
      ".invite_user_button",
      ".add_photo_button",
      ".remove_person_button",
      ".question_mark",
      ".share_with_button"
    ]
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
      $(this).hide().parent().find(".message").removeClass("hidden");
    },
    selector: ".new_request"
  },

  publisher: {
    keydown: function(e) {
      if(e.keyCode === 13) {
        if(!e.shiftKey) {
          $(this).closest("form").submit();
        }
      }
    },
    selector: "#publisher textarea"
  },

  search: {
    blur: function() {
      $(this).removeClass("active");
    },
    focus: function() {
      $(this).addClass("active");
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

    avatars: {
      bind: function() {
        $(".contact_pictures img.avatar, #manage_aspect_zones img.avatar").tipsy({
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
