class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.text :text
      t.datetime :executed

      t.timestamps null: false
    end
  end
end
