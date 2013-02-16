# == Schema Information
#
# Table name: transcript_has_go_terms
#
#  transcript_id :integer          not null, primary key
#  go_term_id    :string(255)      not null
#

class TranscriptHasGoTerm < ActiveRecord::Base
  attr_accessible :transcript, :go_term
  
  belongs_to :transcript
  belongs_to :go_term
end
