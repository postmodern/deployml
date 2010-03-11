require 'yaml'

module Helpers
  module Projects
    PROJECTS_DIR = File.join(File.dirname(__FILE__),'projects')

    def project_dir(name)
      File.join(PROJECTS_DIR,name.to_s)
    end
  end
end
