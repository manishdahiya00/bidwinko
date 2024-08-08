class CreateTransactionHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :transaction_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :payment_id
      t.string :title
      t.string :receipt
      t.string :order_id
      t.string :amount
      t.string :number_of_bids

      t.timestamps
    end
  end
end
