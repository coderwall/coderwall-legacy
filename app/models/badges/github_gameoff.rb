class GithubGameoff
  class << self
    def load_badges
      (2012..2020).each do |year|
        Object.const_set "GithubGameoffJudge#{year}", Class.new(BadgeBase) {
          describe "Github Gameoff Judge",
                   skill:       'game development',
                   description: "Was a judge in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   for:         "judging the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   image_name:  "github-gameoff-judge-#{year}.png",
                   url:         "https://github.com/blog/1303-github-game-off"
        }

        Object.const_set "GithubGameoffWinner#{year}", Class.new(BadgeBase) {
          describe "Github Gameoff Participant",
                   skill:       'game development',
                   description: "Won the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   for:         "winning the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   image_name:  "github-gameoff-winner-#{year}.png",
                   url:         "https://github.com/blog/1303-github-game-off"
        }

        Object.const_set "GithubGameoffRunnerUp#{year}", Class.new(BadgeBase) {
          describe "Github Gameoff Runner Up",
                   skill:       'game development',
                   description: "Was runner up in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   for:         "being the runner up in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   image_name:  "github-gameoff-runner-up-#{year}.png",
                   url:         "https://github.com/blog/1303-github-game-off"
        }

        Object.const_set "GithubGameoffHonorableMention#{year}", Class.new(BadgeBase) {
          describe "Github Gameoff Honorable Mention",
                   skill:       'game development',
                   description: "Was an honorable mention in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   for:         "being noted an honorable mention in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   image_name:  "github-gameoff-honorable-mention-#{year}.png",
                   url:         "https://github.com/blog/1303-github-game-off"
        }

        Object.const_set "GithubGameoffParticipant#{year}", Class.new(BadgeBase) {
          describe "Github Gameoff Participant",
                   skill:       'game development',
                   description: "Participated in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   for:         "participating in the Github Gameoff #{year} building a game based on git concepts of forking, branching, etc",
                   image_name:  "github-gameoff-participant-#{year}.png",
                   url:         "https://github.com/blog/1303-github-game-off"
        }
      end
    end
  end
end

