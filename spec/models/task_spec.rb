require "rails_helper"

RSpec.describe Task, type: :model do
  describe "associations" do
    it { should belong_to(:project) }

    it do
      should belong_to(:assigned_user)
          .class_name("User")
          .optional
    end
  end

  describe "validations" do
    subject(:task) { build(:task) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }

    it do
      should validate_inclusion_of(:status)
          .in_array(Task.statuses.keys)
    end

    it do
      should validate_inclusion_of(:priority)
          .in_array(Task.priorities.keys)
    end
  end

  describe "enums" do
    it "defines status enum correctly" do
      expect(Task.statuses).to eq(
        "pending" => "pending",
        "in_progress" => "in_progress",
        "completed" => "completed",
      )
    end

    it "defines priority enum correctly" do
      expect(Task.priorities).to eq(
        "low" => "low",
        "medium" => "medium",
        "high" => "high",
      )
    end

    it "defaults status to pending" do
      task = described_class.new

      expect(task.status).to eq("pending")
      expect(task).to be_pending
    end

    it "defaults priority to medium" do
      task = described_class.new

      expect(task.priority).to eq("medium")
      expect(task).to be_medium
    end
  end

  describe "callbacks" do
    context "when status changes to completed" do
      it "sets completed_at" do
        task = create(:task)

        expect(task.completed_at).to be_nil

        task.update!(status: :completed)

        expect(task.completed_at).not_to be_nil
      end

      it "does not overwrite completed_at if already present" do
        completed_time = 2.days.ago

        task = create(
          :task,
          status: :completed,
          completed_at: completed_time,
        )

        task.save!

        expect(task.completed_at.to_i).to eq(completed_time.to_i)
      end
    end

    context "when status changes from completed to another status" do
      it "clears completed_at" do
        task = create(:task)

        task.update!(status: :completed)

        expect(task.completed_at).not_to be_nil

        task.update!(status: :pending)

        expect(task.completed_at).to be_nil
      end
    end

    context "when status does not change" do
      it "does not modify completed_at" do
        task = create(:task)

        expect(task).not_to receive(:manage_completed_at)

        task.update!(title: "Updated title")
      end
    end
  end
end
