# frozen_string_literal: true

# Create a .test.env and a .development.env for your different local
# environments
require 'colored'
require 'readline'
require 'fileutils'

require 'movie_organizer/version'

module MovieOrganizer
  def self.root
    Pathname.new(File.dirname(__FILE__)).parent
  end

  def self.current_environment
    ENV.fetch('APP_ENV', 'development')
  end

  def self.config_file(filename = '.movie_organizer.yml')
    return root.join('spec', 'fixtures', filename) if current_environment == 'test'
    #:nocov:
    home = ENV.fetch('HOME')
    file = ENV.fetch('MO_CONFIG_FILE', File.join(home, '.movie_organizer.yml'))
    FileUtils.touch(file)
    file
    #:nocov:
  end

  def self.options
    MovieOrganizer::Options.instance
  end

  def self.verbose_puts(string)
    Logger.instance.info(" #{string}") if options[:verbose]
  end

  def self.os
    if RUBY_PLATFORM.match?(/cygwin|mswin|mingw|bccwin|wince|emx/)
      :retarded
    else
      :normal
    end
  end

  def self.source_directories(settings = Settings.instance, test_response = nil)
    settings[:new_media_directories] || begin
      strings = prompt_for('Media source directories (separated by a colon)', test_response)
      settings[:new_media_directories] = strings.split(':')
      settings.save
      settings[:new_media_directories]
    end
  end

  def self.tmdb_key(settings = Settings.instance, test_response = nil)
    return settings[:movies][:tmdb_key] if settings[:movies] && settings[:movies][:tmdb_key]
    settings[:movies] ||= {}
    settings[:movies][:tmdb_key] =
      prompt_for('TMDB API key (https://www.themoviedb.org/)', test_response)
    settings.save
    settings[:movies][:tmdb_key]
  end

  def self.movie_directory(settings = Settings.instance, test_response = nil)
    return settings[:movies][:directory] if settings[:movies] && settings[:movies][:directory]
    settings[:movies] ||= {}
    settings[:movies][:directory] =
      prompt_for('Movie destination directory', test_response)
    settings.save
    settings[:movies][:directory]
  end

  def self.tv_shows_directory(settings = Settings.instance, test_response = nil)
    return settings[:tv_shows][:directory] if settings[:tv_shows] && settings[:tv_shows][:directory]
    settings[:tv_shows] ||= {}
    settings[:tv_shows][:directory] =
      prompt_for('TV show destination directory', test_response)
    settings.save
    settings[:tv_shows][:directory]
  end

  def self.video_directory(settings = Settings.instance, test_response = nil)
    return settings[:videos][:directory] if settings[:videos] && settings[:videos][:directory]
    settings[:videos] ||= {}
    settings[:videos][:directory] =
      prompt_for('Video destination directory', test_response)
    settings.save
    settings[:videos][:directory]
  end

  #:nocov:
  def self.prompt_for(message = '', test_response = nil)
    prompt = "#{message.dup}\n? "
    return test_response if test_response
    Readline.readline(prompt, true).squeeze(' ').strip
  end
  #:nocov:

  autoload :FileCopier,   'movie_organizer/file_copier'
  autoload :Logger,       'movie_organizer/logger'
  autoload :Medium,       'movie_organizer/medium'
  autoload :MediaList,    'movie_organizer/media_list'
  autoload :Movie,        'movie_organizer/movie'
  autoload :Options,      'movie_organizer/options'
  autoload :Organizer,    'movie_organizer/organizer'
  autoload :Settings,     'movie_organizer/settings'
  autoload :TmdbInstance, 'movie_organizer/tmdb_instance'
  autoload :TvdbInstance, 'movie_organizer/tvdb_instance'
  autoload :TvShow,       'movie_organizer/tv_show'
  autoload :Video,        'movie_organizer/video'
end
