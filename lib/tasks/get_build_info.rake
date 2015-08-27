require 'unirest'

task :get_build_info => [:environment] do
  IGNORED = %w(all.apigw.qa.local
             all.apisearch.qa.local
             all.bob.qa.local
             all.delivery.qa.local
             all.madmin.qa.local
             all.qa.local)
  BASE_URL = 'http://jenkins.qa.local/view/STAND/api/json/'

  ignored_pattern = "(#{IGNORED.join('|')})"

  def get(url)
    url += 'api/json'
    Unirest.timeout(30)
    Unirest.get(url, auth:{:user=>'autotest', :password=>'qwerty'}).body
  end

  puts "Build import from Jenkins started at #{Time.now}."
  import_result = {}
  response = get BASE_URL
  job_urls = response['jobs'].select { |j| j['url'] !~ /#{ignored_pattern}/ }.map { |j| j['url'] }

  job_urls.each do |job_url|
    build_urls = get(job_url)['builds'].map { |b| b['url'] }
    build_count = 0
    component_name, country = nil, nil

    build_urls.each do |build_url|
      build_data = get(build_url)

      url = build_data['url']

      non_country_components = %w(content curr expconfig site express.master)
      job_name = url.match(/job\/(.*)?\/\d+/)[-1]
      is_non_country_specific = non_country_components.select { |j| job_name.include? j }.any?

      country = if is_non_country_specific
                  nil
                else
                  tmp_job_name = job_name.match(/(.*)?\.qa\.local/)[-1]
                  %w(kz ua by).select { |c| tmp_job_name.end_with?(c) }.first || 'ru'
                end
      env_data = build_data['builtOn'].split('.')
      env_name = env_data.first
      component_name = env_data[1]

      number = build_data['number']

      find_by = {component: component_name, number: number}
      find_by[:country] = country if country
      if Build.find_by(find_by)
        # stop getting data when we've hit an existing build
        break
      end

      result = build_data['result']

      unless result.nil?
        actions = build_data['actions']
        parameters = actions.select { |a| a.include?('parameters') }[0]['parameters']

        tmp_params = {}
        parameters.each do |p|
          if p['name'].include?('branch') || p['name'].include?('version')
            tmp_params['branch'] = p['value']
          elsif p['name'].downcase.include?('node')
            # ignore and do nothing
          else
            tmp_params[p['name']] = p['value']
          end
        end
        causes = actions.select { |a| a.include?('causes') }
        duration = build_data['duration']
        timestamp = Time.at((build_data['timestamp'] / 1000).floor)

        env = Env.find_or_create_by(name: env_name)

        Build.find_or_create_by(parameters: tmp_params.to_s, causes: causes.to_s, duration: duration, result: result,
            timestamp: timestamp, url: url, env_id: env.id, number: number, country: country, component: component_name)

        build_count += 1
      else
        puts "Skipping in-progress build for #{component_name}#{" #{country}" if country}."
      end

    end
    import_result["#{component_name}#{" #{country}" if country}"] = build_count
  end
  if import_result.select{ |k, v| v > 0 }.any?
    puts "Added #{import_result.select{ |k, v| v > 0 }.map{ |k, v| "#{v} build#{'s' if v > 1} for #{k}"}.join(', ')}."
  else
    puts 'No new builds in Jenkins since last check.'
  end
end
