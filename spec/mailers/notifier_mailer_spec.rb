RSpec.describe NotifierMailer, type: :mailer do
  let(:user) { user = Fabricate(:user, email: 'some.user@example.com') }

  it 'should send welcome email to user' do
    email = NotifierMailer.welcome_email(user.username).deliver
    expect(email.body.encoded).to include("http://coderwall.com/#{user.username}")
  end

  it 'should record when welcome email was sent' do
    expect(user.last_email_sent).to be_nil
    email = NotifierMailer.welcome_email(user.username).deliver
    expect(user.reload.last_email_sent).not_to be_nil
  end

  it 'should send an email when a user receives an endorsement' do
    endorsements = Fabricate(:user).endorse(user, 'Ruby')
    user.update_attributes last_request_at: 1.day.ago

    email = NotifierMailer.new_activity(user.reload.username)
    expect(email.body.encoded).to include("Congrats friend, you've received 1 endorsement")
  end

  it 'should send an email when a user receives an endorsement and achievement' do
    badge = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s)
    endorsements = Fabricate(:user).endorse(user, 'Ruby')
    user.update_attributes last_request_at: 1.day.ago

    email = NotifierMailer.new_activity(user.reload.username)
    expect(email.body.encoded).to include("Congrats friend, you've unlocked 1 achievement and received 1 endorsement")
  end

  describe 'achievement emails' do

    it 'should send an email when a user receives a new achievement' do
      badge = Fabricate(:badge, user: user, badge_class_name: Badges.all.sample.to_s)
      user.update_attributes last_request_at: 1.day.ago
      expect(user.achievements_unlocked_since_last_visit.count).to eq(1)

      email = NotifierMailer.new_badge(user.reload.username)
      check_badge_message(email, badge)
      expect(email.body.encoded).to include(user_achievement_url(username: user.username, id: badge.id, host: 'coderwall.com'))
    end

    it 'should send one achievement email at a time until user visits' do
      badge1 = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s, created_at: Time.now)
      badge2 = Fabricate(:badge, user: user, badge_class_name: Badges.all.second.to_s, created_at: Time.now + 1.second)
      badge3 = Fabricate(:badge, user: user, badge_class_name: Badges.all.third.to_s, created_at: Time.now + 2.seconds)
      user.update_attributes last_request_at: 1.day.ago

      expect(user.achievements_unlocked_since_last_visit.count).to eq(3)
      email = NotifierMailer.new_badge(user.reload.username)
      check_badge_message(email, badge1)
      expect(user.achievements_unlocked_since_last_visit.count).to eq(3)
      email = NotifierMailer.new_badge(user.reload.username)
      check_badge_message(email, badge2)
      user.last_request_at = Time.now + 3.second
      user.save
      expect(user.achievements_unlocked_since_last_visit.count).to eq(0)
      expect { NotifierMailer.new_badge(user.reload.username) }.to raise_error(NotifierMailer::NothingToSendException)
    end

    def check_badge_message(email, badge)
      if badge.tokenized_skill_name.blank?
        expect(email.body.encoded).to include("You've earned a new badge for #{badge.for}")
      else
        expect(email.body.encoded).to include("You've earned a new badge for your #{badge.tokenized_skill_name} hacking skills and contribution.")
      end
    end
  end

  describe 'comment emails' do
    let(:protip) { Fabricate(:protip, user: user) }
    let(:commentor) { Fabricate(:user) }

    it 'should send an email when a user receives a comment on their protip' do
      protip.comments.create(user: commentor, body: 'hello')
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      email = ActionMailer::Base.deliveries.first
      expect(email.body.encoded).to include(user.short_name)
      expect(email.body.encoded).to include("#{commentor.username} has commented on your pro tip")
      expect(email.body.encoded).to include(protip.title)
    end

    it 'should send an email when a user is mentioned in a comment' do
      mentioned_user = Fabricate(:user)
      protip.comments.create(user: commentor, body: "hello @#{mentioned_user.username}")
      expect(ActionMailer::Base.deliveries.size).to eq(2)
      email = ActionMailer::Base.deliveries.last
      expect(email.body.encoded).to include(mentioned_user.short_name)
      expect(email.body.encoded).to include("#{commentor.username} replied to your comment on the pro tip")
      expect(email.body.encoded).to include(protip.title)
      expect(email.to).to include(mentioned_user.email)
    end
  end
end
