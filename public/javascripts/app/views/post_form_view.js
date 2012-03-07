app.views.PostForm = app.views.Base.extend({
  templateName : "post-form",

  events :{
    'submit form' : 'setModelAttributes'
  },

  formAttrs : {
    ".text" : "text"
  },

  setModelAttributes : function(evt){
    if(evt){ evt.preventDefault(); }

    var form = this.$("form");

    function setValueFromField(memo, attribute, selector){
      memo[attribute] =  form.find(selector).val()
      return memo
    }

    this.model.set(_.inject(this.formAttrs, setValueFromField, {}))
    this.model.trigger("setFromForm")
  }
});