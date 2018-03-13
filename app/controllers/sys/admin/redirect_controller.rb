class Sys::Admin::RedirectController < Cms::Controller::Admin::Base
  def pre_dispatch
    model = params[:model].constantize
    return redirect_to admin_root_path unless model

    @item = model.find_by(id: params[:id])
    return redirect_to admin_root_path unless @item
  end

  def index
    options = recognize_path_options

    if @item.respond_to?(:site) && @item.site && @item.site.admin_full_uri.present?
      options.merge!(host: @item.site.admin_full_uri.chomp('/'), only_path: false)
    end

    url = begin
            url_for(options)
          rescue ActionController::UrlGenerationError => e
            admin_root_path
          end
    redirect_to url
  end

  private

  def recognize_path_options
    controller = recognize_controller
    action = 'show'

    { controller: controller,
      action: action,
      id: @item.id }.merge(recognize_spec_options(controller, action))
  end

  def recognize_controller
    case @item
    when Cms::Piece
      @item.model.underscore.pluralize.sub('/', '/admin/piece/')
    when Cms::Node
      @item.model.underscore.pluralize.sub('/', '/admin/node/')
    else
      @item.class.name.underscore.pluralize.sub('/', '/admin/')
    end
  end

  def recognize_spec_options(controller, action)
    spec = find_path_spec_from_controller_action(controller, action)
    return {} unless spec

    spec.scan(/:(\w+)/).flatten.each_with_object({}) do |part, options|
      case part
      when 'concept'
        if (concept = recognize_concept)
          Core.set_concept(concept)
          options[:concept] = concept
        end
      else
        options[part] = recognize_others(part)
      end
    end
  end

  def recognize_concept
    if @item.class.name !~ /^(Cms|Sys)::/
      @item.content.concept
    else
      if @item.respond_to?(:concept) && @item.concept
        @item.concept
      else
        nil
      end
    end
  end

  def recognize_others(part)
    if @item.respond_to?(part)
      @item.public_send(part)
    else
      nil
    end
  end

  def find_path_spec_from_controller_action(controller, action)
    Rails.application.routes.routes.each do |route|
      if route.requirements[:controller] == controller && route.requirements[:action] == action
        return route.path.spec.to_s
      end 
    end
    nil
  end
end
