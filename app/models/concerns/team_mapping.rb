module TeamMapping
  extend ActiveSupport::Concern

  included do
    mapping team: {
      properties: {
        id:                 { type: 'string', index: 'not_analyzed' },
        slug:               { type: 'string', index: 'not_analyzed' },
        name:               { type: 'string', boost: 100, analyzer: 'snowball' },
        score:              { type: 'float', index: 'not_analyzed' },
        size:               { type: 'integer', index: 'not_analyzed' },
        avatar:             { type: 'string', index: 'not_analyzed' },
        country:            { type: 'string', boost: 50, analyzer: 'snowball' },
        url:                { type: 'string', index: 'not_analyzed' },
        follow_path:        { type: 'string', index: 'not_analyzed' },
        hiring:             { type: 'boolean', index: 'not_analyzed' },
        total_member_count: { type: 'integer', index: 'not_analyzed' },
        completed_sections: { type: 'integer', index: 'not_analyzed' },
        team_members:       { type: 'multi_field', fields: {
          username:    { type: 'string', index: 'not_analyzed' },
          profile_url: { type: 'string', index: 'not_analyzed' },
          avatar:      { type: 'string', index: 'not_analyzed' }
        } }
      }
    }

  end
end
