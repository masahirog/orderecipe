$(function(){
  $('.all_select_material').select2({
  width:"270px",
  placeholder: "食材資材を選択してください"
  });
  var input_order_unit_quantity = $(".input_order_unit_quantity").val();
  var order_unit = $(".input_order_unit").val();
  var recipe_unit = $(".input_calculated_unit").val();
  if (order_unit){
    check_order_unit(input_order_unit_quantity,order_unit)
  };
  if (recipe_unit){
    check_recipe_unit(recipe_unit)
  };

  $(".input_order_unit_quantity").on("change",function(){
    var input_order_unit_quantity = $(".input_order_unit_quantity").val();
    var order_unit = $(".input_order_unit").val();
    check_order_unit(input_order_unit_quantity, order_unit)
  })

  $(".input_order_unit").on("change",function(){
    var order_unit = $(".input_order_unit").val();
    var input_order_unit_quantity = $(".input_order_unit_quantity").val();
    check_order_unit(input_order_unit_quantity, order_unit)
  });
  $(".input_calculated_unit").on("change",function(){
    var recipe_unit = $(".input_calculated_unit").val();
    check_recipe_unit(recipe_unit)
  });

  $(".all_box").on("change",function(){
    var prop = $('.all_box').prop('checked');
    if (prop) {
     $('.menu_check').children().prop('checked', true);
    } else {
     $('.menu_check').children().prop('checked', false);
   };
  });
  $(".all_select_material").on("change",function(){
    var id = $(this).val();
    var name = $(".all_select_material option:selected").text();
    $(".menu_include_material").each(function(){
      var prop = $(this).children(".menu_check").children().prop('checked');
      if (prop) {
        var j = $(this).children(".select_material").children().val();
        $(this).children(".select_material").children().val(id);
        $(this).children(".select_material").find(".select2-selection__rendered").text(name);
      }else{
      };
    });
  });

  $("#material_calculated_value").on('blur', function(){
    cost_price_calculate()
  });
  $("#material_calculated_price").on('blur', function(){
    cost_price_calculate()
  });

  function cost_price_calculate(){
    var amount = parseInt(document.getElementById("material_calculated_value").value);
    var price = parseInt(document.getElementById("material_calculated_price").value);
    var cost_price = Math.round( (price / amount) * 100 ) / 100 ;
    // var cost_price = (price / amount).toFixed(2);
    if (isNaN(cost_price)){
      $("#material_cost_price").val(0);
    } else {
    $("#material_cost_price").val(cost_price)};
  };

  function check_order_unit(input_order_unit_quantity,order_unit){
    $(".calculated_price_label").text(input_order_unit_quantity+order_unit+"あたりの仕入価格").css('background-color','#F6CECE');
    $(".calculated_value_label").text(input_order_unit_quantity+order_unit+"あたりの分量").css('background-color','#F6CECE');
  };
  function check_recipe_unit(recipe_unit){
    $(".calculated_value_unit").text(recipe_unit);
    $(".cost_unit_label").text("単位単価(１"+recipe_unit+"あたりの価格)");
  };
});
