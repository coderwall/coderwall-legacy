class ServeFonts < Sinatra::Base
  ONE_YEAR = 31_557_600
  TEN_YEARS_IN_TEXT = 'Sun, 12 Jun 2022 22:13:16 GMT'

  get '/:font_face' do
    headers['Cache-Control'] = "public, max-age=#{ONE_YEAR}"
    headers['Expires'] = TEN_YEARS_IN_TEXT
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Content-Type'] = case params[:font_face]
                                when /\.ttf$/ then
                                  'font/truetype'
                                when /\.otf$/ then
                                  'font/opentype'
                                when /\.woff$/ then
                                  'font/woff'
                                when /\.eot$/ then
                                  'application/vnd.ms-fontobject'
                                when /\.svg$/ then
                                  'image/svg+xml'
                              end
    File.read(File.join(Rails.root, 'app', 'assets', 'fonts', params[:font_face]))
  end
end
