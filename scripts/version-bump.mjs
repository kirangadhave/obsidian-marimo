// Sets the release version in package.json and manifest.json, and records
// the manifest's minAppVersion for that release in versions.json.
import { readFileSync, writeFileSync } from "node:fs";

const version = process.argv[2] ?? "";
if (!/^\d+\.\d+\.\d+$/.test(version)) {
	console.error("usage: node scripts/version-bump.mjs <x.y.z>");
	process.exit(1);
}

const readJson = (path) => JSON.parse(readFileSync(path, "utf8"));
const writeJson = (path, data) =>
	writeFileSync(path, JSON.stringify(data, null, "\t") + "\n");

const manifest = readJson("manifest.json");
manifest.version = version;
writeJson("manifest.json", manifest);

const versions = readJson("versions.json");
versions[version] = manifest.minAppVersion;
writeJson("versions.json", versions);

const pkg = readJson("package.json");
pkg.version = version;
writeJson("package.json", pkg);

console.log(`version ${version} (minAppVersion ${manifest.minAppVersion})`);
