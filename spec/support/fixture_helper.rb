#def listen_and_respond_with(url, filename)
  #FakeWeb.register_uri(:get, url, body: response_from_disk(filename))
#end

#def listen_and_return(url, contents)
  #FakeWeb.register_uri(:get, url, body: contents)
#end

def response_from_disk(name)
  filename = "#{name}.js"
  File.read(File.join(Rails.root, 'spec', 'fixtures', filename))
end

def json_from_disk(name)
  contents = response_from_disk(name)
  ActiveSupport::JSON.decode(contents).with_indifferent_access
end
