require 'spec_helper'

describe VaingloryAPI do
  subject(:klass) { Object.const_get(self.class.top_level_description) }

  it 'allows instantiation of a Client' do
    client = klass.new('API_KEY')
    expect(client).to be_an_instance_of(klass::Client)
  end
end
