class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.text :body
      t.inet :from_ip

      t.timestamps null: false
    end
  end
end
