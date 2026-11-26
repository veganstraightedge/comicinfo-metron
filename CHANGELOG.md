# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `ComicInfo::Metron`, a metadata source for [Metron](https://metron.cloud). `matches(issue)` finds the issue with the comic's number in every series whose name contains the comic's series, narrowed to its cover year when the comic has a year, ranked by series name then cover year. `issue(match)` reads the picked issue into a `ComicInfo::Issue`: series, volume, title, cover year and month, publisher, imprint, summary, genres, credits by role, characters, teams, story arcs, and its Metron page
- `ComicInfo::Metron::HTTPError` and `ComicInfo::Metron::InvalidIssueIDError`: an HTTP error status, such as 401 for a wrong token, or a match ID that isn't a Metron issue ID
