RADIX_ROOT = File.join( File.dirname(__FILE__), '..' )

require File.join( RADIX_ROOT, 'lib', 'radix.rb' )

describe Radix do

  before(:all) do
    @manifest_schema_path = File.join( RADIX_ROOT, 'schema', 'manifest.xsd' )
    @bad_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'invalid.xml' )
    @good_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest', 'valid.xml' )
    @private_key_path = File.join( RADIX_ROOT, 'fixtures', 'keys', 'fixture.pem' )
    @public_key_path = File.join( RADIX_ROOT, 'fixtures', 'keys', 'fixture.pub' )    
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
  
  describe "Radix#signature" do
    
    it "should create a signature of an file based on a private key" do
      # simple check; real meat is in #check_signature
      Radix.signature( @good_manifest_path, @private_key_path ).should be_a(String)
    end
    
  end
  
  describe "Radix#valid_signature?" do
    
    it "should check a signature, given a file, an existing signature, and a public key" do
      signature = Radix.signature( @good_manifest_path, @private_key_path )
      Radix.valid_signature?( @good_manifest_path, @public_key_path, signature ).should be_true
      
      # pointing at a slightly altered file
      Radix.valid_signature?( @bad_manifest_path, @public_key_path, signature ).should be_false
    end
    
  end

  describe "Radix#digest" do
    it "should create a SHA256 digest for a file" do
      Radix.digest( @good_manifest_path ).length.should eq(64)
    end
    
    it "should throw a standard file exception if the file can't be loaded" do
      lambda { Radix.digest( 'some/bad/file' ) }.should raise_error
    end
  end
  

  
end