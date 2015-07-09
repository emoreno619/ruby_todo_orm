require 'pry'
require 'pg'

HOSTNAME = :localhost
DATABASE = :testdb

class Todo

	attr_accessor :id, :name, :description

	def initialize(args)

		connect

		if args.has_key? :id
			@id = args[:id]
		end

		if args.has_key? :name
			@name = args[:name]
		end

		if args.has_key? :description
			@description = args[:description]
		end

	end

	def updateTodo(params)
		id = params[0]
		name = params[1]
		description = params[2]
		args = [name, description]
		

		sql = "UPDATE testdb2 SET "

		if (id.to_i.integer?)
			if (name && description)
				sql += "name = $1, description = $2"
			elsif (name)
				sql += "name = $1"
			else
				sql += "description = $2"
			end


			sql += " WHERE id = #{id}"

			res = @c.exec_params(sql, args)
		else
			puts "Invalid id!"
		end	
		self
	end

	def createTodo
		sql = "INSERT INTO testdb2 (name, description"
		args = [name, description]

		if id.nil?
		  sql += ") VALUES ($1, $2)"
		else
		  sql += ", id) VALUES ($1, $2, $3)"
		  args.push id
		end

		sql += ' RETURNING *;'

		res = @c.exec_params(sql, args)
		id = res[0]['id']
		self
	end

	def delete
	    sql = "DELETE FROM testdb2 WHERE id=$1"
	    @c.exec_params(sql, [id])
	    self
	 end

	def self.all
	    
		c = PGconn.new(:host => HOSTNAME, :dbname => DATABASE)

	    results = []

	    res = c.exec "SELECT * FROM testdb2;"

	    res.each do |todo|
	      id = todo['id']
	      name = todo['name']
	      description = todo['description']

	      results << Todo.new({:id => id, :name => name, :description => description})
	    end

	    c.close

	    results
	end

	def to_s
	  "#{@id}: #{self.name} - #{self.description}"
	end

	private
    def connect
      @c = PGconn.new(:host => HOSTNAME, :dbname => DATABASE)
    end

end

class Ui

	def initialize

	end

	def self.greet
		flag = false

		while !flag
			puts %{\n\t\tWelcome to the todo app, what would you like to do?
				
				n - make a new todo
				l - list all todos
				u [id] - update a todo with a given id
				d [id] - delete a todo with a given id, if no id is provided, 
						 all todos will be deleted
				q - quit the application}

			input = gets.chomp
			puts "You entered: '#{input}'"
			params = []

			if(input=='n')

				puts "Name of todo:"
				params.push(gets)
				puts "Description of todo:"
				params.push(gets)


				aTodo = Todo.new({:name => params[0], :description => params[1]})
				aTodo.createTodo
				puts aTodo
				puts "todo successfully created"
			
			elsif(input=='q')
			
				puts "BYE!"
				flag = true

			elsif(input=='u')

				puts "Which id would you like to update?"
				params.push(gets)
				puts "What will the 'name' of the todo be?"
				params.push(gets)
				puts "What will the 'description' of the todo be?"
				params.push(gets)
				
				aTodo = Todo.new({})
				aTodo.updateTodo(params)

			elsif(input=='d')
				puts "Which id would you like to delete?"
				aTodo = Todo.new({:id => gets})
				aTodo.delete

			else #list all

				# aTodo = Todo.new({})
				

				results = Todo.all
				
				results.each do |result|
					p result
				end
			end
		end

	end

end
	
Ui.greet