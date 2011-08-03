require 'nokogiri'

class Radix
    
  def self.valid_xml?( xml_path, schema_path )
    doc = Nokogiri::XML( File.read( xml_path ) )
    xsd = Nokogiri::XML::Schema( File.read( schema_path ) )
    
    xsd.validate(doc).empty?    
  end
  
end