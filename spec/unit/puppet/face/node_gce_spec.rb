require 'spec_helper'

describe Puppet::Face[:node_gce, :current] do
  it 'supports calling create' do
    lambda { subject.create }.should_not raise_error
  end


end