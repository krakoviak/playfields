class CreateEnvs < ActiveRecord::Migration
  def change
    create_table :envs do |t|
      t.string :title
      t.string :description

      t.timestamps null: false
    end
  end
end
