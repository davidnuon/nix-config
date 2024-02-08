# NixOS Workstation Config

## Quickstart

1. Clone the repo
2. Do the following

```bash
$ nix  --experimental-features 'nix-command flakes' develop
$ make nixos.switch host=<hostname>
```

where `<hostname>` is a host found in the `./hosts` diretory.

## Inventory

| Hostname      | Model                              | Type    |
|---------------|------------------------------------|---------|
| dn-silverbook | [Framework 13" with AMD 7840U Board](https://en.wikipedia.org/wiki/Framework_Laptop) | Laptop  |
| dn-grill      | [Framework i7-1260P Board](https://en.wikipedia.org/wiki/Framework_Laptop) | Server  |
| dn-jetbook    | [Lenovo ThinkPad X1 Carbon 5th Gen](https://en.wikipedia.org/wiki/ThinkPad_X1_Carbon) | Laptop  |
| dn-ravenbook  | [Lenovo ThinkPad T480](https://en.wikipedia.org/wiki/ThinkPad_T_Series) | Laptop  |
| dn-thickbook  | [Lenovo ThinkPad T440](https://en.wikipedia.org/wiki/ThinkPad_T_Series) | Laptop  |

# History

I used to use Ansible to provision Ubuntu machines in this [repo](https://github.com/davidnuon/ubuntu-setup/).
However, I switched over to NixOS since Ansible made it too difficult to make consistent systems.
I became frustrated with Ansible's imperative nature and having runs fail because a file was touched in a bad place.

Not what you want when you're setting up a new machine!

I switched over to Nix on macOS because of nix-shells and then eventually made it to NixOS after getting more comfortable
with the language and package manager.
