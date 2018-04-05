$(function(){
  $('.input-stock-materials-name').select2({
  width:"100%",
  placeholder: "選択してください",
  });

  $("input"). keydown(function(e) {
    if ((e.which && e.which === 13) || (e.keyCode && e.keyCode === 13)) {
        return false;
    } else {
        return true;
    }
  });

  $(".zero").on("click",function(){
    $(this).parent().find(".input-amount").val(0);
  });

  $(".stocks-all").on('change','.input-stock-materials-name', function(){
    var index = $(this).parent().parent().parent("li")
    var id = $(this).val();
    var u = $('.add_li_stock_material').index(index);
    if (isNaN(id) == true) {} else{
      $.ajax({
          url: "/stocks/material_info/" + id,
          data: { id : id },
          dataType: "json",
          async: false
      })
      .done(function(data){
        var vendor = data.material.vendor_company_name;
        var order_unit = data.material.order_unit;
        $(".add_li_stock_material").eq(u).find(".vendor_company_name").text(vendor);
        $(".add_li_stock_material").eq(u).find(".order-unit").text(order_unit);
      });
    };
  });

  $(".vendor-select").on("change",function(){
    $(".add_li_stock_material").show();
    var id = parseInt($(this).val());
    if (isNaN(id)) {

    }else{
    $(".add_li_stock_material").each(function(){
      var vendor_id = parseInt( $(this).find(".vendor_id").text());
      if (vendor_id == id) {
      }else{
      $(this).hide();
      }
    });
    }
  });


  //material追加
  $(".add_stock_material").on('click', function (){
    add_st_mate();
  });

  $(".stocks-all").on("keypress",".input-amount", function (e) {
    var code = e.which ? e.which : e.keyCode;
    if (code == 13) {
      add_st_mate();
      var last_li =$(".add_li_stock_material").last()
      last_li.find(".input-stock-materials-name").select2('open');
      e.preventDefault();
    }
  });

  //addアクション、materialの追加
  function add_st_mate(){
    var u = $(".add_li_stock_material").length
    $(".input-stock-materials-name").select2('destroy');
    $(".add_li_stock_material").first().clone().appendTo(".stocks-all");
    var last_li =$(".add_li_stock_material").last()
    last_li.find(".input-stock-materials-name").attr('name', "stock[stock_materials_attributes]["+u+"][material_id]" );
    last_li.find(".input-stock-materials-name").attr('id', "stock_stock_materials_attributes_"+u+"_material_id" );
    last_li.find(".input-amount").attr('name', "stock[stock_materials_attributes]["+u+"][amount]" );
    last_li.find(".input-amount").attr('id', "stock_stock_materials_attributes_"+u+"_amount" );
    last_li.find(".destroy").attr('id', "stock_stock_materials_attributes_"+u+"__destroy");
    last_li.find(".destroy").attr('name', "stock[stock_materials_attributes]["+u+"][_destroy]");
    last_li.find(".input-stock-materials-name").val("");
    $(".input-stock-materials-name").select2({placeholder: "選択してください"});
    last_li.find(".vendor_company_name").empty();
    last_li.find(".input-amount").val("");
    last_li.find(".order-unit").empty();
    last_li.find(".destroy").prop('checked',false);
    last_li.show();
  };

});
