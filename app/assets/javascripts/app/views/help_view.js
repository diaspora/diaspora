$(document).ready(function() {
  $('#faq .question.collapsible').removeClass('opened').addClass('collapsed');
  $('#faq .question.collapsible .answer').hide();

  $('#faq .question.collapsible :first').addClass('opened').removeClass('collapsed');
  $('#faq .question.collapsible .answer :first').show();

  $('.question.collapsible a.toggle').click(function ( event ) {
    event.preventDefault();
    $(".answer", this.parentNode).toggle();
    $(this.parentNode).toggleClass('opened').toggleClass('collapsed');
  });
}); 
