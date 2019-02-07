require_relative "../config/environment.rb"

class Student
  attr_accessor :id, :name
  attr_reader :grade

  # CLASS METHODS ****************************
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        grade TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students;")
  end

  def self.create(name, grade)
    student = new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE name = ?;
    SQL

    new_from_db(DB[:conn].execute(sql, name)[0])
  end

  # INSTANCE METHODS ****************************
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if id
      # binding.pry
      update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?);
      SQL

      DB[:conn].execute(sql, name, grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    # binding.pry
    sql = <<-SQL
      UPDATE students
      SET name = ?,
          grade = ?
      WHERE id = ?;
    SQL

    # binding.pry
    DB[:conn].execute(sql, name, grade, id)
  end

  # PRIVATE METHODS ****************************
  private

  def self.bulk_create(rows)
    rows.map { |row| new(row[1], row[2], row[0]) }
  end

end
