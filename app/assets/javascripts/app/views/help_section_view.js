app.views.HelpSectionView = app.views.StaticContentView.extend({

  events: {
    "click .question.collapsible a.toggle" : "toggled"
  },

  initialize : function(options) {
    this.templateName = options.template;
    this.data = this.makeSubs(options.data, options.subs);

    return this;
  },

  render: function(){
    var section = app.views.Base.prototype.render.apply(this, arguments);

    // After render actions
    this.$('.question.collapsible').removeClass('opened').addClass('collapsed');
    this.$('.answer.hideable').hide();
    this.$('.question.collapsible :first').addClass('opened').removeClass('collapsed');
    this.$('.answer.hideable :first').show();

    return section;
  },

  toggled: function(e) {
    el = $(e.target);
    parent = el.parents('.question');

    parent.children('.answer.hideable').toggle();
    parent.toggleClass('opened').toggleClass('collapsed');

    e.preventDefault();
  },

  makeSubs: function(locales, subs) {
    var self = this;

    $.each( subs, function(k, vs){
      if (locales.hasOwnProperty(k)){
        $.each( vs, function(tag, rep){
          locales[k] = self.replace(locales[k], tag, rep);
        });
      }
    });

    return locales;
  },

  replace: function(theString, tag, replacement){
    return theString.replace("%{" + tag + "}", replacement);
  },

});
