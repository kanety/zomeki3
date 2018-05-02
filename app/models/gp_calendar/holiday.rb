class GpCalendar::Holiday < ApplicationRecord
  include Sys::Model::Base
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Content
  include Cms::Model::Auth::Content

  # Pseudo event attributes
  attr_accessor :href, :name, :note, :categories, :files, :image_files
  # Not saved to database
  attr_accessor :doc

  enum_ish :state, [:public, :closed], default: :public
  enum_ish :kind, [:holiday, :event], default: :holiday

  # Content
  belongs_to :content, class_name: 'GpCalendar::Content::Event', required: true

  after_initialize :set_defaults

  after_save     Cms::Publisher::ContentCallbacks.new(belonged: true), if: :changed?
  before_destroy Cms::Publisher::ContentCallbacks.new(belonged: true)

  validates :state, presence: true
  validates :title, presence: true

  scope :public_state, -> { where(state: 'public') }
  scope :scheduled_on, ->(date) { scheduled_between(date, date) }
  scope :scheduled_between, ->(start_date, end_date) {
    if start_date && end_date
      where("repeat = false AND TO_CHAR(date, 'YYYYMMDD') >= ? AND TO_CHAR(date, 'YYYYMMDD') <= ?", start_date.strftime('%Y%m%d'), end_date.strftime('%Y%m%d'))
        .or(where("repeat = true AND TO_CHAR(date, 'MMDD') >= ? AND TO_CHAR(date, 'MMDD') <= ?", start_date.strftime('%m%d'), end_date.strftime('%m%d')))
    elsif start_date
      where("repeat = false AND TO_CHAR(date, 'YYYYMMDD') >= ?", start_date.strftime('%Y%m%d'))
        .or(where("repeat = true AND TO_CHAR(date, 'MMDD') >= ?", start_date.strftime('%m%d')))
    elsif end_date
      where("repeat = false AND TO_CHAR(date, 'YYYYMMDD') <= ?", end_date.strftime('%Y%m%d'))
        .or(where("repeat = true AND TO_CHAR(date, 'MMDD') <= ?", end_date.strftime('%m%d')))
    else
      all
    end
  }

  def started_on=(year)
    @started_on = Date.new(year, self.date.month, self.date.day) if self.date.present?
  end

  def started_on
    @started_on
  end

  def ended_on
    self.started_on
  end

  def public_holidays
    content.public_holidays.where(kind: 'holiday').scheduled_on(started_on)
  end

  private

  def set_defaults
    # event attributes
    self.categories ||= []
    self.files ||= []
    self.image_files ||= []
  end
end
