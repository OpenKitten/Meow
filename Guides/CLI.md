# 🎮 Meow Command Line Interface

We provide a command line interface with Meow, located in the root of the package.


## Installation

To be able to use the CLI, place the following script somewhere in your [`$PATH`](https://superuser.com/questions/284342) and call it `meow`:

```bash
#!/bin/bash

DIRNAME=${PWD##*/}
pkgName="Meow"	
if [[ $DIRNAME == "$pkgName" ]]; then
	PACKAGE_DIR="."
elif [ -d "Packages/Meow" ]; then
	PACKAGE_DIR="Packages/$pkgName"
else
	PACKAGE_DIR=$(echo ".build/checkouts/$pkgName.git"*)
	
	if [ ! -d $PACKAGE_DIR ]; then
		echo "❗️  Error: Meow was not found. Install it using the Swift Package Manager, the run this command again from the root of your package."
		exit 1
	fi
fi
$PACKAGE_DIR/Meow "$@"
```

This script looks up the "real" Meow script and calls it.

Make sure to make the script file executable (`chmod +x meow`).

We'll provide an easier way to install this script in the future. Contributions are welcomed, of course!

## Meowfile

You can store your `meow` arguments in a `Meowfile` at the root of your project. For example:

`--sources Sources/MyModule --output Sources/MyModule/Meow.swift`

If you provide no arguments to `Meow`, it will load them from the `Meowfile`.