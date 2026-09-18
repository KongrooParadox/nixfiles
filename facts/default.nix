{ lib }:
let
  sites = import ./sites.nix;
  siteList = builtins.attrNames sites;
  managedHosts = import ./machines.nix;
  managedHostsPerSite = builtins.listToAttrs (
    map (site: {
      name = site;
      value = lib.filterAttrs (h: cfg: cfg.site == site) managedHosts;
    }) siteList
  );
  unmanagedHostsPerSite = builtins.mapAttrs (site: siteCfg: siteCfg.unmanagedHosts or { }) sites;
  hosts = lib.recursiveUpdate unmanagedHostsPerSite managedHostsPerSite;
  dnsEntriesListPerSite = builtins.listToAttrs (
    map (site: {
      name = site;
      value = helpers.dnsEntriesOf site;
    }) siteList
  );
  duplicateEntries = builtins.listToAttrs (
    map (site: {
      name = site;
      value = helpers.duplicateEntriesOf site;
    }) siteList
  );
  backingMachines = builtins.mapAttrs (n: v: builtins.listToAttrs v) dnsEntriesListPerSite;
  sambaIps = builtins.listToAttrs (
    map (site: {
      name = site;
      value = helpers.ipv4AddressOf site (helpers.hostOf site "samba");
    }) siteList
  );
  helpers = {
    aliasesOf = site: name: hosts.${site}.${name}.aliases or [ ];
    dnsEntriesOf =
      site:
      lib.concatLists (
        lib.mapAttrsToList (
          host: cfg:
          map (name: {
            inherit name;
            value = host;
          }) ([ host ] ++ helpers.aliasesOf site host)
        ) hosts.${site}
      );
    domainOf = site: "${site}.kongroo.ovh";
    duplicateEntriesOf =
      site:
      builtins.attrNames (
        lib.filterAttrs (_: entryCfg: ((builtins.length entryCfg) > 1)) (
          builtins.groupBy (e: e.name) dnsEntriesListPerSite.${site}
        )
      );
    fqdnOf = name: "${name}.${helpers.domainOf name}";
    hostOf =
      site: alias: backingMachines.${site}.${alias} or (throw "host or alias ${alias} is not defined");
    ipv4AddressOf =
      site: name: hosts.${site}.${name}.ipv4 or (throw "host ${name} has no IPv4 address defined");
    nameserversNamesOf = site: (helpers.siteCfgOf site).dns.resolvers;
    nameserversIpv4AddressOf =
      site: map (server: helpers.ipv4AddressOf site server) (helpers.nameserversNamesOf site);
    recordsOf =
      site:
      let
        hostsWithAliases = lib.filterAttrs (h: hostCfg: builtins.hasAttr "aliases" hostCfg) hosts.${site};
        hostsWithIpv4 = lib.filterAttrs (h: hostCfg: builtins.hasAttr "ipv4" hostCfg) hosts.${site};
      in
      lib.mapAttrsToList (host: hostCfg: "${host} IN A ${hostCfg.ipv4}") hostsWithIpv4
      ++ builtins.concatLists (
        lib.mapAttrsToList (
          host: hostCfg: map (a: "${a} IN CNAME ${host}") hostCfg.aliases
        ) hostsWithAliases
      );
    siteCfgOf = site: sites.${site} or (throw "site ${site} is not defined");
    siteOf =
      host:
      let
        topLevelKeys = builtins.attrNames managedHostsPerSite;
        matchingKeys = builtins.filter (
          key: builtins.isAttrs managedHostsPerSite.${key} && builtins.hasAttr host managedHostsPerSite.${key}
        ) topLevelKeys;
      in
      if matchingKeys == [ ] then
        (throw "host ${host} is not defined in facts/machines.nix")
      else if (builtins.length matchingKeys) > 1 then
        (throw "host ${host} is defined in multiple sites")
      else
        builtins.head matchingKeys;
    zoneOf = site: ''
      $ORIGIN ${helpers.domainOf site}.
      $TTL 300
      ${builtins.concatStringsSep "\n" (helpers.recordsOf site)}
    '';
  };
  platforms = lib.partition (n: managedHosts.${n}.isLinux) (builtins.attrNames managedHosts);
in
{
  facts = {
    inherit
      duplicateEntries
      hosts
      managedHosts
      sambaIps
      sites
      ;
    darwinHosts = platforms.wrong;
    nixosHosts = platforms.right;
  };
  helpers = helpers;
}
