
// TODO: this view should be model-driven an re-render when it was updated,
//   instead of changing classes/attributes on elements.
app.pages.Profile = Backbone.View.extend({
  events: {
    'click #block_user_button': 'blockPerson'
  },

  initialize: function(opts) {
    // cache element references
    this.el_profile_btns = this.$('#profile_buttons');
    this.el_sharing_msg  = this.$('#sharing_message');

    // init tooltips
    this.el_profile_btns.find('.profile_button div, .sharin_message_container')
      .tooltip({placement: 'bottom'});

    // respond to global events
    var person_id = this.$('#profile .avatar:first').data('person_id');
    app.events.on('person:block:'+person_id, this._markBlocked, this);
  },

  blockPerson: function(evt) {
    if( !confirm(Diaspora.I18n.t('ignore_user')) ) return;

    var person_id = $(evt.target).data('person-id');
    var block = new app.models.Block({block: {person_id: person_id}});
    block.save()
      .done(function() { app.events.trigger('person:block:'+person_id); })
      .fail(function() { Diaspora.page.flashMessages.render({
        success: false,
        notice: Diaspora.I18n.t('ignore_failed')
      }); });

    return false;
  },

  _markBlocked: function() {
    this.el_profile_btns.attr('class', 'blocked');
    this.el_sharing_msg.attr('class', 'icons-circle');

    this.el_profile_btns.find('.profile_button, .white_bar').remove();
  }
});
