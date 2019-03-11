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
//= require jquery
//= require bootstrap-sprockets
//= require jquery_ujs
//= require jquery-ui/widgets/sortable
//= require cocoon
//= require turbolinks
//= require_tree .

$(document).on("turbolinks:before-cache", function() {
  if ($(".input_select_product").length) {
    $('.input_select_product').select2('destroy');
  }
  if ($(".select_order_materials").length) {
    $('.select_order_materials').select2('destroy');
  }
  if ($(".input_order_code").length) {
    $('.input_order_code').select2('destroy');
  }
});


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
