// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
//= require mailchimp/jquery.form
var View = {
  initialize: function() {
    /* Buttons */
    $("input:submit").addClass("button");

    /* label placeholders */
    $("input, textarea").placeholder();

    /* "Toggling" the search input */
    $(this.search.selector)
      .blur(this.search.blur)
      .focus(this.search.focus)

    /* Submit the form when the user hits enter */
      .keypress(this.search.keyPress);

    /* Dropdowns */
    $(document)
      .on('click', this.dropdowns.selector, this.dropdowns.click)
      .on('keypress', this.dropdowns.selector, this.dropdowns.click);

    /* Avatars */
    $(this.avatars.selector).error(this.avatars.fallback);

    /* Clear forms after successful submit, this is some legacy dan hanson stuff, do we still want it? */
    $.fn.clearForm = function() {
      return this.each(function() {
        if ($(this).is('form') && !$(this).hasClass('form_do_not_clear')) {
          return $(':input', this).clearForm();
        }
        if ($(this).hasClass('clear_on_submit') || $(this).is(':text') || $(this).is(':password') || $(this).is('textarea')) {
          $(this).val('');
        } else if ($(this).is(':checkbox') || $(this).is(':radio')) {
          $(this).attr('checked', false);
        } else if ($(this).is('select')) {
          this.selectedIndex = -1;
        } else if ($(this).attr('name') == 'photos[]') {
          $(this).val('');
        }
        $(this).blur();
      });
    };

    $(document).on('ajax:success', 'form[data-remote]', function (e) {
      $(this).clearForm();
      $(this).focusout();
    });

    /* tag following */
    $("#new_tag_following .tag_input").bind('focus', function(evt){
      $(this).siblings("#tag_following_submit").removeClass('hidden');
    });

    /* photo exporting in the works */
    $("#photo-export-button").bind("click", function(evt){
      evt.preventDefault();
      alert($(this).attr('title'));
    });

    $(document.body).click(this.dropdowns.removeFocus);

    $('a[rel*=facebox]').facebox();
    $(document).bind('reveal.facebox', function() {
      Diaspora.page.directionDetector.updateBinds();
    });

    $("a.new_aspect").click(function(e){
      $("input#aspect_name").focus()
    });

    /* facebox 'done' buttons */
    $(document).on('click', "*[rel*=close]", function(){ $.facebox.close(); });

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
    selector: "#q"
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
      $(this).attr("src", ImagePaths.get("user/default.png"));
    },
    selector: "img.avatar"
  }
};

$(function() {
  View.initialize();
});
// @license-end

