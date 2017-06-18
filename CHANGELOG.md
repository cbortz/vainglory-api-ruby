## 0.1.0
- Adds `VaingloryAPI::Region` object
- Validates `VaingloryAPI::Client` region at instantiation
- Moves Gem date to `VaingloryAPI::RELEASE_DATE`
- Adds shared RSpec example group for all lib specs
- Changes default RSpec format to "documentation"
- Updates README

## 0.0.4
- Fixes bug where where some match data was missing (see: [Issue #7](https://github.com/cbortz/vainglory-api-ruby/issues/7))
- Adds a `CHANGELOG.md` to the repository
- Adds Rubocop configurations
- Adds YARD documentation
- Removes and ignores `Gemfile.lock`
- Refreshes stored VCR cassettes
- Splits `VaingloryAPI` and `VaingloryAPI::Client` specs

## 0.0.3
- Ruby version >= 2.0 is required
- Adds Gem version badge

## 0.0.2 [yanked]
...nothing substantial happened here

## 0.0.1 [yanked]
- Integrates with TravisCI
- Integrates with CodeClimate
- Implements basic OStruct responses for API endpoints

