// JavaScript Document
function visitorList_click(){
    jQuery("#visitorList").addClass("selected");
    jQuery("#mBlacklist").removeClass("selected");
    jQuery("#chooseBox").show();
    jQuery("#intoBlacklist").show();
    jQuery("#outBlacklist").hide();
    }
    //
function mBlacklist_click(){
    jQuery("#visitorList").removeClass("selected");
    jQuery("#mBlacklist").addClass("selected");
    jQuery("#chooseBox").hide();
    jQuery("#intoBlacklist").hide();
    jQuery("#outBlacklist").show();
    }
    //访客列表tab
function CheckAll(elementsA,elementsB)
{
    var len = elementsA;
    if(len.length > 0)
    {
        for(i=0;i<len.length;i++)
        {
            elementsA[i].checked = true;
        }
        if(elementsB.checked ==false)
        {
            for(j=0;j<len.length;j++)
            {
                elementsA[j].checked = false;
            }
        }
    }
    else
    {
        len.checked = true;
        if(elementsB.checked == false)
        {
            len.checked = false;
        }
    }
}
jQuery(function () {
    jQuery("input[name='chk_id']").click(function(){
        if(jQuery(this).attr("checked")){
            return true;
        }else{
            jQuery("#chk_all").attr("checked",false);
        }
    })
})
//访客列表全选
jQuery(function(){
    jQuery("#visitorList_lately").click(function(){
        jQuery("#visitorList_lately").siblings(".visitorSort").show();
        jQuery("#visitorList_first").siblings(".visitorSort").hide();
        })
    jQuery("#visitorList_first").click(function(){
        jQuery("#visitorList_first").siblings(".visitorSort").show();
        jQuery("#visitorList_lately").siblings(".visitorSort").hide();
        })
    })
//访客列表排序
jQuery(function(){
    if(jQuery("#isLoginOne").attr("checked")){
        jQuery("#whitelistB,#whitelistBtn").show();
    }
    else{
        jQuery("#whitelistB,#whitelistBtn").hide();
    }
})
//白名单
 jQuery(function(){
       jQuery("a.sliderBox_a").click(function(){
          jQuery(this).parents(".liBox").siblings(".liBox_shade").show();
          jQuery("#onkey").removeAttr("checked"); 
          jQuery("#onkey").siblings(".tzCheckBox").removeClass("checked"); 
          jQuery("#onkey").siblings(".tzCheckBox").children(".tzCBContent").html("已关闭");    
        });
       jQuery("a#qq_a").click(function(){
          jQuery("#qqLogin").show();
          var ii=0;
          jQuery(".otherLogin").each(function(){
            if(jQuery(this).is(":visible")==true){
                  ii++;
              } 
            })
          if(ii>3){
              loginNum();
              jQuery("#qqLogin").hide();
              jQuery(this).parents(".liBox").siblings(".liBox_shade").hide();
              }
        });
       jQuery("a#wb_a").click(function(){
          jQuery("#wbLogin").show();
          var ii=0;
          jQuery(".otherLogin").each(function(){
            if(jQuery(this).is(":visible")==true){
                  ii++;
              } 
            })
          if(ii>3){
              loginNum();
              jQuery("#wbLogin").hide();
              jQuery(this).parents(".liBox").siblings(".liBox_shade").hide();
              }
        });
       jQuery("a#wx_a").click(function(){
          jQuery("#wxLogin").show();
          var ii=0;
          jQuery(".otherLogin").each(function(){
            if(jQuery(this).is(":visible")==true){
                  ii++;
              } 
            })
          if(ii>3){
              loginNum();
              jQuery("#wxLogin").hide();
              jQuery(this).parents(".liBox").siblings(".liBox_shade").hide();
              }
        });
       jQuery("a#alipay_a").click(function(){
          jQuery("#alipayLogin").show();
          var ii=0;
          jQuery(".otherLogin").each(function(){
            if(jQuery(this).is(":visible")==true){
                  ii++;
              } 
            })
          if(ii>3){
              loginNum();
              jQuery("#alipayLogin").hide();
              jQuery(this).parents(".liBox").siblings(".liBox_shade").hide();
              }
        });
        
    });
//缩小

function openSet_sub(){

      var ii=0;
      jQuery(".otherLogin").each(function(){
        if(jQuery(this).is(":visible")==true){
              ii++;
          } 
        })
      if(jQuery("#onkeyBox>.tzCheckBox").hasClass("checked") || jQuery("#phoneBox>.tzCheckBox").hasClass("checked") || ii>0){           
        saveSuccess();
      }
      else{
        loginConfirm();
      }
}
//提交
function jQuery_jqtab(){
    jQuery.jqtab = function(tabtit,tab_conbox,shijian) {
        jQuery(tab_conbox).find("li").hide();
        jQuery(tabtit).find("li:first").addClass("thistab").show(); 
        jQuery(tab_conbox).find("li:first").show();
    
        jQuery(tabtit).find("li").bind(shijian,function(){
          jQuery(this).addClass("thistab").siblings("li").removeClass("thistab"); 
            var activeindex = jQuery(tabtit).find("li").index(this);
            jQuery(tab_conbox).children().eq(activeindex).show().siblings().hide();
            return false;
        });
    };
    /*调用方法如下：*/
    jQuery.jqtab("#set_tabs","#set_tab_conbox","click");
    //选项卡
}
function js_ocmmon(){
    var text=jQuery("#edit_myfrom textarea").val();
    var counter=text.length;
    jQuery("#numtj span").text(counter);
    jQuery(document).keyup(function() {
        var text=jQuery("#edit_myfrom textarea").val();
        var counter=text.length;
        jQuery("#numtj span").text(counter);
    });
//字数统计
    jQuery('input[type=checkbox]').tzCheckbox({labels:['Enable','Disable']});
    if(jQuery("#isLoginOne").attr("checked")){
        jQuery("#whitelistB,#whitelistBtn").show();
    }
    else{
        jQuery("#whitelistB,#whitelistBtn").hide();
    }
    jQuery("#isLoginOne_box .tzCheckBox").click(function(){
        if(jQuery(this).hasClass("checked")){           
            jQuery("#whitelistB,#whitelistBtn").show();
        }
        else{
            jQuery("#whitelistB,#whitelistBtn").hide();
        }
    })  
    /*认证限制*/
    if(jQuery("#onkey").attr("checked")){
        jQuery(".otherLogin").hide();
        //jQuery(".setBox_shade").show();
        jQuery(".liBox_shade").hide();
    }
    else{
        jQuery(".setBox_shade").hide();
    }
    jQuery("#onkeyBox .tzCheckBox").click(function(){
        if(jQuery(this).hasClass("checked")){           
            openO_line();
        }
        else{
            jQuery(".setBox_shade").hide();
        }
    })  
    /*一键上网*/
    if(jQuery("#phoneBtn").attr("checked")){
        jQuery("#onkey").removeAttr("checked"); 
        jQuery("#onkey").siblings(".tzCheckBox").removeClass("checked"); 
        jQuery("#onkey").siblings(".tzCheckBox").children(".tzCBContent").html("已关闭");      
        }
    jQuery("#phoneBox .tzCheckBox").click(function(){
        if(jQuery(this).hasClass("checked")){           
            jQuery("#onkey").removeAttr("checked"); 
            jQuery("#onkey").siblings(".tzCheckBox").removeClass("checked"); 
            jQuery("#onkey").siblings(".tzCheckBox").children(".tzCBContent").html("已关闭");      
        }
    })  
    /*手机号登录*/
    if(jQuery("#wbFollow").attr("checked")){
        jQuery("#focusList").show();
    }
    else{
        jQuery("#focusList").hide();
    }
    jQuery("#focusList_open .tzCheckBox").click(function(){
        if(jQuery(this).hasClass("checked")){           
            jQuery("#focusList").show();
        }
        else{
            jQuery("#focusList").hide();
        }
    })  
    /*微博关注*/
    jQuery(".loginBtn_a").click(function(){
        jQuery(this).parents(".otherLogin").hide(); 
    })
    jQuery("#loginBtn_qq").click(function(){
        jQuery("#liBox_shade_qq").hide(); 
    })//qq
    jQuery("#loginBtn_wb").click(function(){
        jQuery("#liBox_shade_wb").hide(); 
    })//wb
    jQuery("#loginBtn_wx").click(function(){
        jQuery("#liBox_shade_wx").hide(); 
    })//wx
    jQuery("#loginBtn_al").click(function(){
        jQuery("#liBox_shade_al").hide(); 
    })//al
    /*取消关注*/
    jQuery("#sliderBox").xslider({
        unitdisplayed:4,
        movelength:1,
        unitlen:166,
        autoscroll:5000
    });
    /*左右滚动*/
}
//openSet
function copyob1toob2(){
        document.all["input_title2"].value=document.all["input_title1"].value
    }
function copyob2toob1(){
        document.all["input_title1"].value=document.all["input_title2"].value
    }
//同步输入

function zdy_mkClose(){
    jQuery("#zdy_mkBok").hide();
}
//删除自定义模块
function js_homeSet(){
    jQuery("#input_title1,#input_title2").mouseover(function(){
        jQuery("#input_title1,#input_title2").css("border","1px #ff5a00 solid");
        })
    jQuery("#input_title1,#input_title2").mouseout(function(){
        jQuery("#input_title1").css("border","1px #D7D7D7 solid");
        jQuery("#input_title2").css("border","0px");
        })
    jQuery("#rz_focusBtn>.btn_styleWhite,.focusImg").mouseover(function(){
        jQuery("#rz_focusBtn>.btn_styleWhite,.focusImg").css("border","1px #ff5a00 solid");
        })
    jQuery("#rz_focusBtn>.btn_styleWhite,.focusImg").mouseout(function(){
        jQuery("#rz_focusBtn>.btn_styleWhite").css("border","1px #D7D7D7 solid");
        jQuery(".focusImg").css("border","1px #fff solid");
        })
    
    //鼠标变色
    /*
    jQuery(".capslide_img_cont").capslide({
        caption_color   : 'white',
        caption_bgcolor : 'black',
        overlay_bgcolor : 'black',
        showcaption     : false
    });
    */

    //图片显示信息
    /*jQuery(".m_boxDelete").click(function(){
        jQuery(this).parents("li").hide();
    })//公用删除*/
    jQuery("#intrBtn").click(function(){
        jQuery("#intrLeft_box").show();
    })
    jQuery("#photoBtn").click(function(){
        jQuery("#photoLeft_box").show();
    })
    jQuery("#actBtn").click(function(){
        jQuery("#actLeft_box").show();
    })
    jQuery("#follBtn").click(function(){
        jQuery("#follLeft_box").show();
    })
    jQuery("#aliBtn").click(function(){
        jQuery("#aliLeft_box").show();
    })
    jQuery("#zdyBtn").click(function(){
        jQuery("#zdyLeft_box").show();
    })//自定义模块删除
    //模块删除
    /*jQuery(".openLeft_box").click(function(){
        jQuery(this).parents("table").hide();
    })//公用启用*/
    jQuery("#intrOpen").click(function(){
        jQuery("#intrBtn").parents("li").show();
    })
    jQuery("#photoOpen").click(function(){
        jQuery("#photoBtn").parents("li").show();
    })
    jQuery("#actOpen").click(function(){
        jQuery("#actBtn").parents("li").show();
    })
    jQuery("#follOpen").click(function(){
        jQuery("#follBtn").parents("li").show();
    })
    jQuery("#aliOpen").click(function(){
        jQuery("#aliBtn").parents("li").show();
    })
    jQuery("#zdyOpen").click(function(){
        jQuery("#zdyBtn").parents("li").show();
    })//自定义模块启用
    //模块启用
}
//homeSet
