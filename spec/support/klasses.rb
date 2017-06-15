module KlassExampleGroup
  def self.included(base)
    base.instance_eval do
      # Make the class available as `subject` in your examples:
      subject { Object.const_get(self.class.top_level_description) }
    end
  end
end


RSpec.configure do |config|
  # Tag service specs with `:service` metadata or put them in the spec/services dir
  config.define_derived_metadata(:file_path => %r{/spec/lib/}) do |metadata|
    metadata[:type] = :klass
  end

  config.include KlassExampleGroup, type: :klass
end
