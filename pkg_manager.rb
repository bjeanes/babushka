require 'shell_helpers'

class PkgManager
  def self.for_system
    case `uname -s`.chomp
    when 'Darwin'; MacportsHelper
    when 'Linux'; AptHelper
    end.new
  end
end

class MacportsHelper < PkgManager
  def has? pkg_name
    returning pkg_name.in? existing_packages do |result|
      log "system #{result ? 'has' : 'doesn\'t have'} #{pkg_name} port"
    end
  end
  def install! *pkgs
    shell "port install #{pkgs.join(' ')}"
  end
  def existing_packages
    Dir.glob("/opt/local/var/macports/software/*").map {|i| File.basename i }
  end
  def cmd_dir cmd_name
    File.dirname shell("which #{cmd_name}")
  end
  def prefix
    cmd_dir('port').sub(/\/bin\/?$/, '')
  end
  def bin_path
    prefix / 'bin'
  end
  def cmd_in_path? cmd_name
    returning cmd_dir(cmd_name).starts_with?(prefix) do |result|
      log "#{result ? 'the correct' : 'an incorrect installation of'} #{cmd_name} is in use, at #{cmd_dir(cmd_name)}."
    end
  end
end
class AptHelper < PkgManager
  def self.has? pkg_name
    returning shell "dpkg -s #{pkg_name}" do |result|
      log "system #{result ? 'has' : 'doesn\'t have'} #{pkg_name} package"
    end
  end
  def self.install! *pkgs
    shell "apt-get install #{pkgs.join(' ')}"
  end
end
class GemHelper < PkgManager
  def self.has? pkg_name
    returning shell "gem list -i #{pkg_name}" do |result|
      log "system #{result ? 'has' : 'doesn\'t have'} #{pkg_name} gem"
    end
  end
  def self.install! *pkgs
    sudo "gem install #{pkgs.join(' ')}"
  end
end

def pkg_manager
  PkgManager.for_system
end

shell 'ls'
