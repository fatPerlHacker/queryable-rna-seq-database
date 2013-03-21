class UploadTrinityWithEdgeRTranscriptsAndGenes
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :transcripts_fasta_file, 
                :gene_diff_exp_files, #Array
                :transcript_diff_exp_files, #Array 
                :gene_fpkm_file, 
                :transcript_fpkm_file,
                :dataset_name
  
  validates :transcripts_fasta_file, :presence => true,
                                     :uploaded_file => true
  
  validates :gene_diff_exp_files, :presence => true,
                                  :array => true,
                                  :array_of_uploaded_files => true
  validates :transcript_diff_exp_files, :presence => true,
                                        :array => true,
                                        :array_of_uploaded_files => true
  validate :same_number_of_gene_and_transcript_diff_exp_files
  
  validates :gene_fpkm_file, :presence => true,
                             :uploaded_file => true
  validates :transcript_fpkm_file, :presence => true,
                                   :uploaded_file => true
  validates :dataset_name, :presence => true
  
  
  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def save
    return if not self.valid?
    begin
      ActiveRecord::Base.transaction do   #Transactions work with sub-methods
        process_args_to_create_dataset()
        process_gene_diff_exp_files()
        process_gene_fpkm_file()
        process_transcript_diff_exp_files()
        process_transcript_fpkm_file()
        #find_and_process_go_terms()
        UploadUtil.create_blast_database(@transcripts_fasta_file.tempfile.path,
                                          @dataset)
      end
    rescue Exception => ex
      UploadUtil.rollback_blast_database(@dataset)
      QueryAnalysisMailer.notify_user_of_upload_failure(@current_user,
                                                          @dataset,
                                                          ex.message)
      raise ex
    ensure
      delete_uploaded_files()
    end
    QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end

  private
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                            :name => @dataset_name,
                            :program_used => :trinity_with_edger)
    @dataset.has_transcript_diff_exp = true
    @dataset.has_gene_diff_exp = false
    @dataset.has_transcript_isoforms = false
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def process_gene_diff_exp_files
  end
  
  def process_gene_fpkm_file
  end
  
  def process_transcript_diff_exp_files
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      #Process the file
      tdefp = TranscriptDiffExpFileProcessor.new(transcript_diff_exp_file,
                                                 @dataset)
      tdefp.process_file()
    end
  end
  
  def process_transcript_fpkm_file
    ttffp = TrinityTranscriptFpkmFileProcessor.new(@transcript_fpkm_file,
                                                   @dataset)
    ttffp.process_file()
  end
  
  def find_and_process_go_terms()
    go_terms_file_path = 
        UploadUtil.generate_go_terms(@transcripts_fasta_file.tempfile.path)
    go_terms_file = File.open(go_terms_file_path)
    while not go_terms_file.eof?
      line = go_terms_file.readline
      next if line.blank?
      line_regex = /\A(\S+)\s+(\S+)\s+(.+)\z/
      (transcript_name, go_id, term) = line.strip.match(line_regex).captures
      go_term = GoTerm.find_by_id(go_id)
      if go_term.nil?
        go_term = GoTerm.create!(:id => go_id, :term => term)
      end
      transcript = Transcript.where(:dataset_id => @dataset.id, 
                                    :name_from_program => transcript_name)[0]
      TranscriptHasGoTerm.create!(:transcript => transcript, 
                                     :go_term => go_term)
    end
    go_terms_file.close
    File.delete(go_terms_file.path)
  end
  
  def delete_uploaded_files
    File.delete(@transcripts_fasta_file.tempfile.path) 
    @gene_diff_exp_files.each do |gene_diff_exp_file|
      File.delete(gene_diff_exp_file.tempfile.path)
    end
    @transcript_diff_exp_files.each do |transcript_diff_exp_file|
      File.delete(transcript_diff_exp_file.tempfile.path)
    end
    File.delete(@gene_fpkm_file.tempfile.path)
    File.delete(@transcript_fpkm_file.tempfile.path)
  end
  
  #### Validations #####
  def same_number_of_gene_and_transcript_diff_exp_files
    return if @gene_diff_exp_files.nil?
    return if @transcript_diff_exp_files.nil?
    return if not @gene_diff_exp_files.kind_of? Array
    return if not @transcript_diff_exp_files.kind_of? Array
    if @gene_diff_exp_files.count != @transcript_diff_exp_files.count
      error_msg = 'transcript and gene differential expression files ' +
                  'must be equal in number'
      errors[:gene_diff_exp_files] << error_msg
      errors[:transcript_diff_exp_files] << error_msg
    end
  end
end
