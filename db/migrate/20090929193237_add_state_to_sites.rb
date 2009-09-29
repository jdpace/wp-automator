class AddStateToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :state, :string, :default => 'pending'
  end

  def self.down
    remove_column :sites, :state
  end
end
