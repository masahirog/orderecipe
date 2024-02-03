class DailyItemInvoice < Prawn::Document
	def initialize(date,item_vendors,hash)
    	super(page_size: 'A4')
    	font "vendor/assets/fonts/ipaexg.ttf"
    	item_vendors.each_with_index do |item_vendor,i|
    		daily_items = hash[item_vendor.id][:daily_items].values
    		reduced_tax_subject = hash[item_vendor.id][:reduced_tax_subject]
    		normal_tax_subject = hash[item_vendor.id][:normal_tax_subject]
      		start_new_page unless i == 0
      		header(date,item_vendor,daily_items)
      		table_content(item_vendor,daily_items)
      		footer(item_vendor,reduced_tax_subject,normal_tax_subject)
		end
  	end

  	def header(date,item_vendor,daily_items)
		text "発行日：#{Date.today}",:align => :right
		bounding_box([200, 770], :width => 120, :height => 50) do
      		text "請求書", size: 24
    	end
		bounding_box([0, 730], :width => 270, :height => 100) do
	      	font_size 9
	      	text "株式会社べじはん 御中", size: 15
	      	move_down 5
	     	text "〒164-0011", :leading => 3
			text "東京都中野区中央5-3-11 柴ビル5階", :leading => 3
			move_down 10
			text "#{date.year}年#{date.month}月分を以下の通りご請求申し上げます。", :leading => 3, size: 11
		end
    	bounding_box([330, 690], :width => 200, :height =>100) do
	        font_size 10
	        text "生産者情報"
	        move_down 5
	        text "#{item_vendor.store_name}", :leading => 3
	        text "担当：#{item_vendor.producer_name}", :leading => 3
	        text "#{item_vendor.address}", :leading => 3, size: 9
		end
		bounding_box([0,650], :width => 520) do
			font_size 9
	        text "振込み期日：#{date.next_month.end_of_month.strftime("%Y年%-m月%-d日")}"
	        move_down 5
	        text "ご請求金額：#{daily_items.map{|di|di.tax_including_subtotal_price}.sum.to_s(:delimited)}円（税込）", :leading => 3, size: 13
  		end


	end

	def table_content(item_vendor,daily_items)
		bounding_box([0,600], :width => 520) do
			table line_item_rows(item_vendor,daily_items), cell_style: { size: 9 ,:overflow => :shrink_to_fit } do
		        row(0).size = 9
		        cells.padding = 4
		        column(-4..-1).align = :right
		        cells.border_width = 0.2
		        self.header = true
		        self.column_widths = [60,180,60,70,70,80]
    		end
  		end
  	end
	def line_item_rows(item_vendor,daily_items)
    	data = [["日付","項目","納品量","単価（税込）","送料（税込）","小計（税込）"]]
    	daily_items.each do |daily_item|
    		if daily_item.item.reduced_tax_flag == true
    			reduce_tax_item = "※"
    		else
    			reduce_tax_item = ""
    		end
      		data << [daily_item.date.strftime("%-m/%-d (#{%w(日 月 火 水 木 金 土)[daily_item.date.wday]})"),"#{daily_item.item.name} #{daily_item.item.variety} #{reduce_tax_item}",
      		"#{daily_item.delivery_amount} #{daily_item.unit}",daily_item.tax_including_purchase_price.to_s(:delimited),daily_item.tax_including_delivery_fee.to_s(:delimited),daily_item.tax_including_subtotal_price.to_s(:delimited)]
    	end
    	data << ["","","","","計","#{daily_items.map{|di|di.tax_including_subtotal_price}.sum.to_s(:delimited)} 円"]
    	data
  	end
  	def footer(item_vendor,reduced_tax_subject,normal_tax_subject)
  		move_down 5
  		text "※軽減税率対象"
  		move_up 9
  		text "8%対象：#{(reduced_tax_subject - (reduced_tax_subject*0.08).floor).to_s(:delimited)}円（税：#{(reduced_tax_subject*0.08).floor.to_s(:delimited)}円）　10%対象：#{(normal_tax_subject - (normal_tax_subject*0.1).floor).to_s(:delimited)}円(#{(normal_tax_subject*0.1).floor.to_s(:delimited)}円)",:align => :right
  		move_down 10
  		text "振込先：#{item_vendor.bank_name} #{item_vendor.bank_store_name}　#{item_vendor.bank_category}　#{item_vendor.account_number} #{item_vendor.account_title}"
  		move_down 10
  		bounding_box([0, cursor], width: 520, height: 30) do
  			draw_text "備 考", :at => [5,cursor-10]
  			self.line_width = 0.1
  			padding = 10
	     	stroke_bounds
	    end
  	end
end
