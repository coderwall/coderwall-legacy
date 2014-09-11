module Coderwall
  module Github
    def self.extract_repo_owner_and_name_from_url(url)
      val = {}
      val[:repo_owner], val[:repo_name] = *link.gsub(/https?:\/\/github.com\//i, '').split('/')
      val
    end

    module Queries
    end
  end
end
