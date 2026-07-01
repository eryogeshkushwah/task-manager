module Authentication
  class LoginService
    def initialize(email:, password:, user_agent: nil, ip_address: nil)
      @email = email
      @password = password
      @user_agent = user_agent
      @ip_address = ip_address
    end

    def call
      user = User.find_by("LOWER(email) = ?", @email.to_s.strip.downcase)

      if user&.authenticate(@password)
        session = user.sessions.create!(
          user_agent: @user_agent,
          ip_address: @ip_address
        )
        ServiceResult.new(success: true, data: { user: user, session: session })
      else
        ServiceResult.new(success: false, errors: ["Invalid email or password"])
      end
    rescue => e
      ServiceResult.new(success: false, errors: [e.message])
    end
  end
end
