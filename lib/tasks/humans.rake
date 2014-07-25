task :humans do
	erb = ERB.new(File.read(Rails.root.join('lib', 'templates', 'erb', 'humans.txt.erb')), nil, '-')

  File.open(Rails.root.join('public', 'humans.txt'), 'w') do |file|
  	file.write(erb.result)
  end
end