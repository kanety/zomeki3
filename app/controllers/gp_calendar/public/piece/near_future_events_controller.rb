class GpCalendar::Public::Piece::NearFutureEventsController < GpCalendar::Public::PieceController
  def pre_dispatch
    @piece = GpCalendar::Piece::NearFutureEvent.find(Page.current_piece.id)
    @content = @piece.content
    @item = Page.current_item
  end

  def index
    @today = Date.today
    @tomorrow = Date.tomorrow

    events = @content.events.public_state.scheduled_between(@today, @tomorrow)
    todays_events = events.select { |ev| ev.started_on <= @today && @today <= ev.ended_on }
    tomorrows_events = events.select { |ev| ev.started_on <= @tomorrow && @tomorrow <= ev.ended_on }

    docs = @content.event_docs
    today_docs = docs.event_scheduled_between(@today, @today)
    tomorrow_docs = docs.event_scheduled_between(@tomorrow, @tomorrow)

    @todays_events = sort_events(todays_events + docs_to_events(@content, today_docs))
    @tomorrows_events = sort_events(tomorrows_events + docs_to_events(@content, tomorrow_docs))
  end
end
