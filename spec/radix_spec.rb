RADIX_ROOT = File.join( File.dirname(__FILE__), '..' )

require File.join( RADIX_ROOT, 'lib', 'radix.rb' )

describe Radix do

  before(:all) do
    @manifest_schema_path = File.join( RADIX_ROOT, 'schema', 'manifest.xsd' )
    @bad_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'invalid.xml' )
    @good_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'valid.xml' )
  end
  
  describe "Radix#xml_errors?" do
        
    it "should validate the XML for a given file by enforcing the indicated XSL" do
      Radix.valid_xml?( @good_manifest_path, @manifest_schema_path ).should be_true
      Radix.valid_xml?( @bad_manifest_path, @manifest_schema_path ).should be_false
    end

  end
  
  describe "Radix#xml_errors" do
    
    it "should provide errors for XML for a given file if it does not match the standard" do
      Radix.xml_errors( @good_manifest_path, @manifest_schema_path ).length.should eq(0)
      Radix.xml_errors( @bad_manifest_path, @manifest_schema_path ).length.should eq(2)
    end 
    
  end
  
end