// Rewrites the ISLANDS_VERSION constant in src/main.ts. With no argument,
// pins to the latest @marimo-team/islands release on npm.
import { readFileSync, writeFileSync } from "node:fs";

async function fetchLatest() {
	const res = await fetch(
		"https://registry.npmjs.org/@marimo-team/islands/latest",
	);
	if (!res.ok) {
		throw new Error(`npm registry responded ${res.status}`);
	}
	const data = await res.json();
	return data.version;
}

const version = process.argv[2] ?? (await fetchLatest());
if (!/^\d+\.\d+\.\d+$/.test(version)) {
	console.error(`invalid islands version: ${version}`);
	process.exit(1);
}

const path = "src/main.ts";
const source = readFileSync(path, "utf8");
const pattern = /const ISLANDS_VERSION = "[^"]+"/;
if (!pattern.test(source)) {
	console.error(`ISLANDS_VERSION constant not found in ${path}`);
	process.exit(1);
}
writeFileSync(
	path,
	source.replace(pattern, `const ISLANDS_VERSION = "${version}"`),
);
console.log(`pinned @marimo-team/islands to ${version}`);
