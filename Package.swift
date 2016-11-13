import PackageDescription

let package = Package(
	name: "LostSocks",
	dependencies: [
    .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
    .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1, minor: 0),

	],
	exclude: [
		"Config",
		"Deploy",
		"Public",
		"Resources",
		"Database"
	]
)

