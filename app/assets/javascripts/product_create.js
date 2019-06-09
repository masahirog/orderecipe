$(document).on('turbolinks:load', function() {
  //materialの表示、原価計算
  $(".add_li_menu").each(function() {
    calculate_product_price();
  });
  reset_row_order();

  $('.input_select_menu').select2({
    width:"100%",
    placeholder: "メニューを選択してください",
  });
  $('.cook_category_choice').select2({
    placeholder: "カテゴリ"
  });
  $('.name_search').select2({
    height:"40px",
    width:"100%",
  });

  $('.input_select_product_en').select2({
    width:"300px",
    placeholder: "お弁当を選択してください"
  });

  //並び替え時のrow_order更新
  $(".used_menu_ul.ul-sortable").sortable({
    update: function(){
      reset_row_order();
  }});


  //englishページ検索ajax
  $(".management_id_search_en").val("");
  $(".management_id_search_en").on("blur",function(){
    var management_id =  parseInt($(this).val());
    var inp = $(this).parent().parent().find(".input_select_product_en")
    $.ajax({
      url: "/orders/get_management_id",
      data: { management_id : management_id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var id = parseInt(data.id)
        inp.val(id).change();
      }else{
        inp.val("").change();
      }
    });
  });

  $(".input_select_product_en").on("change",function(){
    var id = $(this).val();
    var inp_bentoid = $(this).parent().parent().find(".management_id_search_en")
    $.ajax({
      url: "/orders/check_management_id",
      data: { id : id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var management_id = parseInt(data.management_id)
        inp_bentoid.val(management_id);
      }else{
        inp_bentoid.val("");
      }
    });
  });



  //bentoIDの発行
  $(".registration").on("change",function(){
    var prop = $('.registration').prop('checked');
    var management_id = $('#management_id_hidden').val();
    if (prop) {
      $(".management_id").val(management_id);
    }else {
      $(".management_id").val("");
      };
    });



  //カテゴリーを変更時に、メニューを絞る機能
  $(".menu-area").on('change','.input_category_select', function(){
    var u = $(".add_li_menu").index($(this).parent().parent(".add_li_menu"));
    category = $(this).val();
    select_option_change(u,category)
  });

  //addアクション、menuの追加
  $('.add_menu_fields').on('click',function(){
    setTimeout(function(){
      $('.add_li_menu').last().find('.cost_price').text("")
      $('.add_li_menu').last().find('.material_name').children().text("")
      $(".input_select_menu").select2('destroy');
      $(".input_select_menu").select2({ width:"100%",placeholder: "メニューを選択してください" });
      reset_row_order();
    },1);
  });

  //menuのdestroyのチェックtrueとtrのhide、原価再計算
  $(".menu-area").on('click','.remove_menu_btn', function(){
    setTimeout(function(){
      calculate_product_price();
      reset_row_order();
      calculate_total_calorie();
    },10);
  });

  //メニュー変更時
  $(".menu-area").on('change','.input_select_menu', function(){
    var id = $(this).val();
    console.log(id);
    var u = $(".add_li_menu").index($(this).parent().parent(".add_li_menu"));
    $.ajax({
        url: "/products/get_menu_cost_price",
        data: { id : id },
        dataType: "json",
    })
    .done(function(data) {
      get_menu_price(data,u);
      calculate_product_price();
      show_calorie(data,u)
   });
  });

  //indexでの弁当名でのリアルタイム検索
  $(".id_search").on("input", function(){
    $("#select2-name-container").text("")
    var path = "get_products"
    var class_name = ".id_search"
    inputaaaaa(class_name,path);
  });
  $(".name_search").on("change", function(){
    $(".id_search").val("")
    var path = "input_name_get_products"
    var class_name = ".name_search"
      inputaaaaa(class_name,path);
  });


  //indexで食品表示
  $(".hyoji-btn").on("click",function(){
    var id = parseInt($(this).parent().parent().children(".product_id").text());
    $("#hyoji_product_id").val(id)
  });

  function inputaaaaa(class_name,path){
    var id = $(class_name).val();
    if (id=="") {} else{
    $.ajax({
        url: "/products/"+path,
        data: { id : id },
        dataType: "json",
        async: false
    })
    .done(function(data) {

      $(".aaaad").children().remove()
      $.each(data, function(i){
        var li = '<tr class="products_li">'+
        '<td>'+
          data[i].management_id+
        '</td>'+
        '<td class="product_name">'+
        '<a href=/products/'+data[i].id+'>'+data[i].name+'</a>'+
        '</td>'+
        '<td>'+
         data[i].cook_category+
        '</td>'+
        '<td>'+
         data[i].type+
        '</td>'+
        '<td>'+
         data[i].sell_price+'円'+
        '</td>'+
        '<td>'+
         data[i].cost_price+'円'+
        '</td>'+
        '<td>'+
        '<a class="btn btn-default" target="_blank" style="margin:0 0 0 10px;" href="/products/serving_kana?id='+data[i].id+'">盛付カナ</a>'+
        '</td>'+
        '<td>'+
        '<a class="btn btn-default" target="_blank" style="margin:0 0 0 10px;" href="/products/recipe_romaji?id='+data[i].id+'">ラム</a>'+
        '</td>'+
        '<td>'+
        '<a class="btn btn-default" target="_blank" href="/products/new_band.pdf?id='+data[i].id+'">帯作成</a>'+
        '</td>'+
        '<td>'+
        '<a class="btn btn-default" href=/products/'+data[i].id+'.csv>CSV</a>'+
        '</td>'+
        '<td class="col-md-1">'+
        '<img src= '+data[i].image.thumb.url+'>' +
        '</td>'+
        '</tr>';

        $(".aaaad").append(li)
      });
      });
    }};

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
      var unit = mmi.calculated_unit;
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
 //メニューセレクトのoptionを変更する
  function select_option_change(u,category){
    $.ajax({
      url: "/products/get_by_category/",
      data: { category: category },
      dataType: "json",
      async: false
    })
    .done(function(data) {
      $(".add_li_menu").eq(u).find(".input_select_menu option").remove();
      first = $('<option>').text("").attr('value',"");
      $(".add_li_menu").eq(u).children(".select_menu").children(".input_select_menu").append(first);
      $.each(data.product, function(index,value){
        option = $('<option>').text(this.name).attr('value',this.id)
        $(".add_li_menu").eq(u).children(".select_menu").children(".input_select_menu").append(option);
      });
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
