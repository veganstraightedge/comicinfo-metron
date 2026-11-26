# comicinfo-metron

Looks up comic details in [Metron](https://metron.cloud), for the [comicinfo](https://github.com/veganstraightedge/comicinfo) gem.

`ComicInfo::Metron` is a metadata source: it searches Metron for an issue, and returns what Metron knows about the one picked as a `ComicInfo::Issue`. See [Looking Up Details in Online Databases](https://github.com/veganstraightedge/comicinfo/blob/main/doc/metadata-sources.md).

It's the Ruby counterpart of [ComicInfoMetron.swift](https://github.com/veganstraightedge/ComicInfoMetron.swift), and a sibling of [comicinfo-comic_vine](https://github.com/veganstraightedge/comicinfo-comic_vine).

## Installation

```ruby
gem 'comicinfo-metron'
```

## Usage

```ruby
require 'comicinfo/metron'

metron = ComicInfo::Metron.new token: 'your API token', user_agent: 'MyApp/1.0'

issue   = ComicInfo.load 'path/to/ComicInfo.xml'
matches = metron.matches issue    # best first
found   = metron.issue matches[0] # after a person picks one
updated = issue.with_blanks_filled_from found
```

- `matches` needs a Series and a Number; `missing_details` says so when either is blank. A Year is optional: when there is one, only issues with a cover dated that year are found.
- It finds the issue with that number in every series whose name contains the issue's series, and ranks the matches by series name, then cover year.
- A match has no `site_url`: Metron's issue pages are addressed by a slug its search results don't include.
- `issue` reads the issue: series, volume, title (or else its first story's title), cover year and month, publisher, imprint, summary, genres, credits by role, characters, teams, story arcs, and the issue's Metron page as its web link.
- A request Metron refuses raises `ComicInfo::Metron::HTTPError` (with its `status`, such as 401 for a wrong token), and a match whose ID isn't a Metron issue ID raises `ComicInfo::Metron::InvalidIssueIDError` (with its `id`). Both are `ComicInfo::Metron::Error`s.

## Credit

Comic details from [Metron](https://metron.cloud). Whatever shows Metron's data must credit and link to Metron (`metron.name`, `metron.home_url`).

## Development

```sh
bin/setup         # bundle install
bundle exec rake  # specs and RuboCop
```

The specs answer every request from a local server with a Metron response from `spec/fixtures/`, so they need no token or network. The fixtures follow the schemas of [Mokkari](https://github.com/Metron-Project/mokkari), Metron's Python client; they weren't recorded from the live API.

## License

[MIT](LICENSE.md)
