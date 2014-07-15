# encoding: utf-8

RSpec.describe HashStringParser do
  it 'converts a simple hash string to Ruby' do
    expect(HashStringParser.better_than_eval('{:x=>"example"}')).to eq('x' => 'example')
  end

  it 'converts a simple hash string to Ruby with a nil' do
    expect(HashStringParser.better_than_eval('{:x=>nil}')).to eq('x' => nil)
  end

  it 'converts a simple hash string to Ruby with a number' do
    expect(HashStringParser.better_than_eval('{:x=>1}')).to eq('x' => 1)
  end

  it 'converts a simple hash string to Ruby with a null string' do
    expect(HashStringParser.better_than_eval('{:x=>"null"}')).to eq('x' => 'null')
  end
end
