class WorkerForUploadTrinityWithEdgerTranscripts
  include SuckerPunch::Worker
  
  def perform(upload_trinity_with_edger_transcripts)
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      upload_trinity_with_edger_transcripts.save
    end
  end
end
