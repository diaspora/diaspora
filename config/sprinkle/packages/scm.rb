package :git, :provides => :scm do
  description 'Git Distributed Version Control'
	apt %w( git-core )  
	#version '1.6.3.3'
  #source "http://kernel.org/pub/software/scm/git/git-#{version}.tar.gz"
  #requires :git_dependencies
end

package :git_dependencies do
  description 'Git Build Dependencies'
  apt 'git-core', :dependencies_only => true
end
