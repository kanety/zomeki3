module Cms::Model::Rel::Ogp
  extend ActiveSupport::Concern

  included do
    has_one :ogp, -> { order(:id) }, class_name: 'Cms::Ogp', dependent: :destroy, as: :taggable
    accepts_nested_attributes_for :ogp
  end
end
