class AddNumberToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :number, :integer
  end
end
