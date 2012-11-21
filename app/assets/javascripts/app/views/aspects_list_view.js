app.views.AspectsList = app.views.Base.extend({
  templateName: 'aspects-list',

  el: '#aspects_list',

  postRenderTemplate : function() {
    this.collection.each(this.appendAspect, this);
    this.$('a[rel*=facebox]').facebox();
  },

  appendAspect: function(aspect) {
    $("#aspects_list > *:last").before(new app.views.Aspect({
      model: aspect, attributes: {'data-aspect_id': aspect.get('id')}
    }).render().el);
  }

})
