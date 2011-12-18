class CreateOwnerships < ActiveRecord::Migration
  def self.up
    create_table :ownerships, :id => false do |t|
      t.integer :owner_id
      t.integer :game_id
    end
  end

  def self.down
    drop_table :ownerships
  end
end
