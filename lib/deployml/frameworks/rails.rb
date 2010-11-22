module DeploYML
  module Frameworks
    module Rails
      def rake(task,*args)
        args += ["RAILS_ENV=#{@environment}"]

        super(task,*args)
      end
    end
  end
end
