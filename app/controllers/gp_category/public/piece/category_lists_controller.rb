class GpCategory::Public::Piece::CategoryListsController < Sys::Controller::Public::Base
  include GpArticle::Controller::Public::Scoping

  def pre_dispatch
    @piece = GpCategory::Piece::CategoryList.find_by(id: Page.current_piece.id)
    render plain: '' unless @piece

    @item = Page.current_item
  end

  def index
    if @piece.setting_state == 'enabled'
      index_at_specified_category
    else
      index_at_current_category
    end
  end

  def index_at_specified_category
    if @piece.category_type_id && @piece.category_id
      @category = @piece.category_type.categories.find_by(id: @piece.category_id)
      return render plain: '' unless @category
      if @piece.base_level == 'self'
        if @category.root?
          @category_type = @category.category_type
          render :category_type
        else
          @category = @category.parent
          render :category
        end
      else
        render :category
      end
    elsif @piece.category_type_id
      @category_type = @piece.category_type
      return render plain: '' unless @category_type
      render :category_type
    else
      @category_types = @piece.public_category_types
    end
  end

  def index_at_current_category
    case @item
    when GpCategory::CategoryType
      @category_type = @item
      render :category_type
    when GpCategory::Category
      if @piece.base_level == 'self'
        if @item.root?
          @category_type = @item.category_type
          render :category_type
        else
          @category = @item.parent
          render :category
        end
      else
        @category = @item
        render :category
      end
    else
      @category_types = @piece.public_category_types
    end
  end
end
