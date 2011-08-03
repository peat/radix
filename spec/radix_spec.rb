RADIX_ROOT = File.join( File.dirname(__FILE__), '..' )

require File.join( RADIX_ROOT, 'lib', 'radix.rb' )

describe Radix do
  
  describe "Radix#validate_xml" do
    
    before(:all) do
      @manifest_schema_path = File.join( RADIX_ROOT, 'schema', 'manifest.xsd' ) 
    end
    
    it "should validate the XML for a given file by enforcing the indicated XSL" do
      good_manifest = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'valid.xml' )        
      Radix.valid_xml?( good_manifest, @manifest_schema_path ).should be_true

      bad_manifest = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'invalid.xml' )        
      Radix.valid_xml?( bad_manifest, @manifest_schema_path ).should be_false
    end
    
    it "should provide errors for XML for a given file if it does not match the standard" do
      bad_manifest = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'invalid.xml' )        
      Radix.xml_errors( bad_manifest, @manifest_schema_path ).length.should eq(2)
    end 
    
    
  end
  
end