$(function(){
  $('.log').each(function(){
    scrollToBottom(this);
  })
  tailLog();
});

function scrollToBottom(scrollable) {
  $(scrollable).attr('scrollTop', $(scrollable).attr('scrollHeight'));
}

function tailLog() {
  if($('.log').length) {
    $('.log').load(
      $('.log').attr('data-location'),
      '',
      function(responseText, textStatus, XMLHttpRequest){ 
        scrollToBottom(this);
        if(XMLHttpRequest.statusText == 'Success') {
          alert('Install Complete');
        } else {
          // Status == 'Partial Content'
          // lets get more
          setTimeout("tailLog()", 3000);
        }
      }
    );
  }
}