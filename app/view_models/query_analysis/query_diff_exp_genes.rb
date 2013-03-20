class QueryDiffExpGenes
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  require 'query/gene_name_query_condition_generator.rb'
  require 'query/go_ids_query_condition_generator.rb'
  require 'query/go_terms_query_condition_generator.rb'
  
  attr_accessor :dataset_id, :sample_comparison_id_pair,
                :fdr_or_p_value, :cutoff, :filter_by_go_terms, :go_terms,
                :filter_by_go_ids, :go_ids,  
                :filter_by_gene_name, :gene_name 
  attr_reader   :names_and_ids_for_available_datasets, 
                :available_sample_comparisons, 
                :show_results, :results, :sample_1_name, :sample_2_name
  
  #TODO: Add validation 
  validate :user_has_permission_to_access_dataset
  validate :sample_is_not_compared_against_itself
  
  def show_results?
    return @show_results
  end
  
  def initialize(current_user)
    @current_user = current_user
  end
  
  def set_attributes_and_defaults(attributes = {})
    #Load in any values from the form
    attributes.each do |name, value|
        send("#{name}=", value)
    end
    #Set available datasets
    @names_and_ids_for_available_datasets = []
    available_datasets = Dataset.where(:user_id => @current_user.id, 
                                       :has_gene_diff_exp => true)
    available_datasets.each do |ds|
      @names_and_ids_for_available_datasets << [ds.name, ds.id]
    end
    #Set default values for the relavent blank attributes
    @dataset_id = available_datasets.first.id if @dataset_id.blank?
    @fdr_or_p_value = 'p_value' if fdr_or_p_value.blank?
    @cutoff = '0.05' if cutoff.blank?
    @filter_by_go_terms = false if filter_by_go_terms.blank?
    @filter_by_go_ids = false if filter_by_go_ids.blank?
    @filter_by_gene_name = false if filter_by_gene_name.blank?
    #Set available samples for comparison
    @available_sample_comparisons = []
    sample_comparisons_query = SampleComparison.joins(:sample_1,:sample_2).
        where('samples.dataset_id' => @dataset_id).
        select('samples.name as sample_1_name, '+
               'sample_2s_sample_comparisons.name as sample_2_name, ' +
               'samples.id as sample_1_id, ' +
               'sample_2s_sample_comparisons.id as sample_2_id')
    sample_comparisons_query.each do |scq|
      display_text = "#{scq.sample_1_name} vs #{scq.sample_2_name}"
      value = "#{scq.sample_1_id},#{scq.sample_2_id}"
      @available_sample_comparisons << [display_text, value]
    end
    if @sample_comparison_id_pair.blank?
      @sample_comparison_id_pair = @available_sample_comparisons[0][1]
    end
    @show_results = false
  end
  
  def query()
    #Don't query if it is not valid
    return if not self.valid?
    #Create and run the query
    sample_ids = @sample_comparison_id_pair.split(',')
    sample_1 = Sample.find_by_id(sample_ids[0])
    sample_2 = Sample.find_by_id(sample_ids[1])
    sample_comparison = SampleComparison.where(
      :sample_1_id => sample_ids[0],
      :sample_2_id => sample_ids[1]
    )[0]
    #Require parts of the where clause
    det_t = DifferentialExpressionTest.arel_table
    where_clause = det_t[:sample_comparison_id].eq(sample_comparison.id)
    #where_clause = where_clause.and(sample_cmp_clause)
    if @fdr_or_p_value == 'p_value'
      where_clause = where_clause.and(det_t[:p_value].lteq(@cutoff))
    else
      where_clause = where_clause.and(det_t[:fdr].lteq(@cutoff))
    end
    #Optional parts of the where clause
    if @filter_by_gene_name == '1'
      gnqcg = GeneNameQueryConditionGenerator.new()
      gnqcg.name = @gene_name
      where_clause = where_clause.and(gnqcg.generate_query_condition())
    end
    query_results = 
      DifferentialExpressionTest.joins(:gene).where(where_clause)
    #Extract the query results to form that can be put in the view
    @sample_1_name = sample_1.name
    @sample_2_name = sample_2.name
    @results = []
    query_results.each do |query_result|
      #Do a few more minor queries to get the data in the needed format
      gene = Gene.find_by_id(query_result.gene_id)
      transcripts = gene.transcripts
      if @filter_by_go_ids == '1'
        giqcg = GoIdsQueryConditionGenerator.new(@go_ids)
        query_condition = giqcg.generate_query_condition()
        match_found = false
        transcripts.each do |transcript|
          if not (transcript.go_terms & GoTerm.where(query_condition)).empty?
            match_found = true
          end
        end
        next if not match_found
      end
      if @filter_by_go_terms == '1'
        gtqcg = GoTermsQueryConditionGenerator.new(@go_terms)
        query_condition = gtqcg.generate_query_condition()
        match_found = false
        transcripts.each do |transcript|
          if not (transcript.go_terms & GoTerm.where(query_condition)).empty?
            match_found = true
          end
        end
        next if not match_found
      end
      #Fill in the result hash that the view will use to display the data
      result = {}
      result[:gene_name] = gene.name_from_program #det.gene
      result[:transcript_names] = transcripts.map{|t| t.name_from_program} #det.gene.transcript_names
      result[:go_terms] = transcripts.map{|t| t.go_terms}.flatten
      result[:test_statistic] = query_result.test_statistic
      result[:p_value] = query_result.p_value
      result[:fdr] = query_result.fdr
      result[:sample_1_fpkm] =  query_result.sample_1_fpkm
      result[:sample_2_fpkm] =  query_result.sample_2_fpkm
      result[:log_fold_change] = query_result.log_fold_change
      result[:test_status] = query_result.test_status
      @results << result
    end
    #Mark the search results as viewable
    @show_results = true
  end
  
  #Accoring http://railscasts.com/episodes/219-active-model?view=asciicast,
  #     this defines that this model does not persist in the database.
  def persisted?
      return false
  end
  
  private
  def user_has_permission_to_access_dataset
  end
  
  def sample_is_not_compared_against_itself
  end
end
