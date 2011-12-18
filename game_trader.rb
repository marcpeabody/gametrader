require 'sinatra/base'
require './models'

class GameTrader < Sinatra::Base
  get '/' do
    "Game Trader<br/><br/>
     <a href='/testdata'>Reset Test Data</a>"
  end

  get '/:user/trusts/:honest_user' do
    user = User.find_by_name(params[:user])
    honest_user = User.find_by_name(params[:honest_user])
    if user && honest_user
      honest_user.vouchers << user
      "<a href='/account/#{user.name}'>#{user.name}</a> now trusts
       <a href='/account/#{honest_user.name}'>#{honest_user.name}</a><br/><br/>

       This means #{user.name} can now see #{honest_user.name}'s game list
       as well as the lists of friends #{honest_user.name} mutually trusts."
    else
      "NO MATCH"
    end
  end

  get '/account/:user' do
    if user = User.find_by_name(params[:user])
      if traders = user.traders
        result = "<ul>"
        traders.each do |trader|
          result += "<li><a href='#{trader.name}'>#{trader.name}#{" (thru #{trader.thru.name})" if trader.thru}</a>"
          result += "<ul>"
          trader.games.each do |game|
            result += "<li>#{game.name}</li>"
          end
          result += "</ul>"
          result += "</li>"
        end
        result += "</ul>"
      end
    end
    result ||= "USER NOT FOUND"
  end

  get '/testdata' do
    Ownership.delete_all
    Voucher.delete_all
    User.delete_all
    Game.delete_all
    marc = User.create!(:name => 'marc')
    brian = User.create!(:name => 'brian')
    tim = User.create!(:name => 'tim')
    animal = User.create!(:name => 'animal')

    mw3 = Game.create!(:name => 'MW3')
    qbert = Game.create!(:name => 'Q*Bert')
    skyrim = Game.create!(:name => 'Skyrim')

    marc.vouchers << brian
    marc.vouchers << animal
    brian.vouchers << marc
    tim.vouchers << brian

    marc.games << qbert
    animal.games << qbert
    brian.games << mw3
    tim.games << skyrim
    tim.games << mw3
    "FINISHED<br/><br/>#{User.all.map{|u| "<a href='/account/#{u.name}'>#{u.name}</a><br/>"}.join }"
  end
end
