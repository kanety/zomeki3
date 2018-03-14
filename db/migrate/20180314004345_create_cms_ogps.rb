class CreateCmsOgps < ActiveRecord::Migration[5.0]
  def change
    create_table :cms_ogps do |t|
      t.references :taggable, polymorphic: true, index: true
      t.string     :og_type
      t.string     :title
      t.text       :description
      t.string     :image
      t.timestamps
    end
  end
end
