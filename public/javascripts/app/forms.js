app.forms.Base = app.views.Base.extend({
  events :{
    'submit form' : 'setModelAttributes'
  },

  setModelAttributes : function(evt){
    if(evt){ evt.preventDefault(); }

    var form = this.$("form");

    function setValueFromField(memo, attribute, selector){
      var selectors = form.find(selector);

      if(selectors.length > 1) {
        memo[attribute] = _.map(selectors, function(selector){
          return $(selector).val()
        })
      } else {
        memo[attribute] = selectors.val();
      }

      return memo
    }

    this.model.set(_.inject(this.formAttrs, setValueFromField, {}))
    this.model.trigger("setFromForm")
  }
})
