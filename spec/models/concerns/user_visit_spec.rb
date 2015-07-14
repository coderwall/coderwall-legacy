require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) {Fabricate(:user)}
  it 'should respond to instance methods' do
    expect(user).to respond_to :visited!
    expect(user).to respond_to :latest_visits
    expect(user).to respond_to :append_latest_visits
    expect(user).to respond_to :average_time_between_visits
    expect(user).to respond_to :calculate_frequency_of_visits!
    expect(user).to respond_to :activity_since_last_visit?
  end

end
