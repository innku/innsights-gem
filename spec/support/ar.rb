ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
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

class Company < ActiveRecord::Base
  def to_s
    @name
  end
end
class User < ActiveRecord::Base 
  belongs_to :company
  def to_s
    @name
  end
end
class Post < ActiveRecord::Base
  belongs_to :user
end