// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
var View = {
  initialize: function() {
    /* Buttons */
    $("input:submit").addClass("button");

    /* label placeholders */
    $("input, textarea").placeholder();

    /* Dropdowns */
    $(document)
      .on('click', this.dropdowns.selector, this.dropdowns.click)
      .on('keypress', this.dropdowns.selector, this.dropdowns.click);

    $(document).on('ajax:success', 'form[data-remote]', function () {
      $(this).clearForm();
      $(this).focusout();
    });

    /* tag following */
    $("#new_tag_following .tag_input").bind('focus', function(){
      $(this).siblings("#tag_following_submit").removeClass('hidden');
    });

    $(document.body).click(this.dropdowns.removeFocus);

    $("a.new_aspect").click(function(){
      $("input#aspect_name").focus();
    });

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
  }
};

$(function() {
  View.initialize();
});
// @license-end
