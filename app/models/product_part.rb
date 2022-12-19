class ProductPart < ApplicationRecord
  belongs_to :product
  enum container: {ビニル袋:0, 真空パック:1,タッパー:2,バット:3,カップ:4,パック（シーラー）:5}
end
