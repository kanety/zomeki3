class GpCalendar::EventsFinder < ApplicationFinder
  def initialize(events)
    @events = events
  end

  def search(criteria)
    criteria ||= {}

    [:state].each do |key|
      @events = @events.where(key => criteria[key]) if criteria[key].present?
    end

    @events = @events.search_with_text(:title, criteria[:title]) if criteria[:title].present?

    if criteria[:date].present?
      date = Date.parse(criteria[:date]) rescue nil
      @events = @events.scheduled_on(date) if date
    end

    if criteria[:sort_key].present?
      @events = @events.order(criteria[:sort_key] => criteria[:sort_order].presence || :asc)
    end

    @events
  end
end
