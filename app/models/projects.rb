require 'fileutils'

class Projects

  class << self
    def load_all(dir = PROJECTS_ROOT)
      Projects.new(dir).load_all
    end

    def load_project(dir)
      project = Project.load_or_create(dir)
      project.path = dir
      project
    end
  end
  
  def initialize(dir = PROJECTS_ROOT)
    @dir = dir
    @list = []
  end

  def load_all
    @list = Dir["#{@dir}/*"].find_all {|child| File.directory?(child)}.
                             collect  {|child| Projects.load_project(child)}
    self
  end
  
  def <<(project)
    raise "project named #{project.name.inspect} already exists" if @list.include?(project)
    @list << project
    save_project(project)
    self
  end

  def save_project(project)
    path = @dir + "/" + project.name
    FileUtils::makedirs path
    File.open(path + "/project_config.rb", "w") {|f| f << project.memento}
  end

  # delegate everything else to the underlying @list
  def method_missing(method, *args, &block)
    @list.send(method, *args, &block)
  end

end
