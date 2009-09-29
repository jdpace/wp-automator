class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string        :name
      t.string        :url
      
      t.string        :domain
      t.string        :alias
      
      t.string        :token
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
