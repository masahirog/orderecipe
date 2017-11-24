$(function(){
  $('.input_select_menu').select2({
  width:"100%",
  placeholder: "メニューを選択してください",
  });
  $('.cook_category_choice').select2({
  placeholder: "カテゴリ"
  });
  //materialの表示、原価計算
  var u = 0
  $(".add_li_menu").each(function() {
      var id = $(this).children(".select_menu").children().val();
      if (isNaN(id) == true) {} else{
      $.ajax({
          url: "/products/get_menu_cost_price/" + id,
          data: { id : id },
          dataType: "json",
          async: false
      })
      .done(function(data) {
        get_menu_price(data,u);
    })};
    u = u+1;
    calculate_product_price();
  });

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
    var sum_menu_cost_tax = Math.round( (sum_menu_cost * 0.08) * 100 ) / 100 ;
    // var sum_menu_cost_tax = (sum_menu_cost * 0.08).toFixed(2);
    var product_cost_price = Math.round( (sum_menu_cost * 1.08) * 10 ) / 10 ;
    // var product_cost_price = (sum_menu_cost * 1.08).toFixed(1);
    var sum_menu_cost = Math.round( sum_menu_cost * 100 ) / 100 ;
    $(".sum_menu_cost").val(sum_menu_cost);
    $(".sum_menu_cost_tax").val(sum_menu_cost_tax);
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
