require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../../lib/generators/formageddon/install/install_generator'

describe "Formageddon Initializer Generator" do
  before(:all) do
    FileUtils.mkdir_p(fake_rails_root)
    @original_files = file_list
  end
  
  after(:all) do
    FileUtils.rm_r(fake_rails_root)
  end
    
  it "should generate an initializer file" do 
    Formageddon::InstallGenerator.start
    new_file = (file_list - @original_files).first
    File.basename(new_file).should match /formageddon/
  end
end


def fake_rails_root
  File.join(File.dirname(__FILE__), 'fake_rails_root')
end

def file_list
  Dir.glob(File.join(fake_rails_root, "config", "initializers", "*"))
end
