class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops  do |t|
      t.string :spiffy_stores_domain, null: false, limit: 255
      t.string :spiffy_stores_token, null: false, limit: 255
      t.timestamps null: false
    end

    add_index :shops, :spiffy_stores_domain, unique: true
  end
end
