class CreateShops < ActiveRecord::Migration
  def self.up
    create_table :shops  do |t|
      t.string :spiffy_stores_domain, null: false
      t.string :spiffy_stores_token, null: false
      t.timestamps
    end

    add_index :shops, :spiffy_stores_domain, unique: true
  end

  def self.down
    drop_table :shops
  end
end
