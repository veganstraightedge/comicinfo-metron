require_relative 'lib/comicinfo/metron/version'

Gem::Specification.new do |spec|
  spec.name    = 'comicinfo-metron'
  spec.version = ComicInfo::Metron::VERSION
  spec.authors = ['Shane Becker']
  spec.email   = ['veganstraightedge@gmail.com']

  spec.summary     = 'Looks up comic details in Metron, for the comicinfo gem'
  spec.description = <<~DESCRIPTION
    A metadata source for the comicinfo gem: searches Metron for an issue,
    and returns what Metron knows about the one picked as a ComicInfo::Issue
  DESCRIPTION

  spec.homepage = 'https://github.com/veganstraightedge/comicinfo-metron'
  spec.license  = 'MIT'

  spec.required_ruby_version = '>= 4.0.9'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/veganstraightedge/comicinfo-metron'
  spec.metadata['changelog_uri']     = 'https://github.com/veganstraightedge/comicinfo-metron/blob/main/CHANGELOG.md'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename __FILE__

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |file|
      ignored_files = %w[
        bin/
        Gemfile
        .gitignore
        .rspec
        script/
        spec/
        .github/
        .rubocop.yml
        .rubocop_todo.yml
      ]

      (file == gemspec) || file.start_with?(*ignored_files)
    end
  end

  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.bindir        = 'exe'

  # Runtime dependencies
  spec.add_dependency 'comicinfo', '>= 2.3'
  spec.add_dependency 'nokogiri', '>= 1.19.7'
end
