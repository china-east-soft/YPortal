$( document ).ready(function() {
  /*-------------------------------------------*/
  var InterValObj; //timer变量，控制时间
  var count = 60; //间隔函数，1秒执行
  var curCount;//当前剩余秒数

  $( "#send_message" ).click(function(event) {
    event.preventDefault();
    curCount = count;
    var uid = ""
    var account_mobile = ""
    var controller_name = ""
    if($("#merchant_mobile").length > 0){
      uid=$("#merchant_mobile").val();//用户uid
    }
    if($("#account_mobile").length > 0){
      account_mobile = $("#account_mobile").val();
    } else if($("#app_account_mobile").length > 0){
      account_mobile = $("#app_account_mobile").val();
    }

    if($("#controller_name").length > 0){
      controller_name = $("#controller_name").val();
    }

    //设置button效果，开始计时
    $("#send_message").attr("disabled", "true");
    $("#send_message").text(curCount + " 秒后重发");
    InterValObj = window.setInterval(SetRemainTime, 1000); //启动计时器，1秒执行一次

    $.ajax({
      type: "get",
      dataType: "text", //数据格式:JSON
      url: '/welcome/generate_verify_code', //目标地址
      data: "uid=" + uid + "&account_mobile=" + account_mobile + "&controller_name=" + controller_name,
      error: function (XMLHttpRequest, textStatus, errorThrown) { },
      success: function (msg){ }
    });

  });


  function SetRemainTime() {
      if (curCount == 0) {                
          window.clearInterval(InterValObj);//停止计时器
          $("#send_message").removeAttr("disabled");//启用按钮
          $("#send_message").text("重发验证码");
          code = ""; //清除验证码。如果不清除，过时间后，输入收到的验证码依然有效    
      }
      else {
          curCount--;
          $("#send_message").text(curCount + " 秒后重发");
      }
  }
});