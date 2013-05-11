###
# Utility class to create a where clause query condition to 
# match one or more GO ids (accessions).
class GoIdsQueryConditionGenerator
  include ActiveModel::Validations
  
  ###
  # The string containing the go id or group of go ids to use when 
  # creating the query condition
  attr_accessor :go_ids
  
  validates :go_ids, :presence => true, 
                     :format => { :with => /\A\s*(GO:\d+;?\s*)+\z/ }
  
  ###
  # parameters::
  # * <b>go_ids_string:</b> The string containing the go ids or group of 
  #   go ids to use when creating the query condition
  def initialize(go_ids_string)
    @go_ids = go_ids_string
  end
  
  def generate_having_string()
    #Do some validation
    if not self.valid?
      raise ArgumentError.new(self.errors.full_messages)
    end
    #Generate and return the query condition
    having_string = ""
    # string_agg(go_terms.id,';') LIKE '%GO:0070373%' AND string_agg(go_terms.id,';') LIKE '%GO:0010540%'
    go_ids = @go_ids.split(';')
    go_ids.each do |go_id|
      # Strip and quote to help prevent sql injection attacks
      go_id =  ActiveRecord::Base.connection.quote_string(go_id.strip())
      if not having_string.strip.blank?
        having_string += " AND "
      end
      adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        having_string += "group_concat(go_terms.id SEPARATOR ';') LIKE '%#{go_id}%' "
      when /postgresql/
        having_string += "string_agg(go_terms.id,';') LIKE '%#{go_id}%' "
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end   
    end
    return having_string
  end
end
