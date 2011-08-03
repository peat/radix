require 'nokogiri'
require 'digest/sha2'
require 'openssl'
require 'base64'
require 'builder'

class Radix
  
  # validates the file at xml_path with the XSD schema at schema_path
  #
  # returns: an Array containing the errors (empty if none)
  def self.xml_errors( xml_path, schema_path )
    doc = Nokogiri::XML( File.read( xml_path ) )
    xsd = Nokogiri::XML::Schema( File.read( schema_path ) )
    
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
    
    signature_path = file_path.chomp( File.extname(file_path) ) + '.signature'
    File.open( signature_path, 'w' ) { |f| f.write( xml.target! ) }
    
    signature_path
  end
  
end