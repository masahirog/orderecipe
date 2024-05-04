require 'selenium-webdriver'
class Analysis < ApplicationRecord
  has_many :smaregi_trading_histories
  has_many :analysis_products
  has_many :analysis_categories
  has_many :sales_reports
  belongs_to :store
  validates :store_id, :uniqueness => {:scope => :date}
  belongs_to :store_daily_menu

  def self.calculate_nomination_rate(from,to)
    update_analysis_product_arr = []
    analyses = Analysis.includes(:analysis_products).where(date:from..to)
    analyses.each do |analysis|
      sixteen_transaction_count = analysis.sixteen_transaction_count
      analysis.analysis_products.each do |ap|
        if sixteen_transaction_count > 0
          ap.nomination_rate = ((ap.sixteen_total_sales_number.to_f/sixteen_transaction_count)*100).round(1)
          update_analysis_product_arr << ap
        end
      end
    end
    AnalysisProduct.import update_analysis_product_arr, on_duplicate_key_update:[:nomination_rate]
  end

  def self.send_report
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument("--user-agent=#{user_agent}")
    options.add_argument('--window-size=4000,1800')
    chrome_bin_path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
    chromedriver_path = ENV.fetch('CHROMEDRIVER_PATH', nil)
    options.binary = chrome_bin_path if chrome_bin_path
    Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path if chromedriver_path

    driver = Selenium::WebDriver.for :chrome,options: options
    driver.get("https://bento-orderecipe.herokuapp.com/")
    email = ENV['LOGIN_MAIL']
    password = ENV['LOGIN_PASS']
    sleep 2
    driver.find_element(:xpath, '//*[@id="user_email"]').send_keys email
    driver.find_element(:xpath, '//*[@id="user_password"]').send_keys password
    driver.find_element(:xpath, '//*[@id="new_user"]/input[3]').click
    sleep 2
    driver.get('https://bento-orderecipe.herokuapp.com/analyses/kpi')
    x = 0
    y = 1400
    driver.execute_script("window.scrollTo(0," + y.to_s + ")")
    sleep 2
    driver.save_screenshot('app/assets/images/screenshot.png')
    driver.quit

    options.add_argument('--window-size=1200,800')
    Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path if chromedriver_path
    driver = Selenium::WebDriver.for :chrome, options: options
    driver.get("https://bento-orderecipe.herokuapp.com/")
    sleep 2
    driver.find_element(:xpath, '//*[@id="user_email"]').send_keys email
    driver.find_element(:xpath, '//*[@id="user_password"]').send_keys password
    driver.find_element(:xpath, '//*[@id="new_user"]/input[3]').click
    sleep 2
    driver.get('https://bento-orderecipe.herokuapp.com/analyses/kpi')
    width = driver.execute_script("return document.body.scrollWidth;")
    height = driver.execute_script("return document.body.scrollHeight;")
    driver.manage.window.resize_to(width, height - 1150)
    sleep 2
    driver.save_screenshot('app/assets/images/screenshot2.png')
    driver.quit

    # Dotenv.overload
    region='ap-northeast-1'
    bucket='bejihan-orderecipe'
    credentials=Aws::Credentials.new(
      ENV['ACCESS_KEY_ID'],
      ENV['SECRET_ACCESS_KEY']
    )
    client=Aws::S3::Client.new(region:region, credentials:credentials)
    upload_file = File.open('app/assets/images/screenshot2.png', :encoding => "UTF-8")
    client.put_object(bucket: bucket, key:"screenshot2.png", body: upload_file)
    upload_file = File.open('app/assets/images/screenshot.png', :encoding => "UTF-8")
    client.put_object(bucket: bucket, key:"screenshot.png", body: upload_file)


    message = "#{Date.today}時点 重要指標\n"+
    "https://bento-orderecipe.herokuapp.com/analyses/kpi/\n"
    attachment_images = [{image_url:"https://bejihan-orderecipe.s3.ap-northeast-1.amazonaws.com/screenshot2.png"},{image_url: "https://bejihan-orderecipe.s3.ap-northeast-1.amazonaws.com/screenshot.png"}]


    Slack::Notifier.new('https://hooks.slack.com/services/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', username: 'Bot', icon_emoji: ':male-farmer:', attachments: attachment_images).ping(message)
  end

end