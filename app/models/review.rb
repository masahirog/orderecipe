class Review < ApplicationRecord
  belongs_to :brand

  def self.send_line
    Dotenv.overload
    s3 = Aws::S3::Resource.new(
      region: 'ap-northeast-1',
      credentials: Aws::Credentials.new(
        ENV['ACCESS_KEY_ID'],
        ENV['SECRET_ACCESS_KEY']
      )
    )
    signer = Aws::S3::Presigner.new(client: s3.client)
    reviews = Review.where(line_sended:false)
    reviews.each do |review|
      brand_name = review.brand.name
      # line_notify = LineNotify.new('eOCIUYoGqmC2FoLDB3a6kxvke0fuRQ2cirDFTXyFuw1')ローカル
      line_notify = LineNotify.new('Xjug7NHU09wUeAouCc1d1aEzE8sNuzXnPkv6TNReSgd')
      file_name = "#{review.brand_id}_#{review.delivery_date.to_s.gsub(/-/, '')}_#{review.delivery_area}"
      options = {
        message: "\n#{brand_name}にあたらしいレビューがあります！",
        imageFullsize: "#{signer.presigned_url(:get_object,bucket: 'review-captures', key: "#{file_name}.jpg", expires_in: 60)}",
        imageThumbnail: "#{signer.presigned_url(:get_object,bucket: 'review-captures', key: "#{file_name}.jpg", expires_in: 60)}"
      }
      line_notify.ping(options)
    end
    reviews.update_all(line_sended:true)
  end
end
