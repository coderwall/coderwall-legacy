# Look at the *.html files in the app/views/pages directory
STATIC_PAGES ||= Dir.glob('app/views/pages/*.html*')
  .map { |f| File.basename(f, '.html.slim') }
  .map { |f| File.basename(f, '.html') }
  .reject{ |f| f =~ /^_/ }
  .sort
  .uniq

# Look at the *.html files in the app/views/pages directory
STATIC_PAGE_LAYOUTS ||= Dir.glob('app/views/layouts/*.html*')
  .map { |f| File.basename(f, '.html.erb') }
  .map { |f| File.basename(f, '.html.slim') }
  .reject{ |f| f =~ /^_/ }
  .sort
  .uniq
