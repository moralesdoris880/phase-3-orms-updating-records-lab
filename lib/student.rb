require_relative "../config/environment.rb"

class Student
  attr_accessor  :id, :name, :grade

  def initialize(name,grade,id:nil)
    @id=id
    @name=name
    @grade=grade
  end
  def self.create_table
    sql= <<-SQL
    CREATE TABLE students(
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    sql= <<-SQL
    DROP TABLE students
    SQL
    DB[:conn].execute(sql)
  end
  def save
    if self.id
      self.update
    else
      sql= <<-SQL
      INSERT INTO students(id,name,grade)
      VALUES(?,?,?)
      SQL
      DB[:conn].execute(sql,self.id,self.name,self.grade)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end
  def self.create(name,grade)
    student= Student.new(name,grade)
    student.save
  end
  def self.new_from_db(student)
    self.new(student[1],student[2],id:student[0])
  end
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE students.name = ?
    LIMIT 1
    SQL

    newarr= DB[:conn].execute(sql, name).map do |student|
        self.new_from_db(student)
    end
    newarr.first
  end
  def update
    sql = <<-SQL
    UPDATE students
    SET
     name = ?,
     grade = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end
end
