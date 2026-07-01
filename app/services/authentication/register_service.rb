module Authentication
  class RegisterService
    def initialize(params)
      @params = params
    end

    def call
      user = User.new(@params)
      
      # Use a transaction to ensure both user and default project are created together
      ActiveRecord::Base.transaction do
        if user.save
          # Provision a default project for a seamless onboarding experience
          user.projects.create!(
            name: "Default Project", 
            description: "This is your default project. Feel free to rename it or create new ones!"
          )
          ServiceResult.new(success: true, data: user)
        else
          ServiceResult.new(success: false, errors: user.errors.full_messages)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.new(success: false, errors: e.record.errors.full_messages)
    rescue => e
      ServiceResult.new(success: false, errors: [e.message])
    end
  end
end
