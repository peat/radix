RADIX_ROOT = File.join( File.dirname(__FILE__), '..' )

require File.join( RADIX_ROOT, 'lib', 'radix.rb' )

describe Radix do
  
  describe "Radix#validate_xml" do
    
    it "should validate the XML for a given file by enforcing the indicated XSL" do
      manifest_valid_path = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'valid.xml' )
      manifest_schema_path = File.join( RADIX_ROOT, 'schema', 'manifest.xsd' )
      
      Radix.valid_xml?( manifest_valid_path, manifest_schema_path ).should be_true
    end
    
    it "should throw an exception if the XML for a given file does not match the standard"    
  end
  
end