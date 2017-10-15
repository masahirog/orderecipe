$(function(){
  $('.input_select_menu').select2({
  width:"300px",
  placeholder: "メニューを選択してください",
  });
  //materialの表示、原価計算
  var u = 0
  $("tr.add_tr_menu").each(function() {
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

  //カテゴリーを変更時に、メニューを絞る機能
  $(".used_menu_table_body").on('change','.category_select', function(){
    var u = $(".add_tr_menu ").index($(this).parent().parent("tr.add_tr_menu"));
    c = $(this).val();
    $.ajax({
      url: "/products/get_by_category/",
      data: { category: c },
      dataType: "json",
      async: false
    })
    .done(function(data) {
      $("#product_product_menus_attributes_"+u+"_menu_id option").remove();
      first = $('<option>').text("").attr('value',"");
      $("tr.add_tr_menu").eq(u).children(".select_menu").children(".input_select_menu").append(first);
      $.each(data.product, function(index,value){
        option = $('<option>').text(this.name).attr('value',this.id)
        $("tr.add_tr_menu").eq(u).children(".select_menu").children(".input_select_menu").append(option);
      });
    });
  });

  //addアクション、menuの追加
  $(".add_menu").on('click', function addInput(){
    var u =  $("tr.add_tr_menu").length;
    $(".input_select_menu").select2('destroy');
    $("tr.add_tr_menu").first().clone().appendTo("table.menu-table");
    var last_tr =$(".add_tr_menu").last();
    last_tr.children(".select_menu").children().attr('name', "product[product_menus_attributes]["+u+"][menu_id]" );
    last_tr.children(".select_menu").children().attr('id', "product_product_menus_attributes_"+u+"_menu_id" );
    last_tr.children(".remove_menu").children(".destroy_menu").attr('id', "product_product_menus_attributes_"+u+"__destroy");
    last_tr.children(".remove_menu").children(".destroy_menu").attr('name', "product[product_menus_attributes]["+u+"][_destroy]");
    last_tr.children(".select_menu").children().val("");
    $(".input_select_menu").select2({ width:"300px",placeholder: "メニューを選択してください" });
    last_tr.children(".cost_price").empty();
    last_tr.children(".material_name").children().children().remove();
    last_tr.children(".amount_used").children().children().remove();
    last_tr.children(".material_unit").children().children().remove();
    last_tr.children(".remove_material").children(".destroy_materials").prop('checked',false);
    last_tr.show();
  });

  //menuのdestroyのチェックtrueとtrのhide、原価再計算
  $(".used_menu_table_body").on('click','.remove_menu_btn', function(){
    $(this).parent().children(".destroy_menu").prop('checked', true);
    $(this).parent().parent("tr.add_tr_menu").hide();
      calculate_product_price();
    });

  //メニュー変更時
  $(".used_menu_table_body").on('change','.input_select_menu', function(){
    var id = $(this).val();
    var u = $("tr.add_tr_menu").index($(this).parent().parent("tr.add_tr_menu"));
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
    var row_len =  $("tr.add_tr_menu").length;
    var sum_menu_cost = 0;
    $("tr.add_tr_menu").each(function(){
      if ($(this).children(".remove_menu").children(".destroy_menu").is(':checked')){
      }else{
      var menu_price = parseFloat($(this).children(".cost_price").html());
      if (isNaN(menu_price) == true ){}else{
      sum_menu_cost += menu_price;
    }}});
    var sum_menu_cost_tax = (sum_menu_cost * 0.08).toFixed(2);
    var product_cost_price = (sum_menu_cost * 1.08).toFixed(1);
    $(".sum_menu_cost").val(sum_menu_cost.toFixed(2));
    $(".sum_menu_cost_tax").val(sum_menu_cost_tax);
    $(".product_cost_price").val(product_cost_price);
  };
  //メニューの情報取得とmaterialの表示
  function get_menu_price(data,u){
    var cost = data.menu.cost_price;
    $("tr.add_tr_menu").eq(u).children(".cost_price").text(cost);
    $("tr.add_tr_menu").eq(u).children(".material_name").children().children().remove();
    $("tr.add_tr_menu").eq(u).children(".amount_used").children().children().remove();
    $("tr.add_tr_menu").eq(u).children(".material_unit").children().children().remove();
    var materials = data.menu.materials;
    var menu_materials = data.menu.menu_materials;
    $.each(materials,function(index,material){
      var name =  material.name;
      var unit = material.calculated_unit;
      $("tr.add_tr_menu").eq(u).children(".material_name").children().append("<li>"+name+"</li>");
      $("tr.add_tr_menu").eq(u).children(".material_unit").children().append("<li class='text-left'>"+unit+"</li>");
    });
    $.each(menu_materials,function(index,mm){
      var amount_used = mm.amount_used;
      $("tr.add_tr_menu").eq(u).children(".amount_used").children().append("<li class='text-right'>"+amount_used+"</li>");
    });
  };
});
