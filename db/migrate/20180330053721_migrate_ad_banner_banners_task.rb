class MigrateAdBannerBannersTask < ActiveRecord::Migration[5.0]
  def change
    now = Time.now
    AdBanner::Banner.find_each do |banner|
      if banner.published_at
        if banner.published_at < now
          banner.tasks.create(site_id: banner.site.id, name: 'publish', process_at: banner.published_at, state: 'performed')
        else
          banner.tasks.create(site_id: banner.site.id, name: 'publish', process_at: banner.published_at, state: 'queued')
          banner.update_columns(state: 'draft') if banner.state == 'public'
        end
      end
      if banner.closed_at
        if banner.closed_at < now
          banner.tasks.create(site_id: banner.site.id, name: 'close', process_at: banner.closed_at, state: 'performed')
          banner.update_columns(state: 'closed') if banner.state == 'public'
        else
          banner.tasks.create(site_id: banner.site.id, name: 'close', process_at: banner.closed_at, state: 'queued')
        end
      end
      banner.enqueue_tasks
    end
  end
end
