class GpCalendar::Public::Node::EventsController < GpCalendar::Public::Node::BaseController
  skip_after_action :render_public_layout, only: [:file_content]

  def index
    start_date, end_date = if @year_only
                             boy = @date.beginning_of_year
                             boy = @min_date if @min_date > boy
                             eoy = @date.end_of_year
                             eoy = @max_date if @max_date < eoy
                             [boy, eoy]
                           else
                             [@date.beginning_of_month, @date.end_of_month]
                           end

    events = @content.public_events.scheduled_between(start_date, end_date)
    events = events.categorized_into(@specified_category.public_descendants_ids) if @specified_category
    events = events.order(:started_on).preload(:categories)

    docs = @content.event_docs.event_scheduled_between(start_date, end_date)
    docs = docs.categorized_into(@specified_category.public_descendants_ids, categorized_as: 'GpCalendar::Event') if @specified_category
    docs = GpArticle::DocsPreloader.new(docs).preload(:public_node_ancestors, :event_categories, :files)

    holidays = @content.public_holidays.where(kind: 'event').scheduled_between(start_date, end_date)
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
