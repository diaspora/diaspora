app.views.FaqQuestionView = app.views.Base.extend({

  templateName: "faq_question",

  events: {
    "click .question.collapsible a.toggle" : "toggled"
  },

  initialize : function(d) {
    this.data = d;
    return this;
  },

  presenter : function(){
    return this.data;
  },

  render: function(){
    var section = app.views.Base.prototype.render.apply(this, arguments);

    // After render actions
    this.$('.question.collapsible').removeClass('opened').addClass('collapsed');
    this.$('.answer').hide();

    return section;
  },

  toggled: function(e) {
    el = $(e.target);
    parent = el.parents('.question');

    parent.children('.answer').toggle();
    parent.toggleClass('opened').toggleClass('collapsed');

    e.preventDefault();
  },
});