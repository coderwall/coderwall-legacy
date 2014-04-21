describe Notifier do
  let(:user) { user = Fabricate(:user, email: 'some.user@example.com') }

  it 'should send welcome email to user' do
    email = Notifier.welcome_email(user.username).deliver
    email.body.encoded.should include("http://coderwall.com/#{user.username}")
  end

  it 'should record when welcome email was sent' do
    user.last_email_sent.should be_nil
    email = Notifier.welcome_email(user.username).deliver
    user.reload.last_email_sent.should_not be_nil
  end

  it "should send an email when a user receives an endorsement" do
    endorsements = Fabricate(:user).endorse(user, 'Ruby')
    user.update_attributes last_request_at: 1.day.ago

    email = Notifier.new_activity(user.reload.username)
    email.body.encoded.should include("Congrats friend, you've received 1 endorsement")
  end

  it "should send an email when a user receives an endorsement and achievement" do
    badge = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s)
    endorsements = Fabricate(:user).endorse(user, 'Ruby')
    user.update_attributes last_request_at: 1.day.ago

    email = Notifier.new_activity(user.reload.username)
    email.body.encoded.should include("Congrats friend, you've unlocked 1 achievement and received 1 endorsement")
  end

  describe 'achievement emails' do

    it "should send an email when a user receives a new achievement" do
      badge = Fabricate(:badge, user: user, badge_class_name: Badges.all.sample.to_s)
      user.update_attributes last_request_at: 1.day.ago
      user.achievements_unlocked_since_last_visit.count.should == 1

      email = Notifier.new_badge(user.reload.username)
      check_badge_message(email, badge)
      email.body.encoded.should include(user_achievement_url(username: user.username, id: badge.id, host: "coderwall.com"))
    end

    it "should send one achievement email at a time until user visits" do
      badge1 = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s, created_at: Time.now)
      badge2 = Fabricate(:badge, user: user, badge_class_name: Badges.all.second.to_s, created_at: Time.now + 1.second)
      badge3 = Fabricate(:badge, user: user, badge_class_name: Badges.all.third.to_s, created_at: Time.now + 2.seconds)
      user.update_attributes last_request_at: 1.day.ago

      user.achievements_unlocked_since_last_visit.count.should == 3
      email = Notifier.new_badge(user.reload.username)
      check_badge_message(email, badge1)
      user.achievements_unlocked_since_last_visit.count.should == 3
      email = Notifier.new_badge(user.reload.username)
      check_badge_message(email, badge2)
      user.last_request_at = Time.now + 3.second
      user.save
      user.achievements_unlocked_since_last_visit.count.should == 0
      expect { Notifier.new_badge(user.reload.username) }.to raise_error(Notifier::NothingToSendException)
    end

    def check_badge_message(email, badge)
      if badge.tokenized_skill_name.blank?
        email.body.encoded.should include("You've earned a new badge for #{badge.for}")
      else
        email.body.encoded.should include("You've earned a new badge for your #{badge.tokenized_skill_name} hacking skills and contribution.")
      end
    end
  end

  describe 'comment emails' do
    let(:protip) { Fabricate(:protip, user: user) }
    let(:commentor) { Fabricate(:user) }

    it 'should send an email when a user receives a comment on their protip' do
      protip.comments.create(user: commentor, body: "hello")
      ActionMailer::Base.deliveries.size.should == 1
      email = ActionMailer::Base.deliveries.first
      email.body.encoded.should include(user.short_name)
      email.body.encoded.should include("#{commentor.username} has commented on your pro tip")
      email.body.encoded.should include(protip.title)
    end

    it 'should send an email when a user is mentioned in a comment' do
      mentioned_user = Fabricate(:user)
      protip.comments.create(user: commentor, body: "hello @#{mentioned_user.username}")
      ActionMailer::Base.deliveries.size.should == 2
      email = ActionMailer::Base.deliveries.last
      email.body.encoded.should include(mentioned_user.short_name)
      email.body.encoded.should include("#{commentor.username} replied to your comment on the pro tip")
      email.body.encoded.should include(protip.title)
      email.to.should include(mentioned_user.email)
    end
  end
end
