path = Rails.root.join('config/twilio.yml')
if path.exist?
  Orderecipe::Application.config.twilio_config = YAML.load(path.read)[Rails.env].to_options
else
  Orderecipe::Application.config.twilio_config = {}
end