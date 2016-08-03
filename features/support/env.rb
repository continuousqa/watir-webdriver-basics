require 'watir-webdriver'
require 'cucumber'

def browser_name
    (ENV['BROWSER'] ||= 'firefox').downcase.to_sym  #setting default browser to be firefox
end

def environment
    (ENV['ENVIRONMENT'] ||= 'prod').downcase.to_sym  # here I'm setting the default env as 'prod' but it can take a command line argument.
end

Before do |scenario|
  def assert_it message, &block
    begin
      if (block.call)
        puts "Assertion PASSED for #{message}"
      else
        puts "Assertion FAILED for #{message}"
        fail('Test Failure on assertion')
      end
    rescue => e
      puts "Assertion FAILED for #{message} with exception '#{e}'"
      fail('Test Failure on assertion')
    end
  end
  p "Starting #{scenario}"
  if environment == :int
    @browser = Watir::Browser.new browser_name
    @browser.goto "http://sandbox.amazon.com"  # this is fake. an example test Env only
    @browser.text_field(:id=>'username').set "test"  #again, fake data. just an example of logging into a test env.
    @browser.text_field(:id=>'password').set "test1234" # again more fake data, as an example of logging into a test env.
    @browser.button(:id => 'submit').click

  elsif environment == :local
    @browser = Watir::Browser.new browser_name
    @browser.goto "http://localhost/"

elsif environment == :prod
    @browser = Watir::Browser.new browser_name
  end
end
After do |scenario|
  if scenario.failed?
    Dir::mkdir('screenshots') if not File.directory?('screenshots')
    screenshot = "./screenshots/FAILED_#{scenario.name.gsub(' ','_').gsub(/[^0-9A-Za-z_]/, '')}.png"
    @browser.driver.save_screenshot(screenshot)
    embed screenshot, 'image/png'
  end
  @browser.close
end

