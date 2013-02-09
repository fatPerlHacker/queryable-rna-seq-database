class Upload_Trinity_With_EdgeR_Transcripts_And_Genes
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :trinity_fasta_file, 
                :gene_differential_expression_file, #Array
                :transcript_differential_expression_file, 
                :gene_fpkm_file, 
                :transcript_fpkm_file
  
  validate :validate_all_or_none_gene_files
  
  def initialize(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
  end
  
  def save!
    debugger if ENV['RAILS_DEBUG'] == 'true'
    #Create new job
    job = Job.new(:email => 'nietz111@ksu.edu',
                  :output_files_type => 'trinity_with_edger')
    job.save!
    #TODO: Run blast2go, writing to the genes table?
    #Read the normalized genes FPKM file, writing to genes and fpkm_samples
    header_line = gene_fpkm_file.tempfile.readline.strip
    sample_names = header_line.split("\t")
    while not gene_fpkm_file.tempfile.eof?
      line = gene_fpkm_file.tempfile.readline.strip
      next if line == ""
      table_cells = line.split("\t")
      gene_name = table_cells.shift
      sample_fpkms = table_cells
      gene = Gene.create!(:job => job, 
                          :name_from_program => gene_name)
      (0..sample_fpkms.length-1).each do |i|
        fpkm_sample = FpkmSample.create!(:gene => gene,
                                         :sample_name => sample_names[i],
                                         :fpkm => sample_fpkms[i])
      end
    end
    #Read the normalized transcripts FPKM file, connecting transcripts to genes
    #   and writing transcripts and fpkm_samples
    header_line = transcript_fpkm_file.tempfile.readline.strip
    samples_names = header_line.split("\t")
    while not transcript_fpkm_file.tempfile.eof? 
      table_cells = transcript_fpkm_file.tempfile.readline.strip.split("\t")
      transcript_name = table_cells.shift
      sample_fpkms = table_cells
      associated_gene = 
          Gene.find_by_name_from_program(transcript_name.gsub(/_seq\d+/,""))
      transcript = Transcript.create!(:job => job, 
                                      :name_from_program => transcript_name,
                                      :gene => associated_gene)
      (0..sample_fpkms.length-1).each do |i|
        fpkm_sample = FpkmSample.create!(:transcript => transcript,
                                         :sample_name => sample_names[i],
                                         :fpkm => sample_fpkms[i])
      end
    end
    #Read the differential expression file for transcripts, 
    #   writing the differential expression table
    while not transcript_differential_expression_file.tempfile.eof?
      line = transcript_differential_expression_file.tempfile.readline.strip
      next if line.match(/\A#/) #Skip comment linse
      table_cells = line.split("\t")
      sample_names = table_cells[0..1]
      transcript = Transcript.find_by_name_from_program(table_cells[2])
      different_expression_values = table_cells[3..6]
      fpkm_sample_1 = 
          transcript.fpkm_samples.find_by_sample_name(sample_names[0])
      fpkm_sample_2 = 
          transcript.fpkm_samples.find_by_sample_name(sample_names[1])
      differential_expression_test = 
        DifferentialExpressionTest.create!(:fpkm_sample_1 => fpkm_sample_1,
                                           :fpkm_sample_2 => fpkm_sample_2,
                                           :transcript => transcript,
                                           :log_fold_change => table_cells[4],
                                           :p_value => table_cells[5],
                                           :q_value => table_cells[6])
    end
    #Read the differential expression file for genes, 
    #   writing the differential expression table
      while not gene_differential_expression_file.tempfile.eof?
      line = gene_differential_expression_file.tempfile.readline.strip
      next if line.match(/\A#/) #Skip comment linse
      table_cells = line.split("\t")
      samples = table_cells[0..1]
      gene = Gene.find_by_name_from_program(table_cells[2])
      fpkm_sample_1 = 
        gene.fpkm_samples.find_by_sample_name(sample_names[0])
      fpkm_sample_2 = 
        gene.fpkm_samples.find_by_sample_name(sample_names[1])
      different_expression_values = table_cells[3..6]
      differential_expression_test = 
        DifferentialExpressionTest.create!(:fpkm_sample_1 => fpkm_sample_1,
                                           :fpkm_sample_2 => fpkm_sample_2,
                                           :gene => gene,
                                           :log_fold_change => table_cells[4],
                                           :p_value => table_cells[5],
                                           :q_value => table_cells[6])
    end
    #Read the Trinity.fasta file, writing to the transcript table
    line = trinity_fasta_file.tempfile.readline
    while not trinity_fasta_file.tempfile.eof?
      #If this is a fasta description line
      description_line_match = line.match(/\A>(\w+)\s/)
      transcript_name = description_line_match.captures[0]
      transcript = Transcript.find_by_name_from_program(transcript_name)
      transcript.fasta_description = line
      line = trinity_fasta_file.tempfile.readline
      transcript.fasta_sequence = ""
      while not line.match(/\A>/) and not trinity_fasta_file.tempfile.eof?
        transcript.fasta_sequence << line
        line = trinity_fasta_file.tempfile.readline
      end
      transcript.save!
    end
    #Delete the files
    File.delete(trinity_fasta_file.tempfile.path)
    File.delete(gene_differential_expression_file.tempfile.path)
    File.delete(transcript_differential_expression_file.tempfile.path)
    File.delete(gene_fpkm_file.tempfile.path)
    File.delete(transcript_fpkm_file.tempfile.path)
  end
  
  def persisted?
      return false
  end
  
  private
  def validate_trinity_fasta_file
    #Validate that transcript name can be captured from description line?
  end
  
  def validate_transcript_differential_expression_file
    #Ensure this is a file before parsing it
#     return if trinity_fasta_file.nil?
#     if not trinity_fasta_file.kind_of? ActionDispatch::Http::UploadedFile
#       errors[:trinity_fasta_file] << "Must be a file."
#       return
#     end
#     
#     #loop through the file.
#     debugger if ENV['RAILS_DEBUG'] == 'true'
#     trinity_fasta_file.tempfile
    #Must have 7 columns
    #Last 4 columns must be convertable to double types
  end
  
  def validate_gene_differential_expression_file
  end
  
  def validate_transcript_fpkm_file
    #Confirm at least two samples in header column
    #Confirm all rows have the right number of fpkm_samples
  end
  
  def validate_gene_fpkm_file
  end
  
  def validate_all_or_none_gene_files
    #User should upload both gene files or neither
  end
end
