describe EmailsController do
  let(:mailgun_params) { {
    'domain'     => ENV['MAILGUN_DOMAIN'],
    'tag'        => '*',
    'recipient'  => 'someone@example.com',
    'event'      => 'unsubscribed',
    'email_type' => Notifier::ACTIVITY_EVENT,
    'timestamp'  => '1327043027',
    'token'      => ENV['MAILGUN_TOKEN'],
    'signature'  => ENV['MAILGUN_SIGNATURE'],
    'controller' => 'emails',
    'action'     => 'unsubscribe'}
  }

  it 'unsubscribes member from notifications when they unsubscribe from a notification email on mailgun' do
    user = Fabricate(:user, email: 'someone@example.com')
    user.notify_on_award.should == true
    EmailsController.any_instance.should_receive(:encrypt_signature).and_return(ENV['MAILGUN_SIGNATURE'])
    post :unsubscribe, mailgun_params
    user.reload
    user.notify_on_award.should == false
    user.receive_newsletter.should == true
  end

  it 'unsubscribes member from everything when they unsubscribe from a welcome email on mailgun' do
    user = Fabricate(:user, email: 'someone@example.com')
    new_params = mailgun_params
    new_params["email_type"] = Notifier::WELCOME_EVENT
    EmailsController.any_instance.should_receive(:encrypt_signature).and_return(ENV['MAILGUN_SIGNATURE'])
    post :unsubscribe, mailgun_params
    user.reload
    user.notify_on_award.should == true
    user.receive_newsletter.should == false
  end

end
