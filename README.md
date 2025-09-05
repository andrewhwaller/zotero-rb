# Zotero Ruby Gem

[![Gem Version](https://badge.fury.io/rb/zotero-rb.svg)](https://badge.fury.io/rb/zotero-rb)
[![CI](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml/badge.svg)](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml)

A comprehensive Ruby client for the [Zotero Web API v3](https://www.zotero.org/support/dev/web_api/v3/start).

NOTE: This gem is experimental and has not been fully tested with real data. So far, the gem has been set up to cover Zotero's web API documentation as much as possible, but testing is still ongoing. Do not use this gem for production applications without exercising due caution. Having said that, if you come across something that doesn't work, open up an issue or even a PR and I'd be happy to get a fix going.

## Installation

```bash
gem install zotero-rb
```

## Usage

```ruby
require 'zotero'

# Create a client with your API key
client = Zotero.new(api_key: 'your-api-key')

# Get a library (user or group)
library = client.user_library(12345)
group_library = client.group_library(67890)

# Work with items
items = library.items
new_item = library.create_item(itemType: 'book', title: 'My Book')
library.update_item('ITEM123', { title: 'Updated Title' }, version: 150)
library.delete_item('ITEM123', version: 151)

# Work with collections
collections = library.collections
new_collection = library.create_collection(name: 'My Collection')

# Upload files
library.upload_file('ITEM123', '/path/to/file.pdf')

# Access metadata
item_types = client.item_types
book_fields = client.item_type_fields('book')
```

## Authentication

1. Create a new Zotero API key or use an existing one in your [Zotero settings](https://www.zotero.org/settings/security)
2. Ensure your key has the appropriate permissions (read library, write library, etc.)
3. Pass it to the client as shown above

## Development

```bash
bundle install
bundle exec rake spec
bundle exec rubocop
```

## Releases

This project uses [Release Please](https://github.com/googleapis/release-please) for automated releases:

1. **Use conventional commits**: `feat: add new feature`, `fix: resolve bug`, etc.
2. **Release Please creates PRs** automatically with version bumps and changelog updates
3. **Merge the release PR** when ready to publish
4. **Automatic publication** to RubyGems happens after merge

### Repository Setup (for maintainers)

To enable automated publishing, add this secret to the GitHub repository:
- `RUBYGEMS_API_KEY`: Your RubyGems API token from https://rubygems.org/profile/edit

## License

[MIT License](LICENSE.txt)
