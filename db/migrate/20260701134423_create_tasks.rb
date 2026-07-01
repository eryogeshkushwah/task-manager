class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'pending'
      t.string :priority, null: false, default: 'medium'
      t.date :due_date
      t.datetime :completed_at
      t.references :project, null: false, foreign_key: true
      t.references :assigned_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :priority
    add_index :tasks, :due_date
  end
end
