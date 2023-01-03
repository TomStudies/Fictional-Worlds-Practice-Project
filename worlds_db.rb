require "pg"

class WorldsDatabase
  def initialize(logger)
    @db = PG.connect(dbname: "worlds")
    @logger = logger
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

  # Retrieve all characters from a world based on world id
  def characters_by_world_id(id)
    result = query("SELECT * FROM characters WHERE world_id = $1", id)
    result.map do |tuple|
      tuple_to_character_hash(tuple)
    end
  end

  # Retrieve all places from a world based on world id
  def places_by_world_id(id)
    result = {}
    # result[:query("SELECT * FROM characters WHERE world_id = $1", id)
  end

  # Retrieve all events from a world based on world id
  def events_by_world_id(id)
    result = query("SELECT * FROM events WHERE world_id = $1", id)
    result.map do |tuple|
      tuple_to_event_hash(tuple)
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
    {
      id: tuple["id"].to_i,
      name: tuple["name"],
      description: tuple["description"],
      date_system: tuple["date_system"]
    }
  end

  def tuple_to_character_hash(tuple)
    {
      id: tuple["id"].to_i,
      name: tuple["name"],
      birth_year: optional_to_i(tuple["birth_year"]),
      birth_month: optional_to_i(tuple["birth_month"]),
      birth_day: optional_to_i(tuple["birth_day"]),
      description: tuple["description"]
    }
  end

  def tuple_to_event_hash(tuple)
    {
      id: tuple["id"].to_i,
      name: tuple["name"].to_i,
      start_year: tuple["start_year"].to_i
    }
  end

  def optional_to_i(str_num)
    str_num == nil ? nil : str_num.to_i
  end
end