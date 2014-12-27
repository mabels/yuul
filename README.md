yuul
====

YubiKey NEO Zuul(Door Keeper)

build a door opener with my yubikey and lookup the key id in a ldap directory.

---

Java strange thing's as expected

* openjdk-7 on raspberry works
* oracle-java-8 on raspberry nada

* oracle-java-8 on macos 10.10 works
* oracle-java-7 on macos 10.10 nada

---

the configuration file should named yuul.yam and contain this

```yaml
ClientId: [you need a key from https://upgrade.yubico.com/getapikey/]
ldapUrl: ldap://192.168.178.37/
ldapSecurity: simple
ldapBindUser:
ldapBindPassword:
ldapBaseDn: dc=nodomain
ldapSearch: (&(objectclass=person)(loginShell={key}))
```
