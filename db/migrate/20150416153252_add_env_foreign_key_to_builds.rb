class AddEnvForeignKeyToBuilds < ActiveRecord::Migration
  def change
    add_foreign_key :builds, :envs
  end
end
