module Cms::OgpHelper
  def og_tags(item, site)
    return '' unless item

    ogp = item.respond_to?(:ogp) && item.ogp || Cms::Ogp.new

    %w(type title description image).map { |key|
      column = key == 'type' ? "og_#{key}" : key 
      value = (ogp[column].presence || site.ogp && site.ogp[column]).to_s.gsub("\n", ' ')
      next if value.blank?

      case key
      when 'image'
        tag :meta, property: 'og:image', content: image_url_for_ogp(item, site, value) 
      else
        tag :meta, property: "og:#{key}", content: value
      end
    }.join.html_safe
  end

  def image_url_for_ogp(item, site, path)
    if path.start_with?('/')
      Addressable::URI.join(site.full_uri, path).to_s
    elsif item.is_a?(GpArticle::Doc) && (file = item.image_files.detect { |f| f.name == path })
      "#{item.content.public_node.public_full_uri}#{item.name}/file_contents/#{url_encode file.name}"
    else
      path
    end
  end
end
