$(function(){
  $('.log').each(function(){
    scrollToBottom(this);
  })
  tailLog();
  
  $('a.continue-button').click(function(){
    if($(this).hasClass('deploying')) {
      return(false);
    }
  });
});

function scrollToBottom(scrollable) {
  $(scrollable).attr('scrollTop', $(scrollable).attr('scrollHeight'));
}

function tailLog() {
  if($('.log').length) {
    var d = new Date;
    $('.log').load(
      $('.log').attr('data-location'),
      ''+d.getTime(),
      function(responseText, textStatus, XMLHttpRequest){ 
        scrollToBottom(this);
        if(XMLHttpRequest.statusText == 'OK') {
          $('a.continue-button').removeClass('deploying').text('Continue');
        } else {
          // Status == 'Partial Content'
          // lets get more
          setTimeout("tailLog()", 500);
        }
      }
    );
  }
}