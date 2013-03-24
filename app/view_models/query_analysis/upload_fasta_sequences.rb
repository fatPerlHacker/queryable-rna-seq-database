class UploadFastaSequences
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :transcripts_fasta_file, 
                  :dataset_name
                  
  validates :transcripts_fasta_file, :presence => true,
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
      File.delete(@transcripts_fasta_file.tempfile.path)
    end
    QueryAnalysisMailer.notify_user_of_upload_success(@current_user,
                                                        @dataset)
  end
  
  #According http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end 
  
  private 
  
  def process_args_to_create_dataset()
    @dataset = Dataset.new(:user => @current_user,
                            :name => @dataset_name,
                            :program_used => :generic_fasta_file)
    @dataset.has_transcript_diff_exp = false
    @dataset.has_gene_diff_exp = false
    @dataset.has_transcript_isoforms = false
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/"
    @dataset.save!
    @dataset.blast_db_location = 
      "#{Rails.root}/db/blast_databases/#{Rails.env}/#{@dataset.id}"
    @dataset.save!
  end
  
  def transcripts_fasta_file_is_uploaded_file
    return if @transcripts_fasta_file.nil?
    if not @transcripts_fasta_file.kind_of? ActionDispatch::Http::UploadedFile
      errors[:transcripts_fasta_file] << "Must be an uploaded file."
    end
  end
end