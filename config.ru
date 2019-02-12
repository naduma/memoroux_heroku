use Rack::ETag
use Rack::Deflater
use Rack::ConditionalGet
use Rack::ContentLength

require './app'
run Sinatra::Application
