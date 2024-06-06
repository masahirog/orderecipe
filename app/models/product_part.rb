class ProductPart < ApplicationRecord
  belongs_to :product
  belongs_to :common_product_part
  enum container: {ビニル袋:0, 真空パック:1,タッパー:2,バット:3,カップ:4,パック（シーラー）:5}
  enum loading_container: {青コンテナ:0,黒コンテナ:1,冷凍:2}
  enum loading_position: {積載:0,切出:1,調理場:2}
end
