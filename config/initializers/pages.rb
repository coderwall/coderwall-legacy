# Look at the *.html.haml files in the app/views/pages directory
STATIC_PAGES ||= Dir.glob('app/views/pages/*.html.{erb,haml}')
  .map { |f| File.basename(f, '.html.erb') }
  .map { |f| File.basename(f, '.html.haml') }
  .reject{ |f| f =~ /^_/ }
  .sort
  .uniq

# Look at the *.html.haml files in the app/views/pages directory
STATIC_PAGE_LAYOUTS ||= Dir.glob('app/views/layouts/*.html.{erb,haml}')
  .map { |f| File.basename(f, '.html.erb') }
  .map { |f| File.basename(f, '.html.haml') }
  .reject{ |f| f =~ /^_/ }
  .sort
  .uniq
