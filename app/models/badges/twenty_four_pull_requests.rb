class TwentyFourPullRequests
  class << self
    def load_badges
      (2012..2020).each do |year|
        Object.const_set "TwentyFourPullRequestsContinuous#{year}", Class.new(BadgeBase) {
          describe "24PullRequests Continuous Syncs",
                   skill:       'Open Source',
                   description: "Sent at least 24 pull requests during the first 24 days of December #{year}",
                   for:         "being an open source machine in the 24pullrequest initiative during #{year}",
                   image_name:  "24-continuous-sync.png",
                   url:         "http://24pullrequests.com/"
        }

        Object.const_set "TwentyFourPullRequestsParticipant#{year}", Class.new(BadgeBase) {
          describe "24PullRequests Participant",
                   skill:       'Open Source',
                   description: "Sent at least one pull request during the first 24 days of December #{year}",
                   for:         "participating in the 24pullrequest initiative during #{year}",
                   image_name:  "24-participant.png",
                   url:         "http://24pullrequests.com/"
        }
      end
    end
  end
end
