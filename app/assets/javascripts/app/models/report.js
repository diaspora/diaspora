app.models.Report = Backbone.Model.extend({
  urlRoot: '/report',

  getReason: function() {
    return prompt(Diaspora.I18n.t('report_prompt'), Diaspora.I18n.t('report_prompt_default'));
  }

});
