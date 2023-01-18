require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'
CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['SECRET_ACCESS_KEY'],
      region: 'ap-northeast-1'
    }
    config.fog_directory  = 'bejihan-orderecipe'
    config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/bejihan-orderecipe'
  else
    # config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/bejihan-orderecipe'
    # config.storage :file
    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['SECRET_ACCESS_KEY'],
      region: 'ap-northeast-1'
    }
    config.fog_directory  = 'bejihan-orderecipe'
    config.asset_host = 'https://s3-ap-northeast-1.amazonaws.com/bejihan-orderecipe'
  end
end

# CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+]/
