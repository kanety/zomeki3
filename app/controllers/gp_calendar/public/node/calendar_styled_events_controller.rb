class GpCalendar::Public::Node::CalendarStyledEventsController < GpCalendar::Public::Node::BaseController
  def index
    start_date = @date.beginning_of_month.beginning_of_week(:sunday)
    end_date = @date.end_of_month.end_of_week(:sunday)

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@specified_category.public_descendants_ids) if @specified_category
    events = events.order(:started_on).preload(:categories).to_a

    docs = @content.event_docs.event_scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@specified_category.public_descendants_ids, categorized_as: 'GpCalendar::Event') if @specified_category
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)

    @events = sort_events(events + docs_to_events(@content, docs))

    @holidays = @content.public_holidays.scheduled_between(start_date, end_date)

    @weeks = (start_date..end_date).inject([]) do |weeks, day|
        weeks.push([]) if weeks.empty? || day.wday.zero?
        weeks.last.push(day)
        next weeks
      end
  end
end
