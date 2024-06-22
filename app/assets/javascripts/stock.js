$(document).on('turbolinks:load', function() {
  $('.input-stock-materials-name').select2({
    width:"100%",
    placeholder: "選択してください",
  });
  $('[data-toggle="tooltip"]').tooltip();

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
