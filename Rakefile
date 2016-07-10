require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :deploy_aws

tags = ['tcp', 'udp']

def check_variables(*args)
  variable_empty = false
  args.each do |env_name|
    if ENV[env_name].nil?
      puts "env #{env_name} is not set - this is a problem."
      variable_empty = true
    end
  end
  raise "At least one required envionment variable is not set. Exiting." if variable_empty
end

namespace 'docker' do
  desc 'Build the base container'
  task :build_base do
    # Generate an environment file for use in the docker container that will
    # point to the appropriate AWS S3 resource to download from.  This file will
    # be part of the image, but at least won't be stored within this repo.  To
    # be fair, this information may not be overly sensitive if exposed (you do
    # have your S3 buckets/directories that are housing your credentials locked
    # down, don't you?), but better safe than sorry.
    check_variables('AWS_REGION', 'S3_BUCKET', 'S3_DIR')
    env_file = open('openvpn/AWS_ENV', 'w')
    env_file.truncate(0)
    ['AWS_REGION', 'S3_BUCKET', 'S3_DIR'].each do |env_name|
      env_file.write("#{env_name}=#{ENV[env_name]}\n")
    end
    sh 'docker build -t aws/openvpn:base -f docker/base/Dockerfile --pull .'
    env_file.close
  end

  desc 'Build the awssdk container'
  task :build_awssdk do
    sh 'docker build -t awssdkgo:alpine -f docker/awssdk/Dockerfile --pull .'
  end

  desc 'Build the actual containers'
  task :build_latest => 'docker:build_base' do
    tags.each do |the_tag|
      sh "docker build -t aws/openvpn:#{the_tag} -f docker/#{the_tag}/Dockerfile ."
    end
  end

  desc 'Clean stale docker containers and images'
  task :clean do
    sh 'docker ps -a | awk \'/Exited/ {print $1}\' | xargs -r docker rm'
    sh 'docker images -q -f dangling=true | xargs -r docker rmi'
  end

  desc 'Tags the containers to prepare for aws'
  task :tag_aws do
    # One piece of information when uploading to ECS repository is the AWS_ID.
    # While this information may not be overly sensitive, would rather not
    # store this information in this repo.
    check_variables('AWS_ID', 'AWS_REGION')
    tags.each do |the_tag|
      sh "docker tag aws/openvpn:#{the_tag} #{ENV['AWS_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/aws/openvpn:#{the_tag}"
    end
  end

  desc 'Pushes the containers to aws'
  task :push_aws do
    check_variables('AWS_ID', 'AWS_REGION')
    tags.each do |the_tag|
      sh "docker push #{ENV['AWS_ID']}.dkr.ecr.#{ENV['AWS_REGION']}.amazonaws.com/aws/openvpn:#{the_tag}"
    end
  end
end

desc 'Build the gets3files command'
file 'gets3files/gets3files' => 'gets3files/gets3files.go' do
  sh 'docker run --rm -v "$PWD/gets3files":/usr/src/myapp -w /usr/src/myapp awssdkgo:alpine go build gets3files.go'
end

file 'openvpn/gets3files' => 'gets3files/gets3files' do |task|
  cp task.prerequisites.first, task.name
end

task :touch_gets3files_go do
  sh 'touch gets3files/gets3files.go'
end

desc 'Force a build of the gets3files command and copy to openvpn'
task :force_build_gets3files => ['docker:build_awssdk', 'touch_gets3files_go', 'openvpn/gets3files']

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  task :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    RSpec::Core::RakeTask.new(target.to_sym) do |t|
      ENV['TARGET_HOST'] = original_target
      t.pattern = "spec/#{original_target}/*_spec.rb"
    end
  end
end

desc 'Does all needed steps to deploy to aws'
task :deploy_aws => ['docker:build_latest', 'spec:opevpn', 'docker:tag_aws', 'docker:push_aws']
