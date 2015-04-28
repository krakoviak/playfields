class EnvsController < ApplicationController

  def index
    envs = Env.all
    @data = {}
    # @data = {kkhaidukov:
    #             {apigw: {last: last_build_info,
    #                      builds: [builds,]},
    #              content: {last: last_build_info,
    #                         builds: [builds,]}
    #             },
    #           trainingcc:
    #             {apigw: {...}}}
    envs.each do |env|
      env_data = {}
      env.builds.order(component: :asc, number: :desc).each do |build|
        component_full = build.country ? "#{build.component}_#{build.country}" : build.component
        if env_data.include? component_full
          env_data[component_full][:builds].push build
        else
          last_build = {params: eval(build.parameters), causes: eval(build.causes), duration: build.duration,
                        result: build.result, timestamp: build.timestamp, url: build.url}
          env_data[component_full] = {last_build: last_build}
          env_data[component_full][:builds] = []
        end
      end
      @data[env.name] = env_data
    end
  end

  def show
    @env = Env.find(params[:id])
  end

  def new
  end

  def create
    @env = Env.new(env_params)

    @env.save
    redirect_to @env
  end

  private
    def env_params
      params.require(:env).permit(:name, :description)
    end
end
