app.views.AspectsList = app.views.Base.extend({
  templateName: 'aspects-list',

  el: '#aspects_list',

  events: {
    'click .toggle_selector' : 'toggleAll'
  },

  initialize: function(){
    this.collection.on('change', this.toggleSelector, this);
    this.collection.on('change', this.updateStreamTitle, this);
  },

  postRenderTemplate: function() {
    this.collection.each(this.appendAspect, this);
    this.$('a[rel*=facebox]').facebox();
    this.updateStreamTitle();
    this.toggleSelector();
  },

  appendAspect: function(aspect) {
    $("#aspects_list > *:last").before(new app.views.Aspect({
      model: aspect, attributes: {'data-aspect_id': aspect.get('id')}
    }).render().el);
  },

  toggleAll: function(evt){
    if (evt) { evt.preventDefault(); };

    if (this.collection.allSelected()) {
      this.collection.deselectAll();
      this.$('li:not(:last)').removeClass("active");
    } else {
      this.collection.selectAll();
      this.$('li:not(:last)').addClass("active");
    }

    this.toggleSelector();
    app.router.aspects_stream();
  },

  toggleSelector: function(){
    var selector = this.$('a.toggle_selector');
    if (this.collection.allSelected()) {
      selector.text(Diaspora.I18n.t('aspect_navigation.deselect_all'));
    } else {
      selector.text(Diaspora.I18n.t('aspect_navigation.select_all'));
    }
  },

  updateStreamTitle: function(){
    $('.stream_title').text(this.collection.toSentence());
  }
})
