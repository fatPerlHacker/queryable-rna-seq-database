module Blast_Query
class Blastn_Query < Blast_Query::Base
    def initialize(attributes = {})
        #Load in any values from the form
        attributes.each do |name, value|
            send("#{name}=", value)
        end
        #Set default values
        #Defaults taken from http://www.ncbi.nlm.nih.gov/books/NBK1763/#CmdLineAppsManual.Appendix_C_Options_for
        if (self.word_size.nil?)
            self.word_size = 11
        end
        if (self.gap_open_penalty.nil?)
            self.gap_open_penalty = 5
        end
        if (self.gap_extension_penalty.nil?)
            self.gap_extension_penalty = 2
        end
        if (self.mismatch_penalty.nil?)
            self.mismatch_penalty = -3
        end
        if self.match_reward.nil?
            self.match_reward = 2
        end
    end
end
end