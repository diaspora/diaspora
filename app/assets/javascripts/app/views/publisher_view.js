//this file is the scary no-no-zone bad-touch of our backbone code.
//after re-writing/eliminating the existing Publisher let's re-write
//this with PANACHE!    <333 Dennis

app.views.Publisher = Backbone.View.extend({
  
  el : "#publisher",

  events : {
    "focus textarea" : "open",
    "click #hide_publisher" : "clear",
    "submit form" : "createStatusMessage"
  },

  initialize : function(){
    this.collection = this.collection //takes a Posts collection
    return this;
  },

  createStatusMessage : function(evt) {
    if(evt){ evt.preventDefault(); }

    var serializedForm = $(evt.target).closest("form").serializeObject();

    // lulz this code should be killed.
    var statusMessage = new app.models.Post();

    statusMessage.save({
      "status_message" : {
        "text" : serializedForm["status_message[text]"]
      },
      "aspect_ids" : serializedForm["aspect_ids[]"],
      "photos" : serializedForm["photos[]"],
      "services" : serializedForm["services[]"]
    }, {
      url : "/status_messages",
      success : function() {
        if(app.publisher) {
          $(app.publisher.el).trigger('ajax:success');
        }
        if(app.stream) {
          statusMessage.set({"user_participation": new app.models.Participation});
          app.stream.items.add(statusMessage.toJSON());
        }
      }
    });

    // clear state
    this.clear();
  },

  clear : function() {
    this.$('textarea').val("");
    this.$('#publisher_textarea_wrapper').removeClass("with_attachments");

    // remove photos
    this.$("#photodropzone").find('li').remove();
    this.$("input[name='photos[]']").remove();

    // close publishing area (CSS)
    this.close();

    Publisher.clear()

    return this;
  },

  open : function() {
    $(this.el).removeClass('closed');
    this.$("#publisher_textarea_wrapper").addClass('active');

    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.$("#publisher_textarea_wrapper").removeClass("active");
    this.$("textarea").css('height', '');

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
