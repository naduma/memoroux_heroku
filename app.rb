require 'fileutils'
require 'pathname'

require 'sinatra'
require 'sinatra/json'
require 'sinatra/reloader' if development?

require 'asciidoctor'
require 'asciidoctor-diagram/extensions'
require 'asciidoctor-diagram/ditaa'
require 'asciidoctor-diagram/graphviz'
require 'asciidoctor-diagram/plantuml'
require 'asciidoctor-pdf'
require 'asciidoctor-pdf-cjk'


if not ENV['USERNAME'].nil? and not ENV['PASSWORD'].nil? then
  use Rack::Auth::Basic, 'Authentication' do |username, password|
    username == ENV['USERNAME'] and password == ENV['PASSWORD']
  end
end


configure do
  tmp_path = Pathname.new(Dir.tmpdir).join('memoroux')
  FileUtils.mkdir_p tmp_path if !Dir.exist? tmp_path

  set :tmp_path, tmp_path
  set :output_name, 'output.html'
  set :adoc_css, 'asciidoctor.css'
  set :adoc_css_path, tmp_path.join('asciidoctor.css')
  set :coderay_css, 'coderay-asciidoctor.css'
  set :coderay_css_path, tmp_path.join('coderay-asciidoctor.css')
  
  # copy asciidoctor stylesheets
  File.open(settings.adoc_css_path, 'w') do |f|
    f.puts Asciidoctor::Stylesheets.new().primary_stylesheet_data
  end
  File.open(settings.coderay_css_path, 'w') do |f|
    f.puts Asciidoctor::Stylesheets.new().coderay_stylesheet_data
  end
end


get '/' do
  send_file Pathname.new(settings.public_folder).join('index.html')
end


post '/convert' do
  data = JSON.parse(request.body.read)
  doc_id = data['id']

  if !doc_id.match(/^[a-zA-Z0-9\-]{1,36}$/)
    return status 500
  end
  
  store_path = Pathname.new(settings.tmp_path).join(doc_id)
  FileUtils.remove_dir store_path if Dir.exist? store_path
  FileUtils.mkdir_p store_path

  url = ''
  if data['type'].downcase() == 'pdf' then
    options = {
      attributes: {
        'source-highlighter' => 'coderay',
        'icons' => 'font',
      },
      base_dir: store_path,
      header_footer: true,
      backend: 'pdf',
    }
    pdf_conv = Asciidoctor.convert data['content'], options
    pdf_conv.render_file store_path.join("#{doc_id}.pdf")
    url = "/docs/#{doc_id}/#{doc_id}.pdf"
  else
    options = {
      attributes: {
        'source-highlighter' => 'coderay',
        'icons' => 'font',
      },
      base_dir: store_path,
      header_footer: true,
    }
    doc = Asciidoctor.load data['content'], options
    File.open(store_path.join("#{doc_id}.html"), 'w') do |f|
      f.puts doc.convert
    end
    url = "/docs/#{doc_id}/#{doc_id}.html"
  end

  json({ 'url' => url })
end


get '/docs/*/*' do |doc_id, file_path|
  if file_path == settings.adoc_css then
    f = settings.adoc_css_path
  elsif file_path == settings.coderay_css then
    f = settings.coderay_css_path
  else
    f = Pathname.new(settings.tmp_path).join(doc_id, file_path)
  end

  if File.exist? f then
    send_file f
  else
    status 404
  end
end
