class IndexesOnParticipation < ActiveRecord::Migration
	def change
		add_index(:participations, [:target_id, :target_type, :author_id])
		add_index(:participations, :guid)
	end
end
