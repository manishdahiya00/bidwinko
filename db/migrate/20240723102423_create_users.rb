class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :device_id
      t.string :device_type
      t.string :device_name
      t.string :advertising_id
      t.string :social_name
      t.string :social_type
      t.string :social_id
      t.string :social_email
      t.string :social_img_url
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_content
      t.string :utm_term
      t.string :version_name
      t.string :version_code
      t.string :source_ip
      t.string :utm_campaign
      t.string :referrer_url
      t.string :security_token
      t.string :refer_code
      t.string :total_bids
      t.string :mobile_number
      t.string :address
      t.datetime :last_check_in

      t.timestamps
    end
  end
end
