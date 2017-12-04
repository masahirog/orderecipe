$(function(){
    $("#amount_calculation").on('click', function (){
      var num = $("#amount_number_input").val();
      var ninmae = kanma(num)


      if (num == ""){
        $(".amount_number").text("1人分のレシピを表示しています")
        $(".calculate_amount_used_th").hide();
        $(".calculate_amount_used").hide();
        $(".calculate_unit").hide();
      }else{
        $(".amount_number").text("太字部分が"+ ninmae +"人分の使用量です")
        var i = 0
        $(".menu_materials").each(function() {
          var oau = $(this).children(".original_amount_used").children(".original_amount_used_value").text();
          var order_unit = $(this).children(".original_amount_used").children(".order_unit").text();
          var cal_val = $(this).children(".original_amount_used").children(".calculated_value").text();
          oau = Number(oau);
          cal_val = Number(cal_val)
            var calculate_amount_used = kanma(oau*num);
            $(this).children(".calculated_unit").children(".calculate_amount_used").text(calculate_amount_used);
            console.log(cal_val);
          if (order_unit.length){
            var cal_amount_order_unit = ((oau*num)/cal_val).toFixed(1);
            $(this).children(".cal_val_order_unit").children(".calculate_amount_used").text(cal_amount_order_unit);
          };
          });
        $(".calculate_amount_used_th").text(kanma(num)+"人分");
        $(".calculate_amount_used_th").show();
        // $(".calculate_amount_used_th").show();
        $(".calculated_unit").children().show()
        $(".cal_val_order_unit").children().show()
      };
    });

    //変換ボタンのプッシュ
      $(".henkanbtn").on("click",function(){
        $(this).attr("disabled","disabled");
        $(".menu_materials").each(function(i){
          var kanji = $(this).children(".menu_materials_name").text()
          $(this).children(".menu_materials_name").text("")
          $.ajax({
              url: "/products/henkan",
              type:'POST',
              data: { kanji : kanji },
              dataType: "json",
              async: false
          })
          .done(function(data) {
            var katakana = $(".menu_materials").eq(i).children(".menu_materials_name")
            var result = data.top.result
            $.each(result,function(i,elem){
              $.each(elem,function(i,e){
                if (e[2]=="＄") {
                  if (e[1]=="句点") {
                    katakana.append("。")
                  } else if (e[1]=="読点") {
                    katakana.append("、")
                  } else if (e[1]=="Number") {
                    katakana.append(e[0])
                  } else if (e[1]=="空白") {
                    katakana.append(" ")
                  } else if (e[0]=="-") {
                    katakana.append("-")
                  }} else {
                    katakana.append(e[2])
                  };
              });
            });
          });
        });
      });
});
