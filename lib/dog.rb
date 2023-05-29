require 'sqlite3'

class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def save
    if id.nil?
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", name, breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    else
      DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
    end
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    id, name, breed = row
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.all
    sql = "SELECT * FROM dogs"
    DB[:conn].execute(sql).map do |row|
      Dog.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    result = DB[:conn].execute(sql, name)[0]
    if result
      Dog.new_from_db(result)
    else
      nil
    end
  end

  def self.find(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    result = DB[:conn].execute(sql, id)[0]
    if result
      Dog.new_from_db(result)
    else
      nil
    end
  end

  # Bonus Methods

  def self.find_or_create_by(name:, breed:)
    dog = find_by_name(name)
    if dog
      dog
    else
      create(name: name, breed: breed)
    end
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name, breed, id)
  end
end
