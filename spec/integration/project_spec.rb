require 'spec_helper'

describe 'when retrieving project data' do
  before do
    @handle = Puppet::GoogleCompute.new
    Puppet::GoogleCompute.stubs(:new).returns(@handle)
  end

  let :face do
    Puppet::Face[:node_gce, :current]
  end

  let :options do
    {
      :project => 'megaproject'
    }
  end

  let :credentials do
    {
      :client_id => 'puppet labs',
      :client_secret => 's3kr1t',
      :verification_code => 'mynameiswernervogelmyvoiceismypasswordauthorizeme'
    }
  end

  let :refresh_credentials do
    {
      :client_id => 'puppet labs',
      :client_secret => 's3kr1t',
      :refresh_token => 'comeatmebr0',
      :expires_at => '8675309'
    }
  end

  it 'fails when there is no project name' do
    options.delete(:project)
    lambda { face.project(options) }.should raise_error
  end

  it 'fails when there is no credentials data' do
    @handle.stubs(:fetch_credentials).returns({})
    lambda { face.project(options) }.should raise_error
  end

  it 'fails when the credentials data does not include a client id' do
    credentials.delete(:client_id)
    @handle.stubs(:fetch_credentials).returns(credentials)
    lambda { face.project(options) }.should raise_error
  end

  it 'fails when the credentials data does not include a client secret' do
    credentials.delete(:client_secret)
    @handle.stubs(:fetch_credentials).returns(credentials)
    lambda { face.project(options) }.should raise_error
  end

  describe 'and the credentials data includes a refresh_token' do
    it 'fails when the credentials data does not include an expiration time' do
      refresh_credentials.delete(:expires_at)
      @handle.stubs(:fetch_credentials).returns(refresh_credentials)
      lambda { face.project(options) }.should raise_error
    end
  end

  describe 'and the credentials data does not include a refresh token' do
    it 'fails when the credentials data does not include a verification code' do
      credentials.delete(:verification_code)
      @handle.stubs(:fetch_credentials).returns(credentials)
      lambda { face.project(options) }.should raise_error
    end
  end

  it 'fails when the credentials provided are invalid'

  it 'returns the project data from the Google Compute API'
end