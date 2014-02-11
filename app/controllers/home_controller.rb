class HomeController < ApplicationController
  layout 'home'

  skip_filter :authenticate_user!

  respond_to :html, :only => [:styleguide]
  respond_to :rss, :only => :builds
  respond_to :json, :only => [:github_status, :heroku_status, :rubygems_status, :index]

  def index
    if aggregate_project_id = params[:aggregate_project_id]
      agg_project = AggregateProject.find(aggregate_project_id)
      @agg_project = agg_project
      projects = agg_project.projects
    else
      aggregate_projects = AggregateProject.displayable(params[:tags])
      standalone_projects = Project.standalone.displayable(params[:tags])
      projects = standalone_projects.concat(aggregate_projects).sort_by { |p| p.code.downcase }
    end

    @projects = projects
  end

  def builds
    @projects = Project.standalone.with_statuses + AggregateProject.with_statuses
    respond_with @projects
  end

  def github_status
    respond_with ExternalDependency.get_or_fetch('GITHUB')
  end

  def heroku_status
    respond_with ExternalDependency.get_or_fetch('HEROKU')
  end

  def rubygems_status
    respond_with ExternalDependency.get_or_fetch('RUBYGEMS')
  end

  def styleguide
  end
end
