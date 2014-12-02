module Users
  module Github
    class FollowedRepo
      attr_reader :data

      def initialize(data)
        @data = JSON.parse(data)
      end

      def description
        data['description']
      end

      def repo
        data['link'].sub('https://github.com/', '')
      end

      def date
        @date ||= Date.parse(data['date'])
      end

      def link
        data['link']
      end

      def user
        User.find(data['user_id'])
      end
    end
  end
end
