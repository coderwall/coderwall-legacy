# encoding: utf-8

describe HashStringParser do
  it 'converts a simple hash string to Ruby' do
    HashStringParser.better_than_eval('{:x=>"example"}').should == {'x' => 'example'}
  end

  it 'converts a simple hash string to Ruby with a nil' do
    HashStringParser.better_than_eval('{:x=>nil}').should == {'x' => nil}
  end

  it 'converts a simple hash string to Ruby with a number' do
    HashStringParser.better_than_eval('{:x=>1}').should == {'x' => 1}
  end

  it 'converts a simple hash string to Ruby with a null string' do
    HashStringParser.better_than_eval('{:x=>"null"}').should == {'x' => 'null'}
  end
end
