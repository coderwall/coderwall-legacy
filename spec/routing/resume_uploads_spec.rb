RSpec.describe ResumeUploadsController, type: :routing do
  describe 'routing' do

    it 'routes to #create' do
      expect(post('/resume_uploads')).to route_to(controller: 'resume_uploads', action: 'create')
    end

  end
end
