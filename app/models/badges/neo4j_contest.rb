class Neo4jContest
  class << self
    def load_facts
      GITHUB.each do |user|
        replace_assignments_and_awards("github:#{user}", Participant)
      end
      replace_assignments_and_awards('twitter:luannem', Winner)
    end

    def replace_assignments_and_awards(identity, badge_class)
      competition_end_date = Date.parse('2012/03/09')
      tags                 = %w(hackathon neo4j award)
      metadata             = {
        award: badge_class.name
      }
      Fact.append!("http://neo4j-challenge.herokuapp.com/:#{identity}", identity, badge_class.description, competition_end_date, 'http://neo4j.org/', tags, metadata)
    end
  end

  class Participant < BadgeBase
    describe 'Neo4j Challenger',
             skill:       'Neo4j',
             description: 'Participated in 2012 Neo4j Challenge',
             for:         'participating in the 2012 Neo4j seed the cloud challenge.',
             image_name:  'neo4j-challenge.png',
             weight:      1
  end

  class Winner < BadgeBase
    describe 'Neo4j Winner',
             skill:       'Neo4j',
             description: 'Won the 2012 Neo4j Challenge',
             for:         'winning the 2012 Neo4j seed the cloud challenge.',
             image_name:  'neo4j-winner.png',
             weight:      2
  end

  GITHUB = %w(
    akollegger
    nellaivijay
    tcjr
    leereilly
    danny
    mattyw
    Romiko
    akollegger
    mhluongo
    espeed
    maxdemarzi
    devender
    tomasmuller
    hleinone
    kluikens
    matthewford
    mhausenblas
    jadell
    vinodh
    chris-allnutt
    jhartwell
    carsonmcdonald
    zain
    sawilde
    sridif
    simon
    qzio
    jadell
    ghjunior
    andypetrella
    forthold
    qzio
    aseemk
  )
end
