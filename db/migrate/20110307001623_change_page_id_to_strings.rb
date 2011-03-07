class ChangePageIdToStrings < ActiveRecord::Migration
  def self.up
    # we use string because facebook ids can get long and this seems to be the only data type that can support all popular SQL engines and hold the facebook ID
    change_column :pages, :page_id, :string
  end

  def self.down
    remove_column :pages, :page_id	
	execute "ALTER TABLE pages ADD page_id BIGINT"
  end
end
