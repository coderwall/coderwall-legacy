RSpec.describe EmailsController, type: :controller do
  let(:mailgun_params) do {
    'domain'     => ENV['MAILGUN_DOMAIN'],
    'tag'        => '*',
    'recipient'  => 'someone@example.com',
    'event'      => 'unsubscribed',
    'email_type' => Notifier::ACTIVITY_EVENT,
    'timestamp'  => '1327043027',
    'token'      => ENV['MAILGUN_TOKEN'],
    'signature'  => ENV['MAILGUN_SIGNATURE'],
    'controller' => 'emails',
    'action'     => 'unsubscribe' }
  end

  it 'unsubscribes member from notifications when they unsubscribe from a notification email on mailgun' do
    user = Fabricate(:user, email: 'someone@example.com')
    expect(user.notify_on_award).to eq(true)
    expect_any_instance_of(EmailsController).to receive(:encrypt_signature).and_return(ENV['MAILGUN_SIGNATURE'])
    post :unsubscribe, mailgun_params
    user.reload
    expect(user.notify_on_award).to eq(false)
    expect(user.receive_newsletter).to eq(true)
  end

  it 'unsubscribes member from everything when they unsubscribe from a welcome email on mailgun' do
    user = Fabricate(:user, email: 'someone@example.com')
    new_params = mailgun_params
    new_params['email_type'] = Notifier::WELCOME_EVENT
    expect_any_instance_of(EmailsController).to receive(:encrypt_signature).and_return(ENV['MAILGUN_SIGNATURE'])
    post :unsubscribe, mailgun_params
    user.reload
    expect(user.notify_on_award).to eq(true)
    expect(user.receive_newsletter).to eq(false)
  end

end
