class AddComponentToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :component, :string
  end
end
