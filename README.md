# IAmICan [PostgreSQL only currently]

[![Build Status](https://travis-ci.org/zhandao/i_am_i_can.svg?branch=master)](https://travis-ci.org/zhandao/i_am_i_can)
[![Maintainability](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/maintainability)](https://codeclimate.com/github/zhandao/i_am_i_can/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/test_coverage)](https://codeclimate.com/github/zhandao/i_am_i_can/test_coverage)

Concise and Natural DSL for `Subject - Role(Role Group) - Permission` Management.

```ruby
# our Subject is People, and subject is he:
he = People.take
# let: Roles means PeopleRole, Groups means PeopleRoleGroup

# Role
People.have_role :admin # role definition
he.becomes_a :admin     # role assignment
he.is? :admin           # role querying => true
he.is? :someone_else    # role querying => false

# Role Group
#   role definition and grouping
People.have_and_group_roles :dev, :master, :committer, by_name: :team
he.becomes_a :master    # role assignment
he.in_role_group? :team # role group querying => true

# Role - Permission
People.have_role :coder            # role definition
Roles.have_permission :fly         # permission definition
Roles.which(name: :coder).can :fly # permission assignment (by predicate)
he.becomes_a :coder                # role assignment
he.can? :fly                       # permission querying

# Role Group - Permission
Groups.have_permission :manage, obj: User        # permission definition
Groups.which(name: :team).can :manage, obj: User # permission assignment (by predicate and object)
he.is? :master                                   # yes
he.can? :manage, User                            # permission querying

# more concise way: 
#   1. define & assign the role to subject
#   2. define & assign the permission to role
he.becomes_a :magician, which_can: [:perform], obj: :magic
he.is? :magician # => true
Roles.which(name: :magician).can? :perform, :magic # => true
he.can? :perform, :magic # => true

# Cancel Assignment
# TODO
```

## Concepts and Overview

In one word:
```
- role has permissions
- subject has the roles
> subject has the permissions through the roles.
```

About role group?
```
- role group has permissions
- roles are in the group
- subject has one or more of the roles
> subject has the permissions through the role which is in the group
```

Three steps of this gem:
3. Querying
    - Find if the given role is assigned to the subject
    - Find if the given permission is assigned to the subject's roles / group
    - instance methods, like: `user.can? :fly`
2. Assignment
    - assign role to subject, or assign permission to role / group
    - instance methods, like: `user.has_role :admin`
1. Definition
    - the role or permission you want to assign MUST be defined before
    - option :auto_define_before (before assignment) what you need in some cases
    - class methods, like: `UserRoleGroup.have_permission :fly`
    
Two Concepts of this gem:
1. Stored (save in database)
2. Local (variable value)

[Feature List: needs you](https://github.com/zhandao/i_am_i_can/issues/2)

## Installation And Setup

1. Add this line to your application's Gemfile and then `bundle`:

    ```ruby
    gem 'i_am_i_can'
    ```
    
2. Generate migrations and models by your subject name:
    
    ```bash
    rails g i_am_i_can:setup <subject_name>
    ```
    
    For example, if your subject name is `user`, it will generate
    model `UserRole`, `UserRoleGroup` and `UserPermission`
    
3. run `rails db:migrate`

4. enable it in your subject model, like:

    ```ruby
    class User
      act_as_i_am_i_can
    end
    ```
    
    [here](#options) is some options you can pass to the declaration.
    
That's all!

## Usage

### Options

### Methods and their Aliases

#### Role Definition

#### Grouping Roles

#### Role Assignment

#### Permission Definition

#### Permission Assignment

#### Role / Group Querying

#### Permission Querying

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i_am_i_can. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IAmICan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/i_am_i_can/blob/master/CODE_OF_CONDUCT.md).
