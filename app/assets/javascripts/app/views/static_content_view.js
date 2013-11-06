app.views.StaticContentView = app.views.Base.extend({

  events: {
  },

  initialize : function(templateName, data) {
    this.templateName = templateName;
    this.data = data;

    return this;
  },

  presenter : function(){
    return this.data;
  },
});