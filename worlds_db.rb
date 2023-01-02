require "pg"

class WorldsDatabase
  def initialize
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "worlds")
          end
  end

  # Retrieve all world names
  def all_worlds
    result = query("SELECT * FROM worlds;")

    result.map do |tuple|
      tuple_to_world_hash(tuple)
    end
  end

  # Create a new world
  def new_world(params)
    sql = <<~SQL
      INSERT INTO worlds(name, description, date_system) VALUES
      ($1, $2, $3)
    SQL
    p params
    query(sql, params[:name].strip, params[:description], params[:date_system])
  end

  # Retrieve a world based on its id
  def world_by_id(id)
    result = query("SELECT * FROM worlds WHERE id = $1", id)
    result.map do |tuple|
      tuple_to_world_hash(tuple)
    end
  end

  def disconnect
    @db.close
  end

  private

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def tuple_to_world_hash(tuple)
    {id: tuple["id"].to_i,
      name: tuple["name"],
      description: tuple["description"],
      date_system: tuple["date_system"]}
  end
end