require 'bundler/setup'
Bundler.setup

require File.join File.dirname(__FILE__), '../testlib/rubylib' # and any other gems you need
require File.join File.dirname(__FILE__), "../testlib/my_http_client"

RSpec.configure do |config|
  # some (optional) config here
end