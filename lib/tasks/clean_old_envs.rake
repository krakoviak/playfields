require 'unirest'

task :clean_old_envs => [:environment] do

  BASE_URL = 'http://jenkins.qa.local/computer/'

  def get(url)
    json_suffix = 'api/json'
    Unirest.get(url + json_suffix, auth:{:user=>'autotest', :password=>'qwerty'}).body
  end

  puts 'Will check for ENVs that no longer are in Jenkins and remove them from DB.'

  envs_db = {}
  Env.find_each {|row| envs_db[row.id] = row.name }

  nodes = get(BASE_URL)['computer'].map { |c| c['displayName'].split('.').first }.uniq

  envs_db.each do |id, env|
    unless nodes.include?(env)
      puts "Node in DB but not among Jenkins nodes: id=#{id}, name=#{env}, will remove from DB."
      Build.destroy_all(env_id: id)
      Env.destroy(id)
    end
  end

end
