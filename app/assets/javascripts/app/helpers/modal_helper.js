(function(){
  app.helpers.showModal = function(id, statusMessagePath, title, conversationPath){
    $(id).modal();
    
    //var modalHeader = $(id).find(".modal-header");

    $(id).find(".modal-title").text(title);
    

    // var profileMention = $(id).find(".modal-body");
    // if ($('showMessageModal').modal()) {
    //   var message = $(id).find(".modal-body");

      
    //   message.load(conversationPath, function(){
    //     $(id).find("#modalWaiter").remove();
    //   });
    // }
    if($('showMentionModal').modal()) {
      if(statusMessagePath){
        // $(id).find(".modal-title").text(title);
        var modalBody = $(id).find(".modal-body");
        modalBody.load(statusMessagePath, function(){
          $(id).find("#modalWaiter").remove();
        });
      }
      else{
        // $(id).find(".modal-title").text(title);
        var profileMention = $(id).find(".modal-body");
        var url = $(id).attr("href");
        profileMention.load(url, function(){
          $(id).find("#modalWaiter").remove();
        });
      }
    }


  };
})();
