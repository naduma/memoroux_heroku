require './app'
require 'minitest/autorun'
require 'rack/test'
require 'json'

require 'zip'


ENV['RACK_ENV'] = 'test'


class ConvertTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_invalid_id
    data = { 'id' => 'a'*37, 'type' => 'html', 'content' => 'foo' }
    post '/convert', data.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert last_response.server_error?
  end

  def test_convert
    data = { 'id' => '123-456-789', 'type' => 'html', 'content' => 'foo' }
    post '/convert', data.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert last_response.ok?

    ret = JSON.parse last_response.body
    get ret['url']
    assert last_response.ok?
  end

end
