# tasks for heroku to run

task :update_place_birthplace_info => :environment do

	DbpediaInfoEngine.update_place_birthplace_info
	
end