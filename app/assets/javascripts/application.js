// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//


//= require rails-ujs
//= require jquery3
//= require activestorage
//= require cocoon
//= require select2
//= require turbolinks
//= require_tree .

$(document).on("turbolinks:before-cache", function() {
  if ($(".input_select_product").length) {
    $('.input_select_product').select2('destroy');
  }

});

$(document).on('turbolinks:load', function() {
  $('.masu_order_select_product').select2();
  $('.add_masu_order_detail').on('click',function(){
    $('.masu_order_select_product').select2('destroy');
    setTimeout(function(){
      $('.masu_order_select_product').select2();
    },5);
  });

  $("#masu_order_details_area").on('keyup','.masu_order_details_product_number', function(){
    var sum = 0;
    $('.masu_order_details_tr').each(function(i){
      sum += Number($(this).find('.masu_order_details_product_number').val());
    });
    $('.masu_order_sum_number').val(sum);
  });

})
function kanma (number) {
  var number = parseFloat(number);
  var number1 = number * 100;
  // //四捨五入したあと、小数点の位置を元に戻す
  number1 = Math.round(number1) / 100;
  var numData = number1.toString().split('.');
  // 整数部分を3桁カンマ区切りへ
  numData[0] = Number(numData[0]).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  // 小数部分と結合して返却
  return numData.join('.');
};
