class CreateTemporaryProductMenus < ActiveRecord::Migration[6.0]
  def change
    create_table :temporary_product_menus do |t|
      t.references :daily_menu_detail,null:false
      t.references :product_menu,null:false
      t.integer :menu_id,null:false
      t.integer :original_menu_id,null:false
      t.string :memo
      t.timestamps
    end
    add_index :temporary_product_menus, [:daily_menu_detail_id, :product_menu_id], unique: true,name: 'index_uniq'
  end
end
