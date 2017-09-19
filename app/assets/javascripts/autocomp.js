
$(function(){
  $('#material_name.typeahead').on('click',function(){
    console.log("aaa");
  });

//   var engine = new Bloodhound({
//     datumTokenizer: function(d){ return Bloodhound.tokenizers.whitespace([d.name]) },
//     queryTokenizer: Bloodhound.tokenizers.whitespace,
//     remote: {
//       url: '/typeahead?term=%QUERY'
//   }});
//
// engine.initialize();
//  jquery( document ).ready(function( $ ) {
//     $('#material_name.typeahead').typeahead({ // #user_nameは後ほどViewファイルのフォーム部分に付与するid属性名
//        hint: true,
//        highlight: true,
//        minLength: 1
//      },
//      {
//        name: 'name',       // 'name'はカラム名
//        displayKey: 'name', // 'name'はカラム名
//        source: engine.ttAdapter()
//   　　}).on("typeahead:selected typeahead:autocomplete", function(e, datum) {
//      return $('#user_name.typeahead').val(datum.name);
//      console.log(e, datum)
//      // #user_nameは後ほどViewファイルのフォーム部分に付与するid属性名
//      // datum.nameのnameはカラム名
//    });
//   });
});
