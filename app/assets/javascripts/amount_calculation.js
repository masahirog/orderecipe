$(function(){
  $(document).on('turbolinks:load', function(){ //リロードしなくてもjsが動くようにする
    var i = 0
    var ii = 0
    $(".table_tr").each(function() {
      $(this).children(".original_amount_used").attr('id', "original_amount_used" + i );
      $(this).children(".calculate_amount_used").attr('id', "calculate_amount_used" + i );
      i += 1;
    });
    $(".first_tr").each(function() {
      $(this).attr("id","first_tr"+ii);
      $(this).children(".first_tr_td").attr("class","first_tr_td"+ii);
      var g = $(this).children(".menu_materials_length").text()
      $(".first_tr_td"+ii).attr("rowspan",g)
      ii += 1;
    });


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
        $(".calculate_amount_used").attr('class', "calculate_amount_used warning text-right");
        $(".calculate_unit").attr('class', "calculate_unit warning");
        $(".calculate_amount_used_th").attr('class', "calculate_amount_used_th warning");
        var i = 0
        $(".table_tr").each(function() {
          var oau = $("#original_amount_used"+ i).text();
          var calculate_amount_used = kanma(oau*num);
          $("#calculate_amount_used"+ i).text(calculate_amount_used);

          i = i+1;
        });

        $(".calculate_amount_used_th").text(kanma(num)+"人分");
        $(".calculate_amount_used_th").show();
        $(".calculate_amount_used").show();
        $(".calculate_unit").show();
      };
    });
  });
});
