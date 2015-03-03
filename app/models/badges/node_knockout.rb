require 'csv'

class NodeKnockout

  CATEGORIES   = %w(innovation design utility completeness popularity)
  PARTICIPANTS = %w(judges contenders)
  WINNERS      = %w(team solo)

  attr_accessor *(CATEGORIES + PARTICIPANTS + WINNERS).map(&:to_sym)
  attr_accessor :winners

  def initialize(year, end_date)
    @year     = year
    @end_date = end_date
  end

  def user_with_github(github_username)
    where(["UPPER(github) = ?", github_username.upcase]).first
  end

  def load_from_file
    text = File.read(Rails.root.join('db', 'seeds', "nodeknockout-#{@year}.csv"))
    unless text.nil?
      csv = CSV.parse(text, headers: false)
      csv.each do |row|
        category = row.shift
        self.send("#{category}=", row.to_a)
      end
    end
  end

  def load_from_website
    CATEGORIES.each do |category|
      populate_category(category)
    end
    populate_participants
    populate_winners
  end

  def reset!
    load_from_file
    only_contenders = self.contenders - (self.winners + self.popularity + self.utility + self.design + self.innovation + self.completeness)
    replace_assignments_and_awards(only_contenders, self.ContenderBadge)
    replace_assignments_and_awards(self.winners, self.ChampionBadge)
    replace_assignments_and_awards(self.popularity, self.MostVotesBadge)
    replace_assignments_and_awards(self.utility, self.MostUsefulBadge)
    replace_assignments_and_awards(self.design, self.BestDesignBadge)
    replace_assignments_and_awards(self.innovation, self.MostInnovativeBadge)
    replace_assignments_and_awards(self.completeness, self.MostCompleteBadge)
    replace_assignments_and_awards_for_twitter(self.judges, self.JudgeBadge)
  end

  def replace_assignments_and_awards(github_usernames, badge_class)
    competition_end_date = Date.parse(@end_date)
    tags                 = ['hackathon', 'nodejs', 'award', 'nodeknockout']
    metadata             = {
      award: badge_class.name
    }
    github_usernames.each do |github_username|
      fact = Fact.append!("http://nodeknockout.com/#{badge_class.to_s}:#{github_username}", "github:#{github_username}", badge_class.description, competition_end_date, "http://nodeknockout.com/", tags, metadata)
      fact.user.try(:check_achievements!)
    end
  end

  # erniehacks => Judget
  def replace_assignments_and_awards_for_twitter(twitter_usernames, badge_class)
    competition_end_date = Date.parse(@end_date)
    tags                 = ['hackathon', 'nodejs', 'award', 'nodeknockout']
    metadata             = { award: badge_class.name }
    twitter_usernames.each do |twitter_username|
      fact = Fact.append!("http://nodeknockout.com/#{badge_class.to_s}:#{twitter_username}", "twitter:#{twitter_username}", badge_class.description, competition_end_date, "http://nodeknockout.com/", tags, metadata)
      fact.user.try(:check_achievements!)
    end
  end

  def get_people_from(path)
    people = []
    res    = Servant.get("http://nodeknockout.com#{path}")
    doc    = Nokogiri::HTML(res.to_s)
    doc.css('#inner ul li a').each do |element|
      if element[:href] =~ /people\//i && element.parent.content !~ /voter/
        people << (github_for(element[:href]) || twitter_for(element[:href]))
      end
    end
    people
  end

  def populate_winners
    WINNERS.each do |winner_category|
      populate_category(winner_category)
    end
    self.winners = WINNERS.map { |winner| self.send(winner) }.reduce(:+)
  end

  def populate_category(category)
    res  = Servant.get("http://nodeknockout.com/entries?sort=#{category}")
    doc  = Nokogiri::HTML(res.to_s)
    link = doc.css('ul.teams > li h4 a').first[:href]
    self.send("#{category}=", get_people_from(link).map { |user| user[1] }) #get the usernames
  end

  def populate_participants
    self.judges     = []
    self.contenders = []
    get_people_from("/people").each do |role, user|
      if role == "judge"
        self.judges << user
      elsif role == "contestant"
        self.contenders << user
      end
    end
  end

  def github_for(path)
    begin
      res      = Servant.get("http://nodeknockout.com#{path}")
      doc      = Nokogiri::HTML(res.to_s)
      username = doc.css("a.github").first[:href].sub(/https?:\/\/github.com\//, '')
      role     = doc.css(".role").first.text
      [role, username]
    rescue Exception => ex
      nil
    end
  end

  def twitter_for(path)
    begin
      res      = Servant.get("http://nodeknockout.com#{path}")
      doc      = Nokogiri::HTML(res.to_s)
      username = doc.css("a.twitter").first[:href].sub("http://twitter.com/", '').strip
      role     = doc.css(".role").first.text
      Rails.logger.info "Found node knockout #{role}: #{username}"
      return [role, username]
    rescue Exception => ex
      Rails.logger.warn("Was unable to determine twitter for #{path}")
      return nil
    end
  end

  AWARDS = %w(Champion BestDesign MostVotes MostUseful MostInnovative MostComplete Contender Judge)

  AWARDS.each do |category|
    define_method("#{category}Badge") { "NodeKnockout::#{category}#{@year}".constantize }
  end

  YEARS = [2011, 2012, 2013, 2014]

  YEARS.each do |year|
    const_set "Contender#{year}", Class.new(BadgeBase) {
      describe "KO Contender",
               skill:       'Node.js',
               description: "Participated in #{year} Node Knockout",
               for:         "participating in #{year} Node Knockout.",
               image_name:  "ko-contender-#{year}.png",
               weight:      1
    }

    const_set "Judge#{year}", Class.new(BadgeBase) {
      describe "KO Judge",
               skill:       'Node.js',
               description: "Official Judge of the #{year} Node Knockout",
               for:         "judging the #{year} Node Knockout.",
               image_name:  "ko-judge-#{year}.png",
               weight:      1
    }

    const_set "Champion#{year}", Class.new(BadgeBase) {
      describe "KO Champion",
               skill:       'Node.js',
               description: "Won first place in the #{year} Node Knockout",
               for:         "winning first place in the #{year} Node Knockout.",
               image_name:  "ko-champion-#{year}.png",
               weight:      2
    }

    const_set "BestDesign#{year}", Class.new(BadgeBase) {
      describe "KO Design",
               skill:       'Node.js',
               description: "Won the best designed app in the #{year} Node Knockout",
               for:         "winning the best designed app in the #{year} Node Knockout",
               image_name:  "ko-best-design-#{year}.png",
               weight:      2
    }

    const_set "MostVotes#{year}", Class.new(BadgeBase) {
      describe "KO Popular",
               skill:       'Node.js',
               description: "Won the most votes in the #{year} Node Knockout",
               for:         "winning the most votes in the #{year} Node Knockout",
               image_name:  "ko-most-votes-#{year}.png",
               weight:      2
    }

    const_set "MostUseful#{year}", Class.new(BadgeBase) {
      describe "KO Utility",
               skill:       'Node.js',
               description: "Won the most useful app in the #{year} Node Knockout",
               for:         "winning the most useful app in the #{year} Node Knockout",
               image_name:  "ko-most-useful-#{year}.png",
               weight:      2
    }

    const_set "MostInnovative#{year}", Class.new(BadgeBase) {
      describe "KO Innovation",
               skill:       'Node.js',
               description: "Won the most innovative app in the #{year} Node Knockout",
               for:         "winning the most innovative app in the #{year} Node Knockout",
               image_name:  "ko-most-innovative-#{year}.png",
               weight:      2
    }

    const_set "MostComplete#{year}", Class.new(BadgeBase) {
      describe "KO Complete",
               skill:       'Node.js',
               description: "Won the most complete app in the #{year} Node Knockout",
               for:         "winning the most complete app in the #{year} Node Knockout",
               image_name:  "ko-most-complete-#{year}.png",
               weight:      2
    }
  end
end
