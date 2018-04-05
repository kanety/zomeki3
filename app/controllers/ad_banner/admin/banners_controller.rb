class AdBanner::Admin::BannersController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base
  include Sys::Controller::Scaffold::Publication

  def pre_dispatch
    @content = AdBanner::Content::Banner.find(params[:content])
    return error_auth unless Core.user.has_priv?(:read, item: @content.concept)
  end

  def index
    items = @content.banners.except(:order).order(sort_no: :asc, created_at: :desc)
    items = items.where(state: params[:target]) if params[:target].present?
    @items = items.paginate(page: params[:page], per_page: params[:limit])

    _index @items
  end

  def show
    @item = @content.banners.find(params[:id])
    _show @item
  end

  def new
    @item = @content.banners.build(site_id: Core.site.id)
  end

  def create
    @item = @content.banners.build(banner_params)
    @item.site_id = Core.site.id
    @item.state = params.keys.detect { |k| k =~ /^commit_/ }.to_s.sub(/^commit_/, '')
    _create @item do
      @item.enqueue_tasks if @item.state == 'draft'
      publish_or_close_images
    end
  end

  def update
    @item = @content.banners.find(params[:id])
    @item.attributes = banner_params
    @item.state = params.keys.detect { |k| k =~ /^commit_/ }.to_s.sub(/^commit_/, '')
    @item.skip_upload if @item.file.blank? && ::File.exist?(@item.upload_path)
    _update @item do
      @item.enqueue_tasks if @item.state == 'draft'
      publish_or_close_images
    end
  end

  def destroy
    @item = @content.banners.find(params[:id])
    _destroy @item do
      @item.close_images if @item.state == 'public'
    end
  end

  def file_content
    item = @content.banners.find(params[:id])
    send_file item.upload_path, filename: item.name
  end

  private

  def publish_or_close_images
    if @item.state == 'public'
      @item.publish_images
    else
      @item.close_images
    end
  end

  def banner_params
    params.require(:item).permit(
      :advertiser_contact, :advertiser_email, :advertiser_name, :advertiser_phone,
      :file, :group_id, :name, :sort_no, :state, :title, :alt_text, :url, :sp_url, :target,
      :creator_attributes => [:id, :group_id, :user_id],
      :tasks_attributes => [:id, :name, :process_at]
    )
  end
end
