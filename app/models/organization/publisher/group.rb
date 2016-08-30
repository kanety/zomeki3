class Organization::Publisher::Group < Cms::Publisher
  default_scope { where(publishable_type: 'Organization::Group') }

  class << self
    def perform_publish(publishers)
      pub_ids = publishers.map(&:id)
      publishers = self.where(id: pub_ids).preload(publishable: { content: :public_nodes })
      node_map = make_node_map(publishers)
      node_map.each do |node, pubs|
        og_param = pubs.map { |pub| "target_organization_group_id[]=#{pub.publishable_id}" }.join('&')
        ::Script.run("cms/script/nodes/publish?target_module=cms&target_node_id=#{node.id}&#{og_param}", force: true)
      end
    end

    private

    def make_node_map(publishers)
      node_map = {}
      publishers.each do |pub|
        og = pub.publishable
        if !og || !og.content || og.content.public_nodes.blank?
          pub.destroy
        else
          og.content.public_nodes.each do |node|
            node_map[node] ||= []
            node_map[node] << pub
          end
        end
      end
      node_map
    end
  end
end
