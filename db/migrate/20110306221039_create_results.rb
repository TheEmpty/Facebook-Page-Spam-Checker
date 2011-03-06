class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.text :data
      t.timestamps
    end
	execute "ALTER TABLE results ADD page_id LONG"
  end

  def self.down
    drop_table :results
  end
end
