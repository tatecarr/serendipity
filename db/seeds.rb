# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
EntityType.create([{entity_type_desc: 'Person'}, {entity_type_desc: 'Place'}, {entity_type_desc: 'Thing'}, {entity_type_desc: 'Event'}])


