describe Coderwall::GitHub do
  it 'defines ACCESS_TOKEN' do
    expect(defined?(Coderwall::GitHub::ACCESS_TOKEN)).to be == 'constant'
  end

  it 'defines CLIENT_ID' do
    expect(defined?(Coderwall::GitHub::CLIENT_ID)).to be == 'constant'
  end

  it 'defines SECRET' do
    expect(defined?(Coderwall::GitHub::SECRET)).to be == 'constant'
  end
end
