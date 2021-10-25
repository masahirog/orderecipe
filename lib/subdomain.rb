module Subdomain
  class One

    def self.matches?(request)
      if Rails.env.production?
        request.subdomain == "one"
      else
        request.subdomain.blank?
      end
    end

    def self.path
      "one" unless Rails.env.production?
    end

  end
end
