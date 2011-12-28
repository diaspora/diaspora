app.views.Publisher = Backbone.View.extend({

  el : "#publisher",

  events : {
    "focus textarea" : "open",
    "click #hide_publisher" : "close",
    "submit form" : "createStatusMessage"
  },

  initialize : function(){
    this.collection = this.collection || new app.collections.Stream;
    return this;
  },

  createStatusMessage : function(evt) {
    if(evt){ evt.preventDefault(); }

    var serializedForm = $(evt.target).closest("form").serializeObject();

    // save status message
    var statusMessage = new app.models.StatusMessage();
    statusMessage.save({
      "status_message" : {
        "text" : serializedForm["status_message[text]"]
      },
      "aspect_ids" : serializedForm["aspect_ids[]"],
      "photos" : serializedForm["photos[]"]
    }, {
      success : $.proxy(function(data) {
        app.stream.collection.add(this);
      }, statusMessage)
    });

    // clear state
    this.clear();
  },

  clear : function() {
    // remove form data
    _.each(this.$('textarea'), function(element) {
      $(element).removeClass("with_attachments")
                .css("paddingBottom", "")
                .val("");
    });

    // remove photos
    this.$("#photodropzone").find('li').remove();

    // close publishing area (CSS)
    this.close();

    return this;
  },

  open : function() {
    $(this.el).removeClass('closed');
    this.$("#publisher_textarea_wrapper").addClass('active');
    this.$("textarea.ac_input").css('min-height', '42px');

    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.$("#publisher_textarea_wrapper").removeClass("active");
    this.$("textarea.ac_input").css('min-height', '');

    return this;
  }
});

// jQuery helper for serializing a <form> into JSON
$.fn.serializeObject = function()
{
  var o = {};
  var a = this.serializeArray();
  $.each(a, function() {
    if (o[this.name] !== undefined) {
      if (!o[this.name].push) {
        o[this.name] = [o[this.name]];
      }
      o[this.name].push(this.value || '');
    } else {
      o[this.name] = this.value || '';
    }
  });
  return o;
};
