{ pkgs, config, specialArgs, lib, ...}:
let pkgs-unstable = specialArgs.nixpkgs-unstable;
in 
{

	programs.home-manager.enable = true;
	home.packages = [
		pkgs.hello
		# (pkgs.writeScriptBin "nixFlakes" ''
		# 	exec ${pkgs.nixVersions.git}/bin/nix --experimental-features "nix-command flakes" "$@"
		# '')
		pkgs.cachix
		pkgs.kubectl
		pkgs.bat
		pkgs.eza
		pkgs.fd
		pkgs.ripgrep
		pkgs.just

		# lsps
		pkgs.nil
		pkgs.nodePackages.pyright

		pkgs.thefuck
		pkgs.fzf
		pkgs.sops
		pkgs.age
	] ++ pkgs.lib.optionals specialArgs.withGUI [
		pkgs.discord
		pkgs.obsidian
		pkgs.audacity
		pkgs.nextcloud-client
		pkgs.libreoffice-qt6-fresh
	];

	home.homeDirectory = "/home/deepak";
	home.username = "deepak";

	# required, was previously default
	home.stateVersion = "18.09";

	programs.direnv.enable = true;
	programs.direnv.nix-direnv.enable = true;

	xdg.enable = true;

	services.nextcloud-client = pkgs.lib.mkIf specialArgs.withGUI {
		enable = true;
	};

	programs.git = {
		enable = true;
		userName	= "Deepak Mallubhotla";
		userEmail = "dmallubhotla+github@gmail.com";
		signing = {
			key = specialArgs.gitSigningKey;
			signByDefault = true;
		};
		extraConfig = {
			core = {
				fileMode = false;
			};
		};
		includes = [
			# this allows us to have a local gitconfig maybe?
			{ path = "~/.gitconfig.local"; }
		];
	};


	programs.neovim = {
		enable = true;
		package = pkgs-unstable.neovim-unwrapped;
		defaultEditor = true;
		vimAlias = true;

		plugins = with pkgs.vimPlugins; [
			{
				plugin = vimtex;
				config = "let g:nix_recommended_style = 0";
			}
			vim-nix
			# plenary and stuff for telescope
			plenary-nvim telescope-nvim telescope-file-browser-nvim
			# need fzf for parrot
			fzf-lua
			ctrlp-vim
			# lsp stuff
			lsp-zero-nvim
			nvim-cmp
			cmp-nvim-lsp
			cmp_luasnip
			nvim-lspconfig

			vim-vinegar

			wiki-vim
			vim-markdown
			cmp-buffer
			# vim-airline
			vim-fugitive
			flash-nvim
			gitsigns-nvim
			friendly-snippets
			luasnip
			which-key-nvim

			overseer-nvim

			# prettiness
			lualine-nvim
			goyo-vim
			limelight-vim
			nui-nvim
			zen-mode-nvim
			twilight-nvim

			# color schemes
			rose-pine
			kanagawa-nvim

			# custom plugins from flakes
			pkgs.customVimPlugins.cmp-vimtex
			pkgs.customVimPlugins.spaceport-nvim
			pkgs.customVimPlugins.nomodoro
			pkgs.customVimPlugins.parrot-nvim

			# syntax highlighting
			vim-just
		];
		extraConfig = import ./neovim/init-vim.nix { inherit config; };
	};

	programs.thefuck.enable = true;

	programs.zsh = {
		enable = true;
		shellAliases = {
			doo="./do.sh";
			wttr="curl wttr.in";
			gcd="_t=$(git rev-parse --show-toplevel) && cd \"$_t\" && pwd";
		};
		history = {
			size = 10000;
			path = "${lib.removePrefix "/home/deepak/" config.xdg.dataHome}/zsh/history";
		};
		oh-my-zsh = {
				enable = true;
				plugins = [
					"poetry"
					"themes"
					"emoji-clock"
					"screen"
					"ssh-agent"
				];
				theme = "random";
		};
		plugins = [
			{
				name = "sd";
				src = pkgs.fetchFromGitHub {
					owner = "ianthehenry";
					repo = "sd";
					rev = "ecd1ab8d3fc3a829d8abfb8bf1e3722c9c99407b";
					sha256 = "0fm1r8w73vaab5r9dj5jdxsfc7pbddxf4dvvasfq8rry2dxaf7sy";
				};
			}
			{
				name = "zsh-z";
				src = pkgs.fetchFromGitHub {
					owner = "agkozak";
					repo = "zsh-z";
					rev = "b5e61d03a42a84e9690de12915a006b6745c2a5f";
					sha256 = "1gsgmsvl1sl9m3yfapx6bp0y15py8610kywh56bgsjf9wxkrc3nl";
				};
			}
		];
		initExtra = ''
			eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
		'';
	};
	
	sops = {
		age.keyFile = "/home/deepak/.config/sops/age/keys.txt"; # must have no password!
		# It's also possible to use a ssh key, but only when it has no password:
		#age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
		defaultSopsFile = ./secrets.yaml;
		defaultSymlinkPath = "/run/${specialArgs.rundirnum}/secrets";
		defaultSecretsMountPoint = "/run/${specialArgs.rundirnum}/secrets.d";
		
		secrets = {
			anthropic_api_key = {
				path = "${config.sops.defaultSymlinkPath}/anthropic_api_key";
			};
			hello = {};
			newkey = {
				path = "/home/deepak/newkeytest.txt";
			};
		};
	};

}
