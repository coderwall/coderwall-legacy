def make_env(path = '/auth/test', props = {})
  {
    'REQUEST_METHOD' => 'GET',
    'PATH_INFO' => path,
    'rack.session' => {},
    'rack.input' => StringIO.new('test=true')
  }.merge(props)
end

class ExampleStrategy
  include OmniAuth::Strategy
  option :name, 'test'

  def call(env)
    ; self.call!(env)
  end

  attr_reader :last_env

  def request_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    fail 'Request Phase'
  end

  def callback_phase
    @fail = fail!(options[:failure]) if options[:failure]
    @last_env = env
    return @fail if @fail
    fail 'Callback Phase'
  end
end
