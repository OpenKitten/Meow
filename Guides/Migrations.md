# Migrations

Whenever you make a breaking change to your models and you want to keep using your existing data, you will need to provide a migration. Breaking changes are:

- Adding a required property (including those with default values!)
- Renaming a property
- Changing the data type of a property (except for changing between Int, Int32 and Double)

Migrations are performed on a lower level than other operations in Meow, because Meow does not know the difference between the before and after data model. Migrations look like this:

```swift
Meow.migrate("My migration description", on: MyModel.self) { migrate in
	// rename a property
	migrate.rename("foo", to: "bar")
	
	// convert a property into a new format
	migrate.map("myStringFormattedDate") { myStringFormattedDate in
		return myDateConversionFunction(myStringFormattedDate)
	}
	
	// advanced: custom document adaption
	migrate.map { document in
		// change the document
		return otherDocument
	}
}
```

From the given closure, Meow will create a migration plan. The plan is optimized into a minimum amount of database operations and then executed.

## `Migrator`

The migration closure will be called with a `Migrator` as argument. Check the `Migrator` documentation for more information about the available operations.