(function(){
  app.helpers.showModal = function(id){
    $(id).modal();
    var modalBody = $(id).find(".modal-body");

    var url = $(id).attr("href");

    modalBody.load(url, function(){
      $(id).find("#modalWaiter").remove();
      autosize($("textarea", modalBody));
      $(id).trigger("modal:loaded");
    });
  };
})();
