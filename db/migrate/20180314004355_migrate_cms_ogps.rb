class MigrateCmsOgps < ActiveRecord::Migration[5.0]
  def up
    execute %Q|insert into cms_ogps (taggable_id, taggable_type, og_type, title, description, image, created_at, updated_at)
      select id, 'Cms::Site', og_type, og_title, og_description, og_image, created_at, updated_at from cms_sites;|
    execute %Q|insert into cms_ogps (taggable_id, taggable_type, og_type, title, description, image, created_at, updated_at)
      select id, 'GpArticle::Doc', og_type, og_title, og_description, og_image, created_at, updated_at from gp_article_docs;|
  end

  def down
  end
end
