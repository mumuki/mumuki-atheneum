class AddDefaultGuideToUser < ActiveRecord::Migration
  def change
    add_column :users, :default_guide_id, :integer, index: true, uniq: true
  end
end
