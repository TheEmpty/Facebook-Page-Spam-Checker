class AddVersionToResults < ActiveRecord::Migration
  def self.up
    add_column :results, :version, :float
  end

  def self.down
    remove_column :results, :version
  end
end
