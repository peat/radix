require 'nokogiri'
require 'digest/sha2'
require 'openssl'
require 'base64'

class Radix
    
  def self.xml_errors( xml_path, schema_path )
    doc = Nokogiri::XML( File.read( xml_path ) )
    xsd = Nokogiri::XML::Schema( File.read( schema_path ) )
    
    xsd.validate(doc)    
  end
  
  def self.valid_xml?( xml_path, schema_path )
    xml_errors( xml_path, schema_path ).empty?
  end
  
  def self.digest( file_path )
    Digest::SHA2.hexdigest( File.read( file_path ) )
  end
  
  def self.signature( file_path, private_key_path )
    plain_text = digest( file_path )
    private_key = OpenSSL::PKey::RSA.new( File.read( private_key_path ) )
    raw_signature = private_key.private_encrypt( plain_text )
    Base64.strict_encode64( raw_signature )
  end
  
end