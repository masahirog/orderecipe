class MaterialVendorStock < ApplicationRecord
	def self.aaa(stock_hash,material_id,today)
    if stock_hash[material_id].present?
      material_stock_hash = stock_hash[material_id].map{|data|[data.date,data]}.to_h
    else
      material_stock_hash ={}
    end
    @thead = ["<th>日付</th>"]
    @tr0 = ["<td>始在庫</td>"]
    @tr1 = ["<td>納品</td>"]
    @tr2 = ["<td>使用</td>"]
    @tr3 = ["<td>終在庫</td>"]
    @tr4 = ["<td>棚卸</td>"]

    (today-10..today+10).each do |day|
      if day.wday == 0 || HolidayJapan.name(day).present?
        color = "color:red;"
      elsif day.wday == 6
        color = "color:blue;"
      else
        color = ""
      end
      if material_stock_hash[day].present?
        stock = material_stock_hash[day]
        zero = "<td style='color:silver;'>0</td>"
        if stock.used_amount == 0
          used_amount = zero
        else
          used_amount = "<td style='color:darkorange;'>- #{(stock.used_amount/stock.material.accounting_unit_quantity).ceil(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.delivery_amount == 0
          delivery_amount = zero
        else
          delivery_amount = "<td style='color:blue;'>+ #{(stock.delivery_amount/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.end_day_stock == 0
          end_day_stock = zero
        elsif stock.end_day_stock < 0
          end_day_stock = "<td style='color:red;'>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        else
          end_day_stock = "<td style=''>#{(stock.end_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end
        if stock.start_day_stock == 0
          start_day_stock = zero
        else
          start_day_stock = "<td style=''>#{(stock.start_day_stock/stock.material.accounting_unit_quantity).floor(1)}#{stock.material.accounting_unit}</td>"
        end

        if stock.inventory_flag == true
          inventory = "<td><span class='label label-success'>棚卸し</span></td>"
        else
          inventory = "<td></td>"
        end
        if stock.date == today
          bc = "background-color:#ffebcd;"
        else
          bc = ""
        end
        @thead << "<th style='text-align:center;#{bc}#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
        @tr0 << start_day_stock
        @tr1 << delivery_amount
        @tr2 << used_amount
        @tr3 << end_day_stock
        @tr4 << inventory
      else
        @thead << "<th style='text-align:center;background-color:white;#{color}'>#{day.strftime("%-m/%-d(#{%w(日 月 火 水 木 金 土)[day.wday]})")}</th>"
        @tr0 << "<td></td>"
        @tr1 << "<td></td>"
        @tr2 << "<td></td>"
        @tr3 << "<td></td>"
        @tr4 << "<td></td>"
      end
    end
    return ["<thead><tr>#{@thead.join('')}</tr></thead><tbody><tr>#{@tr0.join('')}</tr><tr>#{@tr1.join('')}</tr><tr>#{@tr2.join('')}</tr><tr>#{@tr3.join('')}</tr><tr>#{@tr4.join('')}</tr><tbody>"]
  end
end
