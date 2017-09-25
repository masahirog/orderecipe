$(function(){
    $("#material_calculated_value").on('blur', function(){
      var amount = parseInt(document.getElementById("material_calculated_value").value);
      var price = parseInt(document.getElementById("material_calculated_price").value);
      var cost_price = (price / amount).toFixed(1);
      if (isNaN(cost_price)){
        $("#material_cost_price").val(0);
      } else {
      $("#material_cost_price").val(cost_price)};
    });
    $("#material_calculated_price").on('blur', function(){
      var amount = parseInt(document.getElementById("material_calculated_value").value);
      var price = parseInt(document.getElementById("material_calculated_price").value);
      var cost_price = (price / amount).toFixed(1)
      if (isNaN(cost_price)){
        $("#material_cost_price").val(0);
      } else {
      $("#material_cost_price").val(cost_price);
    }});
  });
