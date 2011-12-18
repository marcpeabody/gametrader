class CreateVouchers < ActiveRecord::Migration
  def self.up
    create_table :vouchers, :id => false do |t|
      t.integer :voucher_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :vouchers
  end
end
