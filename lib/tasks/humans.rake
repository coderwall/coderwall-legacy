desc 'Generate the humans.txt file to publicly acknowledge contributors'
task :humans do
  begin
    erb = ERB.new(File.read(Rails.root.join('lib', 'templates', 'erb', 'humans.txt.erb')), nil, '-')

    File.open(Rails.root.join('public', 'humans.txt'), 'w') do |file|
      file.write(erb.result)
    end
  rescue => e
    puts "Rake task humans failed: #{e}"
  end
end
