
(function(){
  app.helpers.showModal = function(id, statusMessagePath, title){
    $(id).modal();

    //var modalBody = $(id).find(".modal-body");

    //$(id).find(".modal-title").text(title);
    var $modalTitle = $(id).find(".modal-title");

    if($('showMentionModal').modal()) {
      if(statusMessagePath){
        // $(id).find(".modal-title").text(title);
        if($modalTitle.data("original-title") == null){
          $modalTitle.data("original-title", $modalTitle[0].textContent);
        }

        var $modalTitle = $(id).find(".modal-title");
        var modalBody = $(id).find(".modal-body");
        
        $modalTitle.text(title);
        modalBody.load(statusMessagePath, function(){
          $(id).find("#modalWaiter").remove();
        });  
      }
      else{

      	if($modalTitle.data("original-title") != null){
          $modalTitle.text($modalTitle.data("original-title"));
        }
        // $(id).find(".modal-title").text(title);
        var profileMention = $(id).find(".modal-body");
        var url = $(id).attr("href");
        profileMention.load(url, function(){
          $(id).find("#modalWaiter").remove();
        });
      }
    }

    // var url = $(id).attr("href");
    // modalBody.load(url, function(){
    //   $(id).find("#modalWaiter").remove();
    // });
  };
})();

// (function(){
//   app.helpers.showModal = function(id, statusMessagePath, title, conversationPath, title_message){
//     $(id).modal();
    
//     //var modalHeader = $(id).find(".modal-header");

//     $(id).find(".modal-title").text(title);
    
//     var $modalTitle = $(id).find(".modal-title");

//     // var profileMention = $(id).find(".modal-body");
//     // if ($('showMessageModal').modal()) {
//     //   var message = $(id).find(".modal-body");
//     //   var url = $(id).attr("href");
      
//     //   message.load(url, function(){
//     //     $(id).find("#modalWaiter").remove();
//     //   });
//     // }
//     if($('showMentionModal').modal()) {
//       if(statusMessagePath){
//         // $(id).find(".modal-title").text(title);

//         if($modalTitle.data("original-title") == null){
//           $modalTitle.data("original-title", $modalTitle[0].textContent);
//         }

//         $modalTitle.text(title);

//         var modalBody = $(id).find(".modal-body");

//         modalBody.load(statusMessagePath, function(){
//           $(id).find("#modalWaiter").remove();
//         });  
//       }
//       else{

//         if($modalTitle.data("original-title") != null){
//           $modalTitle.text($modalTitle.data("original-title"));
//         }
//         // $(id).find(".modal-title").text(title);
//         var profileMention = $(id).find(".modal-body");
//         var url = $(id).attr("href");
//         profileMention.load(url, function(){
//           $(id).find("#modalWaiter").remove();
//         });
//       }
//     }
//     else if($('showMessageModal').modal()) {
//       var message = $(id).find(".modal-body");
//       // var url = $(id).attr("href");
      
//       message.load(conversationPath, function(){
//         $(id).find("#modalWaiter").remove();
//       });
//     }


//   };
// })();
