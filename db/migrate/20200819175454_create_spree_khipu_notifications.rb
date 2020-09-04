class CreateSpreeKhipuNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_khipu_notifications do |t|
      t.integer :payment_id
      t.integer :order_id
      t.timestamps
    end
  end
end
