app.forms.Base = app.views.Base.extend({
  formSelector : "form",

  initialize : function() {
    this.setupFormEvents()
  },

  setupFormEvents : function(){
    this.events = {}
    this.events['submit ' + this.formSelector] =  'setModelAttributes';
    this.delegateEvents();
  },

})
