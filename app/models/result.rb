class Result < ActiveRecord::Base
  belongs_to :page
  
  def averages
    YAML::load(self[:data])
  end
  
  def averages=(averages)
    self[:data] = YAML::dump(averages)
  end
end
