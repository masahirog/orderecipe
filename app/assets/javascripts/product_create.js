$(function(){
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

  //englishページ検索ajax
  $(".bento_id_search_en").val("");
  $(".bento_id_search_en").on("blur",function(){
    var bento_id =  parseInt($(this).val());
    var inp = $(this).parent().parent().find(".input_select_product_en")
    $.ajax({
      url: "/orders/get_bento_id",
      data: { bento_id : bento_id },
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
    var inp_bentoid = $(this).parent().parent().find(".bento_id_search_en")
    $.ajax({
      url: "/orders/check_bento_id",
      data: { id : id },
      dataType: "json",
      async: false
    })
    .done(function(data){
      if (data) {
        var bento_id = parseInt(data.bento_id)
        inp_bentoid.val(bento_id);
      }else{
        inp_bentoid.val("");
      }
    });
  });


  //materialの表示、原価計算
  $(".add_li_menu").each(function() {
    calculate_product_price();
  });


  //bentoIDの発行
  $(".registration").on("change",function(){
    var prop = $('.registration').prop('checked');
    var bento_id = $('#bento_id_hidden').val();
    if (prop) {
      $(".bento_id").val(bento_id);
    }else {
      $(".bento_id").val("");
      };
    });



  //カテゴリーを変更時に、メニューを絞る機能
  $(".menu-area").on('change','.input_category_select', function(){
    var u = $(".add_li_menu").index($(this).parent().parent(".add_li_menu"));
    category = $(this).val();
    select_option_change(u,category)
  });

  //addアクション、menuの追加
  $(".add_menu").on('click', function addInput(){
    var u =  $(".add_li_menu").length;
    $(".input_select_menu").select2('destroy');
    $(".add_li_menu").first().clone().appendTo(".used_menu_ul");
    var last_li =$(".add_li_menu").last();
    var c = last_li.children(".category_select").children().val()
    last_li.children(".select_menu").children().children("option")
    last_li.children(".select_menu").children().attr('name', "product[product_menus_attributes]["+u+"][menu_id]" );
    last_li.children(".select_menu").children().attr('id', "product_product_menus_attributes_"+u+"_menu_id" );
    last_li.children(".remove_menu").children(".destroy_menu").attr('id', "product_product_menus_attributes_"+u+"__destroy");
    last_li.children(".remove_menu").children(".destroy_menu").attr('name', "product[product_menus_attributes]["+u+"][_destroy]");
    last_li.children(".select_menu").children().val("");
    $(".input_select_menu").select2({ width:"270px",placeholder: "メニューを選択してください" });
    last_li.children(".cost_price").empty();
    last_li.children(".material_name").children().children().remove();
    last_li.children(".amount_used").children().children().remove();
    last_li.children(".material_unit").children().children().remove();
    last_li.children(".preparation").children().children().remove();
    last_li.children(".remove_material").children(".destroy_materials").prop('checked',false);
    select_option_change(u,c)
    last_li.show();
  });

  //menuのdestroyのチェックtrueとtrのhide、原価再計算
  $(".menu-area").on('click','.remove_menu_btn', function(){
    $(this).parent().children(".destroy_menu").prop('checked', true);
    $(this).parent().parent(".add_li_menu").hide();
      calculate_product_price();
    });

  //メニュー変更時
  $(".used_menu_ul").on('change','.input_select_menu', function(){
    var id = $(this).val();
    var u = $(".add_li_menu").index($(this).parent().parent(".add_li_menu"));
      $.ajax({
          url: "/products/get_menu_cost_price/" + id,
          data: { id : id },
          dataType: "json",
      })
      .done(function(data) {
        get_menu_price(data,u);
        calculate_product_price();
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
        var li = '<li class="li-active products_li col-md-12 list-group-item" id="aaa">'+
        '<div class="col-md-1">'+
          data[i].bento_id+
        '</div>'+
        '<div class="product_name col-md-2">'+
        '<a href=/products/'+data[i].id+'>'+data[i].name+'</a>'+
        '</div>'+
        '<div class="col-md-1">'+
         data[i].cook_category+
        '</div>'+
        '<div class="col-md-1">'+
         data[i].product_type+
        '</div>'+
        '<div class="col-md-1">'+
         data[i].sell_price+'円'+
        '</div>'+
        '<div class="col-md-1">'+
         data[i].cost_price+'円'+
        '</div>'+
        '<div class="col-md-2">'+
        '</div>'+
        '<div class="col-md-1">'+
        '<a class="btn btn-default" href=/products/'+data[i].id+'.csv>CSV</a>'+
        '</div>'+
        '<div class="col-md-1">'+
        '<img src= '+data[i].product_image.thumb.url+'>' +
        '</div>'+
        '</li>';

        $(".aaaad").append(li)
      });
      });
    }};

  //原価計算
  function calculate_product_price(){
    var row_len =  $(".add_li_menu").length;
    var sum_menu_cost = 0;
    $(".add_li_menu").each(function(){
      if ($(this).children(".remove_menu").children(".destroy_menu").is(':checked')){
      }else{
      var menu_price = parseFloat($(this).children(".cost_price").html());
      if (isNaN(menu_price) == true ){}else{
      sum_menu_cost += menu_price;
    }}});
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
      $("#product_product_menus_attributes_"+u+"_menu_id option").remove();
      first = $('<option>').text("").attr('value',"");
      $(".add_li_menu").eq(u).children(".select_menu").children(".input_select_menu").append(first);
      $.each(data.product, function(index,value){
        option = $('<option>').text(this.name).attr('value',this.id)
        $(".add_li_menu").eq(u).children(".select_menu").children(".input_select_menu").append(option);
      });
    });
  };
});
