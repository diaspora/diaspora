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

  afterRender: function(){
    console.log("Rendered yo")
    var el = $(this.el)
    el.find('.question.collapsible').removeClass('opened').addClass('collapsed');
    el.find('.answer').hide();
  },

  toggled: function(e) {
    el = $(e.target);
    parent = el.parents('.question');

    parent.children('.answer').toggle();
    parent.toggleClass('opened').toggleClass('collapsed');

    e.preventDefault();
  },
});