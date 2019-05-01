class CreateEventUsers < ActiveRecord::Migration
  def change
    create_table :event_responses do |t|
      t.integer :event_id
      t.integer :user_id
      t.string :rsvp

      t.timestamps
    end
  end
end
