require 'spec_helper'

RSpec.describe LifecycleMarketing, type: :model, skip: true do

  describe 'valid_newsletter_users' do
    it 'should only find users with newsletter enabled' do
      receive_newsletter = Fabricate(:user, receive_newsletter: true)
      does_not_receive_newsletter = Fabricate(:user, receive_newsletter: false)
      users_to_email = LifecycleMarketing.valid_newsletter_users.all
      expect(users_to_email).to include(receive_newsletter)
      expect(users_to_email).not_to include(does_not_receive_newsletter)
    end

    it 'should only find users that have not recieved an email in a week' do
      emailed_last_week = Fabricate(:user, receive_newsletter: true, last_email_sent: 8.days.ago)
      just_emailed = Fabricate(:user, receive_newsletter: true, last_email_sent: 1.day.ago)
      users_to_email = LifecycleMarketing.valid_newsletter_users.all
      expect(users_to_email).to include(emailed_last_week)
      expect(users_to_email).not_to include(just_emailed)
    end
  end

  describe 'reminding user to invite team members' do
    it 'should only if they are on a team' do
      user_on_team = Fabricate(:user, receive_newsletter: true, team_id: Fabricate(:team).id.to_s)
      LifecycleMarketing.send_reminders_to_invite_team_members
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'should not send multiple reminders' do
      user_on_team = Fabricate(:user, receive_newsletter: true, team_id: Fabricate(:team).id.to_s)
      LifecycleMarketing.send_reminders_to_invite_team_members
      user_on_team.update_attributes!(last_email_sent: 2.weeks.ago)
      LifecycleMarketing.send_reminders_to_invite_team_members
      expect(ActionMailer::Base.deliveries.size).to eq(1)
    end

    it 'should not if they are not on a team' do
      user_on_team = Fabricate(:user, receive_newsletter: true, team_id: nil)
      LifecycleMarketing.send_reminders_to_invite_team_members
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'should only send email to a team once a day' do
      team_id = Fabricate(:team).id.to_s
      member1 = Fabricate(:user, email: 'member1@test.com', receive_newsletter: true, team_id: team_id)
      member2 = Fabricate(:user, email: 'member2@test.com', receive_newsletter: true, team_id: team_id)
      LifecycleMarketing.send_reminders_to_invite_team_members
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.last.to).to include(member1.email)
    end
  end

  describe 'reminding users when they get new achievements' do
    it 'should send only one email at a time' do
      team_id = Fabricate(:team).id.to_s
      user = Fabricate(:user, email: 'member2@test.com', receive_newsletter: true, team_id: team_id)
      badge1 = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s, created_at: Time.now)
      badge2 = Fabricate(:badge, user: user, badge_class_name: Badges.all.second.to_s, created_at: Time.now + 1.second)
      badge3 = Fabricate(:badge, user: user, badge_class_name: Badges.all.third.to_s, created_at: Time.now + 2.seconds)
      user.update_attributes last_request_at: 1.day.ago

      LifecycleMarketing.send_new_achievement_reminders
      LifecycleMarketing.send_new_achievement_reminders
      expect(ActionMailer::Base.deliveries.size).to eq(1)
      expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    end

    it 'should not send email if user visited since earning achievements' do
      team_id = Fabricate(:team).id.to_s
      user = Fabricate(:user, email: 'member2@test.com', receive_newsletter: true, team_id: team_id)
      badge1 = Fabricate(:badge, user: user, badge_class_name: Badges.all.first.to_s, created_at: Time.now)
      badge2 = Fabricate(:badge, user: user, badge_class_name: Badges.all.second.to_s, created_at: Time.now + 1.second)
      badge3 = Fabricate(:badge, user: user, badge_class_name: Badges.all.third.to_s, created_at: Time.now + 2.seconds)
      user.update_attributes last_request_at: Time.now + 1.hour

      LifecycleMarketing.send_new_achievement_reminders
      expect(ActionMailer::Base.deliveries.size).to eq(0)
    end

  end
end
