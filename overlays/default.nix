{ cmp-vimtex, spaceport-nvim, nomodoro }:
{
	overlay = final: prev:
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
	in
	{
		customVimPlugins = { 
			cmp-vimtex = cmpVimtexPlugin;
			spaceport-nvim = spaceportNvimPlugin;
			nomodoro = nomodoroNvimPlugin;
		};
	};
}
