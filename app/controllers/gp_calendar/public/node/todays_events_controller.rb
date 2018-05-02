class GpCalendar::Public::Node::TodaysEventsController < GpCalendar::Public::Node::BaseController
  def index
    events = @content.public_events.scheduled_on(@today)
    docs = @content.event_docs.event_scheduled_on(@today)

    @events = sort_events(events + docs_to_events(@content, docs))

    @holidays = @content.public_holidays.where(kind: 'holiday').scheduled_on(@today)
  end
end
