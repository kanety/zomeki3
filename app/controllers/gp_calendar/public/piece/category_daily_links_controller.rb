class GpCalendar::Public::Piece::CategoryDailyLinksController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::CategoryDailyLink.find(Page.current_piece.id)
    @content = @piece.content
    @item = Page.current_item
  end

  def index
    date     = params[:gp_calendar_event_date]
    min_date = params[:gp_calendar_event_min_date]
    max_date = params[:gp_calendar_event_max_date]

    unless date
      date = Date.today
      min_date = 1.year.ago(date.beginning_of_month)
      max_date = 11.months.since(date.beginning_of_month)
    end

    start_date = date.beginning_of_month.beginning_of_week(:sunday)
    end_date = date.end_of_month.end_of_week(:sunday)

    @calendar = Util::Date::Calendar.new(date.year, date.month)
    @calendar.set_event_class = true

    return unless (@node = @piece.target_node)

    @calendar.day_uri   = "#{@node.public_uri}?start_date=:year-:month-:day&end_date=:year-:month-:day"

    events = @content.public_events
                     .scheduled_between(start_date, end_date)
                     .categorized_into(@piece.category_ids)
    docs = @content.event_docs
                   .event_scheduled_between(start_date, end_date)
                   .categorized_into(@piece.category_ids)

    days = docs.inject([]) do |dates, doc|
             dates | (doc.event_started_on..doc.event_ended_on).to_a
           end

    (start_date..end_date).each do |date|
      if events.detect { |e| e.started_on <= date && date <= e.ended_on }
        days << date unless days.include?(date)
      end
    end

    @calendar.day_link = days.sort!
  end
end
