#Easymon

This gem extracts and modularizes the logic we had in our monitoring controllers
and were copying back and forth between applications.
## Installation

Not sure yet. This might work:

Add to Gemfile:
```
gem 'easymon'
```

Execute:
```
bundle
```

Or maybe just:
```
gem install easymon
```

##Usage
Ok, you'll need to add an initializer for this to do anything. In 
`config/initializers/easymon.rb`:

```
Easymon::Repository.add("Application Database", Easymon::ActiveRecordCheck.new(ActiveRecord::Base.connection))
```

This will register a check called "application-database", and run it when you
visit "`/up/application-database`" or as a part of your overall checklist at 
"`/up`".

