require 'nokogiri'
require 'digest/sha2'
require 'openssl'
require 'base64'
require 'builder'

class Radix
  
  def self.open_xml( xml_path )
    Nokogiri::XML( File.read( xml_path ) )
  end
  
  def self.open_schema( schema_path )
    Nokogiri::XML::Schema( File.read( schema_path ) )
  end
  
  # validates the file at xml_path with the XSD schema at schema_path
  #
  # returns: an Array containing the errors (empty if none)
  def self.xml_errors( xml_path, schema_path )
    doc = open_xml( xml_path )
    xsd = open_schema( schema_path )
    
    xsd.validate(doc)    
  end
  
  # validates the file at xml_path with the XSD schema at schema_path
  #
  # returns: true if valid, false otherwise.
  def self.valid_xml?( xml_path, schema_path )
    xml_errors( xml_path, schema_path ).empty?
  end
  
  # returns: a SHA2, 256-bit digest for the file at file_path
  def self.digest( file_path )
    Digest::SHA2.hexdigest( File.read( file_path ) )
  end
  
  # returns: a base-64 encoded, private key encrypted digest for the file_path 
  def self.signature( file_path, private_key_path )
    plain_text = digest( file_path )
    private_key = OpenSSL::PKey::RSA.new( File.read( private_key_path ) )
    raw_signature = private_key.private_encrypt( plain_text )
    Base64.strict_encode64( raw_signature )
  end
  
  # returns: true if the encoded_signature is valid for a file, given a public_key
  def self.valid_signature?( file_path, public_key_path, encoded_signature )
    plain_text = digest( file_path ) # get the original file digest.
    public_key = OpenSSL::PKey::RSA.new( File.read( public_key_path ) )
    encrypted_signature = Base64.strict_decode64( encoded_signature )
    raw_signature = public_key.public_decrypt( encrypted_signature )
    
    plain_text == raw_signature
  end
  
  def self.generate_signature_file( file_path, private_key_path, public_key_path )
    signature_value = signature( file_path, private_key_path )
    
    xml = Builder::XmlMarkup.new( :indent => 2 )
    xml.instruct! :xml, :encoding => 'UTF-8'
    xml.signature( 
      :path => File.basename(file_path), 
      :key => File.join('keys', File.basename(public_key_path)), 
      :value => signature_value 
    )
    
    signature_path = signature_path_for( file_path )
    File.open( signature_path, 'w' ) { |f| f.write( xml.target! ) }
    
    signature_path
  end
  
  def self.signature_path_for( file_path )
    file_path.chomp( File.extname(file_path) ) + '.signature'
  end
  
  def self.valid_signature_file?( file_path )
    doc = open_xml( file_path )
    signature_node = doc.at_xpath('//signature')
    
    # sort out the base path, because all paths are relative
    base_path = File.dirname( file_path )
    source_file_path = File.join( base_path, signature_node['path'] )
    public_key_path = File.join( base_path, signature_node['key'] )
    
    # pull out the signature value for comparison
    signature_value = signature_node['value']
    
    valid_signature?( source_file_path, public_key_path, signature_value )
  end
  
  def self.manifest_errors( file_path, schema_path )
    errors = []
    
    manifest_doc = open_xml( file_path )
    schema = open_schema( schema_path )
    
    schema.validate(manifest_doc).each do |err|
      errors << "#{file_path} validation error: #{err}"
    end
    
    return errors unless errors.empty?
    
    # pull out the manifest object ID
    manifest_id = manifest_doc.at_xpath('/manifest/id').text
    
    # paths are relative in manifest; sort out the real paths
    base_path = File.dirname( file_path )
    
    # validate the referenced files
    manifest_doc.xpath('/manifest/file').each do |f|
      file_path = File.join( base_path, f['path'] )
      file_doc = open_xml( file_path )
    
      # error unless file validates against the schema
      schema.validate(file_doc).each do |err|
        errors << "#{f['path']} validation error: #{err}"
      end
    
      # error unless file's ID matches the manifest ID
      if file_doc.children.first['id'] != manifest_id
        errors << "ID in #{f['path']} does not match manifest ID: #{manifest_id}"
      end
      
      # validate signature if it exists
      signature_path = signature_path_for( file_path )
      unless valid_signature_file?( signature_path )
        errors << "Invalid signature in #{signature_path}"
      end
      
    end    
    
    errors
  end
  
  def self.valid_manifest?( file_path, schema_path )
    manifest_errors( file_path, schema_path ).empty?
  end
  
end