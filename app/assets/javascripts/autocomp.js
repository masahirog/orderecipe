
$(function(){
  $(document).on('turbolinks:load', function(){
    $('.input_select').select2({
    width:"300px",  //サイズ
    placeholder: "食材資材を選択してください", //プレースフォルダ
    // allowClear: true //
    })
    //セレクトボックス変更時
    .on('change',function(){

    })
  });
});
