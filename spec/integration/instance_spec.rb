require 'spec_helper'
require 'yaml'

describe 'instances' do
  let :face do
    Puppet::Face[:node_gce, :current]
  end

  let :options do
    YAML.load(File.read(fixture_path('project.yml')))
  end

  let :credentials do
    YAML.load(File.read(fixture_path('credentials.yml')))[:gce]
  end

  before do
    @handle = Puppet::GoogleCompute.new(options[:project])
    Puppet::GoogleCompute.stubs(:new).returns(@handle)
    @handle.stubs(:fetch_credentials).returns(credentials)
    options.merge!({})
  end

  describe 'when creating an instance' do
    let :options do
      YAML.load(File.read(fixture_path('project.yml'))).merge(:name => 'testnode')
    end

    before do
      @needs_instance_cleanup = false
    end

    after do
      tear_down_instances if @needs_instance_cleanup
    end

    it 'fails when there is no credentials data' do
      @handle.stubs(:fetch_credentials).returns({})
      lambda { face.create(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client id' do
      credentials.delete(:client_id)
      lambda { face.create(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client secret' do
      credentials.delete(:client_secret)
      lambda { face.create(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a refresh token' do
      credentials.delete(:refresh_token)
      lambda { face.create(options) }.should raise_error
    end

    it 'fails when the credentials provided are invalid' do
      credentials[:client_id] = '1462647242-bad-id.apps.googleusercontent.com'
      lambda { face.create(options) }.should raise_error
    end

    it 'fails when the operation would cause a failure on the Google Compute API remote end' do
      # for example, creating a duplicate instance
      face.create(options)
      flag_for_instance_cleanup!
      lambda { face.create(options) }.should raise_error
    end

    it 'returns instance data from the Google Compute API' do
      json_result = face.create(options)
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)  # yeah, I know.  "PSON" was not my decision.
      result.keys.sort.should == ["description", "disks", "id", "image", "kind", "machineType", "name", "networkInterfaces", "selfLink", "status", "zone"]
    end

    it 'creates an instance with the specified name' do
      json_result = face.create(options)
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)
      result['name'].split('/').last.should == options[:name]
    end

    it 'creates an instance with the specified machine type when a machine type is provided' do
      json_result = face.create(options.merge(:machine_type => 'standard-2-cpu'))
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)
      result['machineType'].split('/').last.should == 'standard-2-cpu'
    end

    it 'creates an instance with a standard-1-cpu-ephemeral-disk machine type when no machine type is provided' do
      json_result = face.create(options)
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)
      result['machineType'].split('/').last.should == 'standard-1-cpu-ephemeral-disk'
    end

    it 'creates an instance with the specified zone when a zone is provided' do
      json_result = face.create(options.merge(:zone => 'us-east-b'))
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)
      result['zone'].split('/').last.should == 'us-east-b'
    end

    it 'creates an instance in the us-east-a zone when no zone is provided' do
      json_result = face.create(options)
      flag_for_instance_cleanup!
      result = PSON.parse(json_result)
      result['zone'].split('/').last.should == 'us-east-a'
    end
  end

  describe 'when terminating an instance' do
    let :options do
      YAML.load(File.read(fixture_path('project.yml'))).merge(:name => 'testnode')
    end

    it 'fails when there is no credentials data' do
      @handle.stubs(:fetch_credentials).returns({})
      lambda { face.terminate(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client id' do
      credentials.delete(:client_id)
      lambda { face.terminate(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client secret' do
      credentials.delete(:client_secret)
      lambda { face.terminate(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a refresh token' do
      credentials.delete(:refresh_token)
      lambda { face.terminate(options) }.should raise_error
    end

    it 'fails when the credentials provided are invalid' do
      credentials[:client_id] = '1462647242-bad-id.apps.googleusercontent.com'
      lambda { face.terminate(options) }.should raise_error
    end

    it 'fails when the operation would cause a failure on the Google Compute API remote end' do
      lambda { face.terminate(options.merge( :name => 'bogus-node' )) }.should raise_error
    end

    it 'returns termination operation status data from the Google Compute API' do
      face.create(options)
      json_result = face.terminate(options)
      result = PSON.parse(json_result)
      result.keys.sort.should == ["endTime", "id", "insertTime", "kind", "name", "operationType", "progress", "selfLink", "startTime", "status", "targetId", "targetLink", "user"]
    end

    it 'terminates the instance with the specified name' do
      face.create(options)
      json_result = face.terminate(options)
      result = PSON.parse(json_result)
      result['targetLink'].split('/').last.should == options[:name]
    end
  end

  describe 'when retrieving instance list data' do
    it 'fails when there is no credentials data' do
      @handle.stubs(:fetch_credentials).returns({})
      lambda { face.list(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client id' do
      credentials.delete(:client_id)
      lambda { face.list(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a client secret' do
      credentials.delete(:client_secret)
      lambda { face.list(options) }.should raise_error
    end

    it 'fails when the credentials data does not include a refresh token' do
      credentials.delete(:refresh_token)
      lambda { face.list(options) }.should raise_error
    end

    it 'fails when the credentials provided are invalid' do
      credentials[:client_id] = '1462647242-bad-id.apps.googleusercontent.com'
      lambda { face.list(options) }.should raise_error
    end

    it 'returns the instance list data from the Google Compute API' do
      json_result = face.list(options)
      result = PSON.parse(json_result)
      result['kind'].should == "compute\#instanceList"
    end

    it 'follows pagination links when a large number of instances are present'
  end
end