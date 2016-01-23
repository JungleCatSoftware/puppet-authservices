require 'spec_helper'
describe 'authservices' do

  context 'with defaults for all parameters' do
    it { should contain_class('authservices') }
  end
end
