desc 'Generate slugs for existing protips'
task :generate_protip_slugs => :environment do
  begin
    Protip.all.each do |pt|
      pt.save
    end
  rescue => e
    puts "Rake task protip slugs failed: #{e}"
  end
end
