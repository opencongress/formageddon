class CreateContactableObjects < ActiveRecord::Migration
  def self.up
    create_table :contactable_objects do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :contactable_objects
  end
end
