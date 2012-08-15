ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dudes do |t|
      t.string :name
    end
    create_table :companies do |t|
      t.string :name
    end
    create_table :users do |t|
      t.string :name
      t.references :company
    end
    create_table :posts do |t|
      t.string :title
      t.references :user
      t.timestamps
    end
  end
end

class Company < ActiveRecord::Base
  attr_accessible :name
  def to_s
    self.name
  end
end
class User < ActiveRecord::Base 
  attr_accessible :name, :company
  belongs_to :company

  def to_s
    self.name
  end
end
class Post < ActiveRecord::Base
  attr_accessible :title, :user
  belongs_to :user
end
