(function(){
  app.helpers.showModal = function(id, statusMessagePath, title){
    $(id).modal();
    
    //var modalHeader = $(id).find(".modal-header");

    $(id).find(".modal-title").text(title);
    

    // var profileMention = $(id).find(".modal-body");

    

    if(statusMessagePath){
      var modalBody = $(id).find(".modal-body");
      modalBody.load(statusMessagePath, function(){
        $(id).find("#modalWaiter").remove();
      });
    }
    else{
      var profileMention = $(id).find(".modal-body");
      var url = $(id).attr("href");
      profileMention.load(url, function(){
        $(id).find("#modalWaiter").remove();
      });
    }
    


  };
})();
