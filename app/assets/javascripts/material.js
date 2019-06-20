$(document).on('turbolinks:load', function() {
  $('.input_select_food_additive').select2({
  width:"200px"
  });

  $(".add_food_additive").on('click', function (){
    addInput();
  });
  //removeのチェックと、trをhide
  $(".food_additive_ul").on('click','.remove_btn', function(){
    $(this).parent().children(".destroy_food_additives").prop('checked', true);
    $(this).parent().parent(".add_li_food_additive").hide();
  });

  //追加ボタン時のカーソル移動
  $(".add_food_additive").keypress(function (e) {
    addInput();
    var code = e.which ? e.which : e.keyCode;
    if (code == 13) {
    var last_li =$(".add_li_food_additive").last()
    last_li.find(".input_select_food_additive").select2('open');
    e.preventDefault();
    }
  });


  $('.all_select_material').select2({
    placeholder: "食材資材を選択してください"
  });
  var input_order_unit_quantity = $(".input_order_unit_quantity").val();
  var order_unit = $(".input_order_unit").val();
  var recipe_unit = $(".input_recipe_unit").val();
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
  $(".input_recipe_unit").on("change",function(){
    console.log($(this).val());
  });

  var previous;

  $(".input_recipe_unit").on('focus', function () {
    previous = this.value;
  }).change(function() {
    if(!confirm('変更すると、レシピに大きく影響します。本当に変更しますか？（変更した場合はレシピを確認してください。）')){
      $(this).val(previous);
      return false;
    }else{
      var recipe_unit = $(".input_recipe_unit").val();
      check_recipe_unit(recipe_unit)
    }
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

  $("#material_recipe_unit_quantity").on('blur', function(){
    cost_price_calculate()
  });
  $("#material_recipe_unit_price").on('blur', function(){
    cost_price_calculate()
  });



  function cost_price_calculate(){
    var amount = $("#material_recipe_unit_quantity").val();
    var price = $("#material_recipe_unit_price").val();
    var cost_price = Math.round( (price / amount) * 100 ) / 100 ;
    if (isNaN(cost_price)){
      $("#material_cost_price").val(0);
    } else {
    $("#material_cost_price").val(cost_price)};
  };

  function check_order_unit(input_order_unit_quantity,order_unit){
    $(".recipe_unit_price_label").text(input_order_unit_quantity+order_unit+"あたりの仕入価格(税抜き)").css('background-color','#F6CECE');
    $(".recipe_unit_quantity_label").text(input_order_unit_quantity+order_unit+"あたりの分量").css('background-color','#F6CECE');
  };
  function check_recipe_unit(recipe_unit){
    $(".recipe_unit_quantity_unit").text(recipe_unit);
    $(".cost_unit_label").text("単位単価(１"+recipe_unit+"あたりの価格 税抜き)");
  };

  function addInput(){
    var u = $(".add_li_food_additive").length
    $(".input_select_food_additive").select2('destroy');
    $(".add_li_food_additive").first().clone().appendTo(".food_additive_ul");
    var last_li =$(".add_li_food_additive").last()
    last_li.children(".select_food_additive").children().attr('name', "material[material_food_additives_attributes]["+u+"][food_additive_id]" );
    last_li.children(".select_food_additive").children().attr('id', "material_material_food_additives_attributes_"+u+"_food_additive_id" );
    last_li.children(".remove_food_additive").children(".destroy_food_additives").attr('id', "material_material_food_additives_attributes_"+u+"__destroy");
    last_li.children(".remove_food_additive").children("").attr('name', "material[material_food_additives_attributes]["+u+"][_destroy]");
    last_li.children(".select_food_additive").children().val("");
    $(".input_select_food_additive").select2({width:"200px"});
    last_li.children(".remove_food_additive").children(".destroy_food_additives").prop('checked',false);
    last_li.show();
  };
});
