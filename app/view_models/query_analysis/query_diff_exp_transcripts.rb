require 'query/transcript_name_query_condition_generator.rb'
require 'query/go_ids_query_condition_generator.rb'
require 'query/go_terms_query_condition_generator.rb'
require 'query/go_filter_checker.rb'

###
# View model for the query differentially expressed transcripts page.
#
# <b>Associated Controller:</b> QueryAnalysisController
class QueryDiffExpTranscripts
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  # The id of the dataset whose transcript differential expression tests will be 
  # queried.
  attr_accessor :dataset_id
  # The id of the sample comparison whose transript differential expression tests 
  # will be queried.
  attr_accessor :sample_comparison_id
  # Whether the cutoff should be by fdr or p_value
  attr_accessor :fdr_or_p_value
  # The cutoff where differential expression tests with an fdr_or_p_value 
  # above this will not be included in the query results 
  attr_accessor :cutoff
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go terms (names) should be displayed in the 
  # query results.
  attr_accessor :go_terms
  # Specifies that only the differential expression tests with transcripts that 
  # have all of these go ids (accessions) should be displayed in the 
  # query results.
  attr_accessor :go_ids
  # Specifies that only records matching this transcript name should be display 
  # in the query results.
  attr_accessor :transcript_name
  # Because the query results are loaded in pieces using LIMIT and OFFSET, 
  # this specifies which piece to load.
  attr_accessor :page_number
  attr_accessor :sort_order
  attr_accessor :sort_column
  
  # The name/id pairs of the datasets that can be selected to have their 
  # transcript differential expression tests queried.
  attr_reader   :names_and_ids_for_available_datasets
  # The available sample comparisons for the selected dataset. These consist of 
  # any two samples that have transcript differential expression tests between them.
  attr_reader   :available_sample_comparisons
  # Contains the results from the query
  attr_reader   :results
  # The name of the first sample in the sample comparison
  attr_reader   :sample_1_name
  # The name of the second sample in the sample comparison
  attr_reader   :sample_2_name
  # The program used when generating the dataset's data, such as Cuffdiff or 
  # Trinity with EdgeR
  attr_reader   :program_used
  # The status of the go terms for the selected dataset
  attr_reader   :go_terms_status
  attr_reader   :show_results
  attr_reader   :available_sort_columns
  attr_reader   :available_sort_orders
  attr_reader   :available_page_numbers
  attr_reader   :results_count
  
  # The number of records in each piece of the query. This is used to 
  # determine the values for LIMIT and OFFSET in the query itself.
  PAGE_SIZE = 50
  
  AVAILABLE_SORT_ORDERS = {'ascending' => 'ASC', 'descending' => 'DESC'}
  
  
  validates :dataset_id, :presence => true,
                         :dataset_belongs_to_user => true
  validates :sample_comparison_id, :presence => true,
                                   :sample_comparison_belongs_to_user => true
  validates :cutoff, :presence => true,
                     :format => { :with => /\A\d*\.?\d*\z/ }
  
  
  def show_results?
    return @show_results
  end
  
  ###
  # parameters::
  # * <b>current_user:</b> The currently logged in user
  def initialize(current_user)
    @current_user = current_user
  end
  
  # Set the view model's attributes or set those attributes to their 
  # default values
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available datasets
    @names_and_ids_for_available_datasets = []
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                       :has_transcript_diff_exp => true,
                                       :finished_uploading => true)
                                .order(:name)
    available_datasets.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    if @dataset_id.blank?
      @dataset_id = available_datasets.first.id
    elsif not @dataset_id.to_s.match(/\A\d+\z/)
      @dataset_id = available_datasets.first.id
    end
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    s_t = Sample.arel_table
    where_clause = s_t[:dataset_id].eq(@dataset_id)
    sample_type_eq_both = s_t[:sample_type].eq('both')
    sample_type_eq_transcript = s_t[:sample_type].eq('transcript')
    sample_type_where_clause = sample_type_eq_transcript.or(sample_type_eq_both)
    where_clause = where_clause.and(sample_type_where_clause)
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where(where_clause).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'sample_comparisons.id as sample_comparison_id')
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = scq.sample_comparison_id
      @available_sample_comparisons << [display_text, value]
    end
    @available_sample_comparisons.sort!{|t1,t2|t1[0] <=> t2[0]}
    if @sample_comparison_id.blank?
      @sample_comparison_id = @available_sample_comparisons[0][1]
    end
    sample_cmp = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_cmp.sample_1.name
    @sample_2_name = sample_cmp.sample_2.name
    dataset = Dataset.find_by_id(@dataset_id)
    @program_used = dataset.program_used
    @go_terms_status = dataset.go_terms_status
    @page_number = '1' if @page_number.blank?
    @available_sort_orders = AVAILABLE_SORT_ORDERS.keys
    if @program_used == 'cuffdiff'
      @available_sort_columns = ['Transcript','Associated Gene', 
                                 'Test Statistic', 'P-value','FDR', 
                                "#{@sample_1_name} FPKM", 
                                "#{@sample_2_name} FPKM", 'Log Fold Change',
                                'Test Status']
    else
      @available_sort_columns = ['Transcript','Associated Gene', 'P-value','FDR', 
                                "#{@sample_1_name} FPKM", "#{@sample_2_name} FPKM",
                                'Log Fold Change']
    end
    @sort_order = @available_sort_orders.first if @sort_order.blank?
    @sort_column = @available_sort_columns.first if @sort_column.blank?
    @show_results = false if @show_results.blank?
  end
  
  # Execute the query to get the transcript differential expression tests 
  # with the specified filtering options and store them in #results.
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    #Record that the dataset was queried at this time
    @dataset = Dataset.find_by_id(@dataset_id)
    @dataset.when_last_queried = Time.now
    @dataset.save!
    select_string = 'transcripts.id as transcript_id,' +
                    'transcripts.name_from_program as transcript_name, ' +
                    'genes.name_from_program as gene_name,' +
                    'differential_expression_tests.test_statistic,' +
                    'differential_expression_tests.p_value,' +
                    'differential_expression_tests.fdr,' +
                    'differential_expression_tests.sample_1_fpkm,' +
                    'differential_expression_tests.sample_2_fpkm,' +
                    'differential_expression_tests.log_fold_change,' +
                    'differential_expression_tests.test_status, '
     adapter_type = ActiveRecord::Base.connection.adapter_name.downcase
      case adapter_type
      when /mysql/
        select_string += 'group_concat(go_terms.id SEPARATOR ";") as go_ids, '
        select_string += 'group_concat(go_terms.term SEPARATOR ";") as go_terms'
      when /postgresql/
        #TODO: Make sure these work
        select_string += 'array_agg(go_terms.id) as go_ids, '
        select_string += 'array_agg(go_terms.term) as go_terms'
      else
        throw NotImplementedError.new("Unknown adapter type '#{adapter_type}'")
      end
     # transcripts.id is at the end of the string to prevent a strange error 
     # with counting
     group_by_string = "genes.name_from_program, " +
                       "test_statistic, " +
                       "p_value, " +
                       "fdr, " +
                       "sample_1_fpkm, " +
                       "sample_2_fpkm, " +
                       "log_fold_change, " +
                       "test_status, " +
                       "transcripts.id "
     thgt_left_join = "LEFT OUTER JOIN transcript_has_go_terms " +
                 "ON transcript_has_go_terms.transcript_id = transcripts.id"
     go_terms_left_join = "LEFT OUTER JOIN go_terms " +
                          "ON transcript_has_go_terms.go_term_id = go_terms.id"
    #Retreive some variables to use later
    sample_comparison = SampleComparison.find_by_id(@sample_comparison_id)
    @sample_1_name = sample_comparison.sample_1.name
    @sample_2_name = sample_comparison.sample_2.name
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    where_clause = det_t[:sample_comparison_id].eq(sample_comparison.id)
    if @fdr_or_p_value == 'p_value'
      where_clause = where_clause.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clause = where_clause.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if not @transcript_name.blank?
      tnqcg = TranscriptNameQueryConditionGenerator.new()
      tnqcg.name = @transcript_name
      where_clause = where_clause.and(tnqcg.generate_query_condition())
    end
    case @sort_column
    when'Transcript'
      sort_column = 'transcripts.name_from_program'
    when 'Associated Gene'
      sort_column = 'genes.name_from_program'
    when 'Test Statistic'
      sort_column = 'differential_expression_tests.test_statistic'
    when 'P-value'
      sort_column = 'differential_expression_tests.p_value'
    when 'FDR'
      sort_column = 'differential_expression_tests.fdr'
    when "#{@sample_1_name} FPKM"
      sort_column = 'differential_expression_tests.sample_1_fpkm'
    when "#{@sample_2_name} FPKM"
      sort_column = 'differential_expression_tests.sample_2_fpkm'
    when 'Log Fold Change'
      sort_column = 'differential_expression_tests.log_fold_change'
    when 'Test Status'
      sort_column = 'differential_expression_tests.test_status'
    end
     @results = DifferentialExpressionTest
       .joins(:transcript => [:gene])
       .joins(thgt_left_join)
       .joins(go_terms_left_join)
       .where(where_clause)
       .group(group_by_string)
       .select(select_string)
       .order("#{sort_column} #{AVAILABLE_SORT_ORDERS[@sort_order]}")
       .limit(PAGE_SIZE)
       .offset(PAGE_SIZE*(@page_number.to_i-1)) #TODO: Fixme
#    query_results = 
#      DifferentialExpressionTest.joins(:transcript => [:gene])
#                                .where(where_clause)
#                                .select(select_string)
#                                .limit(PAGE_SIZE)
#                                .offset(PAGE_SIZE*@page_number.to_i)
#    #Extract the query results to a form that can be put in the view
#    @results = []
#    query_results.each do |query_result|
#      #Fill in the result hash that the view will use to display the data
#      if (@dataset.go_terms_status == 'found')
#        go_filter_checker = GoFilterChecker.new(query_result.transcript_id,
#                                                  @go_ids,
#                                                  @go_terms)
#        next if go_filter_checker.passes_go_filters() == false
#      end
#      result = {}
#      result[:transcript_name] = query_result.transcript_name
#      result[:gene_name] =  query_result.gene_name
#      if (@dataset.go_terms_status == 'found')
#        result[:go_terms] = go_filter_checker.transcript_go_terms
#      else
#        result[:go_terms] = []
#      end
#      result[:test_statistic] = query_result.test_statistic
#      result[:p_value] = query_result.p_value
#      result[:fdr] = query_result.fdr
#      result[:sample_1_fpkm] =  query_result.sample_1_fpkm
#      result[:sample_2_fpkm] =  query_result.sample_2_fpkm
#      result[:log_fold_change] = query_result.log_fold_change
#      result[:test_status] = query_result.test_status
#      @results << result
#    end
    #@available_page_numbers = 100
#    results.each do |result|
#      go_term_objects = []
#      if not result[:go_terms].nil?
#        go_terms = result[:go_terms].strip.split(';')
#        go_ids = result[:go_ids].strip.split(';')
#        (0..go_terms.length - 1).each do |i|
#          go_term_objects << GoTerm.new(:term => go_terms[i], :id => go_ids[i])
#        end
#      end
#      result.write_attribute(:go_term_objects,go_term_objects)
#    end
    
    @results_count = DifferentialExpressionTest
       .joins(:transcript => [:gene])
       .joins(thgt_left_join)
       .joins(go_terms_left_join)
       .where(where_clause)
       .group(group_by_string)
       .select(select_string)
       .count.count
    @available_page_numbers = (1..(@results_count.to_f/PAGE_SIZE.to_f).ceil).to_a
    @show_results = true
  end
  
  ###
  # According to http://railscasts.com/episodes/219-active-model?view=asciicast,
  # this defines that this view model does not persist in the database.
  def persisted?
      return false
  end
end
