class AddCountryToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :country, :string
  end
end
