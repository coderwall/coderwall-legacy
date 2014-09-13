describe Coderwall::Facts::GitHub do
  it 'has a thing_name' do
    expect(Coderwall::Facts::GitHub.new(nil).friendly_thing_name).to be == 'git hub'
  end
end
