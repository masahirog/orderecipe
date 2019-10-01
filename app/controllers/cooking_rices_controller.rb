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
    @arr = []
    kurikoshi = 0
    kurikosu = 0
    man_kurikoshi = 0
    man_kurikosu = 0
    date = params[:date]
    shogun_bentos = DailyMenuDetail.joins(:daily_menu,:product).where(:daily_menus => {start_time:date,fixed_flag:true},:products => {product_category:1}).order(:row_order).group('product_id').sum(:manufacturing_number)
    kurumesi_bentos = KurumesiOrderDetail.joins(:kurumesi_order,:product).where(:kurumesi_orders => {start_time:date,canceled_flag:false},:products => {product_category:1}).group('product_id').sum(:number)
    kurumesi_rice_hash = {}
    number = 0
    kurumesi_bentos.each do |data|
      cooking_rice_id = Product.find(data[0]).cooking_rice_id
      if kurumesi_rice_hash[cooking_rice_id]
         kurumesi_rice_hash[cooking_rice_id] += data[1]
      else
        kurumesi_rice_hash[cooking_rice_id] = data[1]
      end
    end
    test_hash = {}
    shogun_bentos.each do |pro_num|
      product = Product.find(pro_num[0])
      cooking_rice = product.cooking_rice
      test_hash[number] = {product_name:product.name,num:pro_num[1],cooking_rice:cooking_rice}
      number += 1
    end
    kurumesi_rice_hash.each do |data|
      cooking_rice = CookingRice.find(data[0])
      test_hash[number] = {product_name:cooking_rice.name,num:data[1],cooking_rice:cooking_rice}
      number += 1
    end
    @hash = {}
    test_hash.each_with_index do |data|
      test_hash.shift
      base_rice_hash={}
      test_hash.values.each do |data|
        if base_rice_hash[data[:cooking_rice].base_rice]
          base_rice_hash[data[:cooking_rice].base_rice] += (data[:num] * data[:cooking_rice].shoku_per_shou).ceil(1)
        else
          base_rice_hash[data[:cooking_rice].base_rice] = (data[:num] * data[:cooking_rice].shoku_per_shou).ceil(1)
        end
      end
      num = data[1][:num]
      cooking_rice = data[1][:cooking_rice]
      need_shou = (num * cooking_rice.shoku_per_shou).ceil(2)
      @hash[data[0]] = {:amount =>[],:kurikosu => 0,:mannan => false,:kurikoshi => 0,:cooking_rice => cooking_rice,:product_name => data[1][:product_name],make_num:num}
      if  base_rice_hash[cooking_rice.base_rice].to_i > 6
        kurikoshi_able_flag = true
      else
        kurikoshi_able_flag = false
      end
      if cooking_rice.base_rice == "マンナン"
        if kurikoshi_able_flag == true
          man_kurikoshi = man_kurikosu
          @hash[data[0]][:kurikoshi] = man_kurikoshi
          man_kurikosu = 0
          @hash[data[0]][:mannan] = true
          while num > 0 do
            shokusu = (3.5 / cooking_rice.shoku_per_shou).floor
            if shokusu < num
              num -= shokusu
              @hash[data[0]][:amount] << [3.5,shokusu]
            else
              man_kurikosu = ((shokusu - num) * cooking_rice.shoku_per_shou).floor(2)
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
      else
        if kurikoshi_able_flag == true
          kurikoshi = kurikosu
          @hash[data[0]][:kurikoshi] = kurikoshi
          kurikosu = 0
          if kurikoshi > 0
            kurikoshi_shokusu = (kurikoshi / cooking_rice.shoku_per_shou).floor
            @hash[data[0]][:amount]<<[kurikoshi,kurikoshi_shokusu]
            num -= kurikoshi_shokusu
          end
          while num > 0 do
            shokusu = (4 / cooking_rice.shoku_per_shou).floor
            if shokusu < num
              num -= shokusu
              @hash[data[0]][:amount] << [4.0,shokusu]
            else
              kurikosu = ((shokusu - num) * cooking_rice.shoku_per_shou).floor(2)
              @hash[data[0]][:amount] << [4.0,num]
              @hash[data[0]][:kurikosu] = kurikosu
              num = 0
            end
          end
        else
          kurikoshi = kurikosu
          @hash[data[0]][:kurikoshi] = kurikoshi
          kurikosu = 0
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
              @hash[data[0]][:kurikosu] = kurikosu
              num = 0
            else
              suihan = (2 / cooking_rice.shoku_per_shou).floor
              @hash[data[0]][:amount]<<[2,num]
              kurikosu = (2 - need_shou).floor(2)
              @hash[data[0]][:kurikosu] = kurikosu
              num = 0
            end
          end
        end
      end
      @hash
    end
    respond_to do |format|
     format.html
     format.pdf do
       pdf = RiceSheet.new(@hash,date,)
       send_data pdf.render,
        filename:    "#{date}_rice.pdf",
        type:        "application/pdf",
        disposition: "inline"
      end
    end
  end

  private
    def set_cooking_rice
      @cooking_rice = CookingRice.find(params[:id])
    end

    def cooking_rice_params
      params.require(:cooking_rice).permit(:name,:base_rice,:serving_amount,:shoku_per_shou,cooking_rice_materials_attributes: [:id, :cooking_rice_id, :material_id,:used_amount,:_destroy])
    end
end
