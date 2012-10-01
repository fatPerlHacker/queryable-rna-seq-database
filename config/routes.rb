require 'sinatra'
class ApiApp < Sinatra::Base
  get '/' do
  end

  get "/endpoint" do
  end

  post "/endpoint" do
  end
  
  get "/get_sequence" do
  end
end 


RnaSeqAnalysisPipeline::Application.routes.draw do
  get "processing_analysis/main_menu"
  post "processing_analysis/main_menu"

  get "processing_analysis/quality_filtering"

  get "processing_analysis/reference_analysis"

  get  "processing_analysis/reference_analysis_isoforms_only"
  post "processing_analysis/reference_analysis_isoforms_only"
  
  get "processing_analysis/de_novo_analysis_edgeR"

  get "processing_analysis/de_novo_analysis_cuffdiff"

  #root :to => "query_analysis#upload_main_menu"
  root :to => "query_analysis#upload_de_novo_edgeR"
    
  get  "query_analysis/upload_main_menu"
  post "query_analysis/upload_main_menu"

  get "query_analysis/upload_reference_cuffdiff"

  get "query_analysis/upload_de_novo_cuffdiff"

  get "query_analysis/upload_de_novo_edgeR"
  post "query_analysis/upload_de_novo_edgeR"

  get "query_analysis/query_diff_exp_transcripts"
  post "query_analysis/query_diff_exp_transcripts"

  get "query_analysis/query_diff_exp_genes"

  get "query_analysis/query_transcript_isoforms"

  get "query_analysis/query_gene_isoforms"
 
  get  "query_analysis/query_blast_db"
  get  "query_analysis/query_blast_db_2"
  post "query_analysis/query_blast_db_2"
  
  get  "query_analysis/blastn"
  post "query_analysis/blastn"
  
  get  "query_analysis/tblastn"
  post "query_analysis/tblastn"
  
  SequenceServer::App.init
  #match "/sequenceserver" => SequenceServer::App, :anchor => false
  #match "/sequenceserver(/*other_params)" => SequenceServer::App, :anchor => false
   mount SequenceServer::App => "sequenceserver"
   #ApiApp.init
   mount ApiApp => "api"
#   SequenceServer::App.routes do
#     get "get_sequence"# => "sequenceserver/get_sequence"
#     get "sequenceserver/get_sequence"
#     get "/sequenceserver/get_sequence"
#     match "get_sequence", :to => SequenceServer::App
#     match "/sequenceserver/get_sequence", :to => SequenceServer::App
#     match "sequenceserver/get_sequence", :to => SequenceServer::App
#     match "get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#     match "/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#     match "/sequenceserver/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#     match "sequenceserver/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#   end
#   match "get_sequence", :to => SequenceServer::App
#   match "/sequenceserver/get_sequence", :to => SequenceServer::App
#   match "sequenceserver/get_sequence", :to => SequenceServer::App
#   match "get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#   match "/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#   match "/sequenceserver/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
#   match "sequenceserver/get_sequence", :to => "get_sequence", :constraints => {:subdomain => "sequenceserver"}
  
# class HomeApp < Sinatra::Base
#     get "/" do
#     "Hello World!"
#     end
# end
 
# Basecamp::Application.routes do
#   match "/home", :to => HomeApp
# end
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
