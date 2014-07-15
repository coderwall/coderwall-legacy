class LocationPhoto < Struct.new(:image_name, :author, :url, :location)
  @@photos = {}

  class << self
    def photos
      @@photos
    end

    def photo(image_name, author, url, match_name)
      photos[match_name] = LocationPhoto.new(image_name, author, url, match_name)
    end

    def for(user, location = nil)
      return photos[location] unless location.nil?
      return photos[user.city] if photos[user.city]
      return photos[user.state_name] if photos[user.state_name]
      return photos[user.country] if photos[user.country]
      photos['Nowhere']
    end
  end

  photo 'nowhere.jpg', 'sanfranannie', 'http://www.flickr.com/photos/sanfranannie/2929942248', 'Nowhere'
  photo 'czech.jpg', 'fklv', 'http://www.flickr.com/photos/fklv/2984579465/', 'Czech Republic'
  photo 'turkey.png', 'hectorgarcia', 'http://www.flickr.com/photos/hectorgarcia/5637715404/', 'Turkey'

  class Panoramic < Struct.new(:image_name, :author, :url, :location)
    @@panoramas = {}
    class << self
      def photos
        @@panoramas
      end

      def photo(image_name, author, url, match_name)
        photos[match_name] = LocationPhoto::Panoramic.new(image_name, author, url, match_name)
      end

      def for(location)
        photos[location.titleize] || photos['Worldwide']
      end
    end
  end
end

LocationPhoto::Panoramic.photo 'San_Francisco.jpg', 'patrick-smith-photography', 'https://www.flickr.com/photos/patrick-smith-photography/5624097073', 'San Francisco'
LocationPhoto::Panoramic.photo 'Boston.jpg', 'rickharris', 'https://www.flickr.com/photos/rickharris/144287116/', 'Boston'
LocationPhoto::Panoramic.photo 'Palo_Alto.jpg', 'moonsoleil', 'http://www.flickr.com/photos/moonsoleil/5816814203/', 'Palo Alto'
LocationPhoto::Panoramic.photo 'Ottawa.jpg', 'alexindigo', 'http://www.flickr.com/photos/alexindigo/1473500746/', 'Ottawa'
LocationPhoto::Panoramic.photo 'New_York.jpg', 'dennoit', 'http://www.flickr.com/photos/dennoit/4982584929/', 'New York'
LocationPhoto::Panoramic.photo 'Chicago.jpg', 'dherholz', 'http://www.flickr.com/photos/dherholz/2651752852/', 'Chicago'
LocationPhoto::Panoramic.photo 'Toronto.jpg', 'dcronin', 'http://www.flickr.com/photos/dcronin/5362386184/', 'Toronto'
LocationPhoto::Panoramic.photo 'Austin.jpg', 'jrandallc', 'http://www.flickr.com/photos/jrandallc/5269793786/', 'Austin'
LocationPhoto::Panoramic.photo 'Portland.jpg', 'oceanyamaha', 'http://www.flickr.com/photos/oceanyamaha/214822573/', 'Portland'
LocationPhoto::Panoramic.photo 'Miami.jpg', 'greyloch', 'http://www.flickr.com/photos/greyloch/5690979394/', 'Miami'
LocationPhoto::Panoramic.photo 'Worldwide.jpg', 'wwworks', 'http://www.flickr.com/photos/wwworks/2712985992/', 'Worldwide'
LocationPhoto::Panoramic.photo 'Atlanta.jpg', 'hectoralejandro', 'http://www.flickr.com/photos/hectoralejandro/5845851927/', 'Atlanta'
LocationPhoto::Panoramic.photo 'Capetown.jpg', 'blyzz', 'http://www.flickr.com/photos/blyzz/5092353659', 'Capetown'
LocationPhoto::Panoramic.photo 'Johannesburg.jpg', 'mister-e', 'http://www.flickr.com/photos/mister-e/196266116', 'Johannesburg'
LocationPhoto::Panoramic.photo 'Hamburg.jpg', 'visualities', 'http://www.flickr.com/photos/visualities/2768964900/', 'Hamburg'
LocationPhoto::Panoramic.photo 'Munich.jpg', 'justinm', 'http://www.flickr.com/photos/justinm/1785895161', 'Munich'
LocationPhoto::Panoramic.photo 'Barcelona.jpg', 'bcnbits', 'http://www.flickr.com/photos/bcnbits/3092562270', 'Barcelona'
LocationPhoto::Panoramic.photo 'Seattle.jpg', 'severud', 'http://www.flickr.com/photos/severud/2446381722', 'Seattle'
LocationPhoto::Panoramic.photo 'Cambridge.jpg', 'docsearls', 'http://www.flickr.com/photos/docsearls/3530162411', 'Cambridge'
LocationPhoto::Panoramic.photo 'Copenhagen.jpg', 'stignygaard', 'http://www.flickr.com/photos/stignygaard/160827308', 'Copenhagen'
LocationPhoto::Panoramic.photo 'Boulder.jpg', 'frankenstoen', 'http://www.flickr.com/photos/frankenstoen/2718673998', 'Boulder'

LocationPhoto.photo 'San_Francisco.jpg', 'salim', 'http://www.flickr.com/photos/salim/402618628', 'San Francisco'
LocationPhoto.photo 'Seattle.jpg', 'acradenia', 'http://www.flickr.com/photos/acradenia/5858166551/', 'Seattle'
# LocationPhoto.photo 'Seattle.jpg', 'acradenia', 'http://www.flickr.com/photos/acradenia/5858166551/', 'Washington' conflicts with washington dc
LocationPhoto.photo 'France.jpg', 'cheindel', 'http://www.flickr.com/photos/cheindel/3270957323/', 'France'
LocationPhoto.photo 'Paris.jpg', '26700188@N05', 'http://www.flickr.com/photos/26700188@N05/4451676248/', 'Paris'
LocationPhoto.photo 'Los_Angeles.jpg', 'danielaltamirano', 'http://www.flickr.com/photos/danielaltamirano/2763173103', 'Los Angeles'
LocationPhoto.photo 'Portland.jpg', 'congaman', 'http://www.flickr.com/photos/congaman/4358234584', 'Portland'
LocationPhoto.photo 'Portland.jpg', 'congaman', 'http://www.flickr.com/photos/congaman/4358234584', 'Oregon'
LocationPhoto.photo 'Berlin.jpg', 'wordridden', 'http://www.flickr.com/photos/wordridden/1900892029', 'Berlin'
LocationPhoto.photo 'Sao_Paulo.jpg', 'thomashobbs', 'http://www.flickr.com/photos/thomashobbs/96794488', 'Sao Paulo'
LocationPhoto.photo 'Toronto.jpg', 'davidcjones', 'http://www.flickr.com/photos/davidcjones/4222408288', 'Toronto'
LocationPhoto.photo 'Austin.jpg', 'haggismac', 'http://www.flickr.com/photos/haggismac/5050364022', 'Austin'
LocationPhoto.photo 'Melbourne.jpg', 'rykneethling', 'http://www.flickr.com/photos/rykneethling/4616216715', 'Melbourne'
LocationPhoto.photo 'Sweden.jpg', 'mispahn', 'http://www.flickr.com/photos/mispahn/2750008975', 'Sweden'
LocationPhoto.photo 'Sweden.jpg', 'mispahn', 'http://www.flickr.com/photos/mispahn/2750008975', 'Kingdom of Sweden'
LocationPhoto.photo 'Atlanta.jpg', 'docsearls', 'http://www.flickr.com/photos/docsearls/3287944095', 'Atlanta'
LocationPhoto.photo 'Georgia.jpg', 'jongos', 'http://www.flickr.com/photos/jongos/326337675', 'Georgia'
LocationPhoto.photo 'Bengaluru.jpg', 'hpnadig', 'http://www.flickr.com/photos/hpnadig/5341916872', 'Bengaluru'
LocationPhoto.photo 'Sydney.jpg', 'robertpaulyoung', 'http://www.flickr.com/photos/robertpaulyoung/2677399791', 'Sydney'
LocationPhoto.photo 'Boston.jpg', 'rosenkranz', 'http://www.flickr.com/photos/rosenkranz/2788839653', 'Boston'
LocationPhoto.photo 'Rio_de_Janeiro.jpg', 'hectorgarcia', 'http://www.flickr.com/photos/hectorgarcia/6658699023', 'Rio de Janeiro'
LocationPhoto.photo 'Hamburg.jpg', 'lhoon', 'http://www.flickr.com/photos/lhoon/1330132713', 'Hamburg'
LocationPhoto.photo 'Montreal.jpg', 'sergemelki', 'http://www.flickr.com/photos/sergemelki/2613093643', 'Montreal'
LocationPhoto.photo 'Vancouver.jpg', 'poudyal', 'http://www.flickr.com/photos/poudyal/30924248', 'Vancouver'
LocationPhoto.photo 'San_Diego.jpg', 'chris_radcliff', 'http://www.flickr.com/photos/chris_radcliff/4488396247', 'San Diego'
LocationPhoto.photo 'Philadelphia.jpg', 'garyisajoke', 'http://www.flickr.com/photos/garyisajoke/5565916600', 'Philadelphia'
LocationPhoto.photo 'Denver.jpg', 'anneh632', 'http://www.flickr.com/photos/anneh632/3832540818', 'Denver'
LocationPhoto.photo 'Brisbane.jpg', 'eguidetravel', 'http://www.flickr.com/photos/eguidetravel/5662399294', 'Brisbane'
LocationPhoto.photo 'Buenos_Aires.jpg', 'davidberkowitz', 'http://www.flickr.com/photos/davidberkowitz/5269251427', 'Buenos Aires'
LocationPhoto.photo 'Columbus.jpg', 'dougtone', 'http://www.flickr.com/photos/dougtone/4103926290', 'Columbus'
LocationPhoto.photo 'Pittsburgh.jpg', 'dougtone', 'http://www.flickr.com/photos/dougtone/4189402481', 'Pittsburgh'
LocationPhoto.photo 'Amsterdam.jpg', 'mauro9', 'http://www.flickr.com/photos/mauro9/5068223866', 'Amsterdam'
LocationPhoto.photo 'Amsterdam.jpg', 'mauro9', 'http://www.flickr.com/photos/mauro9/5068223866', 'The Netherlands'
LocationPhoto.photo 'Amsterdam.jpg', 'mauro9', 'http://www.flickr.com/photos/mauro9/5068223866', 'Netherlands'
LocationPhoto.photo 'Washington_D_C_.jpg', '24736216@N07', 'http://www.flickr.com/photos/24736216@N07/4412624398', 'District of Columbia'
LocationPhoto.photo 'Dallas.jpg', '28795465@N03/3282536921', 'http://www.flickr.com/photos/28795465@N03/3282536921/', 'Dallas'
LocationPhoto.photo 'Vienna.jpg', 'muppetspanker', 'http://www.flickr.com/photos/muppetspanker/718665493', 'Vienna'
LocationPhoto.photo 'Colorado.jpg', 'jumpyjodes', 'http://www.flickr.com/photos/jumpyjodes/122371179', 'Colorado'
LocationPhoto.photo 'Edinburgh.jpg', 'chris-yunker', 'http://www.flickr.com/photos/chris-yunker/2504695724', 'Edinburgh'
LocationPhoto.photo 'Edinburgh.jpg', 'chris-yunker', 'http://www.flickr.com/photos/chris-yunker/2504695724', 'Scotland'
LocationPhoto.photo 'Minneapolis.jpg', 'dougtone', 'http://www.flickr.com/photos/dougtone/6188186129', 'Minnesota'
LocationPhoto.photo 'New_York.jpg', 'isherwoodchris', 'http://www.flickr.com/photos/isherwoodchris/3096255994', 'New York'
LocationPhoto.photo 'Ukraine.jpg', 'anaroz', 'http://www.flickr.com/photos/anaroz/1299717637', 'Ukraine'
LocationPhoto.photo 'Texas.jpg', 'theodorescott', 'http://www.flickr.com/photos/theodorescott/4155884901', 'Texas'
LocationPhoto.photo 'Texas.jpg', 'theodorescott', 'http://www.flickr.com/photos/theodorescott/4155884901', 'Houstan'
LocationPhoto.photo 'Norway.jpg', 'nelsonminar', 'http://www.flickr.com/photos/nelsonminar/5982537085', 'Norway'
LocationPhoto.photo 'Barcelona.jpg', '22746515@N02', 'http://www.flickr.com/photos/22746515@N02/2418242475', 'Barcelona'
LocationPhoto.photo 'Spain.jpg', 'promomadrid', 'http://www.flickr.com/photos/promomadrid/5781941734', 'Spain'
LocationPhoto.photo 'Mountain_View.jpg', 'ogachin', 'http://www.flickr.com/photos/ogachin/4940228785', 'Mountain View'
LocationPhoto.photo 'Tennessee.jpg', 'brent_nashville', 'http://www.flickr.com/photos/brent_nashville/133323377', 'Tennessee'
LocationPhoto.photo 'Palo_Alto.jpg', 'cytech', 'http://www.flickr.com/photos/cytech/4111311671', 'California'
LocationPhoto.photo 'North_Carolina.jpg', 'kamoteus', 'http://www.flickr.com/photos/kamoteus/2329402291', 'North Carolina'
LocationPhoto.photo 'Moscow.jpg', 'yourdon', 'http://www.flickr.com/photos/yourdon/2899648837', 'Moscow'
LocationPhoto.photo 'Russian_Federation.jpg', 'bbmexplorer', 'http://www.flickr.com/photos/bbmexplorer/1387630903', 'Russian Federation'
LocationPhoto.photo 'Denmark.jpg', 'jamesz_flickr/2440962462', 'http://www.flickr.com/photos/jamesz_flickr/2440962462/', 'Denmark'
LocationPhoto.photo 'Poland.jpg', 'wm_archiv', 'http://www.flickr.com/photos/wm_archiv/3360514904', 'Poland'
LocationPhoto.photo 'Chennai.jpg', 'vinothchandar', 'http://www.flickr.com/photos/vinothchandar/4215634377', 'Chennai'
LocationPhoto.photo 'Munich.jpg', 'moonsoleil', 'http://www.flickr.com/photos/moonsoleil/482606062', 'Munich'
LocationPhoto.photo 'Brazil.jpg', 'rob_sabino', 'http://www.flickr.com/photos/rob_sabino/4460055296', 'Brazil'
LocationPhoto.photo 'Chicago.jpg', 'endymion120', 'http://www.flickr.com/photos/endymion120/4800209439', 'Illinois'
LocationPhoto.photo 'Chicago.jpg', 'dgriebeling', 'http://www.flickr.com/photos/dgriebeling/3858526828', 'Chicago'
LocationPhoto.photo 'Cape_Town.jpg', 'nolandstooforeign', 'http://www.flickr.com/photos/nolandstooforeign/5512625043', 'Cape Town'
LocationPhoto.photo 'Canada.jpg', '62904109@N00', 'http://www.flickr.com/photos/62904109@N00/257831124', 'Canada'
LocationPhoto.photo 'Cologne.jpg', '11742539@N03', 'http://www.flickr.com/photos/11742539@N03/3849238477', 'Cologne'
LocationPhoto.photo 'Belgium.jpg', 'erasmushogeschool', 'http://www.flickr.com/photos/erasmushogeschool/3179361408', 'Belgium'
LocationPhoto.photo 'Wisconsin.jpg', 'midnightcomm', 'http://www.flickr.com/photos/midnightcomm/2708323382', 'Wisconsin'
LocationPhoto.photo 'Switzerland.jpg', 'jeffwilcox', 'http://www.flickr.com/photos/jeffwilcox/121769869', 'Switzerland'
LocationPhoto.photo 'Germany.jpg', '27752998@N04', 'http://www.flickr.com/photos/27752998@N04/3018494595', 'Germany'
LocationPhoto.photo 'Tokyo.jpg', 'manuuuuuu', 'http://www.flickr.com/photos/manuuuuuu/6136157876', 'Tokyo'
LocationPhoto.photo 'Japan.jpg', 'jseita', 'http://www.flickr.com/photos/jseita/5499535860', 'Japan'
LocationPhoto.photo 'Taiwan.jpg', 'http2007', 'http://www.flickr.com/photos/http2007/524982681', 'Taiwan'
LocationPhoto.photo 'Alaska.jpg', '24736216@N07', 'http://www.flickr.com/photos/24736216@N07/3840895221', 'Alaska'
LocationPhoto.photo 'Portugal.jpg', 'hom26', 'http://www.flickr.com/photos/hom26/6647457947', 'Portugal'
LocationPhoto.photo 'United_Kingdom.jpg', 'anniemole', 'http://www.flickr.com/photos/anniemole/2758348852', 'United Kingdom'
LocationPhoto.photo 'London.jpg', 'flamesworddragon', 'http://www.flickr.com/photos/flamesworddragon/5030767739', 'London'
LocationPhoto.photo 'Hungry.jpg', 'fatguyinalittlecoat', 'http://www.flickr.com/photos/fatguyinalittlecoat/4027128545', 'Hungary'
LocationPhoto.photo 'Massachusetts.jpg', '91829349@N00', 'http://www.flickr.com/photos/91829349@N00/2953131136', 'Massachusetts'
LocationPhoto.photo 'Kentucky.jpg', 'dougtone', 'http://www.flickr.com/photos/dougtone/4111366477', 'Kentucky'
LocationPhoto.photo 'Chile.jpg', 'hectorgarcia', 'http://www.flickr.com/photos/hectorgarcia/4282194530', 'Chile'
LocationPhoto.photo 'Indiana.jpg', 'netmonkey', 'http://www.flickr.com/photos/netmonkey/47901838', 'Indiana'
LocationPhoto.photo 'Flordia.jpg', 'alan-light', 'http://www.flickr.com/photos/alan-light/4316330444', 'Florida'
LocationPhoto.photo 'Arizona.jpg', 'combusean', 'http://www.flickr.com/photos/combusean/2568503883', 'Arizona'
LocationPhoto.photo 'Ohio.jpg', 'theclevelandkid24', 'http://www.flickr.com/photos/theclevelandkid24/3956087366', 'Ohio'
LocationPhoto.photo 'Missouri.jpg', 'orijinal', 'http://www.flickr.com/photos/orijinal/3985603991', 'Missouri'
LocationPhoto.photo 'Michigan.jpg', 'patriciadrury/3381026294', 'http://www.flickr.com/photos/patriciadrury/3381026294/', 'Michigan'
LocationPhoto.photo 'Milian.jpg', 'ikkoskinen', 'http://www.flickr.com/photos/ikkoskinen/5883454794', 'Milan'
LocationPhoto.photo 'Rome.jpg', 'z_wenjie', 'http://www.flickr.com/photos/z_wenjie/5644842473', 'Italy'
LocationPhoto.photo 'Rome.jpg', 'z_wenjie', 'http://www.flickr.com/photos/z_wenjie/5644842473', 'Rome'
LocationPhoto.photo 'Maryland.jpg', 'davies', 'http://www.flickr.com/photos/davies/5047932', 'Maryland'
LocationPhoto.photo 'India.jpg', 'hectorgarcia', 'http://www.flickr.com/photos/hectorgarcia/322071722', 'India'
LocationPhoto.photo 'Mexico.jpg', '22240293@N05', 'http://www.flickr.com/photos/22240293@N05/4526847801', 'Mexico'
LocationPhoto.photo 'Mexico_City.jpg', 'jorgebrazil', 'http://www.flickr.com/photos/jorgebrazil/6644379931', 'Mexico City'
LocationPhoto.photo 'New_Jersey.jpg', 'r0sss', 'http://www.flickr.com/photos/r0sss/899920125', 'New Jersey'
LocationPhoto.photo 'New_Jersey.jpg', 'hobokencondos', 'http://www.flickr.com/photos/hobokencondos/6461676753', 'New Jersey'
LocationPhoto.photo 'Connecticut.jpg', 'global-jet', 'http://www.flickr.com/photos/global-jet/2051525208', 'Connecticut'
LocationPhoto.photo 'Alabama.jpg', 'acnatta', 'http://www.flickr.com/photos/acnatta/264575595', 'Alabama'
LocationPhoto.photo 'Finland.jpg', 'seisdeagosto', 'http://www.flickr.com/photos/seisdeagosto/4308508577', 'Finland'
LocationPhoto.photo 'Auckland.jpg', 'jasonpratt', 'http://www.flickr.com/photos/jasonpratt/5355889516', 'Auckland'
LocationPhoto.photo 'New_Zealand.jpg', 'glutnix/6063846', 'http://www.flickr.com/photos/glutnix/6063846/', 'New Zealand'
LocationPhoto.photo 'Australia.jpg', 'hectorgarcia', 'http://www.flickr.com/photos/hectorgarcia/396072534', 'Australia'
LocationPhoto.photo 'Louisiana.jpg', 'moralesphoto', 'http://www.flickr.com/photos/moralesphoto/411678050', 'Louisiana'
LocationPhoto.photo 'Louisiana.jpg', 'cavemanlawyer15', 'http://www.flickr.com/photos/cavemanlawyer15/29345340', 'Louisiana'
LocationPhoto.photo 'Austria.jpg', 'roblisameehan', 'http://www.flickr.com/photos/roblisameehan/875194614', 'Austria'
