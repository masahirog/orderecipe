class KurumesiOrder < ApplicationRecord
  require 'selenium-webdriver'

  has_many :kurumei_mails
  has_many :kurumesi_order_details, dependent: :destroy
  accepts_nested_attributes_for :kurumesi_order_details, allow_destroy: true

  validates :management_id, presence: true

  enum payment: {請求書:0, 現金:1, クレジットカード:2}

  # 在庫に関する部分が動いた時だけ、在庫の計算を行う
  before_save :changed_check
  after_save :input_stock

  def input_stock
    if @change_flag == true
      #saveされたdailymenuの日付を取得
      date = self.start_time
      previous_day = self.start_time - 1
      Stock.calculate_stock(date,previous_day)
    end
  end

  def changed_check
    @change_flag = false
    if self.canceled_flag_changed? ||self.start_time_changed?
      @change_flag = true
    else
      self.kurumesi_order_details.each do |kod|
        @change_flag = true if kod.changed? || kod.marked_for_destruction?
      end
    end
  end

  def self.paper_print

    # Selenium::WebDriver::Chrome.path = ENV.fetch('GOOGLE_CHROME_BIN', nil)
    #
    # options = Selenium::WebDriver::Chrome::Options.new(
    #   prefs: { 'profile.default_content_setting_values.notifications': 2 },
    #   binary: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
    # )
    #
    # driver = Selenium::WebDriver.for :chrome, options: options


    # options = Selenium::WebDriver::Chrome::Options.new
    # options.binary = ENV.fetch("GOOGLE_CHROME_SHIM")
    # options.add_argument('headless')
    # options.add_argument('disable-gpu')
    # driver = Selenium::WebDriver.for :chrome, options: options


    caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {binary: "/app/.apt/usr/bin/google-chrome", args: ["--headless"]})
    driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps

    url = "http://admin.kurumesi-bentou.com/admin_shop/"
    driver.get url
    driver.find_element(:class, 'inputId').send_keys "759"
    driver.find_element(:class, 'password').send_keys "bchimBS9"
    driver.find_element(:class, 'password').send_keys(:return)

    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_yy_s'))
    select.select_by(:value, '2020')
    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_mm_s'))
    select.select_by(:value, '01')
    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_dd_s'))
    select.select_by(:value, '10')

    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_yy_e'))
    select.select_by(:value, '2020')
    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_mm_e'))
    select.select_by(:value, '01')
    select = Selenium::WebDriver::Support::Select.new(driver.find_element(:id, 'delivery_dd_e'))
    select.select_by(:value, '10')

    driver.find_elements(:name,'order_status').each do |element|
      element.click if element.attribute('value') == '1'
    end

    driver.find_element(:class, 'free').send_keys(:return)

    wait = Selenium::WebDriver::Wait.new(:timeout => 5) # seconds

    wait.until { driver.find_element(:class => "detail").displayed? }
    driver.find_elements(:class,'detail').each do |element|
      tr = element.find_elements(:tag_name, 'tr')[1]
      if tr.find_elements(:tag_name,'td')[1].text.include? '持参'
        element.find_element(:name, 'form3').submit
        # window = driver.window_handles.last # 最後に開いたタブのwindowハンドルを取得
        # driver.switch_to.window(window)
        # driver.execute_script(' return window.print();')
        element.find_element(:name, 'form4').submit
        sleep 1
      else
        element.find_element(:name, 'form4').submit
        sleep 1
      end
    end

  end
end
