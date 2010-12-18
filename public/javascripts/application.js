//$(function () {  
  //$('#main_stream .pagination a').live('click', function () {  
      //$.getScript(this.href);  
      //return false;  
    //}
  //);
//});

// infinitescroll() is called on the element that surrounds 
// the items you will be loading more of
 $(document).ready(function() { 
$('#main_stream').infinitescroll({
   navSelector  : "div.pagination",            
                   // selector for the paged navigation (it will be hidden)
    nextSelector : ".pagination a.next_page",    
                   // selector for the NEXT link (to page 2)
    itemSelector : "#main_stream",
                   // selector for all items you'll retrieve
    bufferPx: 300,
    donetext: "no more.",
    loadingText: "", 
    loadingImg: 'images/ajax-loader.gif'
  });
});

