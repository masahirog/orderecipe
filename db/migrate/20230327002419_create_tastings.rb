class CreateTastings < ActiveRecord::Migration[6.0]
  def change
    create_table :tastings do |t|
    	t.integer :product_id
    	t.integer :staff_id
    	t.date :date
    	t.text :comment
    	t.integer :appearance
    	t.integer :taste
    	t.integer :total_evaluation
    	t.integer :price_satisfaction
        t.integer :sell_price
        t.string :image
      t.timestamps
    end
  end
end
