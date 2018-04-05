class AdBanner::Public::Piece::BannersController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = AdBanner::Piece::Banner.find_by(id: Page.current_piece.id)
    render plain: '' if @piece.nil? || @piece.content.public_node.nil?
  end

  def index
    @banners = @piece.banners.where(state: 'public')

    @banners = if @piece.groups.present?
                 if @piece.group
                   @banners.where(group_id: @piece.group.id)
                 else
                   @banners.where(group_id: nil)
                 end
               else
                 @banners
               end

    @banners = case @piece.sort.last
               when 'ordered'
                 @banners.sort { |a, b| a.sort_no <=> b.sort_no }
               when 'random'
                 @banners.shuffle
               else
                 @banners
               end
  end
end
