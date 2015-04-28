class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.text :parameters
      t.text :causes
      t.integer :duration
      t.string :result
      t.datetime :timestamp
      t.string :url
      t.references :env, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
