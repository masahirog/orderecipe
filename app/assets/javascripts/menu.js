$(document).on('turbolinks:load', function() {
  var controller = $('body').data('controller');
  if (controller == "menus") {
    $(".select_used_additives").select2();
    calculate_menu_price();
    reset_row_order();
    material_select2();
    calculate_menu_nutrition();
    u = 0
    $(".add_li_material").each(function(){
      var eos = $(this).find(".sales_check").text()
      var unit = $(this).find(".recipe_unit").text()
      eos_check(eos,u);
      sabun_check(u);
      u += 1
    });
  }

  $('.add_material_fields').on('click',function(){
    setTimeout(function(){
      // menu_category_check();
      reset_row_order();
      material_select2();
    },5);
  });

  function material_select2(){
    $(".input_select_material").select2({
      ajax: {
        url: "/menus/get_material/",
        dataType: 'json',
        delay: 50,
        data: function(params) {
          return {　q: params.term　};
        },
        processResults: function (data, params) {
          return { results: $.map(data, function(obj) {
              return { id: obj[0], text: obj[1] };
            })
          };
        }
      }
    });
  };
//並び替え時のrow_order更新
  $(".material_ul.ul-sortable").sortable({
    items: '.add_li_material',
    handle: '.drag',
    update: function(){
      reset_row_order();
    }});

  //removeのチェックと、trをhide
  $(".material_ul").on('click','.remove_fields', function(){
    setTimeout(function(){
      calculate_menu_price();
      reset_row_order();
      calculate_menu_nutrition();
    },10);
  });


  $(".material_ul").on('change','.post', function(){
    var u = $(".add_li_material").index($(this).parents('.add_li_material'));
    if ($(this).val().match(/切出/)) {
      $(".add_li_material").eq(u).find(".div_material_cut_pattern").children().show();
    }else{
      $(".add_li_material").eq(u).find(".material_cut_pattern").val('');
      $(".add_li_material").eq(u).find(".div_material_cut_pattern").children().hide();
    }
  });


  $(".all_box").on("change",function(){
    var prop = $('.all_box').prop('checked');
    if (prop) {
     $('.product_check').children().prop('checked', true);
    } else {
     $('.product_check').children().prop('checked', false);
   };
  });

  $(".all_select_menu").on("change",function(){
    var id = $(this).val();
    var name = $(".all_select_menu option:selected").text();
    $(".product_include_menu").each(function(){
      var prop = $(this).children(".product_check").children().prop('checked');
      if (prop) {
        var j = $(this).children(".select_menu").children().val();
        $(this).children(".select_menu").children().val(id);
        $(this).children(".select_menu").find(".select2-selection__rendered").text(name);
      }else{
      };
    });
  });


  //追加ボタン時のカーソル移動
  $(".add_material").keypress(function (e) {
    addInput();
    var code = e.which ? e.which : e.keyCode;
    if (code == 13) {
    var last_li =$(".add_li_material").last()
    last_li.children(".select_material").children().select2('open');
    e.preventDefault();
    }
  });


  function sabun_check(u){
    var amount_used = $(".add_li_material").eq(u).find('.amount_used_input').val();
    var gram_quantity = $(".add_li_material").eq(u).find('.input_gram_quantity').val();
    if (amount_used==gram_quantity) {
    }else{
      $(".add_li_material").eq(u).find('.input_gram_quantity').attr('style','background-color: #ffa2a2;')
    }
  };

  function eos_check(eos,u){
    if (eos==1) {
      $(".add_li_material").eq(u).attr("style","background-color:gray;")
      var height = $('.eos-alert').innerHeight();
      $('body').css('padding-top',height);
      $('.eos-alert').show();
    }else {
      $(".add_li_material").eq(u).attr("style","background-color:white;")
    }
  };

  //addアクション、materialの追加
  function addInput(){
    var u = $(".add_li_material").length
    $(".input_select_material").select2('destroy');
    $(".input_select_material").select2({width:"270px",placeholder: "食材資材を選択してください"});
    last_li.find(".input_row_order").val(u);
  };

  function reset_row_order(){
    $(".add_li_material").each(function(i){
      $(this).find('.input_row_order').val(i)
    });
  };




  //amount_used変更でprice_used取得
  $(".material_ul").on('change','.amount_used', function(){
    var u = $(".add_li_material").index($(this).parents(".add_li_material"));
    var cost_price = $(this).parents(".add_li_material").find(".cost_price").html();
    var amount_used = $(this).parents(".add_li_material").find(".amount_used_input").val();
    if (isNaN(amount_used) == true){
      var calculate_price = 0;
      var amount = 0;
    }else {
      var calculate_price = Math.round( (cost_price * amount_used) * 100 ) / 100;
      $(this).parents(".add_li_material").find(".price_used").text(calculate_price);
      calculate_menu_price();
      var unit = $(".add_li_material").eq(u).find(".recipe_unit").text().trim();
      var recipe_unit_gram_quantity = $(this).parents(".add_li_material").find(".recipe_unit_gram_quantity").val();
      var amount = Math.round( (amount_used*recipe_unit_gram_quantity) * 100 ) / 100;
      $(this).parents(".add_li_material").find(".input_gram_quantity").val(amount);
    }
    calculate_food_ingredient(amount,u);
    calculate_menu_nutrition();
  });


  $(".material_ul").on('change','.input_gram_quantity', function(){
    var amount = $(this).val();
    var u = $(".add_li_material").index($(this).parents('.add_li_material'));
    calculate_food_ingredient(amount,u);
    calculate_menu_nutrition();
  });


// input内のチェックと各カラムへの代入、materialデータベースに無ければ空欄にする
  $(".material_ul").on('change','.input_select_material', function(){
    additives_select_change()
    $('.eos-alert').hide();
    var u = $(".add_li_material").index($(this).parents('.add_li_material'));
    $(".add_li_material").eq(u).find(".amount_used_input").val("");
    $(".add_li_material").eq(u).find(".input_gram_quantity").val("");
    var id = $(this).val();
    if (isNaN(id) == true) {} else{
      $.ajax({
        url: "/menus/get_cost_price/",
        data: { id : id },
        dataType: "json",
        async: false
      })
      .done(function(data){
        get_material_info(data,u);
        change_food_ingredient(data,u);
        calculate_menu_price();
        calculate_menu_nutrition();
      });
    }
  });



  function additives_select_change() {
    var array = [];
    $(".add_li_material").each(function(){
      var id = $(this).find(".input_select_material").val();
      array.push(id);
    });
    var data = array
    $.ajax({
      type: 'POST',
      url: "/materials/change_additives",
      data: { data : data },
      dataType: "json",
      async: false
    })
    .done(function(data){
      $(".select_used_additives").select2('destroy');
      $(".select_used_additives optgroup").remove();
      $(".select_used_additives").select2({
        data: data
      });
    });
  }


  function get_material_info(data,u){
    var id = data.material.id;
    var cost = data.material.cost_price;
    var unit = data.material.recipe_unit;
    var eos = data.material.unused_flag;
    var material_cut_patterns = data.material.material_cut_patterns
    $(".add_li_material").eq(u).find(".material_link").attr('href',"/materials/"+id+"/edit")
    $(".add_li_material").eq(u).children(".sales_check").text(eos);
    $(".add_li_material").eq(u).find(".recipe_unit_gram_quantity").val(data.material.recipe_unit_gram_quantity);
    $(".add_li_material").eq(u).children(".cost_price").text(cost);
    $(".add_li_material").eq(u).find(".recipe_unit").text(unit);
    $(".add_li_material").eq(u).children(".price_used").text(0);
    $(".add_li_material").eq(u).find(".div_material_cut_pattern").children('a').attr("href", "/materials/"+id+"/edit");
    $(".add_li_material").eq(u).find(".material_cut_pattern option").remove();
    $(".add_li_material").eq(u).find('.material_cut_pattern').append($('<option>').val('').text(''));
    material_cut_patterns.forEach(function(mcp, idx) {
      var $option_tag = $('<option>').val(mcp.id).text(mcp.name);
      $(".add_li_material").eq(u).find('.material_cut_pattern').append($option_tag);
    });
    eos_check(eos,u)
  };

  //メニュー価格の変更
  function calculate_menu_price(){
    var menu_price = 0;
    $(".add_li_material").each(function(){
      if ($(this).find(".remove_material").children("input").val()==1){
      }else{
        var price_used = Number($(this).children(".price_used").html())
        if (isNaN(price_used) == true ){}else{
        menu_price += price_used}
      }});
      var sum_material_cost = Math.round( menu_price * 100 ) / 100 ;
      $(".menu_cost_price").val(sum_material_cost)
  };

  function calculate_menu_nutrition(){
    var arr_menu_nutrition =[]
    var obj = {calorie:0,protein:0,lipid:0,carbohydrate:0,dietary_fiber:0,salt:0};
    $(".add_li_material").each(function(i) {
      calorie = Number(obj['calorie']) + Number($(this).find(".input_calorie").val());
      protein = Number(obj['protein']) + Number($(this).find(".input_protein").val());
      lipid = Number(obj['lipid']) + Number($(this).find(".input_lipid").val());
      carbohydrate = Number(obj['carbohydrate']) + Number($(this).find(".input_carbohydrate").val());
      dietary_fiber = Number(obj['dietary_fiber']) + Number($(this).find(".input_dietary_fiber").val());
      salt = Number(obj['salt']) + Number($(this).find(".input_salt").val());
      obj = {calorie:calorie,protein:protein,lipid:lipid,carbohydrate:carbohydrate,dietary_fiber:dietary_fiber,salt:salt};
    });
    $(".menu_calorie").val(Math.round(obj['calorie']*100)/100);
    $(".menu_protein").val(Math.round(obj['protein']*100)/100);
    $(".menu_lipid").val(Math.round(obj['lipid']*100)/100);
    $(".menu_carbohydrate").val(Math.round(obj['carbohydrate']*100)/100);
    $(".menu_dietary_fiber").val(Math.round(obj['dietary_fiber']*100)/100);
    $(".menu_salt").val(Math.round(obj['salt']*100)/100);
  };


  function change_food_ingredient(data,u){
    var food_ingredient = data["material"]["food_ingredient"]
    if (food_ingredient) {
      $(".add_li_material").eq(u).find(".food_ingredient").find(".name").attr('href',"/food_ingredients/"+food_ingredient.id+"/edit")
      $(".add_li_material").eq(u).find(".food_ingredient").find(".name").text(food_ingredient.name);
      var hyoji = "cal："+food_ingredient.calorie +"　pro："+food_ingredient.protein +"　lip："+food_ingredient.lipid +"　car："+food_ingredient.carbohydrate +"　fib："+food_ingredient.dietary_fiber +"　salt："+food_ingredient.salt
      $(".add_li_material").eq(u).find(".food_ingredient").find(".hyoji").text(hyoji);
      $(".add_li_material").eq(u).find(".calorie").val(food_ingredient.calorie);
      $(".add_li_material").eq(u).find(".protein").val(food_ingredient.protein);
      $(".add_li_material").eq(u).find(".lipid").val(food_ingredient.lipid);
      $(".add_li_material").eq(u).find(".carbohydrate").val(food_ingredient.carbohydrate);
      $(".add_li_material").eq(u).find(".dietary_fiber").val(food_ingredient.dietary_fiber);
      $(".add_li_material").eq(u).find(".salt").val(food_ingredient.salt);
    }else{
      $(".add_li_material").eq(u).find(".food_ingredient").find(".name").text("未登録");
      var hyoji = "-"
      $(".add_li_material").eq(u).find(".food_ingredient").find(".hyoji").text(hyoji);
      $(".add_li_material").eq(u).find(".calorie").val(0);
      $(".add_li_material").eq(u).find(".protein").val(0);
      $(".add_li_material").eq(u).find(".lipid").val(0);
      $(".add_li_material").eq(u).find(".carbohydrate").val(0);
      $(".add_li_material").eq(u).find(".dietary_fiber").val(0);
      $(".add_li_material").eq(u).find(".salt").val(0);

    };
    calculate_menu_nutrition();
  };
  

  function calculate_food_ingredient(amount,u){
    var food_ingredient = $(".add_li_material").eq(u).find(".food_ingredient").text();
    var unit_calorie = $(".add_li_material").eq(u).find(".calorie").val();
    var unit_protein = $(".add_li_material").eq(u).find(".protein").val();
    var unit_lipid = $(".add_li_material").eq(u).find(".lipid").val();
    var unit_carbohydrate = $(".add_li_material").eq(u).find(".carbohydrate").val();
    var unit_dietary_fiber = $(".add_li_material").eq(u).find(".dietary_fiber").val();
    var unit_salt = $(".add_li_material").eq(u).find(".salt").val();
    if (food_ingredient) {
      $(".add_li_material").eq(u).find(".input_calorie").val(Math.round(amount*unit_calorie*100)/100);
      $(".add_li_material").eq(u).find(".input_protein").val(Math.round(amount*unit_protein*100)/100);
      $(".add_li_material").eq(u).find(".input_lipid").val(Math.round(amount*unit_lipid*100)/100);
      $(".add_li_material").eq(u).find(".input_carbohydrate").val(Math.round(amount*unit_carbohydrate*100)/100);
      $(".add_li_material").eq(u).find(".input_dietary_fiber").val(Math.round(amount*unit_dietary_fiber*100)/100);
      $(".add_li_material").eq(u).find(".input_salt").val(Math.round(amount*unit_salt*100)/100);
    }else{
      $(".add_li_material").eq(u).find(".input_calorie").val(0);
      $(".add_li_material").eq(u).find(".input_protein").val(0);
      $(".add_li_material").eq(u).find(".input_lipid").val(0);
      $(".add_li_material").eq(u).find(".input_carbohydrate").val(0);
      $(".add_li_material").eq(u).find(".input_dietary_fiber").val(0);
      $(".add_li_material").eq(u).find(".input_salt").val(0);
    }

  };

  $(".material_ul").on('click','.edit_gram_quantity', function(){
    if ($(this).parents('.add_li_material').find(".input_gram_quantity").attr('readonly')=='readonly') {
      $(this).parents('.add_li_material').find(".input_gram_quantity").attr('readonly',false);
    }else{
      $(this).parents('.add_li_material').find(".input_gram_quantity").attr('readonly',true);
    }
  });

});
