
$(document).on('turbolinks:load', function() {
  //materialの表示、原価計算
  $(".add_li_menu").each(function() {
    calculate_product_price();
  });
  reset_row_order();
  menu_select2();
  cost_rate_calc();
  calculate_seibun();


  //addアクション、menuの追加
  $('.add_menu_fields').on('click',function(){
    setTimeout(function(){
      $('.add_li_menu').last().find('.cost_price').text("")
      $('.add_li_menu').last().find('.material_name').children().text("")
      menu_select2();
      reset_row_order();
    },1);
  });

  $("#product_sell_price").on('keyup',function(){
    cost_rate_calc();
  });

  function cost_rate_calc(){
    var price = $("#product_sell_price").val();
    var cost_price = $("#product_cost_price").val();
    var cost_rate = Math.round((cost_price/price)*1000)/10;
    $('.cost_rate').val(cost_rate);
  };


  function menu_select2(){
    $(".input_select_menu").select2({
      ajax: {
        url: "/products/get_menu/",
        dataType: 'json',
        delay: 50,
        data: function(params) {
          return {　q: params.term　};
        },
        processResults: function (data, params) {
          return { results: $.map(data, function(obj) {
              return { id: obj.id, text: obj.name };
            })
          };
        }
      },width:"100%"
    });
  };



  //並び替え時のrow_order更新
  $(".used_menu_ul.ul-sortable").sortable({
    update: function(){
      reset_row_order();
  }});




  //menuのdestroyのチェックtrueとtrのhide、原価再計算
  $(".menu-area").on('click','.remove_menu_btn', function(){
    setTimeout(function(){
      calculate_product_price();
      reset_row_order();
      calculate_total_calorie();
      cost_rate_calc();
      calculate_seibun();
    },10);
  });

  //メニュー変更時
  $(".menu-area").on('change','.input_select_menu', function(){
    var id = $(this).val();
    var u = $(".add_li_menu").index($(this).parent().parent(".add_li_menu"));
    $.ajax({
        url: "/products/get_menu_cost_price",
        data: { id : id },
        dataType: "json",
    })
    .done(function(data) {
      $(".add_li_menu").eq(u).find(".product_menu_calorie").val(data.menu.calorie);
      $(".add_li_menu").eq(u).find(".product_menu_protein").val(data.menu.protein);
      $(".add_li_menu").eq(u).find(".product_menu_lipid").val(data.menu.lipid);
      $(".add_li_menu").eq(u).find(".product_menu_carbohydrate").val(data.menu.carbohydrate);
      $(".add_li_menu").eq(u).find(".product_menu_dietary_fiber").val(data.menu.dietary_fiber);
      $(".add_li_menu").eq(u).find(".product_menu_salt").val(data.menu.salt);
      get_menu_price(data,u);
      calculate_product_price();
      show_calorie(data,u);
      cost_rate_calc();
      calculate_seibun();
   });
  });

  function calculate_seibun(){
    var calorie = 0;
    var protein = 0;
    var lipid = 0;
    var carbohydrate = 0;
    var dietary_fiber = 0;
    var salt = 0;
    $(".add_li_menu").each(function(){
      if ($(this).find('.remove_menu').children().val()=='false') {
        calorie += Number($(this).find(".product_menu_calorie").val());
        protein += Number($(this).find(".product_menu_protein").val());
        lipid += Number($(this).find(".product_menu_lipid").val());
        carbohydrate += Number($(this).find(".product_menu_carbohydrate").val());
        dietary_fiber += Number($(this).find(".product_menu_dietary_fiber").val());
        salt += Number($(this).find(".product_menu_salt").val());
      }
    });
    $(".calorie").val(Math.round(calorie * 100 ) / 100);
    $(".protein").val(Math.round(protein * 100 ) / 100);
    $(".lipid").val(Math.round(lipid * 100 ) / 100);
    $(".carbohydrate").val(Math.round(carbohydrate * 100 ) / 100);
    $(".dietary_fiber").val(Math.round(dietary_fiber * 100 ) / 100);
    $(".salt").val(Math.round(salt * 100 ) / 100);
  };

  //原価計算
  function calculate_product_price(){
    var sum_menu_cost = 0;
    $(".add_li_menu").each(function(){
      if ($(this).find('.remove_menu').children().val()=='false') {
        var menu_price = parseFloat($(this).children(".cost_price").html());
        if (isNaN(menu_price) == true ){}else{
          sum_menu_cost += menu_price;
      }
    }});
    var product_cost_price = Math.round( sum_menu_cost * 10 ) / 10 ;
    $(".product_cost_price").val(product_cost_price);
  };
  //メニューの情報取得とmaterialの表示
  function get_menu_price(data,u){
    var cost = data.menu.cost_price;
    $(".add_li_menu").eq(u).children(".cost_price").text(cost);
    $(".add_li_menu").eq(u).children(".material_name").children().children().remove();
    $(".add_li_menu").eq(u).children(".amount_used").children().children().remove();
    $(".add_li_menu").eq(u).children(".material_unit").children().children().remove();
    $(".add_li_menu").eq(u).children(".preparation").children().children().remove();
    var menu_materials_info = data.menu.menu_materials_info;
    $.each(menu_materials_info,function(index,mmi){
      var amount_used = mmi.amount_used;
      var name =  mmi.material_name;
      var unit = mmi.recipe_unit;
      var material_cost_price = mmi.material_cost_price;
      var cost = Math.round( ( amount_used * material_cost_price ) * 10 ) / 10
      var prepa = mmi.preparation;
      if (prepa) {
        var li = '<li class="col-md-12">'+
          '<div class="col-md-4">'+name+'</div>'+
          '<div class="col-md-2 text-right">'+amount_used+" "+unit+'</div>'+
          '<div class="col-md-2 text-right">'+cost+'</div>'+
          '<div class="col-md-4">'+prepa+'</div>'+
          '</li>';
      }else {
        var li = '<li class="col-md-12">'+
          '<div class="col-md-4">'+name+'</div>'+
          '<div class="col-md-2 text-right">'+amount_used+" "+unit+'</div>'+
          '<div class="col-md-2 text-right">'+cost+'</div>'+
          '<div class="col-md-4"></div>'+
          '</li>';
      };
      $(".add_li_menu").eq(u).children(".material_name").children().append(li);

    });
  };

//並び替え
  function reset_row_order(){
    var u = 0
    $(".add_li_menu").each(function(){
      if ($(this).find('.remove_menu').children().val()=='false') {
        $(this).children(".row_order").children().val(u)
        u += 1
      }
    });
  };

  //カロリー表示
  function show_calorie(data,u){
    var calorie = Math.round(data.menu.calorie*100) / 100;
    $(".add_li_menu").eq(u).find('.product_make_menu_calorie').text(calorie);
    calculate_total_calorie();
  };

  function calculate_total_calorie(){
    var each_calorie = 0
    var total_calorie = 0
    $('.product_make_menu_calorie').each(function(){
      each_calorie =  parseFloat($(this).text());
      total_calorie += each_calorie;
    });
    $(".total_calorie").text((Math.round(total_calorie * 100) / 100) + "kcal");
  }
});
