require 'yaml'

module Init

  def self.params

    # read items from console.yml
    read_yml = -> (key) do
      YAML::load_file( File.expand_path('../config.yml',__FILE__))[key]
    end

    { client:  read_yml[ :client_id ] ,   port:  read_yml[ read_yml[ :product ] ] }
  end
end
