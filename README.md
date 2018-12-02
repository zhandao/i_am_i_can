# IAmICan

[![Gem Version](https://badge.fury.io/rb/i_am_i_can.svg)](https://badge.fury.io/rb/i_am_i_can)
[![Build Status](https://travis-ci.org/zhandao/i_am_i_can.svg?branch=master)](https://travis-ci.org/zhandao/i_am_i_can)
[![Maintainability](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/maintainability)](https://codeclimate.com/github/zhandao/i_am_i_can/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/27b664da01b6cc7180e3/test_coverage)](https://codeclimate.com/github/zhandao/i_am_i_can/test_coverage)

Concise and Natural DSL for `Subject - Role(Role Group) - Permission - Resource` Management (RBAC like).

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

# more concise and faster way
he.becomes_a :magician, which_can: [:perform], obj: :magic
he.is? :magician # => true
Roles.which(name: :magician).can? :perform, :magic # => true
he.can? :perform, :magic # => true

# Cancel Assignment
he.falls_from :admin
Roles.which(name: :coder).cannot :fly

# Get allowed resources:
Resource.that_allow(user, to: :manage) # => ActiveRecord_Relation[]
```

## Table of Content

1. [Concepts and Overview](#concepts-and-overview)
    - [In one word](#in-one-word)
    - [Definition and uniqueness of nouns](#definition-and-uniqueness-of-nouns)
    - [About role group](#about-role-group)
    - [Three steps to use this gem](#three-steps-to-use-this-gem)
    - [Two Concepts of this gem](#two-concepts-of-this-gem)

2. [Installation and Setup](#installation-and-setup)

3. [Usage](#usage)
    - [Config Options](#config-options)
    - [Methods and helpers](#methods-and-helpers)
        - [A. Role Definition](#a-role-definition)
        - [B. Grouping Roles](#b-grouping-roles)
        - [C. Role Assignment](#c-role-assignment)
        - [D. Role / Group Querying](#d-role--group-querying)
        - [E. Permission Definition](#e-permission-definition)
        - [F. Permission Assignment](#f-permission-assignment)
        - [G. Permission Querying](#g-permission-querying)
        - [H. Shortcut Combinations - which_can](#h-shortcut-combinations---which_can)
        - [I. Resource Querying](#i-resource-querying)
        - [J. Useful Helpers](#j-useful-helpers)

## Concepts and Overview

### In one word:
```
- role has permissions
- subject has the roles
> subject has the permissions through the roles.
```

### Definition and uniqueness of nouns

0. Subject
    - Someone who can be assigned roles, and who has permissions through the assigned roles.
    - See wiki [RBAC](https://en.wikipedia.org/wiki/Role-based_access_control)
1. Role
    - A job function that groups a series of permissions according to a certain dimension.
    - Also see wiki [RBAC](https://en.wikipedia.org/wiki/Role-based_access_control)
    - Uniquely identified by `name`
2. Role Group
    - A group of roles that may have the same permissions.
    - Uniquely identified by `name`
3. Permission
    - An action, or an approval of a mode of access to a resource
    - Also see wiki [RBAC](https://en.wikipedia.org/wiki/Role-based_access_control)
    - Uniquely identified by `predicate( + object)` (name),
      or we can say, `action( + resource)`
4. Object (Resource)
    - Polymorphic association with permissions

### About role group?
```
- role group has permissions
- roles are in the group
- subject has one or more of the roles
> subject has the permissions through the role which is in the group
```

### Three steps to use this gem

1. Querying
    - Find if the given role is assigned to the subject
    - Find if the given permission is assigned to the subject's roles / group
    - instance methods, like: `user.can? :fly`
2. Assignment
    - assign role to subject, or assign permission to role / group
    - instance methods, like: `user.has_role :admin`
3. Definition
    - the role or permission you want to assign **MUST** be defined before
    - option :auto_definition (before assignment) you may need in some cases
    - class methods, like: `UserRoleGroup.have_permission :fly`

**Definition => Assignment => Querying**

### Two Concepts of this gem

1. Stored (save in database) TODO
2. Temporary (save in instance variable) TODO

[Feature List: needs you](https://github.com/zhandao/i_am_i_can/issues/2)

## Installation and Setup

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

3. Add the code returned by the generator to your subject model, like:

    ```ruby
    class User
      has_and_belongs_to_many :stored_roles,
                              join_table: 'users_and_user_roles', foreign_key: 'user_role_id', class_name: 'UserRole', association_foreign_key: 'user_id'
      has_many_temporary_roles
      acts_as_subject
    end
    ```

    [here](#config-options) is some options you can pass to the declaration.

4. Run `rails db:migrate`

That's all!

## Usage

### Config Options

1. auto_definition: Auto definition before assignment if it's set to `true`. defaults to `false`.

2. strict_mode: Raise error when doing wrong definition or assignment if it's
set to `true`. defaults to `false`.

3. without_group: Unable `role group` feature if it's set to `true`. defaults to `false`.

4. **relation names**: you can change the names in model declarations, defaults to `stored_roles`, `permissions`, `stored_users` and so on.

### Methods and helpers

#### A. [Role Definition](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

1. caller: Subject Model, like `User`
2. method: `have_role`. aliases:
    1. `have_roles`
    2. `has_role` & `has_roles`

Explanation:
```ruby
# === method signature ===
have_role *names, which_can: [ ], obj: nil

# === examples ===
User.have_roles :admin, :master # => 'Role Definition Done' or error message
# is the same as: `UserRole.create([{ name: :admin }, ...])`

# then:
UserRole.count # => 2
```

#### B. [Grouping Roles](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

**Tip:** Roles that you're going to group should be defined

1. caller: Subject Model, like `User`
2. method: `group_roles`. aliases:
    1. `group_role`
    2. `groups_role` & `groups_roles`
3. shortcut combination method: `have_and_group_roles` (alias `has_and_groups_roles`)  
    it will do: roles definition && roles grouping
4. helpers:
    1. relation with role (member), defaults to `members`.

Explanation:
```ruby
# === method signature ===
group_roles *members, by_name:, which_can: [ ], obj: nil

# === examples ===
# 1. normal usage
User.have_roles :vip1, :vip2, :vip3
User.group_roles :vip1, :vip2, :vip3, by_name: :vip

# 2. shortcut combination
User.have_and_group_roles :vip1, :vip2, :vip3, by_name: :vip

UserRoleGroup.count # => 1
UserRoleGroup.which(name: :vip).members.names # => %i[vip1 vip2 vip3]
```

#### C. [Role Assignment](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

1. caller: subject instance, like `User.first`
2. assignment by calling:
    1. `becomes_a`, or it's aliases:
        1. `is` / `is_a_role` / `is_roles`
        2. `has_role` / `has_roles`
        3. `role_is` / `role_are`
    2. `is_a_temporary`: just like the name, the assignment occurs only
       in instance variable (will be in the cache).
3. cancel assignment by calling:
    1. `falls_from`, or it's aliases:
        1. `removes_role`
        2. `leaves`
        3. `is_not_a` / `has_not_role` / `has_not_roles`
        4. `will_not_be`
    2. `is_not_a_temporary`
4. helpers:
    1. relation with stored role, defaults to `stored_roles`.
    2. `temporary_roles` and `valid_temporary_roles`
    3. `roles`

Explanation:
```ruby
he = User.take
# Dont't forget to define roles before assignment
User.have_roles :admin, :coder

# === Stored Assignment ===
# method signature
becomes_a *roles, which_can: [ ], obj: nil,
                  _d: config.auto_definition,
                  auto_definition: _d || which_can.present?
# examples
he.becomes_a :admin # => 'Role Assignment Done' or error message
he.stored_roles     # => [<#UserRole id: 1>]

# === Temporary Assignment ===
# signature as `becomes_a`
# examples
he.is_a_temporary :coder # => 'Role Assignment Done' or error message
he.temporary_roles       # => [<#UserRole id: 2>]

he.roles # => [:admin, :coder]

# === Cancel Assignment ===
# method signature
falls_from *roles
is_not_a_temporary *roles
# examples
he.falls_from :admin         # => 'Role Assignment Done' or error message
he.is_not_a_temporary :coder # => 'Role Assignment Done' or error message
he.roles # => []
```

#### D. [Role / Group Querying](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/subject/role_querying.rb)

1. caller: subject instance, like `User.first`
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
    
Examples:
```ruby
he = User.take

he.is?   :admin
he.isnt? :admin
he.is!   :admin

he.is_every?  :admin, :master # return false if he is not a `admin` or `master`
he.is_one_of! :admin, :master # return true if he is a `master` or `admin`

he.is_in_role_group? :vip # return true if he has at least one role of the group `vip`
```

#### E. [Permission Definition](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/permission/definition.rb)

1. caller: Role / Role Group Model, like `UserRole` / `UserRoleGroup`
2. method: `have_permission`. aliases:
    1. `have_permissions`
    2. `has_permission` & `has_permissions`

Explanation:
```ruby
# === method signature ===
have_permission *actions, obj: nil
# It is not recommended to pass an array of objects

# === examples ===
UserRole.have_permission :fly # => 'Permission Definition Done' or error message
UserPermission.count          # => 1

UserRoleGroup.have_permissions :read, :write, obj: book # => 'Permission Definition Done' or error message
UserPermission.count # => 1 + 2
```

#### F. [Permission Assignment](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/permission/assignment.rb)

1. caller: role / role group instance, like `UserRole.which(name: :admin)`
2. assignment by calling `can`. alias `has_permission`
3. cancel assignment by calling `cannot`. alias `is_not_allowed_to`
4. helpers:
    1. relation with stored permission, defaults to `permissions`.


Explanation:
```ruby
role = UserRole.which(name: :admin)
# Dont't forget to define permission before assginment
UserRole.have_permission :fly

# === Assignment ===
# method signature
can *actions, resource: nil, obj: resource,
    _d: config.auto_definition, auto_definition: _d
# examples
role.can :fly # => 'Permission Assignment Done' or error message
role.permissions # => [<#UserPermission id: ..>]
```

#### G. [Permission Querying](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/subject/role_querying.rb)

1. caller: 
    1. subject instance, like `User.find(1)`
    2. role / role group instance, like `Role.which(name: :master)`
        (only have `can?` method)
2. methods:
    1. `can?`
    2. `cannot?`
    3. `can!`
    4. `can_each?` & `can_each!`
    4. `can_one_of!` & `can_one_of!`
    5. `temporarily_can?`
    6. `stored_can?`
    7. `group_can?`
    
all the `?` methods will return `true` or `false`  
all the `!` bang methods will return `true` or raise `IAmICan::InsufficientPermission`
    
Examples:
```ruby
he = User.take

# `perform` is action, and `magic` is object (resource)
he.can?    :perform, :magic
# the same as:
he.can?    :perform, obj: :magic

he.cannot? :perform, :magic
he.can!    :perform, :magic

he.can_each?   %i[fly jump] # return false if he can not `fly` or `jump`
he.can_one_of! %i[fly jump] # return true if he can `fly` or `jump`
```

#### H. Shortcut Combinations - which_can

Faster way to assign, define roles and their permissions.  
You can use it when defining role even assigning role.

```ruby
# === use when defining role ===
# it does:
#   1. define the role to Subject Model
#   2. define & assign the permission to the role
User.have_role :coder, which_can: [:perform], obj: :magic
UserRole.which(name: :coder).can? :perform, :magic # => true

# === use when assigning role ===
# it does:
#   1. define the role to Subject Model
#   2. assign the role to subject instance
#   2. define & assign the permission to the role
user = User.take
user.becomes_a :master, which_can: [:read], obj: :book
user.is? :master # => true
user.can? :read, :book # => true
```

#### I. Resource Querying

1. caller: Resource Collection or Instance
2. scopes:
    1. `that_allow`

Explanation:
```ruby
# === method signature ===
scope :that_allow, -> (subject, to:) { }

# === examples ===
Book.that_allow(User.all, to: :read)
Book.that_allow(User.last, to: :write)
```

#### J. Useful Helpers

1. for Subject (e.g. User)

    ```ruby
    # declaration in User
    has_and_belongs_to_many :identities # stored_roles
    
    # 1. [scope] with_<stored_roles>
    #   is the same as `includes(:stored_roles)` for avoiding N+1 querying
    User.with_identities.where(identities: { name: 'teacher' })
    ```

2. for Role / RoleGroup (e.g. UserRole)

    ```ruby
    # declaration in UserRole
    has_and_belongs_to_many :related_users
    has_and_belongs_to_many :related_role_groups
    has_and_belongs_to_many :permissions
    
    # 1. [class method] which(name:, **conditions)
    #    the same as `find_by!`
    UserRole.which(name: :admin)
 
    # 2. [class method] names
    UserRole.all.names # => symbol array
 
    # 3. [class method] <related_*>
    #    returns a ActiveRecord_Relation
    #    for example, to get the users of the role `admin` and `dev`:
    UserRole.where(name: ['admin', 'dev']).related_users
    #    to get the groups of the role `admin` and `dev`:
    UserRole.where(name: ['admin', 'dev']).related_role_groups
 
    # 4. [scope] with_<permissions>
    #   is the same as `includes(:permissions)` for avoiding N+1 querying
    UserRole.with_permissions.where(permissions: { id: 1 })
    ```

3. for `Permission` (e.g. UserPermission)

    ```ruby
    # declaration in UserPermission
    has_and_belongs_to_many :related_roles
    has_and_belongs_to_many :related_role_groups
 
    # 1. [class method] which(action:, obj: nil, **conditions)
    #    the same as `find_by!`
    UserPermission.which(action: :read, obj: Book.first)
    UserPermission.which(action: :read, obj_type: 'Book', obj_id: 1)

    # 2. [class method] names
    UserPermission.all.names # => symbol array
 
    # 3. [class method] <related_*>
    #    returns a ActiveRecord_Relation as above
    UserPermission.where(..).related_roles
    UserPermission.where(..).related_role_groups
 
    # 4. [instance method] name
    UserPermission.first.name # => :read_Book_1
 
    # 5. [instance method] obj
    UserPermission.first.obj # => nil / Book / book / :book
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i_am_i_can. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IAmICan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/i_am_i_can/blob/master/CODE_OF_CONDUCT.md).
