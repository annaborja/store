class CreateGatewayCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :gateway_customers do |t|
      t.integer :user_id, null: false
      t.string :gateway, null: false
      t.string :customer_id, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :gateway_customers, %i[user_id gateway deleted_at]
    add_index :gateway_customers, %i[gateway customer_id], unique: true
  end
end
