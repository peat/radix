RADIX_ROOT = File.join( File.dirname(__FILE__), '..' )

require File.join( RADIX_ROOT, 'lib', 'radix.rb' )

describe Radix do

  before(:all) do
    @schema_path = File.join( RADIX_ROOT, 'schema', 'radix.xsd' )
    @bad_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest-invalid.xml' )
    @good_manifest_path = File.join( RADIX_ROOT, 'fixtures', 'manifest-valid.xml' )
    @good_banknote_path = File.join( RADIX_ROOT, 'fixtures', 'banknote-valid.xml' )
    @private_key_path = File.join( RADIX_ROOT, 'fixtures', 'keys', 'fixture.pem' )
    @public_key_path = File.join( RADIX_ROOT, 'fixtures', 'keys', 'fixture.pub' )
    
    @delete = [] # for cleaning up files
  end
  
  describe "Radix#valid_xml?" do
        
    it "should validate the XML for a given file by enforcing the indicated XSL" do
      Radix.valid_xml?( @good_manifest_path, @schema_path ).should be_true
      Radix.valid_xml?( @bad_manifest_path, @schema_path ).should be_false
    end

  end
  
  describe "Radix#xml_errors" do
    
    it "should provide errors for XML for a given file if it does not match the standard" do
      Radix.xml_errors( @good_manifest_path, @schema_path ).length.should eq(0)
      Radix.xml_errors( @bad_manifest_path, @schema_path ).length.should eq(2)
    end 
    
  end
  
  describe "Radix#signature" do
    
    it "should create a signature of an file based on a private key" do
      # simple check; real meat is in #valid_signature?
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
  
  describe "Radix#generate_signature_file" do
    
    it "should generate a signature file for the specified XML file and private key" do
      signature_path = Radix.generate_signature_file( @good_banknote_path, @private_key_path, @public_key_path )
            
      File.exist?( signature_path ).should be_true
      Radix.valid_xml?( signature_path, @schema_path ).should be_true
      
      @delete << signature_path
    end
    
  end
  
  describe "Radix#valid_signature_file?" do
    
    it "should ensure a signature file is correct." do
      signature_path = Radix.generate_signature_file( @good_banknote_path, @private_key_path, @public_key_path )
      
      Radix.valid_signature_file?( signature_path ).should be_true
      lambda { 
        Radix.valid_signature_file?( File.join( RADIX_ROOT, 'fixtures', 'manifest-invalid.signature' ) ) 
      }.should raise_error
    end
    
  end

  describe "Radix#valid_manifest?" do
    
    it "should ensure that a manifest parses, that the indicated files parse, and that signatures are valid" do
      # make sure our signature file exists for the banknotes, which is referenced in the manifest.
      Radix.generate_signature_file( @good_banknote_path, @private_key_path, @public_key_path )
      
      Radix.valid_manifest?( @good_manifest_path, @schema_path ).should be_true
      Radix.valid_manifest?( @bad_manifest_path, @schema_path ).should be_false
    end
    
  end
  
  describe "Radix#valid_package?" do
    
    it "should ensure that the manifest is valid, and all signatures are valid" do
      good_package_path = File.join( RADIX_ROOT, 'fixtures', 'packages', 'banknote-example.radix' )
      
      Radix.valid_package?( good_package_path, @schema_path ).should be_true
    end
    
    
  end
  
  after(:all) do
    File.delete( *@delete )
  end
  
end