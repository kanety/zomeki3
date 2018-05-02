class GpCalendar::Public::Node::SearchEventsController < GpCalendar::Public::Node::BaseController
  skip_after_action :render_public_layout, only: [:file_content]

  def index
    @start_date = Date.parse(params[:start_date]) rescue nil || Date.today
    @end_date   = Date.parse(params[:end_date]) rescue nil || nil
    if params[:all] && params[:start_date].blank? && params[:end_date].blank?
      @start_date = nil
      @end_date   = nil
    end
    @date =  @start_date.present? ? @start_date : Date.today

    category_ids = params[:categories].to_h.values.reject(&:blank?)

    events = @content.public_events.scheduled_between(@start_date, @end_date)
    events = events.categorized_into(category_ids, alls: true) if category_ids.present?
    events = events.order(:started_on).preload(:categories).to_a

    docs = @content.event_docs.event_scheduled_between(@start_date, @end_date)
    docs = docs.categorized_into(category_ids, categorized_as: 'GpCalendar::Event', alls: true) if category_ids.present?
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)

    holidays = @content.public_holidays.where(kind: 'event').scheduled_between(@start_date, @end_date)
    holidays.each do |holiday|
      holiday.started_on = holiday.repeat? ? @date.year : holiday.date.year
    end

    @events = sort_events(events + docs_to_events(@content, docs) + holidays)
  end

  def file_content
    @event = @content.events.find_by!(name: params[:name])
    file = @event.files.find_by!(name: "#{params[:basename]}.#{params[:extname]}")
    send_file file.upload_path, filename: file.name
  end
end
