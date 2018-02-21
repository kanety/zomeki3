module Map::MarkerHelper
  def marker_image(marker)
    if (doc = marker.doc) && doc.content.public_node
      GpArticle::DocHelper::Formatter.new(doc).format("@image_tag@")
    elsif (file = marker.files.first) && file.file_attachable.content.public_node
      image_tag("#{file.file_attachable.content.public_node.public_uri}#{file.file_attachable.name}/file_contents/#{url_encode file.name}")
    end
  end
end
