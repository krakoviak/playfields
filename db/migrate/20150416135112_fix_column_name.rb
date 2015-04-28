class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :envs, :title, :name
  end
end
