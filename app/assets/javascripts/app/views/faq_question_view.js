// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
    var el = $(e.target);
    var parent = el.parents('.question');

    parent.children('.answer').toggle();
    parent.toggleClass('opened').toggleClass('collapsed');

    e.preventDefault();
  },
});
// @license-end

