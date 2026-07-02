require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validationss' do
    context 'validate title' do
      it 'title is valid' do
        task = build(:task)

        expect(task).to be_valid
      end

      it 'title is invalid' do
        task = build(:task, title: nil)

        expect(task).not_to be_valid
      end
    end
  end

  # describe '#manage_completed_at' do
  #   context 'it will manager completed_at' do
  #     it 'when task already completed' do
  #       task = Task.create(title: 'my task', status: :completed)

  #       expect(task.completed_at).to eq(task.completed_at || Time.current)
  #     end

  #     it 'when task is not completed' do
  #       task = Task.create(title: 'my task')

  #       expect(task.completed_at).to be(nil)
  #     end
  #   end
  # end
end
