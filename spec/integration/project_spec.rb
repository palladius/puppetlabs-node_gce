require 'spec_helper'

describe 'when retrieving project data' do
  let :face do
    Puppet::Face[:node_gce, :current]
  end

  let :options do
    {
      :project => 'ogtastic.com:rick-hello-world'
    }
  end

  let :credentials do
    {
      :client_id     => '1462647242-kfksu80t99hepn4jbtjrul5f0kb4ja16.apps.googleusercontent.com',
      :client_secret => 'dJFz1EidloS4i6UGLt8mzYbs',
      :refresh_token => '1/vvCW0aPjecDx__bjcEsm2aRJH_QV_oH9COXFlAzfQIs',
    }
  end

  before do
    @handle = Puppet::GoogleCompute.new
    Puppet::GoogleCompute.stubs(:new).returns(@handle)
    @handle.stubs(:fetch_credentials).returns(credentials)
  end

  # it 'fails when there is no project name' do
  #   options.delete(:project)
  #   lambda { face.project(options) }.should raise_error
  # end
  #
  # it 'fails when there is no credentials data' do
  #   @handle.stubs(:fetch_credentials).returns({})
  #   lambda { face.project(options) }.should raise_error
  # end
  #
  # it 'fails when the credentials data does not include a client id' do
  #   credentials.delete(:client_id)
  #   lambda { face.project(options) }.should raise_error
  # end
  #
  # it 'fails when the credentials data does not include a client secret' do
  #   credentials.delete(:client_secret)
  #   lambda { face.project(options) }.should raise_error
  # end
  #
  # it 'fails when the credentials data does not include a refresh token' do
  #   credentials.delete(:refresh_token)
  #   lambda { face.project(options) }.should raise_error
  # end
  #
  # it 'fails when the credentials provided are invalid' do
  #   credentials[:client_id] = '1462647242-bad-id.apps.googleusercontent.com'
  #   lambda { face.project(options) }.should raise_error
  # end

  it 'returns the project data from the Google Compute API' do
    face.project(options).should == '{}'
  end
end