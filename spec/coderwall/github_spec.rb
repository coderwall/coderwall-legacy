describe Coderwall::Github do
  it 'defines ACCESS_TOKEN' do
    expect(defined?(Coderwall::Github::ACCESS_TOKEN)).to be == 'constant'
  end

  it 'defines CLIENT_ID' do
    expect(defined?(Coderwall::Github::CLIENT_ID)).to be == 'constant'
  end

  it 'defines SECRET' do
    expect(defined?(Coderwall::Github::SECRET)).to be == 'constant'
  end
end
