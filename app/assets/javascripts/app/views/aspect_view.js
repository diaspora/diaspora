app.views.Aspect = app.views.Base.extend({
  templateName: "aspect",

  tagName: "li",

  className: 'sub_nav_item',

  initialize: function(){
    if (this.model.get('selected')){
      this.$el.addClass('active');
    };
  },

  events: {
    'click a.aspect_selector': 'toggleAspect'
  },

  toggleAspect: function(evt){
    if (evt) { evt.preventDefault(); };
    this.$el.toggleClass('active');
    this.$el.find('.icons-check_yes_ok').toggleClass('invisible')
    this.model.toggleSelected();
    app.router.aspects_stream();
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      aspect : this.model
    })
  }
});
