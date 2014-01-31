class Import < ActiveRecord::Base
  
  include Importer
  
  belongs_to :user
  has_many :failed_imports
    
  state_machine :status, initial: :new do
    
    after_transition :on => :completed, :do => :delete_file
    
    event :start do
      transition :new => :started
    end
    
    event :complete do
      transition [:started, :conflicted] => :completed
    end
    
    event :conflict do
      transition :started => :conflicted
    end
    
    event :fail do
      transition [:new, :started] => :failed
    end
    
  end
  
  def self.new_file(file, user_id)
    path = save_file(file)
    import = self.create path_file: path, user_id: user_id
    Workers::FileImport.perform_async(import.id)
  end
  
  def self.save_file(file)
    path = File.join("public/tmp", file.original_filename)
    File.open(path, "wb") { |f| f.write(file.read) }
    path
  end
  
  def self.started
    where(status: :started)
  end
  
  def self.new_imports
    where(status: :new)
  end
  
  def self.conflited
    where(status: :conflicted)
  end
  
  def delete_file
    File.delete(path_file)
  end
  
  def complete_if_not_failed_imports!
    complete! if failed_imports.unresolved.count == 0 and can_complete?
  end
  
  def process
    begin
      start!
      import
      complete! if can_complete?
    rescue Exception => e
      fail!
    end
  end
end
