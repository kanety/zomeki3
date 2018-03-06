class BizCalendar::PlacesScript < PublicationScript
  def publish
    publish_page(@node, uri: @node.public_uri,
                        path: @node.public_path,
                        smart_phone_path: @node.public_smart_phone_path)

    @node.content.places.with_state(:public).each do |place|
      publish_page(place, uri: place.public_uri,
                          path: place.public_path,
                          smart_phone_path: place.public_smart_phone_path)
    end
  end
end
