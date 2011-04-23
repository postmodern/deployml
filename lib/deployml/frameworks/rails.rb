module DeploYML
  module Frameworks
    #
    # Provides common methods needed to deploy Rails 2 and 3 projects.
    #
    module Rails
      #
      # Overrides the default `rake` method to add a `RAILS_ENV`
      # environment variable.
      #
      # @see {Environment#rake}
      #
      def rake(task,*arguments)
        arguments += ["RAILS_ENV=#{@environment}"]

        super(task,*arguments)
      end
    end
  end
end
