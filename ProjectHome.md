= HasManyWithArgs

An association that returns records based on arguments.


Usage:

> class User
> > has\_many\_with\_args :messages\_from :user,
> > > :class\_name => 'Message',
> > > :conditions => { :user\_id => '#{user.id}' }

> end

Supports association extensions:

> class User
> > has\_many\_with\_args :messages\_from :user,
> > > :class\_name => 'Message',
> > > :conditions => { :user\_id => '#{user.id}' } do


> def recent(how\_many)
> > find :all, :order => 'created\_at DESC', :limit => how\_many

> end
> end
> end

Users can now access their messages\_from association with an argument.

> account\_owner = User.find(1)
> viewer = User.find(2)

> account\_owner.messages\_from(viewer)