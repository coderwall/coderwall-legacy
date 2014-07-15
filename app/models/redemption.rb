class Redemption < Struct.new(:code, :name, :url, :relevant_on, :badge, :description, :tags, :metadata)
  ALL = [
    STANDFORD_ACM312 = Redemption.new('ACM312', '2012 Winter Hackathon', 'http://stanfordacm.com', Date.parse('12/03/2012'), HackathonStanford, "Participated in Stanford's premier Hackathon on March 3rd 2012.", %w(hackathon university award inperson),  school: 'Stanford', award: HackathonStanford.name),
    CMU_HACKATHON    = Redemption.new('CMUHACK', 'CMU Hackathon', 'http://www.scottylabs.org/', Date.parse('01/05/2012'), HackathonCmu, "Participated in Carnegie Mellon's Hackathon.", %w(hackathon university award inperson),  school: 'Carnegie Mellon', award: HackathonCmu.name),
    WROCLOVE         = Redemption.new('WROCLOVE', '2012 wroc_love.rb Conference', 'http://wrocloverb.com', Date.parse('09/03/2012'), WrocLover, 'Attended the wroc_lover.rb conference on March 9th 2012.', %w(conference attended award),  name: 'WrocLove', award: WrocLover.name),
    UHACK            = Redemption.new('UHACK12', 'UHack 2012', 'http://uhack.us', Date.parse('01/4/2012'), Hackathon, 'Participated in UHack, organized by the ACM and IEEE at the University of Miami in April 2012.', %w(hackathon award inperson),  school: 'University of Miami', award: Hackathon.name),
    ADVANCE_HACK     = Redemption.new('AH12', 'Advance Hackathon 2012', 'https://github.com/railslove/Hackathon2012', Date.parse('29/4/2012'), Hackathon, 'Participated in the Advance Hackathon, a 3 day event for collaborative coding, meeting the finest designers and coders from whole NRW at Coworking Space Gasmotorenfabrik, Cologne.', %w(hackathon award inperson),  award: Hackathon.name),
    RAILSBERRY       = Redemption.new('RAILSBERRY2012', '2012 Railsberry Conference', 'http://railsberry.com', Date.parse('20/04/2012'), Railsberry, 'Attended the Railsberry April 20th 2012.', %w(conference attended award),  name: 'Railsberry', award: Railsberry.name)
  ]

  def self.for_code(code)
    ALL.find { |redemption| redemption.code.downcase == code.downcase }
  end

  def award!(user)
    Fact.append!("redemption:#{code}:#{user.id}", user.id.to_s, name, relevant_on, url, tags, metadata)
    user.redemptions << code
    user.award(badge.new(user))
    user.save!
  end
end
