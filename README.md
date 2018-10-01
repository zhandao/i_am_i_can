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

# more concise way, it does:
#   1. define & assign the role to subject
#   2. define & assign the permission to role
he.becomes_a :magician, which_can: [:perform], obj: :magic
he.is? :magician # => true
Roles.which(name: :magician).can? :perform, :magic # => true
he.can? :perform, :magic # => true

# Cancel Assignment
he.falls_from :admin
Roles.which(name: :coder).cannot :fly
```

## Concepts and Overview

### Definition and uniqueness of nouns

1. Role
    - definition: TODO
    - uniqueness: by `name`
1. Role Group
    - definition: TODO
    - uniqueness: by `name`
1. Permission
    - definition: TODO
    - uniqueness: by `predicate + object`


### In one word:
```
- role has permissions
- subject has the roles
> subject has the permissions through the roles.
```

### About role group?
```
- role group has permissions
- roles are in the group
- subject has one or more of the roles
> subject has the permissions through the role which is in the group
```

### Three steps of this gem

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
    
### Two Concepts of this gem

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

TODO

### Methods and their Aliases

#### [Role Definition](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

Overview:  
1. Caller: Subject Model, like `User`
2. methods:
    1. save to database: `have_role`. aliases:
        1. `have_roles`
        2. `has_role` & `has_roles`
    2. save to local variable: `declare_role`. aliases:
        1. `declare_roles`
3. helpers:
    1. `defined_local_roles`
    2. `defined_stored_roles` & `defined_stored_role_names`
    3. `defined_roles`
    
Methods Explanation:
```ruby
# === Save to DB ===
# method signature
have_role *names, desc: nil, save: default_save#, which_can: [ ], obj: nil
# examples
User.have_roles :admin, :master # => 'Role Definition Done' or error message
User.defined_stored_roles.keys.count # => 2

# === Save in Local
# signature as `have_role`
# examples
User.declare_role :coder # => 'Role Definition Done' or error message
User.defined_local_roles.keys.count # => 1

User.defined_roles.keys.count # => 3
```

#### [Grouping Roles](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

**Tips:**  
1. Role Group must be saved in database currently
2. Roles that you're going to group should be defined

Overview:  
1. Caller: Subject Model, like `User`
2. method: `group_roles`. aliases:
    1. `group_role`
    2. `groups_role` & `groups_roles`
3. shortcut combination method: `have_and_group_roles` (alias `has_and_groups_roles`)  
    it will do: roles definition => roles grouping
4. helpers:
    1. `defined_role_groups` & `defined_role_group_names`
    2. `members_of_role_group`
    
Methods Explanation:
```ruby
# method signature
group_roles *members, by_name:, #which_can: [ ], obj: nil
# examples
User.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip
User.defined_role_group_names # => [:vip]
User.members_of_role_group(:vip) # => %i[vip1 vip2 vip3]
```

#### [Role Assignment](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

Overview:  
1. Caller: subject instance, like `User.find(1)`
2. assign methods:
    1. save to database: `becomes_a`. aliases:
        1. `is` & `is_a_role` & `is_roles`
        2. `has_role` & `has_roles`
        3. `role_is` & `role_are`
    2. save to local variable: `temporarily_is`. aliases:
        1. `locally_is`
3. cancel assign method: `falls_from`. aliases:
    1. `removes_role`
    2. `leaves`
    3. `is_not_a` & `has_not_role` & `has_not_roles`
    4. `will_not_be`
4. helpers:
    1. `local_roles` & `local_role_names`
    2. `stored_roles` & `stored_role_names`
    3. `roles`
    
Methods Explanation:
```ruby
he = User.take
# === Save to DB ===
# method signature
becomes_a *roles, auto_define_before: auto_define_before, save:  default_save#, which_can: [ ], obj: nil
# examples
he.becomes_a :admin # => 'Role Definition Done' or error message
he.stored_roles   # => [<#UserRole id: 1>]

# === Save in Local
# signature as `becomes_a`
# examples
he.temporarily_is :coder # => 'Role Assignment Done' or error message
he.local_roles.keys.count # => 1

he.roles # => [:admin, :coder]

# === Cancel ===
# method signature
falls_from *roles, saved: default_save
# examples
he.falls_from :admin # => 'Role Assignment Done' or error message
he.removes_roles :coder, saved: false # => 'Role Assignment Done' or error message
he.roles # => []
```

#### [Role / Group Querying](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/subject/role_querying.rb)

Overview:  
1. Caller: subject instance, like `User.find(1)`
2. role querying methods:
    1. `is?` / `is_role?` / `has_role?`
    2. `isnt?`
    3. `is!` / `is_role!` / `has_role!`
    4. `is_one_of?` / `is_one_of_roles?`
    4. `is_one_of!` / `is_one_of_roles!`
    5. `is_every?` / `is_every_role_in?`
    6. `is_every!` / `is_every_role_in!`
3. group querying methods:
    1. `is_in_role_group?` / `in_role_group?`
    2. `is_in_one_of?` / `in_one_of?`
    
all the `?` methods will return `true` or `false`  
all the `!` bang methods will return `true` or raise `IAmICan::VerificationFailed`
    
Methods Explanation:
```ruby
he = User.take

he.is?   :admin
he.isnt? :admin
he.is!   :admin

he.is_every?  :admin, :master # return false if he is not a admin or master
he.is_one_of! :admin, :master # return true if he is a master or admin

he.is_in_role_group? :vip # return true if he has a role which is in the group :vip
```

#### Permission Definition

#### Permission Assignment

#### Shortcut Combinations - which_can

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
