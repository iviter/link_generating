# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'aes'
require 'sinatra'
require 'sinatra/base'
require 'securerandom'
require 'sinatra/activerecord'
require 'sinatra/helper'
require 'bundler/setup'
require 'logger'
require 'active_support'
require 'byebug'

set :database, "sqlite3:project-name.sqlite3"

use Rack::Session::Cookie, key: 'rack.session',
                           path: '/',
                           secret: 'your_secret'

RAILS_ROOT = File.expand_path(__dir__)

Log = Logger.new(File.expand_path('log/app.log', __dir__))

# class Myapp < Sinatra::Base

get '/' do
  @links = Link.all
  erb :index
end

get '/new' do
  erb :new
end

post '/generate' do
  key = AES.key
  @link = Link.new(url: Helpers.random,
                   encrypted_key: key, message: AES.encrypt(params[:text], key))
  @link.save
  redirect to("/message/#{@link.url}")
end

get '/message/:url' do
  @link = Link.where(url: params[:url]).last
  erb :show
end

get '/delete/:url' do
  @message = Link.where(url: params[:url]).last
  few_hours = params[:delete_value].to_i
  hidden_value = params[:one_hour_value].to_i
  if @message.nil?
    redirect to('/')
  elsif hidden_value == 39
    sleep 1.hour
    @message.delete
    @message = 'Your message has been deleted within 1 hour!'
  elsif few_hours > 1
    sleep few_hours.hours
    @message.delete
    @message = "Your message has been deleted within #{few_hours} hours!"
  else
    @message.delete
    @message = 'Your message was deleted!'
  end
  erb :delete
end

require './models/link.rb'

# end
