class Author < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "index_name_author"
  document_type self.name.downcase

  settings index: { number_of_shards: 1 } do
    mapping dynamic: false do
      indexes :first_name, analyzer: 'english', index_options: 'offset'
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ['first_name^5', 'last_name']
          }
        },
        highlight: {
          pre_tags: ['<mark>'],
          post_tags: ['</mark>'],
          fields: {
            first_name: {},
            last_name: {},
          }
        },
        suggest: {
          text: query,
          first_name: {
            term: {
              size: 1,
              field: :first_name
            }
          },
          last_name: {
            term: {
              size: 1,
              field: :last_name
            }
          }
        }
      }
    )
  end

  def as_indexed_json(options = nil)
    self.as_json( only: [ :first_name, :last_name ] )
  end
end
