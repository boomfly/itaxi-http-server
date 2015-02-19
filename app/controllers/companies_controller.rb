class CompaniesController < ApplicationController
  before_action :authenticate_user!

  def index
    @companies = Company.where(user_id: current_user.id)

    render json: @companies, :include => [:user, :users, :transactions]
  end

  def create
    @company = CompaniesService.create current_user, params

    render json: @company, :include => [:user, :users, :transactions]
  end

  def update
    @company = CompaniesService.update current_user, params

    render json: @company, :include => [:user, :users, :transactions]
  end

  def show
    @company = Company.find(params[:id])

    render :json => @company
  end


end
