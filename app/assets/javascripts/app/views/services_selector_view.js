app.views.ServicesSelector = app.views.Base.extend({

  templateName : "services-selector",

  events : {
    "click label" : "askForAuth"
  },

  tooltipSelector : "img",

  services : [
    'facebook',
    'twitter',
    'tumblr'
  ],

  presenter : function() {
    var selectedServices = this.model.get('services');

    return _.extend(this.defaultPresenter(), {
      services :_.map(this.services, function(service){
        return {
          name : service,
          checked :_.include(selectedServices, service)
        }
      })
    })
  },

  askForAuth : function(evt){
    var $target = $(evt.target);

    if(app.currentUser.isServiceConfigured($target.data('provider'))) { return }

    var serviceUrl = $target.data('url')
    window.open(serviceUrl, 'popup', 'height=400,width=500')
  }

});
