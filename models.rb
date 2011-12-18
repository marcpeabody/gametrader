require 'sinatra/activerecord'
ActiveRecord::Base.configurations = {
  'development' => {
    'adapter' => 'postgresql',
    'host' => 'localhost',
    'username' => 'root',
    'password' => '',
    'database' => 'gametrader'
  },
  'production' => {
    'adapter' => 'postgresql',
    'host' => 'ec2-107-22-181-228.compute-1.amazonaws.com',
    'username' => 'kuxjcchuex',
    'password' => 'NSdbpkkith7A2vFJgJKp',
    'database' => 'kuxjcchuex'
  }
}
config = ActiveRecord::Base.configurations[ENV['RACK_ENV'] || 'development']
begin
ActiveRecord::Base.establish_connection config.merge('database' => 'postgres')
ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => 'utf8'))
rescue;end
ActiveRecord::Base.establish_connection config
ActiveRecord::Base.logger = Logger.new($stdout)


class User < ActiveRecord::Base
  attr_accessor :thru
  has_and_belongs_to_many :games,
                          :join_table => 'ownerships',
                          :foreign_key => "owner_id" do
                            def <<(*items)
                              super( items - proxy_owner.games )
                            end
                          end
  has_and_belongs_to_many :vouchers,
                          :class_name => "User",
                          :foreign_key => "voucher_id",
                          :join_table => "vouchers" do
                            def <<(*items)
                              super( items - proxy_owner.vouchers - [proxy_owner] )
                            end
                          end

  has_and_belongs_to_many :trusted,
                          :class_name => "User",
                          :association_foreign_key => "voucher_id",
                          :join_table => "vouchers" do
                            def <<(*items)
                              super( items - proxy_owner.trusted - [proxy_owner] )
                            end
                          end

  def traders
    # people you trust
    # and the people who have mutual trust with them
    trusted.map do |t|
      [t] + t.trusted.select{|t2| t2.vouchers.include? t  }.map{|t2| t2.thru = t; t2 }
    end.flatten.uniq - [self]
  end
end

class Game < ActiveRecord::Base
  has_and_belongs_to_many :users,
                          :join_table => 'ownerships',
                          :association_foreign_key => 'owner_id'
end
class Voucher < ActiveRecord::Base
end
class Ownership < ActiveRecord::Base
end
