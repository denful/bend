// @ts-check
import { defineConfig, fontProviders } from 'astro/config';
import starlight from '@astrojs/starlight';

import mermaid from 'astro-mermaid';
import catppuccin from "@catppuccin/starlight";

// https://astro.build/config
export default defineConfig({
	experimental: {
		fonts: [
			{
				provider: fontProviders.google(),
				name: "Victor Mono",
				cssVariable: "--font-victor-mono",
			},
			{
				provider: fontProviders.google(),
				name: "JetBrains Mono",
				cssVariable: "--font-jetbrains-mono",
			},
		],
	},
	integrations: [
		mermaid({
			theme: 'forest',
			autoTheme: true
		}),
		starlight({
			title: 'bend',
			social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/denful/bend' }
      ],
			sidebar: [
				{
					label: 'Bend',
					items: [
						{ label: 'Overview', slug: 'overview' },
					],
				},
				{
					label: 'Understand',
					items: [
						{ label: 'The adapt Primitive', slug: 'explanation/adapt' },
						{ label: 'Parse, Don\'t Validate', slug: 'explanation/parse-dont-validate' },
						{ label: 'Bidirectional Lenses', slug: 'explanation/bidirectional-lenses' },
						{ label: 'Validation Is Parsing', slug: 'explanation/validation-is-parsing' },
					],
				},
				{
					label: 'Guides',
					items: [
						{ label: 'Lenses', slug: 'guides/lenses' },
						{ label: 'Parsing', slug: 'guides/parsing' },
						{ label: 'Optics', slug: 'guides/optics' },
					],
				},
				{
					label: 'Reference',
					items: [
						{ label: 'adapt — The Primitive', slug: 'reference/adapt' },
						{ label: 'Either', slug: 'reference/either' },
						{ label: 'Core Combinators', slug: 'reference/core' },
						{ label: 'Bifunctors', slug: 'reference/bifunctor' },
						{ label: 'Attributes & Paths', slug: 'reference/attributes' },
						{ label: 'Type Parsers & Predicates', slug: 'reference/parsers' },
						{ label: 'Records & Validation', slug: 'reference/records' },
						{ label: 'Lists', slug: 'reference/lists' },
						{ label: 'Collections', slug: 'reference/collections' },
						{ label: 'Control Flow', slug: 'reference/combinators' },
						{ label: 'Error Recovery', slug: 'reference/recovery' },
						{ label: 'Error Handling', slug: 'reference/errors' },
						{ label: 'Function Application', slug: 'reference/apply' },
						{ label: 'Debugging', slug: 'reference/debug' },
					],
				},
			],
			components: {
				Head: './src/components/Head.astro',
				Sidebar: './src/components/Sidebar.astro',
				Footer: './src/components/Footer.astro',
				SocialIcons: './src/components/SocialIcons.astro',
				PageSidebar: './src/components/PageSidebar.astro',
				Hero: './src/components/Hero.astro',
			},
			plugins: [
				catppuccin({
					dark: { flavor: "macchiato", accent: "mauve" },
					light: { flavor: "latte", accent: "mauve" },
				}),
			],
			editLink: {
				baseUrl: 'https://github.com/denful/bend/edit/main/docs/',
			},
			customCss: [
				'./src/styles/custom.css'
			],
		}),
	],
});
