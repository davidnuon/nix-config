{
 pkgs, ...
}:
with pkgs;
{
     home.packages = [ 
	discord 
        vscode
      ];
     home.stateVersion = "22.11";
}
