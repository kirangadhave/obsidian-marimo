import { Notice, Plugin } from "obsidian";

export default class MarimoPlugin extends Plugin {
	async onload() {
		this.addRibbonIcon("leaf", "Marimo: say hello", () => {
			new Notice("Hello from marimo 🌿");
		});

		this.addCommand({
			id: "say-hello",
			name: "Say hello",
			callback: () => new Notice("Hello from marimo 🌿"),
		});

		// Placeholder for the real goal: render marimo notebooks inline.
		this.registerMarkdownCodeBlockProcessor("marimo", (source, el) => {
			const box = el.createDiv({ cls: "marimo-placeholder" });
			box.createEl("strong", { text: "marimo notebook" });
			box.createEl("div", {
				text: source.trim() || "(no notebook path given)",
			});
		});
	}
}
