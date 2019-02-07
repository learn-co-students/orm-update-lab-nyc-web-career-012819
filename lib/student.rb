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
    name = row[1]
    grade = row[2]
    id = row[0]
    new(name, grade, id)
  end

  def self.find_by_name(name)
    new_from_db(DB[:conn].execute("SELECT * FROM students WHERE name = ?;", name)[0])
  end

  # INSTANCE METHODS ****************************
  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if id
      update
    else
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES (?, ?);", @name, @grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?,
          grade = ?
      WHERE id = ?;
    SQL

    DB[:conn].execute(sql, @name, @grade, @id)
  end
end
