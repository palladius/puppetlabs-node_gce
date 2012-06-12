require 'spec_helper'

describe Puppet::Face[:node_gce, :current] do
  it 'supports creating an instance' do
    lambda { subject.create }.should_not raise_error
  end

  it 'supports retrieving project data' do
    lambda { subject.project }.should_not raise_error
  end
end