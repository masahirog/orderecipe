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
        $(".amount_number").text("黄色の列が"+ ninmae +"人分の使用量です")
        var i = 0
        $(".menu_materials").each(function() {
          var oau = $(this).children(".original_amount_used").children(".original_amount_used_value").text();
            oau = Number(oau);
          var calculate_amount_used = kanma(oau*num);
          $(this).children(".calculate_unit").children(".calculate_amount_used").text(calculate_amount_used);
        });

        $(".calculate_amount_used_th").text(kanma(num)+"人分");
        $(".calculate_amount_used_th").show();
        $(".calculate_unit").show();
      };
    });
});
