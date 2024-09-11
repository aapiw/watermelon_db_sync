class CreateGlobalSeqs < ActiveRecord::Migration[6.0]
  def change
    execute "CREATE SEQUENCE global_seqs"
  end
end