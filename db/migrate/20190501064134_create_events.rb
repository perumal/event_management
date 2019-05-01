class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.datetime :starttime
      t.datetime :endtime
      t.text :description
      t.boolean :allday
      t.boolean :completed
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
