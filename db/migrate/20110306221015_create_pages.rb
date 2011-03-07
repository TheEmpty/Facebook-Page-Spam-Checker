class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      #t.int :page_id
      t.timestamps
    end
	execute "ALTER TABLE pages ADD page_id BIGINT"
  end

  def self.down
    drop_table :pages
  end
end
