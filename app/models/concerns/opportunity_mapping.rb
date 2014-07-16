module OpportunityMapping
  extend ActiveSupport::Concern

  included do
    settings analysis: { analyzer: { comma: { 'type'    => 'pattern',
                                              'pattern' => ',' } } }
    mapping show: { properties: {
        public_id:        { type: 'string', index: 'not_analyzed' },
        name:             { type: 'string', boost: 100, analyzer: 'snowball' },
        description:      { type: 'string', boost: 100, analyzer: 'snowball' },
        designation:      { type: 'string', index: 'not_analyzed' },
        opportunity_type: { type: 'string', index: 'not_analyzed' },
        location:         { type: 'string', boost: 80, analyzer: 'snowball' },
        location_city:    { type: 'string', boost: 80, analyzer: 'snowball' },
        tags:             { type: 'string', boost: 50, analyzer: 'comma' },
        link:             { type: 'string', index: 'not_analyzed' },
        salary:           { type: 'integer', boost: 80, index: 'not_analyzed' },
        created_at:       { type: 'string', index: 'not_analyzed' },
        updated_at:       { type: 'string', index: 'not_analyzed' },
        expires_at:       { type: 'string', index: 'not_analyzed' },
        url:              { type: 'string', index: 'not_analyzed' },
        apply:            { type: 'boolean', index: 'not_analyzed' },
        team:             { type: 'multi_field', index: 'not_analyzed', fields: {
            name:                  { type: 'string', index: 'snowball' },
            slug:                  { type: 'string', boost: 50, index: 'snowball' },
            id:                    { type: 'string', index: 'not_analyzed' },
            avatar_url:            { type: 'string', index: 'not_analyzed' },
            featured_banner_image: { type: 'string', index: 'not_analyzed' },
            big_image:             { type: 'string', index: 'not_analyzed' },
            hiring:                { type: 'boolean', index: 'not_analyzed' }
        } },
    } }
  end
end