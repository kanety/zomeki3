class AdBanner::BannersScript < PublicationScript
  def publish
    banners = @node.content.banners
    banners.each do |banner|
      ::Script.progress(banner) do
        if banner.state == 'public'
          banner.publish_images
        else
          banner.close_images
        end
      end
    end
  end

  def publish_by_task(item)
    if item.state == 'draft'
      ::Script.current

      if item.publish
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'publish')
      else
        raise "#{item.class}##{item.id}: failed to publish"
      end

      ::Script.success
      return true
    elsif item.state == 'public'
      return true
    end
  end

  def close_by_task(item)
    if item.state == 'public'
      ::Script.current

      if item.close
        Sys::OperationLog.script_log(item: item, site: item.content.site, action: 'close')
      end

      ::Script.success
      return true
    elsif item.state == 'closed'
      return true
    end
  end
end
