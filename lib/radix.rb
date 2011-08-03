require 'nokogiri'
require 'digest/sha2'

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
  
end