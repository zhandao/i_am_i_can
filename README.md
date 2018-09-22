# IAmICan

[![Build Status](https://travis-ci.org/zhandao/i_am_i_can.svg?branch=master)](https://travis-ci.org/zhandao/i_am_i_can)
[![Maintainability](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/maintainability)](https://codeclimate.com/github/zhandao/i_am_i_can/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/test_coverage)](https://codeclimate.com/github/zhandao/i_am_i_can/test_coverage)

Concise and Natural DSL for `ActiveModel - Role(Role Group) - Permission` Management.

```ruby
# let:
he = People.take

# Role
People.have_role :admin # role definition
he.becomes_a :admin     # role assignment
he.is? :admin           # role querying

# Role Group
#   role definition and grouping
People.have_and_group_roles :dev, :master, :committer, by_name: :team
he.becomes_a :master    # role assignment
he.in_role_group? :team # role group querying

# Role - Permission
People.have_role :coder           # role definition
Role.which(name: :coder).can :fly # permission assignment (by predicate)
he.becomes_a :coder               # role assignment
he.can? :fly                      # permission querying

# Role Group - Permission
RoleGroup.which(name: :team).can :manage, obj: User # permission assignment (by predicate and object)
he.is? :master                                      # yes
he.can? :manage, User                               # permission querying
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'i_am_i_can'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install i_am_i_can

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i_am_i_can. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IAmICan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/i_am_i_can/blob/master/CODE_OF_CONDUCT.md).
