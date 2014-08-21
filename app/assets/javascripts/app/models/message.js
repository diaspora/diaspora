app.models.Message = Backbone.Model.extend({
  urlRoot: "/messages",

  saveDraft : function() {
    localStorage.setItem('message', JSON.stringify(this.attributes) );
  },

  getDraft : function() {
    return JSON.parse(localStorage.getItem("message")).text;
  }
});
