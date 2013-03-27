require 'spec_helper'
require 'view_models/shared_examples.rb'
require 'upload/blast_util.rb'

describe UploadFastaSequences do
  before(:each) do
    @it = FactoryGirl.build(:upload_fasta_sequences)
    #Stub the file delete method so that test files aren't delete
    File.stub(:delete){}
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
    DatabaseCleaner.clean
  end
  
  it 'should test the logger for that weird issue'
  
  ################# Validations ###################
  describe 'validations', :type => :validations do
    describe 'transcripts_fasta_file' do
      before (:each) do @attribute = 'transcripts_fasta_file' end
      
      it_should_behave_like 'a required attribute'
      it_should_behave_like 'an uploaded file'
    end
    
    describe 'dataset_name' do
      before (:each) do @attribute = 'dataset_name' end
      
      it_should_behave_like 'a required attribute'
    end
  end
  
  ################# White Box ###################
  describe 'flow control', :type => :white_box do
    before (:each) do
      @it.stub(:process_args_to_create_dataset)
      File.stub(:delete)
      BlastUtil.stub(:create_blast_database)
      BlastUtil.stub(:rollback_blast_database)
      QueryAnalysisMailer.stub(:notify_user_of_upload_success)
      QueryAnalysisMailer.stub(:notify_user_of_upload_failure)
    end
  
    describe 'when an exception occurs' do
      before (:each) do
        BlastUtil.stub(:create_blast_database){raise SeededTestException}
      end
      
      it 'should call QueryAnalysisMailer.notify_user_of_upload_failure' do
        begin
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save
        rescue SeededTestException => ex
        end
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_success' do
        begin 
          QueryAnalysisMailer.should_receive(:notify_user_of_upload_failure)
          @it.save 
        rescue SeededTestException => ex
        end
      end
      it 'should rollback the blast database' do
        begin
          BlastUtil.should_receive(:rollback_blast_database)
          @it.save
        rescue SeededTestException => ex
        end
      end
    end
    
    describe 'no matter whether an exception occurs' do
      it 'should call valid?' do
        @it.should_receive(:valid?)
        @it.save
      end
    
      it 'should delete transcripts_fasta_file' do
        transcripts_fasta_file_path = @it.transcripts_fasta_file.tempfile.path
        File.should_receive(:delete).with(transcripts_fasta_file_path)
        @it.save
      end
      
    end
    
    describe 'when no exception occurs' do
      it 'should call process_args_to_create_dataset' do
        @it.should_receive(:process_args_to_create_dataset)
        @it.save
      end
      it 'should call BlastUtil.create_blast_database' do
        BlastUtil.should_receive(:create_blast_database)
        @it.save
      end
      it 'should call QueryAnalysisMailer.notify_user_of_upload_success' do
        QueryAnalysisMailer.should_receive(:notify_user_of_upload_success)
        @it.save
      end
      it 'should not call QueryAnalysisMailer.notify_user_of_upload_failure' do
        QueryAnalysisMailer.should_not_receive(:notify_user_of_upload_failure)
        @it.save
      end
      it 'should not call BlastUtil.rollback_blast_database' do
        BlastUtil.should_not_receive(:rollback_blast_database)
        @it.save
      end
    end
  end
  
  ################# Black Box ###################
  describe 'database/email/file interaction', :type => :black_box do
    describe 'when no exception occurs' do
      it 'should add 0 transcripts to the database' do
        lambda do
          @it.save
        end.should change(Transcript,:count).by(0)
      end
      it 'should add 0 genes to the database' do
        lambda do
          @it.save
        end.should change(Gene,:count).by(0)
      end
      it 'should add 0 fpkm samples to the database' do
        lambda do
          @it.save
        end.should change(FpkmSample,:count).by(0)
      end
      it 'should add 0 samples to the database' do
        lambda do
          @it.save
        end.should change(Sample,:count).by(0)
      end
      it 'should add 0 sample comparisons to the database' do
        lambda do
          @it.save
        end.should change(SampleComparison,:count).by(0)
      end
      it 'should add 0 differential expression tests to the database' do
        lambda do
          @it.save
        end.should change(DifferentialExpressionTest,:count).by(0)
      end
      it 'should add 0 transcript has go terms to the database' do
        lambda do
          @it.save
        end.should change(TranscriptHasGoTerm,:count).by(0)
      end
      it 'should add 0 transcript fpkm tracking informations to the database' do
        lambda do
          @it.save
        end.should change(TranscriptFpkmTrackingInformation,:count).by(0)
      end
      it 'should add 0 go terms to the database' do
        lambda do
          @it.save
        end.should change(GoTerm,:count).by(0)
      end
    end
    
    it_should_behave_like 'any upload view model when no exception occurs'
    it_should_behave_like 'any upload view model when an exception occurs' 
  end
end
