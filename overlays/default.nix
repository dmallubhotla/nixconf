{ cmp-vimtex, spaceport-nvim, nomodoro, parrot-nvim, inputs }:
let 
	pluginoverlay= final: prev:
	let
		cmpVimtexPlugin = prev.vimUtils.buildVimPlugin {
			src = cmp-vimtex;
			name = "cmp-vimtex";
		};
		spaceportNvimPlugin = prev.vimUtils.buildVimPlugin {
			src = spaceport-nvim;
			name = "spaceport-nvim";
		};
		nomodoroNvimPlugin = prev.vimUtils.buildVimPlugin {
			src = nomodoro;
			name = "nomodoro";
		};

		parrotNvimPlugin = prev.vimUtils.buildVimPlugin {
			src = parrot-nvim;
			name = "parrot-nvim";
		};

		zshCompletionPlugin = {
			name = "zsh-completions";
			src = inputs.zsh-completions;
		};
	in
	{
		customVimPlugins = { 
			cmp-vimtex = cmpVimtexPlugin;
			spaceport-nvim = spaceportNvimPlugin;
			nomodoro = nomodoroNvimPlugin;
			parrot-nvim = parrotNvimPlugin;
		};

		customZshPlugins = {
			zsh-completions = zshCompletionPlugin;
		};

	};
in {
	overlay = inputs.nixpkgs.lib.composeManyExtensions[
		pluginoverlay
		inputs.claude-mcp-bundle.overlays.default
	];
}
