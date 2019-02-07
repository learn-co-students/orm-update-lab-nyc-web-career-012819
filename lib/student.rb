require_relative "../config/environment.rb"
require "pry"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = "CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade BLOB);"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def save
    if !!self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end

  def self.create(name, grade)
    Student.new(name, grade).save

  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    Student.new(name, grade, id)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE students.name = '#{name}';"
    DB[:conn].execute(sql).map { |row| self.new_from_db(row) }.first
  end

  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
