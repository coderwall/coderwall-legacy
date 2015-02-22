openssl Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the openssl cookbook.

v4.0.0 (2014-02-19)
-------------------
- Reverting to Opscode module namespace

v3.0.2 (2014-12-30)
-------------------
- Accidently released 2.0.2 as 3.0.2

v2.0.2 (2014-12-30)
-------------------
- Call cert.to_pem before recipe DSL

v2.0.0 (2014-06-11)
-------------------

- #1 - **[COOK-847](https://tickets.chef.io/browse/COOK-847)** - Add LWRP for generating self signed certs
- #4 - **[COOK-4715](https://tickets.chef.io/browse/COOK-4715)** - add upgrade recipe and complete test harness

v1.1.0
------
### Improvement
- **[COOK-3222](https://tickets.chef.io/browse/COOK-3222)** - Allow setting length for `secure_password`

v1.0.2
------
- Add name attribute to metadata
