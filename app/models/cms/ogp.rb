class Cms::Ogp < ApplicationRecord
  include Sys::Model::Base

  enum_ish :og_type, [:article, :product, :profile]

  belongs_to :taggable, polymorphic: true

  nested_scope :in_site, through: :taggable
end
