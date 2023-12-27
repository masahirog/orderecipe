class CookingRicesController < AdminController
  before_action :set_cooking_rice, only: [:show, :edit, :update, :destroy]
  def index
    @cooking_rices = CookingRice.includes(:products).all
  end

  def show
  end

  def new
    @cooking_rice = CookingRice.new
  end

  def edit
    @materials = Material.all
  end

  def create
    @cooking_rice = CookingRice.new(cooking_rice_params)
    respond_to do |format|
      if @cooking_rice.save
        format.html { redirect_to cooking_rices_path, success: '新規登録OK！' }
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
        format.html { redirect_to cooking_rices_path, success: '更新OK！' }
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
      format.html { redirect_to cooking_rices_path, success: '1件削除しやした' }
      format.json { head :no_content }
    end
  end

  def rice_sheet
    @arr = []
    @make_products = {}
    date = params[:date]
    number = 0
    bentos.each do |data|
      product = Product.find(data[0])
      @make_products[product] = data[1]
      cooking_rice_id = product.cooking_rice_id
      else
      end
    end
    test_hash = {}
    aa = {}
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
    aa = aa.sort.to_h
      number += 1
    end
    @hash = {}
    kurikosu = 0
    kurikosu_kg = 0
    test_hash.each_with_index do |data|
      test_hash.shift
      @hash[data[0]] = {:name => data[1][:product_name],:mori =>"",:amount =>[],:kurikosu => 0,:mannan => false,:kurikoshi => 0,:product_name => data[1][:product_name],make_num:"#{data[1][:num]}食（#{data[1][:need_shou]}升）",:kurikosu_kg => 0,:kurikoshi_kg =>0}
      need_shou = data[1][:need_shou]
      if kurikosu > 0
        @hash[data[0]][:kurikoshi] = kurikosu
        @hash[data[0]][:kurikoshi_kg] = kurikosu_kg
        need_shou -= kurikosu
        @hash[data[0]][:amount] << [kurikosu,""]
        kurikosu = 0
        kurikosu_kg = 0
      end
      while need_shou > 0
        if need_shou <= 1
          @hash[data[0]][:amount] << [1,""]
          need_shou -= 1
        elsif need_shou <= 1.5
          @hash[data[0]][:amount] << [1.5,""]
          need_shou -= 1.5
        elsif need_shou <= 2
          @hash[data[0]][:amount] << [2,""]
          need_shou -= 2
        elsif need_shou <= 2.5
          @hash[data[0]][:amount] << [2.5,""]
          need_shou -= 2.5
        elsif need_shou <= 3
          @hash[data[0]][:amount] << [3,""]
          need_shou -= 3
        elsif need_shou <= 3.5
          @hash[data[0]][:amount] << [3.5,""]
          need_shou -= 3.5
        elsif need_shou <= 4
          @hash[data[0]][:amount] << [4,""]
          need_shou -= 4
        elsif need_shou <= 4.5
          @hash[data[0]][:amount] << [2.5,""]
          @hash[data[0]][:amount] << [2,""]
          need_shou -= 4.5
        elsif need_shou <= 5
          @hash[data[0]][:amount] << [2.5,""]
          @hash[data[0]][:amount] << [2.5,""]
          need_shou -= 5.0
        elsif need_shou <= 5.5
          @hash[data[0]][:amount] << [3,""]
          @hash[data[0]][:amount] << [2.5,""]
          need_shou -= 5.5
        else
          @hash[data[0]][:amount] << [4.0,""]
          need_shou -= 4.0
        end
        if need_shou < 0
          @hash[data[0]][:kurikosu] = (-1 * need_shou).floor(2)
          kurikosu = (-1 * need_shou).floor(2)
          kurikosu_kg = (3000.0 * (-1 * need_shou)/1000).ceil(2)
          @hash[data[0]][:kurikosu_kg] = kurikosu_kg
        end
      end
      @hash
    end
    @make_products.each do |key,value|
      product = key
      product.menus.includes(menu_materials:[:material]).where(category:1).each do |menu|
        menu.menu_materials.each do |mm|
          if mm.material_id == 3491 && menu.menu_materials.where(source_flag:true).exists?
            else
            end
          end
          if mm.source_flag == true
              else
              end
            else
            end
          end
        end
      end
    end
    respond_to do |format|
     format.html
     format.pdf do
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
      params.require(:cooking_rice).permit(:name,:base_rice,:serving_amount,:shoku_per_shou)
    end
end
