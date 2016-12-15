class Sys::StorageFile < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::TextExtraction

  scope :available, -> { where(available: true) }
  scope :unavailable, -> { where.not(available: true) }

  validates :path, presence: true, uniqueness: true
  validates :available, presence: true

  validate :file_existence

  before_save :set_mime_type

  def self.import(r = 'sites')
    root = Rails.root.join(r.to_s.sub(/\A\//, ''))
    return unless root.directory?

    transaction do
      update_all(available: false)
      Dir.glob(root.join('**/*')) do |file|
        next unless File.file?(file)
        find_or_create_by!(path: file).update!(available: true)
      end
      unavailable.destroy_all
    end
  end

  private

  def file_existence
    errors.add(:base, "File does not exist: #{path}") unless File.exists?(path.to_s)
  end

  def set_mime_type
    result = `file -b --mime #{path}`
    self.mime_type = result.split(/[:;]\s+/).first
  rescue => e
    warn_log e.message
  end
end
