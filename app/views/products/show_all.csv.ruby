#全部のお弁当の仕込みを調べたくてこのcsv作りました、ボタンはproductのindex上部でコメントアウトしています。idsに入れた弁当の詳細がダウンロード出来ます

require 'csv'
CSV.generate do |csv|
  csv_column_names = %w(product_id bento_id product_name product_cost menu_id menu_name material_id material_name amount_used unit used_cost preparaiton post)
  csv << csv_column_names
  ids = [191,361,401,591,31,371,801,51,181,231,411,731,831,931,1101,21,101,111,131,201,301,321,1661,391,
  441,501,601,1811,661,751,761,841,1141,1321,1621,1701,11,381,521,561,571,1601,711,781,901,1081,
  1191,1201,121,1251,1261,1271,1281,1301,1391,1411,1441,1151,1161,1461,1491,1531,1611,1581,1651,
  1591,1671,1,41,211,221,431,481,541,581,621,651,811,881,951,991,1031,1181,1221,1231,1311,1361,
  1371,1481,1451,1501,1691,1721,1761,1771,1781,1571,1801]

  ids.each do |id|
    product = @products.find(id)
    menus = product.menus
    menus.each_with_index do |menu,i|
      menu.menu_materials.each_with_index do |mm,ii|
        if i == 0 && ii == 0
          csv_column_values = [
            product.id,
            product.bento_id,
            product.name,
            product.cost_price,
            menu.id,
            menu.name,
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post
          ]
          csv << csv_column_values
        elsif ii == 0
          csv_column_values = [
            "",
            "",
            "",
            "",
            menu.id,
            menu.name,
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post
          ]
          csv << csv_column_values
        else
          csv_column_values = [
            "",
            "",
            "",
            "",
            "",
            "",
            mm.material_id,
            mm.material.name,
            mm.amount_used,
            mm.material.calculated_unit,
            (mm.amount_used * mm.material.cost_price).round(1),
            mm.preparation,
            mm.post
          ]
          csv << csv_column_values
        end
      end
    end
  end
end
