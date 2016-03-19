class AddScoreIndexToInference < ActiveRecord::Migration
  def change
    add_index :inferences, :score
  end
end
