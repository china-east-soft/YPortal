function timeCountDown(countdown_tag,duration)
{
   
  // variables for time units
  var hours, minutes, seconds;
 
  // get tag element
  var countdown = document.getElementById(countdown_tag);
  
  // update the tag with id "countdown" every 1 second
  var refreshIntervalId = setInterval(function () {
    if(duration >= 0) {
      // find the amount of "seconds" between now and target
      var seconds_left = duration;
       
      hours = parseInt(seconds_left / 3600);
      seconds_left = seconds_left % 3600;
       
      minutes = parseInt(seconds_left / 60);
      seconds = parseInt(seconds_left % 60);
       
      // format countdown string + set tag value
      countdown.innerHTML = hours + " 小时 "
      + minutes + " 分 " + seconds + " 秒";     
    } else {
      window.clearInterval(refreshIntervalId);
    }
  
    duration = duration - 1;
   
  }, 1000);
}