class CookingRicesController < ApplicationController
  before_action :set_cooking_rice, only: [:show, :edit, :update, :destroy]
  def index
    @cooking_rices = CookingRice.includes(:products,cooking_rice_materials:[:material]).all
  end

  def show
  end

  def new
    @cooking_rice = CookingRice.new
    @cooking_rice.cooking_rice_materials.build()
    @materials = Material.all
  end

  def edit
    @materials = Material.all
  end

  def create
    @cooking_rice = CookingRice.new(cooking_rice_params)
    respond_to do |format|
      if @cooking_rice.save
        format.html { redirect_to cooking_rices_path, notice: '新規登録OK！' }
        format.json { render :show, status: :created, location: @cooking_rice }
      else
        format.html { render :new }
        format.json { render json: @cooking_rice.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cooking_rice.update(cooking_rice_params)
        format.html { redirect_to cooking_rices_path, notice: '更新OK！' }
        format.json { render :show, status: :ok, location: @cooking_rice }
      else
        format.html { render :edit }
        format.json { render json: @cooking_rice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cooking_rice.destroy
    respond_to do |format|
      format.html { redirect_to cooking_rices_path, notice: '1件削除しやした' }
      format.json { head :no_content }
    end
  end

  def rice_sheet
    # 標準米とマンナンライスの2パターンに大別する（完璧ではないが、いったんこのやり方でキッチンは運用可能なので、これでやる、外出しとかの場合はロジックを考えるべき）
    # そこからくりこせるか？くりこせないか？で計算方法を変更している
    @arr = []
    @make_products = {}
    kurikoshi = 0
    kurikosu = 0
    man_kurikoshi = 0
    man_kurikosu = 0
    kurikosu_kg =  0
    date = params[:date]
    shogun_bentos = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:date,fixed_flag:true},:products => {product_category:1}).order(:row_order).group('product_id').sum(:manufacturing_number)
    kurumesi_bentos = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {start_time:date,canceled_flag:false},:products => {product_category:1}).group('product_id').sum(:number)
    kurumesi_rice_hash = {}
    number = 0
    kurumesi_bentos.each do |data|
      # くるめしのはベースの米でまとめる、なぜなら細かく分かれていくので
      product = Product.find(data[0])
      @make_products[product] = data[1]
      cooking_rice_id = product.cooking_rice_id
      if kurumesi_rice_hash[cooking_rice_id]
         kurumesi_rice_hash[cooking_rice_id] += data[1]
      else
        kurumesi_rice_hash[cooking_rice_id] = data[1]
      end
    end
    test_hash = {}
    shogun_bentos.each do |pro_num|
      product = Product.find(pro_num[0])
      @make_products[product] = pro_num[1]
      cooking_rice = product.cooking_rice
      # test_hash[number] = {product_name:product.name,num:pro_num[1],cooking_rice:cooking_rice,kurumesi_flag:false}
      need_shou = (pro_num[1] * cooking_rice.shoku_per_shou).ceil(2)
      test_hash[number] = {product_name:product.name,num:pro_num[1],base_rice:cooking_rice.base_rice,need_shou:need_shou,kurumesi_flag:false,cooking_rice:cooking_rice}
      number += 1
    end
    aa = {}
    kurumesi_rice_hash.each do |data|
      cooking_rice = CookingRice.find(data[0])
      num = data[1]
      need_shou = num * cooking_rice.shoku_per_shou
      if aa[cooking_rice.base_rice].present?
        aa[cooking_rice.base_rice][:need_shou] += need_shou
        aa[cooking_rice.base_rice][:num] += num
      else
        aa[cooking_rice.base_rice] = {need_shou:need_shou,num:num}
      end
    end
    aa.each do |kurumesi_rice|
      test_hash[number] = {product_name:"くるめし#{kurumesi_rice[0]}",num:kurumesi_rice[1][:num],kurumesi_flag:true,need_shou:kurumesi_rice[1][:need_shou].ceil(2)}
      number += 1
    end
    @hash = {}
    test_hash.each_with_index do |data|
      test_hash.shift
      if data[1][:kurumesi_flag]==true
        @hash[data[0]] = {:name => data[1][:product_name],:mori =>"",:amount =>[],:kurikosu => 0,:mannan => false,:kurikoshi => 0,:product_name => data[1][:product_name],make_num:"#{data[1][:num]}食（#{data[1][:need_shou]}升）",:kurikosu_kg => 0,:kurikoshi_kg =>0}
        kurikoshi = kurikosu
        kurikoshi_kg = kurikosu_kg
        @hash[data[0]][:kurikoshi] = kurikoshi
        @hash[data[0]][:kurikoshi_kg]= kurikoshi_kg
        kurikosu = 0
        kurikosu_kg = 0
        #くるめしは食数では無く、重さで管理
        @hash[data[0]][:amount]<<[kurikoshi,'']
        # kurikoshiから何食とれる？
        need_shou = data[1][:need_shou]
        need_shou -= kurikoshi
        while need_shou > 0
          if need_shou < 2
            @hash[data[0]][:amount] << [2,""]
            need_shou -= 2
          elsif need_shou < 2.5
            @hash[data[0]][:amount] << [2.5,""]
            need_shou -= 2.5
          elsif need_shou < 3
            @hash[data[0]][:amount] << [3,""]
            need_shou -= 3
          elsif need_shou < 4
            @hash[data[0]][:amount] << [4,""]
            need_shou -= 4
          elsif need_shou < 4.5
            @hash[data[0]][:amount] << [2.5,""]
            @hash[data[0]][:amount] << [2,""]
            need_shou -= 4.5
          elsif need_shou < 5
            @hash[data[0]][:amount] << [2.5,""]
            @hash[data[0]][:amount] << [2.5,""]
            need_shou -= 5.0
          elsif need_shou < 5.5
            @hash[data[0]][:amount] << [3,""]
            @hash[data[0]][:amount] << [2.5,""]
            need_shou -= 5.5
          else
            @hash[data[0]][:amount] << [4.0,""]
            need_shou -= 4.0
          end
          if need_shou < 0
            @hash[data[0]][:kurikosu] = -1 * need_shou
            @hash[data[0]][:kurikosu_kg] = (3000.0 * (-1 * need_shou)/1000).ceil(2)
          end
        end
      else
        base_rice_hash={}
        test_hash.values.each do |data|
          if base_rice_hash[data[:base_rice]]
            base_rice_hash[data[:base_rice]] += data[:need_shou].ceil(1)
          else
            base_rice_hash[data[:base_rice]] = data[:need_shou].ceil(1)
          end
        end
        num = data[1][:num]
        cooking_rice = data[1][:cooking_rice]
        # need_shou = (num * data[1][:shoku_per_shou]).ceil(2)
        @hash[data[0]] = {:name => cooking_rice.name,:mori => "#{cooking_rice.serving_amount} g",:amount =>[],:kurikosu => 0,:mannan => false,:kurikoshi => 0,:product_name => data[1][:product_name],make_num:"#{num}食",:kurikosu_kg => 0,:kurikoshi_kg =>0}
        if base_rice_hash[data[1][:base_rice]].to_i > 6
          kurikoshi_able_flag = true
        else
          kurikoshi_able_flag = false
        end
        if data[1][:base_rice] == "マンナン"
          if kurikoshi_able_flag == true
            man_kurikoshi = man_kurikosu
            @hash[data[0]][:kurikoshi] = man_kurikoshi
            man_kurikosu = 0
            @hash[data[0]][:mannan] = true
            while num > 0 do
              shokusu = (3.5 / data[1][:shoku_per_shou]).floor
              if shokusu < num
                num -= shokusu
                @hash[data[0]][:amount] << [3.5,shokusu]
              else
                man_kurikosu = ((shokusu - num) * data[1][:shoku_per_shou]).floor(2)
                @hash[data[0]][:amount] << [3.5,num]
                @hash[data[0]][:kurikosu] = man_kurikosu
                num = 0
              end
            end
          else
            man_kurikoshi = man_kurikosu
            @hash[data[0]][:kurikoshi] = man_kurikoshi
            man_kurikosu = 0
            @hash[data[0]][:mannan] = true
            # だいたいこのくらいの食数を作る想定で、70と60で割り切れないケースをifで分岐、一旦これで....
            if num == 290
              @hash[data[0]][:amount] = [[4.0,80],[3.5,70],[3.5,70],[3.5,70]]
            elsif num == 230
              @hash[data[0]][:amount] = [[3.0,60],[3.0,60],[3.0,60],[2.5,50]]
            elsif num == 220
              @hash[data[0]][:amount] = [[4.0,80],[3.5,70],[3.5,70]]
            else
              while num > 0 do
                if num % 70 == 0
                  kaisu = num / 70
                  kaisu.times{|num|@hash[data[0]][:amount]<<[3.5,70]}
                  num = 0
                elsif num % 60 == 0
                  kaisu = num / 60
                  kaisu.times{|num|@hash[data[0]][:amount]<<[3.0,60]}
                  num = 0
                else
                  if num < 60
                    @hash[data[0]][:amount]<<[2.5,50]
                    num -= 50
                  else
                    @hash[data[0]][:amount]<<[3.5,70]
                    num -= 70
                  end
                end
              end
            end
          end
        else
          if kurikoshi_able_flag == true
            kurikoshi = kurikosu
            kurikoshi_kg = kurikosu_kg
            @hash[data[0]][:kurikoshi] = kurikoshi
            @hash[data[0]][:kurikoshi_kg]=kurikoshi_kg
            kurikosu = 0
            kurikosu_kg = 0
            if kurikoshi > 0
              kurikoshi_shokusu = (kurikoshi / cooking_rice.shoku_per_shou).floor
              if num > kurikoshi_shokusu
                @hash[data[0]][:amount]<<[kurikoshi,kurikoshi_shokusu]
                num -= kurikoshi_shokusu
              else
                used_shou = (num * cooking_rice.shoku_per_shou).floor(2)
                @hash[data[0]][:amount]<<[used_shou,num]
                kurikosu = (kurikoshi - used_shou).floor(2)
                kurikosu_kg = (((kurikoshi_shokusu - num) * cooking_rice.serving_amount)/1000.to_f).round(2)
                @hash[data[0]][:kurikosu] = kurikosu
                @hash[data[0]][:kurikosu_kg] = kurikosu_kg
                num = 0
              end
            end
            while num > 0 do
              shokusu = (4 / cooking_rice.shoku_per_shou).floor
              if shokusu < num
                num -= shokusu
                @hash[data[0]][:amount] << [4.0,shokusu]
              else
                kurikosu = ((shokusu - num) * cooking_rice.shoku_per_shou).floor(2)
                kurikosu_kg = (((shokusu - num) * cooking_rice.serving_amount)/1000.to_f).round(2)
                @hash[data[0]][:amount] << [4.0,num]
                @hash[data[0]][:kurikosu] = kurikosu
                @hash[data[0]][:kurikosu_kg] = kurikosu_kg
                num = 0
              end
            end
          else
            kurikoshi = kurikosu
            kurikoshi_kg = kurikosu_kg
            @hash[data[0]][:kurikoshi] = kurikoshi
            @hash[data[0]][:kurikoshi_kg]= kurikoshi_kg
            kurikosu = 0
            kurikosu_kg = 0
            # kurikoshiから何食とれる？
            kurikoshi_shokusu = (kurikoshi / cooking_rice.shoku_per_shou).floor
            @hash[data[0]][:amount]<<[kurikoshi,kurikoshi_shokusu]
            num -= kurikoshi_shokusu
            while num > 0 do
              need_shou = (num * cooking_rice.shoku_per_shou).ceil(2)
              if need_shou >= 6
                suihan = (4 / cooking_rice.shoku_per_shou).floor
                @hash[data[0]][:amount]<<[4,suihan]
                num -= suihan
              elsif need_shou > 5
                suihan = (3.5 / cooking_rice.shoku_per_shou).floor
                @hash[data[0]][:amount]<<[3.5,suihan]
                num -= suihan
              elsif need_shou > 4
                suihan = (2.5 / cooking_rice.shoku_per_shou).floor
                @hash[data[0]][:amount]<<[2.5,suihan]
                num -= suihan
              elsif need_shou >= 2
                if (need_shou % 1).round == 1
                  shou = need_shou.to_i + 1
                else
                  shou = need_shou.to_i + 0.5
                end
                suihan = (shou / cooking_rice.shoku_per_shou).floor
                @hash[data[0]][:amount]<<[shou,num]
                kurikosu = (shou - need_shou).floor(2)
                kurikosu_kg = (((suihan - num) * cooking_rice.serving_amount)/1000.to_f).round(2)
                @hash[data[0]][:kurikosu] = kurikosu
                @hash[data[0]][:kurikosu_kg] = kurikosu_kg
                num = 0
              else
                suihan = (2 / cooking_rice.shoku_per_shou).floor
                @hash[data[0]][:amount]<<[2,num]
                kurikosu = (2 - need_shou).floor(2)
                kurikosu_kg = (((suihan - num) * cooking_rice.serving_amount)/1000.to_f).round(2)
                @hash[data[0]][:kurikosu] = kurikosu
                @hash[data[0]][:kurikosu_kg] = kurikosu_kg
                num = 0
              end
            end
          end
        end
      end
      @hash
    end
    # 将軍とそれ以外で分岐
    @shogun_mazekomi= {}
    @kurumesi_mazekomi = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }
    @make_products.each do |key,value|
      product = key
      if product.brand_id == 1
        @shogun_mazekomi[product.id] = []
        product.menus.includes(menu_materials:[:material]).where(category:1).each do |menu|
          menu.menu_materials.each do |mm|
            if mm.rice_mixed_flag == true
              @shogun_mazekomi[product.id] << [mm.material.name,value,(product.cooking_rice.serving_amount*value),mm.amount_used,(mm.amount_used * value).round,mm.material.recipe_unit]
            end
          end
        end
      else
        product.menus.includes(menu_materials:[:material]).where(category:1).each do |menu|
          menu.menu_materials.each do |mm|
            if mm.material_id == 3491 && menu.menu_materials.where(rice_mixed_flag:true).exists?
              if @kurumesi_mazekomi[menu.base_menu_id][mm.material_id].present?
                @kurumesi_mazekomi[menu.base_menu_id][3491][1] += value
                @kurumesi_mazekomi[menu.base_menu_id][3491][2] += (mm.amount_used * value * 2.17).round
              else
                @kurumesi_mazekomi[menu.base_menu_id][3491] = ['ご飯',value,(mm.amount_used * value * 2.17).round,'g'] if menu.menu_materials.where(rice_mixed_flag:true).exists?
              end
            end
            if mm.rice_mixed_flag == true
              if @kurumesi_mazekomi[menu.base_menu_id].present?
                if @kurumesi_mazekomi[menu.base_menu_id][mm.material_id].present?
                  @kurumesi_mazekomi[menu.base_menu_id][mm.material_id][1] += value
                  @kurumesi_mazekomi[menu.base_menu_id][mm.material_id][2] += (mm.amount_used * value).round
                else
                  @kurumesi_mazekomi[menu.base_menu_id][mm.material_id] = [mm.material.name,value,(mm.amount_used * value).round,mm.material.recipe_unit]
                end
              else
                @kurumesi_mazekomi[menu.base_menu_id] = {mm.material_id => [mm.material.name,value,(mm.amount_used * value).round,mm.material.recipe_unit]}
              end
            end
          end
        end
      end
    end
    respond_to do |format|
     format.html
     format.pdf do
       pdf = RiceSheet.new(@hash,date,@shogun_mazekomi,@kurumesi_mazekomi)
       send_data pdf.render,
        filename:    "#{date}_rice.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  private
    def set_cooking_rice
      @cooking_rice = CookingRice.includes(cooking_rice_materials:[:material]).find(params[:id])
    end

    def cooking_rice_params
      params.require(:cooking_rice).permit(:name,:base_rice,:serving_amount,:shoku_per_shou,cooking_rice_materials_attributes: [:id, :cooking_rice_id, :material_id,:used_amount,:_destroy])
    end
end
