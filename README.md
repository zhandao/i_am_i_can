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

# more concise and faster way
he.becomes_a :magician, which_can: [:perform], obj: :magic
he.is? :magician # => true
Roles.which(name: :magician).can? :perform, :magic # => true
he.can? :perform, :magic # => true

# Cancel Assignment
he.falls_from :admin
Roles.which(name: :coder).cannot :fly

# Get allowed resources:
Resource.that_allow(user).to(:manage) # => Active::Relation
```

## Concepts and Overview

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
4. Resource
    - Polymorphic association with permissions


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
2. Local (variable value) TODO

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

3. Add the code returned by the generator to your subject model, like:

    ```ruby
    class User
      has_and_belongs_to_many :stored_roles,
                              join_table: 'users_and_user_roles', foreign_key: 'user_role_id', class_name: 'UserRole', association_foreign_key: 'user_id'
   
      acts_as_subject
    end
    ```

    [here](#config-options) is some options you can pass to the declaration.

4. Run `rails db:migrate`

That's all!

## Usage

### Customization

1. association names TODO

### Config Options

TODO

### Methods and their Aliases

#### A. [Role Definition](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

1. Caller: Subject Model, like `User`
2. methods:
    1. save to database: `have_role`. aliases:
        1. `have_roles`
        2. `has_role` & `has_roles`
    2. save to local variable: `declare_role`. alias `declare_roles`
3. helpers:
    1. `defined_temporary_roles`
    2. `defined_roles`
    
Methods Explanation:
```ruby
# === Save to DB ===
# method signature
have_role *names, desc: nil, save: saved_by_default#, which_can: [ ], obj: nil
# examples
User.have_roles :admin, :master # => 'Role Definition Done' or error message
UserRole.count # => 2

# === Save in Local ===
# signature as `have_role`
# examples
User.declare_role :coder # => 'Role Definition Done' or error message
User.defined_temporary_roles.keys.count # => 1

User.defined_roles.count # => 3
```

#### B. [Grouping Roles](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

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

#### C. [Role Assignment](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/role/definition.rb)

1. Caller: subject instance, like `User.find(1)`
2. assign methods:
    1. save to database: `becomes_a`. aliases:
        1. `is` & `is_a_role` & `is_roles`
        2. `has_role` & `has_roles`
        3. `role_is` & `role_are`
    2. save to local variable: `is_a_temporary`.
3. cancel assign method: `falls_from`. aliases:
    1. `removes_role`
    2. `leaves`
    3. `is_not_a` & `has_not_role` & `has_not_roles`
    4. `will_not_be`
4. helpers:
    1. `temporary_roles` & `temporary_role_names`
    2. `stored_roles` & `stored_role_names`
    3. `roles`

Methods Explanation:
```ruby
he = User.take
# === Save to DB ===
# method signature
becomes_a *roles, auto_definition: auto_definition, save:  saved_by_default#, which_can: [ ], obj: nil
# examples
he.becomes_a :admin # => 'Role Definition Done' or error message
he.stored_roles   # => [<#UserRole id: 1>]

# === Save in Local ===
# signature as `becomes_a`
# examples
he.is_a_temporary :coder # => 'Role Assignment Done' or error message
he.temporary_roles # => [{ coder: { .. } }]

he.roles # => [:admin, :coder]

# === Cancel ===
# method signature
falls_from *roles, saved: saved_by_default
# examples
he.falls_from :admin # => 'Role Assignment Done' or error message
he.removes_roles :coder, saved: false # => 'Role Assignment Done' or error message
he.roles # => []
```

#### D. [Role / Group Querying](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/subject/role_querying.rb)

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
    
Methods Examples:
```ruby
he = User.take

he.is?   :admin
he.isnt? :admin
he.is!   :admin

he.is_every?  :admin, :master # return false if he is not a admin or master
he.is_one_of! :admin, :master # return true if he is a master or admin

he.is_in_role_group? :vip # return true if he has a role which is in the group :vip
```

#### E. [Permission Definition](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/permission/definition.rb)

1. Caller: Role / Role Group Model, like `UserRole` / `UserRoleGroup`
2. methods:
    1. save to database: `have_permission`. aliases:
        1. `have_permissions`
        2. `has_permission` & `has_permissions`
    2. save to local variable: `declare_permission`. alias `declare_permissions`
3. helpers:
    1. `defined_local_permissions`
    2. `defined_stored_permissions`
    3. `defined_permissions`
4. class method: `which(name:)`
5. Permission
    1. class method: `which(pred:, obj:)`
    2. instance methods: `#pred`, `#obj`, `#name`
    
Methods Explanation:
```ruby
# === Save to DB ===
# method signature
have_permission *preds, obj: nil, desc: nil, save: saved_by_default
# examples
UserRole.have_permission :fly # => 'Permission Definition Done' or error message
UserRole.defined_stored_permissions.keys.count # => 1
UserRoleGroup.have_permissions *%i[read write], obj: Book.find(1) # => 'Permission Definition Done' or error message
UserRoleGroup.defined_stored_permissions.keys.count # => 1

# === Save in Local ===
# signature as `have_permission`
# examples
UserRole.declare_permission :perform, obj: :magic # => 'Permission Definition Done' or error message
UserRole.defined_local_permissions.keys.count # => 1

UserRole.defined_permissions.keys.count # => 2

# === class methods ===
UserRole.which(name: :admin)
# as same as
UserRole.find_by_name!(:admin)

# === Permission ===
p = UserPermission.which(pred: :read, obj: Book.find(1))
p.pred == 'read'
p.obj == Book.find(1)
p.name == :read_Book_1
```

#### F. [Permission Assignment](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/permission/assignment.rb)

**What is Wrong Assignment - Covered?**
> Before: he can manage User  
> When you do: he can manage User.find(1)  
> will get an Error, tell you that User is cover User.find(1), no need to assign

Overview:  
1. Caller: role / role group instance, like `UserRole.which(name: :admin)`
2. methods:
    1. save to database: `can`. aliases: `has_permission`
    2. save to local variable: `temporarily_can`. alias `locally_can`
3. cancel assign method: `cannot`. alias `is_not_allowed_to`
3. helpers:
    1. `local_permissions`
    2. `stored_permissions`
    3. `permissions`
    
Methods Explanation:
```ruby
role = UserRole.which(name: :admin)

# === Save to DB ===
# method signature
can *preds, obj: nil, strict_mode: false, auto_definition: auto_definition
# examples
role.can :fly # => 'Permission Assignment Done' or error message
role.stored_permissions # => [<#UserPermission id: ..>]

# === Save in Local
# signature as `can`
# examples
role.temporarily_can :perform, obj: :magic # => 'Permission Assignment Done' or error message
role.local_permissions # => [:perform_magic]

role.permissions.keys.count # => 3
```

#### G. [Permission Querying](https://github.com/zhandao/i_am_i_can/blob/master/lib/i_am_i_can/subject/role_querying.rb)

1. Caller: 
    1. subject instance, like `User.find(1)`
    2. role / role group instance, like `Role.which(name: :master)`  
        notice that this caller have only `can?` and `temporarily_can?` methods.
2. methods:
    1. `can?`
    2. `cannot?`
    3. `can!`
    4. `can_each?` & `can_each!`
    4. `can_one_of!` & `can_one_of!`
    5. `temporarily_can?` / `locally_can?`
    6. `stored_can?`
    7. `group_can?`
3. helpers:
    1. `permissions_of_stored_roles`
    2. `permissions_of_temporary_roles`
    3. `permissions_of_role_groups`
    
all the `?` methods will return `true` or `false`  
all the `!` bang methods will return `true` or raise `IAmICan::InsufficientPermission`
    
Methods Examples:
```ruby
he = User.take

he.can?    :perform, :magic
he.cannot? :perform, :magic
he.can!    :perform, :magic

he.can_each?   :fly, :jump # return false if he can not fly or jump
he.can_one_of! :fly, :jump # return true if he can fly or jump
```

#### H. Shortcut Combinations - which_can

Faster way to assign, define roles and thier permissions.  
You can use it when defining role even assigning role.

```ruby
# === use when defining role ===
# it does:
#   1. define the role to Subject Model
#   2. define & assign the permission to the role
User.have_role :coder, which_can: [:perform], obj: :magic
UserRole.which(name: :coder).can? :perform, :magic # => true
# save in local
User.temporary_role_which(name: :local_role).can :perform, obj: :magic
UserRole.new(name: :local_role).temporarily_can? :perform, :magic # => true

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

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/i_am_i_can. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IAmICan project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/i_am_i_can/blob/master/CODE_OF_CONDUCT.md).
