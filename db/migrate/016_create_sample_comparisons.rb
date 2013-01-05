class CreateSampleComparisons < ActiveRecord::Migration
  def change
    create_table :sample_comparisons, :id => false do |t|
      t.integer :sample_1_id
      t.integer :sample_2_id

      t.timestamps
    end
    
    #This is a workaround because rails can't do string or multiple 
    #   primary keys by default
    execute('ALTER TABLE sample_comparisons ' +
            'ADD PRIMARY KEY (sample_1_id,sample_2_id);')
  end
end
