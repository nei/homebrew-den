class DockerRequirement < Requirement
  fatal true

  DOCKER_MIN_VERS = "20.10.16"
  COMPOSE_MIN_VERS = "2.2.3"

  satisfy(build_env: false) { self.class.has_docker? }

  def message
    "Docker with Docker Compose >= #{COMPOSE_MIN_VERS} is " \
    "required for Den. Please install Docker Desktop via brew with 'brew " \
    "install --cask docker', download it from https://docker.com/ or use " \
    "your system package manager to install Docker Engine "\
    ">= #{DOCKER_MIN_VERS}"
  end

  def self.has_docker?
    self.docker_installed? &&
      (
        self.docker_minimum_version_met? &&
        self.docker_compose_minimum_version_met?
      )
  end

  def self.docker_installed?
    return File.exists?("/Applications/Docker.app") &&
      File.exists?("/usr/local/bin/docker") if OS.mac?
    return File.exists?("/usr/bin/docker") if OS.linux?
  end

  def self.get_docker_exec
    return "/usr/local/bin/docker" if OS.mac?
    return "/usr/bin/docker" if OS.linux?
  end

  def self.docker_minimum_version_met?
    docker_exec = self.get_docker_exec
    current_vers, status =\
      Open3.capture2("#{docker_exec} version --format '{{.Server.Version}}'")
    return false if !status.success?
    return Gem::Version.new(current_vers) >= Gem::Version.new(DOCKER_MIN_VERS)
  end

  def self.docker_compose_minimum_version_met?
    docker_exec = self.get_docker_exec
    current_vers, status = Open3.capture2("#{docker_exec} compose version --short")
    return false if !status.success?
    return Gem::Version.new(current_vers) >= Gem::Version.new(COMPOSE_MIN_VERS)
  end
end

class Den < Formula
  desc "Den is a CLI utility for working with docker-compose environments"
  homepage "https://swiftotter.github.io/den"
  license "MIT"
  version "1.0.0-beta.10"
  url "https://github.com/swiftotter/den/archive/1.0.0-beta.10.tar.gz"
  sha256 "49d69675c92f6a6108aab0864e3bf593bec2aacedded953d7dfb0878813a121d"
  head "https://github.com/swiftotter/den.git", :branch => "main"

  depends_on DockerRequirement

  def install
    prefix.install Dir["*"]
  end

  def post_install
    # This is required so docker is found if it's not installed via brew
    ENV["PATH"] += ":/usr/local/bin" if OS.mac? || OS.linux?

    # Specify necessary environment variables
    ENV["WARDEN_DIR"] = prefix
    ENV["WARDEN_HOME_DIR"] = Dir.home
    ENV["WARDEN_SERVICE_DIR"] = prefix

    # Future proof environment variable names
    ENV["DEN_HOME_DIR"] = prefix
    ENV["DEN_SERVICE_DIR"] = prefix

    Pathname(prefix/"docker").cd do
      den_version = File.read(prefix/"version").strip()
      system "docker",
            "compose",
            "-p", "den",
            "build",
            "--no-cache",
            "--build-arg", "DEN_VERSION=#{den_version}",
            "dashboard"
      system "docker",
            "compose",
            "--project-directory", prefix,
            "-p", "den",
            "-f", prefix/"docker/docker-compose.yml",
            "up", "-d", "dashboard"
    end
  end

  def caveats
    <<~EOS
      Den manages a set of global services on the docker host machine. You
      will need to have Docker running and Docker Compose (>= 2.2.3) available in 
      your local $PATH configuration prior to starting Den.

      To start warden simply run:
        den svc up
      
      This command will automatically run "den install" to setup a trusted
      local root certificate and sign an SSL certificate for use by services
      managed by warden via the "warden sign-certificate warden.test" command.
      To print a complete list of available commands simply run "den" without
      any arguments.
    EOS
  end
end
