app.views.HelpSectionView = app.views.StaticContentView.extend({

  events: {
    "click .question.collapsible a.toggle" : "toggled"
  },

  initialize : function(templateName, data, subs) {
    this.templateName = templateName;
    this.data = this.makeSubs(data, subs);

    return this;
  },

  render: function(){
    var section = app.views.Base.prototype.render.apply(this, arguments);

    // After render actions
    $(this.el).find('.question.collapsible').removeClass('opened').addClass('collapsed');
    $(this.el).find('.answer.hideable').hide();
    $(this.el).find('.question.collapsible :first').addClass('opened').removeClass('collapsed');
    $(this.el).find('.answer.hideable :first').show();

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