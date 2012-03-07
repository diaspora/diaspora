app.forms.Base = app.views.Base.extend({
  events :{
    'submit form' : 'setModelAttributes'
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
})
