# Zotero Ruby Gem

[![Gem Version](https://badge.fury.io/rb/zotero-rb.svg)](https://badge.fury.io/rb/zotero-rb)
[![CI](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml/badge.svg)](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml)

A comprehensive Ruby client for the [Zotero Web API v3](https://www.zotero.org/support/dev/web_api/v3/start).

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

## License

[MIT License](LICENSE.txt)
