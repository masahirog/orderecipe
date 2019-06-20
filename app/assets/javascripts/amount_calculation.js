$(document).on('turbolinks:load', function() {
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
        $(".menu_materials_li").each(function() {
          var oau = $(this).children(".original_amount_used").children(".original_amount_used_value").text();
          var order_unit = $(this).children(".original_amount_used").children(".order_unit").text();
          var cal_val = $(this).children(".original_amount_used").children(".recipe_unit_quantity").text();
          oau = Number(oau);
          cal_val = Number(cal_val)
          var calculate_amount_used = kanma(oau*num);

          $(this).children(".recipe_unit").children(".calculate_amount_used").text(calculate_amount_used);
          if (order_unit.length){
            var cal_amount_order_unit = ((oau*num)/cal_val).toFixed(1);
            $(this).children(".cal_val_order_unit").children(".calculate_amount_used").text(cal_amount_order_unit);
          };
          });
        $(".calculate_amount_used_th").text(kanma(num)+"人分");
        $(".calculate_amount_used_th").show();
        // $(".calculate_amount_used_th").show();
        $(".recipe_unit").children().show()
        $(".cal_val_order_unit").children().show()
      };
    });
  //変換ボタンのプッシュ
  $(".henkanbtn").on("click",function(){
    $(this).attr("disabled","disabled");
    var kanji0='';
    var kanji='';
    var kanji1='';
    $('.product_menus').each(function(i){
      if (i==0) {
        kanji0 += $(this).children(".menu_name").text()
        kanji1 += $(this).children(".recipe").text()
        $(this).children(".menu_name").text("")
        $(this).children(".recipe").text("")
      }else{
        kanji0 += (" ^^ " + $(this).children(".menu_name").text())
        kanji1 += (" ^^ " + $(this).children(".recipe").text())
        $(this).children(".menu_name").text("")
        $(this).children(".recipe").text("")
      }
    });
    $(".menu_materials_li").each(function(i){
      if (i==0) {
        kanji += $(this).children(".menu_materials_name").text()
        $(this).children(".menu_materials_name").text("")
      }else{
        kanji += (" ^^ " + $(this).children(".menu_materials_name").text())
        $(this).children(".menu_materials_name").text("")
      }
    });
    $.ajax({
        url: "/products/henkan",
        type:'POST',
        data: { kanji : kanji,kanji0:kanji0,kanji1:kanji1},
        dataType: "json",
        async: false
    })
    .done(function(data) {
      var data = data.top.data
      $.each(data,function(i,data_arr){
        $.each(data_arr, function(index, elem){
          if (i==0) {
            $('.menu_materials_li').eq(index).children(".menu_materials_name").text(elem);
          }else if (i==1) {
            $('.product_menus').eq(index).children(".menu_name").text(elem);
          }else if (i==2) {
            console.log(index);
            $('.product_menus').eq(index).children(".recipe").text(elem);
          }
        })
      });
    });
  });
});
