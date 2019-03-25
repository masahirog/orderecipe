$(document).on('turbolinks:load', function() {
  $('.input-stock-materials-name').select2({
    width:"100%",
    placeholder: "選択してください",
  });

  $(".stocks-all").on("keypress",".input-amount", function (e) {
    var code = e.which ? e.which : e.keyCode;
    if (code == 13) {
      var tr = $(this).parents('tr.add_stock_material')
      var index = $('tr.add_stock_material:visible').index(tr);
      $('tr.add_stock_material:visible').eq(index + 1).find('.input-amount').focus().select();
    }
  });


  $(".stocks-all").on('change','.input-stock-materials-name', function(){
    var index = $(this).parent().parent().parent("li")
    var id = $(this).val();
    var u = $('.add_stock_material').index(index);
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
        $(".add_stock_material").eq(u).find(".vendor_company_name").text(vendor);
        $(".add_stock_material").eq(u).find(".order-unit").text(order_unit);
      });
    };
  });

  $(".vendor-select").on("change",function(){
    $(".add_stock_material").show();
    var id = parseInt($(this).val());
    if (isNaN(id)) {
    }else{
      $(".add_stock_material").each(function(){
        var vendor_id = parseInt( $(this).find(".vendor_id").text());
        if (vendor_id == id) {
        }else{
        $(this).hide();
        }
      });
    }
  });



});
