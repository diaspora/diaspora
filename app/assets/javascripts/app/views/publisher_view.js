/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

// TODO: split this up in modules:
// - base
// - services
// - aspect selector
// - getting started
app.views.Publisher = Backbone.View.extend({

  el : "#publisher",

  events : {
    "focus textarea" : "open",
    "click #hide_publisher" : "clear",
    "submit form" : "createStatusMessage",
    "click .service_icon": "toggleService",
    "textchange #status_message_fake_text": "handleTextchange",
    "click .dropdown .dropdown_list li": "toggleAspect"
  },

  initialize : function(){
    // init shortcut references to the various elements
    this.el_input = this.$('#status_message_fake_text');
    this.el_hiddenInput = this.$('#status_message_text');
    this.el_wrapper = this.$('#publisher_textarea_wrapper');
    this.el_submit = this.$('input[type=submit]');
    this.el_photozone = this.$('#photodropzone');

    // init mentions plugin
    Mentions.initialize(this.el_input);

    // init autoresize plugin
    this.el_input.autoResize({ 'extraSpace' : 10, 'maxHeight' : Infinity });

    // sync textarea content
    if( this.el_hiddenInput.val() == "" ) {
      this.el_hiddenInput.val( this.el_input.val() );
    }

    // this has to be here, otherwise for some reason the callback for the
    // textchange event won't be called in Backbone...
    this.el_input.bind('textchange', function(ev){
      //console.log(ev);
    });

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
          app.stream.items.add(statusMessage.toJSON());
        }
      }
    });

    // clear state
    this.clear();
  },

  clear : function() {
    // clear text(s)
    this.el_input.val('');
    this.el_hiddenInput.val('');

    // remove mentions
    this.el_input.mentionsInput('reset');

    // remove photos
    this.el_photozone.find('li').remove();
    this.$("input[name='photos[]']").remove();
    this.el_wrapper.removeClass("with_attachments");

    // close publishing area (CSS)
    this.close();

    // disable submitting
    this.checkSubmitAvailability();

    return this;
  },

  open : function() {
    // visually 'open' the publisher
    this.$el.removeClass('closed');
    this.el_wrapper.addClass('active');

    // fetch contacts for mentioning
    Mentions.fetchContacts();

    return this;
  },

  close : function() {
    $(this.el).addClass("closed");
    this.el_wrapper.removeClass("active");
    this.el_input.css('height', '');

    return this;
  },

  checkSubmitAvailability: function() {
    if( this._submittable() ) {
      this.el_submit.removeAttr('disabled');
    } else {
      this.el_submit.attr('disabled','disabled');
    }
  },

  // determine submit availability
  _submittable: function() {
    var onlyWhitespaces = ($.trim(this.el_input.val()) === ''),
        isPhotoAttached = (this.el_photozone.children().length > 0);

    return (!onlyWhitespaces || isPhotoAttached);
  },

  toggleService: function(evt) {
    var el = $(evt.target);
    var provider = el.attr('id');

    el.toggleClass("dim");

    this._createCounter();
    this._toggleServiceField(provider);
  },

  // keep track of character count
  _createCounter: function() {
    // remove obsolete counter
    this.$('.counter').remove();

    // create new counter
    var min = 40000;
    var a = this.$('.service_icon:not(.dim)');
    if(a.length > 0){
      $.each(a, function(index, value){
        var num = parseInt($(value).attr('maxchar'));
        if (min > num) { min = num; }
      });
      this.el_input.charCount({allowed: min, warning: min/10 });
    }
  },

  // add or remove the input containing the selected service
  _toggleServiceField: function(provider) {
    var hidden_field = this.$('input[name="services[]"][value="'+provider+'"]');
    if(hidden_field.length > 0){
      hidden_field.remove();
    } else {
      var uid = _.uniqueId('services_');
      this.$(".content_creation form").append(
      '<input id="'+uid+'" name="services[]" type="hidden" value="'+provider+'">');
    }
  },

  handleTextchange: function() {
    var self = this;

    this.checkSubmitAvailability();
    this.el_input.mentionsInput("val", function(value){
      self.el_hiddenInput.val(value);
    });
  },

  triggerGettingStarted: function() {
    this._addPopover(this.el_input, {
      trigger: 'manual',
      offset: 30,
      id: 'first_message_explain',
      placement: 'right',
      html: true
    }, 600);
    this._addPopover(this.$('.dropdown'), {
      trigger: 'manual',
      offset: 10,
      id: 'message_visibility_explain',
      placement: 'bottom',
      html: true
    }, 1000);
    this._addPopover($('#gs-shim'), {
      trigger: 'manual',
      offset: -5,
      id: 'stream_explain',
      placement: 'left',
      html: true
    }, 1400);

    // hide some popovers when a post is created
    this.$('.button.creation').click(function() {
      this.$('.dropdown').popover('hide');
      this.el_input.popover('hide');
    });
  },

  _addPopover: function(el, opts, timeout) {
    el.popover(opts);
    el.click(function() {
      el.popover('hide');
    });

    // show the popover after the given timeout
    setTimeout(function() {
      el.popover('show');

      // disable 'getting started' when the last popover is closed
      var popup = el.data('popover').$tip[0];
      var close = $(popup).find('.close');

      close.click(function() {
        if( $('.popover').length==1 ) {
          $.get('/getting_started_completed');
        }
        el.popover('hide');
      });
    }, timeout);
  },

  toggleAspect: function(evt) {
    var el = $(evt.target);
    var btn = el.parent('.dropdown').find('.button');

    // visually toggle the aspect selection
    if( el.is('.radio') ) {
      AspectsDropdown.toggleRadio(el);
    } else {
      AspectsDropdown.toggleCheckbox(el);
    }

    // update the selection summary
    AspectsDropdown.updateNumber(
      el.closest(".dropdown_list"),
      null,
      el.parent().find('li.selected').length,
      ''
    );

    this._updateSelectedAspectIds();
  },

  _updateSelectedAspectIds: function() {
    var self = this;

    // remove previous selection
    this.$('input[name="aspect_ids[]"]').remove();

    // create fields for current selection
    this.$('.dropdown .dropdown_list li.selected').each(function() {
      var el = $(this);
      var aspectId = el.data('aspect_id');

      self._addHiddenAspectInput(aspectId);

      // close the dropdown when a radio item was selected
      if( el.is('.radio') ) {
        el.closest('.dropdown').removeClass('active');
      }
    });
  },

  _addHiddenAspectInput: function(id) {
    var uid = _.uniqueId('aspect_ids_');
    this.$('.content_creation form').append(
      '<input id="'+uid+'" name="aspect_ids[]" type="hidden" value="'+id+'">'
    );
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
