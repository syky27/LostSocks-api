import PackageDescription

let package = Package(
	name: "LostSocks",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1),
		.Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1),
		.Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0)

	],
	exclude: [
		"Config",
		"Deploy",
		"Public",
		"Resources",
		"Database"
	]
)

