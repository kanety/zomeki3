class GpCalendar::Public::NodeController < Cms::Controller::Public::Base
  include GpArticle::Controller::Public::Scoping

  private

  def docs_to_events(content, docs)
    docs.map { |doc| GpCalendar::Event.from_doc(doc, content) }
  end

  def sort_events(events)
    events.sort_by { |e| e.started_on || Time.new(0) }
  end
end
